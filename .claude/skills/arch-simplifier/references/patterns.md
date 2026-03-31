# Canonical Patterns — Spring Boot + Kafka + Flink

These are the patterns to standardize across the codebase. Once agreed, every new feature follows the same shape. Developers can focus on domain, not structure.

---

## Pattern: Kafka Consumer

**Canonical shape**: Consumer is thin. It deserializes, validates headers/keys, maps to domain event, and delegates to an application use case. No business logic.

```kotlin
@Component
class BetPlacedConsumer(private val placeBetUseCase: PlaceBetUseCase) {

    @KafkaListener(topics = ["\${kafka.topics.bet-placed}"])
    fun consume(record: ConsumerRecord<String, ByteArray>) {
        val proto = BetPlacedProto.parseFrom(record.value())
        val command = BetPlacedCommand.from(proto)        // mapping layer
        placeBetUseCase.execute(command)
    }
}
```

**Anti-patterns to eliminate**:

- Business logic inside `@KafkaListener` method
- Direct repository access from consumer
- try/catch inside consumer (use `@KafkaListenerErrorHandler` or SeekToCurrentErrorHandler)
- Proto parsing inside the use case

---

## Pattern: Protobuf → Domain Mapping

**Canonical shape**: A companion object `from()` or a dedicated `*Mapper` class. Never inline.

```kotlin
// Option A: companion object (for simple cases)
data class BetPlacedCommand(
    val betId: BetId,
    val selection: BetSelection,
    val stake: Money
) {
    companion object {
        fun from(proto: BetPlacedProto) = BetPlacedCommand(
            betId = BetId(proto.betId),
            selection = BetSelection(MarketId(proto.marketId), OutcomeId(proto.outcomeId)),
            stake = Money(proto.stake.toBigDecimal(), Currency.of(proto.currency))
        )
    }
}

// Option B: mapper class (when proto ↔ domain is complex or bidirectional)
@Component
class BetMapper {
    fun toDomain(proto: BetPlacedProto): BetPlacedCommand { ... }
    fun toProto(command: BetPlacedCommand): BetPlacedProto { ... }
}
```

---

## Pattern: Application Use Case

**Canonical shape**: One class per use case. Takes a command/query, orchestrates domain + infrastructure ports. Returns a result or throws a domain exception.

```kotlin
@UseCase  // custom annotation = @Service + documentation intent
class PlaceBetUseCase(
    private val betRepository: BetRepository,       // port (interface)
    private val marketPort: MarketPort,             // port (interface)
    private val eventPublisher: DomainEventPublisher
) {
    fun execute(command: PlaceBetCommand): BetId {
        val market = marketPort.findActive(command.selection.marketId)
            ?: throw MarketNotFoundException(command.selection.marketId)

        val bet = Bet.place(command, market)         // domain logic IN the domain
        betRepository.save(bet)
        eventPublisher.publish(BetPlacedEvent(bet))
        return bet.id
    }
}
```

---

## Pattern: Domain Service vs Application Use Case

|                        | Domain Service                       | Application Use Case                     |
| ---------------------- | ------------------------------------ | ---------------------------------------- |
| **Lives in**           | `domain/service/`                    | `application/usecase/`                   |
| **Knows about**        | Other domain objects                 | Ports (repositories, publishers)         |
| **Spring annotations** | None                                 | `@UseCase`                               |
| **Example**            | `OddsCalculator`, `SettlementEngine` | `PlaceBetUseCase`, `SettleMarketUseCase` |

---

## Pattern: Repository Port

**Canonical shape**: Domain defines the interface. Infrastructure implements it. Domain never imports Spring Data.

```kotlin
// In domain/port/
interface BetRepository {
    fun findById(id: BetId): Bet?
    fun save(bet: Bet)
    fun findOpenByMarket(marketId: MarketId): List<Bet>
}

// In infrastructure/persistence/
@Repository
class ElasticsearchBetRepository(
    private val esClient: ElasticsearchClient
) : BetRepository {
    override fun findById(id: BetId): Bet? { ... }
    override fun save(bet: Bet) { ... }
    override fun findOpenByMarket(marketId: MarketId): List<Bet> { ... }
}
```

---

## Pattern: Flink Operator Structure

**Canonical shape**: Operator = wiring. Domain logic extracted to pure functions/classes.

```kotlin
class MarketSettlementOperator(
    private val settlementEngine: MarketSettlementEngine,  // pure domain
    private val stateDescriptor: ValueStateDescriptor<MarketState>
) : KeyedProcessFunction<MarketId, SettlementEvent, SettledBet>() {

    private lateinit var state: ValueState<MarketState>

    override fun open(parameters: Configuration) {
        state = runtimeContext.getState(stateDescriptor)
    }

    override fun processElement(event: SettlementEvent, ctx: Context, out: Collector<SettledBet>) {
        val current = state.value() ?: MarketState.empty()
        val (updated, outputs) = settlementEngine.process(current, event)
        state.update(updated)
        outputs.forEach(out::collect)
    }
}

// Pure, testable, no Flink dependency
class MarketSettlementEngine {
    fun process(state: MarketState, event: SettlementEvent): Pair<MarketState, List<SettledBet>> {
        // all the domain logic here, easily unit-tested
    }
}
```

---

## Pattern: Error Handling

**Canonical shape**: One place per boundary (consumer, controller, operator).

```kotlin
// For Kafka: one error handler, registered centrally
@Component
class KafkaErrorHandler : KafkaListenerErrorHandler {
    override fun handleError(message: Message<*>, exception: ListenerExecutionFailedException): Any {
        log.error("Failed to process {}: {}", message.headers[KafkaHeaders.RECEIVED_TOPIC], exception.cause?.message)
        // DLQ logic here
        return Unit
    }
}

// For controllers: one @ControllerAdvice
@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(DomainException::class)
    fun handleDomain(ex: DomainException): ResponseEntity<ErrorResponse> { ... }
}
```

**Anti-pattern**: try/catch blocks repeated in every consumer/controller.

---

## Pattern: Domain Events

```kotlin
// Domain event = immutable fact that something happened
data class BetPlacedEvent(
    val betId: BetId,
    val selection: BetSelection,
    val stake: Money,
    val occurredAt: Instant = Instant.now()
) : DomainEvent

// Publisher port (domain defines the interface)
interface DomainEventPublisher {
    fun publish(event: DomainEvent)
}

// Kafka implementation (infrastructure)
@Component
class KafkaDomainEventPublisher(private val kafkaTemplate: KafkaTemplate<String, ByteArray>) : DomainEventPublisher {
    override fun publish(event: DomainEvent) {
        val record = event.toProducerRecord()   // mapping via extension or mapper
        kafkaTemplate.send(record)
    }
}
```
