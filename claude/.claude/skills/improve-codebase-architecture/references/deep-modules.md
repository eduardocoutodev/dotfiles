# Deep Modules Reference

From _A Philosophy of Software Design_ by John Ousterhout, adapted for JVM backend systems.

## The Core Idea

A **deep module** has:

- A **simple interface** — small API surface, few parameters, predictable behavior
- A **deep implementation** — handles lots of complexity internally so callers don't have to

A **shallow module** has:

- A complex interface (many params, many methods, unclear ordering)
- A trivial implementation (just delegates to something else)

Shallow modules are a net negative: they add cognitive load without hiding complexity.

---

## Diagnosing Depth

### Signs of a shallow module

```kotlin
// Shallow: caller must know internals, does nothing itself
class BetValidationService(
    private val betRepository: BetRepository,
    private val marketRepository: MarketRepository,
    private val outcomeRepository: OutcomeRepository
) {
    fun validate(betId: Long, marketId: Long, outcomeId: Long): Boolean {
        val bet = betRepository.findById(betId)
        val market = marketRepository.findById(marketId)
        val outcome = outcomeRepository.findById(outcomeId)
        return bet != null && market != null && outcome != null
    }
}
```

```kotlin
// Deep: caller just asks "is this valid?" and gets an answer
class BetValidator(private val betContext: BetContext) {
    fun validate(request: PlaceBetRequest): ValidationResult {
        // all the complexity of what "valid" means is inside here
    }
}
```

### Signs of a deep module

- Callers don't import things the module uses internally
- The method name describes _what_, not _how_
- Adding a new rule inside doesn't change the interface
- Tests for callers don't need to set up the module's dependencies

---

## Making Modules Deeper

### 1. Pull validation inward

Instead of: caller validates before calling → push validation into the module

```kotlin
// Before
if (bet.status == BetStatus.OPEN && market.isActive && outcome.exists) {
    settlementService.settle(bet, outcome)
}

// After
settlementService.settle(bet, outcome)  // throws if preconditions not met, internally
```

### 2. Use value objects to shrink parameter lists

```kotlin
// Before (shallow: caller assembles the pieces)
fun placeBet(userId: Long, marketId: Long, outcomeId: Long, stake: BigDecimal, currency: String)

// After (deep: caller provides intention, not components)
fun placeBet(request: PlaceBetRequest)

data class PlaceBetRequest(
    val userId: UserId,
    val selection: BetSelection,  // wraps marketId + outcomeId
    val stake: Money               // wraps amount + currency
)
```

### 3. Encode invariants in types, not checks

```kotlin
// Before: any code can create an invalid Stake
data class Bet(val stake: BigDecimal)  // could be negative, zero, null

// After: impossible to create invalid Stake
@JvmInline value class Stake private constructor(val amount: BigDecimal) {
    companion object {
        fun of(amount: BigDecimal): Stake {
            require(amount > BigDecimal.ZERO) { "Stake must be positive" }
            return Stake(amount)
        }
    }
}
```

### 4. Exception handling as depth

```kotlin
// Shallow: every caller must handle checked exceptions
try {
    kafkaProducer.send(record)
} catch (e: TimeoutException) { ... }
  catch (e: InterruptedException) { ... }

// Deep: event publisher hides Kafka details
interface DomainEventPublisher {
    fun publish(event: DomainEvent)  // handles retries, serialization, exceptions internally
}
```

---

## Module Depth in Flink Operators

Flink operators become shallow when they:

- Mix windowing logic with business logic
- Have `processElement` methods > 50 lines
- Directly serialize/deserialize domain objects

```kotlin
// Shallow Flink operator
class BetSettlementOperator : KeyedProcessFunction<...>() {
    override fun processElement(value: ProtoMessage, ctx: Context, out: Collector<...>) {
        // deserialize proto
        // validate fields
        // apply settlement logic
        // update state
        // emit result
        // handle late data
        // 80 lines of mixed concerns
    }
}

// Deep: operator orchestrates, delegates domain logic
class BetSettlementOperator(
    private val settlementDomain: BetSettlementDomain,
    private val stateManager: SettlementStateManager
) : KeyedProcessFunction<...>() {
    override fun processElement(value: ProtoMessage, ctx: Context, out: Collector<...>) {
        val event = SettlementEvent.from(value)         // delegated
        val result = settlementDomain.apply(event)      // delegated
        stateManager.update(result, ctx)                // delegated
        result.outputs().forEach(out::collect)          // clean
    }
}
```
