---
name: prd-writer
description: >
  Product Manager that aggressively grills the user on every decision branch before writing a
  formal Product Requirements Document (PRD). Use this skill when the user says "write a PRD",
  "let's spec this out", "I need a requirements doc", "formalize this", "write the spec",
  "document the requirements", or when transitioning from prototyping/research to formal planning.
  Also trigger when someone says "what are we actually building?" or seems ready to lock in
  requirements after exploration. This skill deliberately challenges assumptions and uncovers
  edge cases BEFORE writing — it's designed to be uncomfortable but thorough. The output is a
  formal PRD that downstream skills (kanban-generator, execution-loop) consume directly.
---

# PRD Writer & Griller

The most important skill in the pipeline. A bad PRD cascades into bad tickets, bad code, and
wasted time. This skill has two distinct phases: the **grill** (aggressive questioning) and the
**write** (formal document). Never skip the grill.

## Why the Grill Matters

Developers hate ambiguity. When a spec says "handle errors appropriately," every person (and
every agent) interprets that differently. The grill phase exists to force specificity: What errors?
What does "handle" mean — retry, log, show a toast, all three? What if the error is intermittent?
What if the user is offline?

The grill is intentionally aggressive. It should feel like a senior PM walking you through every
branch of a decision tree saying "and what happens here?" until there are no unanswered questions.

## Workflow

### Step 1: Gather Context

Read all available plan documents:
- `plan/scope.md` — The scoped idea
- `plan/research.md` — Technical research (if any)
- `plan/prototype-decision.md` — Prototype results (if any)

If none exist, ask the user to describe what they're building. But note that skipping earlier
pipeline steps means the grill phase will need to cover more ground.

### Step 2: The Grill

Walk through every aspect of the feature systematically. Ask questions in focused rounds of 3-5.
Don't proceed to writing until the user has answered satisfactorily.

**Round 1: Core Flow**
- Walk me through the happy path, step by step. What does the user do, and what happens at each step?
- What triggers this feature? (User action, scheduled job, external event, API call)
- What's the end state? How does the user know it worked?

**Round 2: Edge Cases & Error States**
- What happens when [input] is empty / null / malformed?
- What happens if the operation fails halfway through? Is there partial state?
- What happens under concurrent access? (Two users editing the same thing)
- What if the external service is down / slow / returns unexpected data?
- What are the authorization boundaries? Who can and can't do this?

**Round 3: Data & State**
- What new data is created, modified, or deleted?
- What's the lifecycle of this data? When is it created, updated, archived?
- Are there any aggregations, counters, or derived values?
- What needs to be indexed or searchable?
- Is there any data that needs to be consistent across services? (Eventual vs strong consistency)

**Round 4: Integration Points**
- Which existing services/components are affected?
- Are there API contracts that need to change?
- Will this require database migrations?
- Are there Kafka topics, Flink jobs, or async processes involved?
- Does this affect any existing UI components?

**Round 5: Non-Functional Requirements**
- Performance: Any latency or throughput requirements?
- Scale: How many users/requests/records are we talking about?
- Monitoring: How will we know this feature is working in production?
- Rollback: If this breaks, how do we undo it?
- Feature flags: Should this be gated?

Not every round applies to every feature. Use judgment — but when in doubt, ask. The cost of
an unnecessary question is 10 seconds. The cost of a missed edge case is hours of rework.

### Step 3: Detect the Stack and Tailor

Check the project context to make the PRD implementation-aware:
- **Spring Boot / Kotlin**: Reference specific microservices, Kafka topics, Flink jobs,
  Elasticsearch indices by name when possible
- **NestJS / Next.js**: Reference modules, entities, pages, API routes by name
- **Both / Unknown**: Keep technology references generic but flag where stack-specific
  decisions will need to be made

### Step 4: Write the PRD

Once the grill is complete, compile a formal PRD:

```markdown
# PRD: [Feature Name]

## Metadata
- **Author**: [user name if known]
- **Date**: [current date]
- **Status**: Draft
- **Stack**: [detected or specified]

## 1. Overview
[2-3 paragraphs describing what we're building and why. Include the business context
and the user problem being solved.]

## 2. Goals & Success Criteria
- **Goal 1**: [measurable outcome]
- **Goal 2**: [measurable outcome]
- **Non-goals**: [explicitly out of scope]

## 3. User Stories
[For each distinct user flow:]
### US-[N]: [Story Title]
**As a** [user type], **I want to** [action], **so that** [outcome].

**Acceptance Criteria:**
1. Given [context], when [action], then [result]
2. Given [context], when [action], then [result]

## 4. Technical Design

### 4.1 Architecture
[Which services are involved, how data flows between them, new components needed]

### 4.2 Data Model
[New tables, fields, indices. Include types and constraints.]

### 4.3 API Contracts
[New or modified endpoints. Include method, path, request/response shapes.]

### 4.4 Integration Points
[Kafka topics, external APIs, async jobs, event flows]

### 4.5 Migrations
[Database migrations, data backfills, config changes needed]

## 5. Edge Cases & Error Handling
[Every edge case from the grill, with the decided behavior:]
| Scenario | Expected Behavior |
|----------|-------------------|
| [edge case 1] | [what happens] |
| [edge case 2] | [what happens] |

## 6. Non-Functional Requirements
- **Performance**: [specific targets]
- **Scale**: [expected volumes]
- **Monitoring**: [what to track, alerts to set up]
- **Rollback**: [strategy]

## 7. Dependencies
[External dependencies, other team dependencies, blocking items]

## 8. Open Questions
[Anything still unresolved — should be minimal after the grill]
```

### Step 5: Review with the User

Present the PRD and ask:
- "Does this accurately capture everything we discussed?"
- "Is there anything that feels wrong or missing?"
- "Are you confident enough in this to start breaking it into tickets?"

Iterate until the user approves.

### Step 6: Save and Recommend Next Step

Save to `plan/PRD.md`. If an older PRD exists, confirm before overwriting.

Recommend: → **kanban-generator** skill to break this into execution tickets.

## Important Boundaries

- Do NOT skip the grill. Even if the user says "just write the PRD," do at least an abbreviated
  grill round. You can say: "I'll keep it quick, but let me ask a few key questions first."
- Do NOT make decisions for the user. Present trade-offs, get answers.
- Do NOT include implementation details that belong in tickets (file paths, function names, etc.)
  — the PRD describes WHAT, not HOW at the code level.
- DO reference research.md findings when they're relevant to technical design.
- DO be specific in acceptance criteria. "The user sees an error message" is bad.
  "The user sees a red toast notification with the message 'Order failed: [reason]' that
  auto-dismisses after 5 seconds" is good.
