# Java/Kotlin Code Smells & Fixes

Specific smells common in Java/Kotlin Spring Boot backends, with targeted fixes.

---

## Smell: Anemic Domain Model

**Symptom**: Domain classes are data bags. All logic is in `*Service` classes.

```kotlin
// Anemic
data class Bet(val id: Long, val status: String, val stake: BigDecimal)

class BetService {
    fun settle(betId: Long, winningOutcomeId: Long) {
        val bet = repo.findById(betId)
        if (bet.status != "OPEN") throw IllegalStateException()
        // settlement logic lives here, not in Bet
        bet.status = "SETTLED"
        repo.save(bet)
    }
}
```

**Fix**: Move behavior into the entity.

```kotlin
class Bet private constructor(...) {
    var status: BetStatus = BetStatus.OPEN
        private set

    fun settle(winningOutcome: Outcome): SettlementResult {
        check(status == BetStatus.OPEN) { "Cannot settle non-open bet" }
        status = BetStatus.SETTLED
        return SettlementResult.compute(this, winningOutcome)
    }
}
```

---

## Smell: Service Explosion

**Symptom**: `UserBetService`, `UserBetHelperService`, `UserBetUtilService`, `UserBetProcessingService` — all doing adjacent things with no clear boundary.

**Fix**: Merge into one deep `BetDomainService` with a clear, stable interface. Or split by use case, not by layer.

---

## Smell: Long Parameter Lists

**Symptom**: `fun createBet(userId: Long, marketId: Long, outcomeId: Long, stake: BigDecimal, currency: String, ipAddress: String, deviceId: String)`

**Fix**: Introduce a command/request value object.

```kotlin
data class PlaceBetCommand(
    val userId: UserId,
    val selection: BetSelection,
    val stake: Money,
    val clientContext: ClientContext
)
```

---

## Smell: Boolean Flag Parameters

**Symptom**: `fun processEvent(event: Event, isDryRun: Boolean, isRetry: Boolean)`

**Fix**: Two methods, or a sealed class for mode.

```kotlin
fun processEvent(event: Event)
fun dryRunEvent(event: Event): ProcessingPreview

// Or:
sealed class ProcessingMode {
    object Live : ProcessingMode()
    object DryRun : ProcessingMode()
    data class Retry(val attempt: Int) : ProcessingMode()
}
```

---

## Smell: String-typed Domain Concepts

**Symptom**: `status: String`, `currency: String`, `betType: String` — compared with `==` everywhere.

**Fix**: Enums for closed sets, inline value classes for IDs, sealed classes for variants.

```kotlin
enum class BetStatus { OPEN, SETTLED, VOID, CANCELLED }

@JvmInline value class BetId(val value: Long)
@JvmInline value class MarketId(val value: String)

sealed class SettlementOutcome {
    data class Won(val payout: Money) : SettlementOutcome()
    data class Lost(val stake: Money) : SettlementOutcome()
    object Void : SettlementOutcome()
}
```

---

## Smell: Chained Null Checks

**Symptom**:

```kotlin
if (bet != null && bet.market != null && bet.market.outcome != null) {
    process(bet.market.outcome)
}
```

**Fix**: Use Kotlin's safe operators or domain methods that encapsulate navigation.

```kotlin
bet?.market?.outcome?.let(::process)

// Or better: the domain knows how to get the outcome
bet?.resolvedOutcome()?.let(::process)
```

---

## Smell: Repository Used Directly in Controller/Consumer

**Symptom**: `@KafkaListener` method calls `betRepository.findById(...)` directly.

**Fix**: Add a use case layer. Controller/consumer → use case → repository.

---

## Smell: Config Values Scattered

**Symptom**: `@Value("\${kafka.topics.bet-placed}")` duplicated in 8 classes.

**Fix**: One typed config class per concern.

```kotlin
@ConfigurationProperties(prefix = "kafka.topics")
data class KafkaTopicsConfig(
    val betPlaced: String,
    val marketSettled: String,
    val outcomeResolved: String
)
```

---

## Smell: Logging Inside Domain

**Symptom**: `log.info("Settling bet ${bet.id}")` inside `Bet.settle()`.

**Fix**: Domain is silent. Logging happens at the application/infrastructure layer where the operation is called.

---

## Smell: Flink State Defined in processElement

**Symptom**:

```kotlin
override fun open(params: Configuration) {
    betState = runtimeContext.getState(ValueStateDescriptor("bet-state", BetStateProto::class.java))
    marketState = runtimeContext.getState(ValueStateDescriptor("market-state", MarketStateProto::class.java))
    // 5 more state descriptors
}
```

**Fix**: Extract state management into a dedicated `*StateManager` class. `open()` just wires it.

---

## Smell: Protobuf Leaking into Domain

**Symptom**: Domain service method takes `BetPlacedProto` as a parameter.

**Fix**: Proto is infrastructure. Map to domain object at the consumer boundary (Kafka consumer, Flink source). Domain speaks domain types only.

---

## Kotlin-Specific: Not Using Data Classes for Value Objects

**Fix**: Use `data class` (or `@JvmInline value class` for wrappers) for all value objects. Gives you `equals`, `hashCode`, `copy`, `toString` for free.

---

## Kotlin-Specific: Using `var` When `val` Suffices

**Symptom**: `var status: BetStatus` on a class that should be immutable after construction.

**Fix**: Model state transitions by returning new instances, or use a separate mutable state holder if Flink state requires mutability.

---

## Kotlin-Specific: Not Using Sealed Classes for Domain Variants

**Symptom**: `when (type) { "WIN" -> ... "LOSS" -> ... else -> throw IllegalArgumentException() }`

**Fix**:

```kotlin
sealed class BetResult {
    data class Win(val payout: Money) : BetResult()
    data class Loss(val forfeited: Money) : BetResult()
}
// exhaustive when, compiler-checked
```
