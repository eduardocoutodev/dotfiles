---
name: qa-planner
description: >
  QA Engineer that generates step-by-step human testing plans and converts test failures into
  actionable bug tickets. Use this skill when the user says "create a QA plan", "how do I test
  this", "write test cases", "QA this feature", "is this ready for review", "generate a test
  plan", "I need to test this", or after the execution-loop completes all tickets for a feature.
  Also trigger when the user reports bugs or test failures and needs them formatted as tickets
  for the execution loop. The output is a qa-plan.md checklist that a human can walk through
  to verify the feature meets PRD requirements, plus the ability to convert failures into new
  execution tickets.
---

# QA Plan Generator

The quality gate. After the code is written, someone needs to verify it actually works. This
skill creates a structured, step-by-step testing plan that a human can follow to verify every
requirement in the PRD. When things fail, it converts those failures into bug tickets that feed
back into the execution loop.

## Why Human QA Matters

Automated tests verify that code does what the programmer intended. Human QA verifies that the
feature does what the user needs. These are different things. A feature can pass all tests and
still be wrong — confusing UX, missing edge cases that weren't in the spec, integration issues
that only appear in a real environment.

## Workflow

### Step 1: Load Context

Read these files:
1. `plan/PRD.md` — The requirements and acceptance criteria
2. `plan/tickets.json` or `plan/tickets.md` — The completed tickets
3. `plan/research.md` — For API/integration-specific test scenarios

Also review the actual code changes:
- Look at recent commits related to the feature
- Understand what was built, where it lives, how it runs

### Step 2: Build the QA Plan

Structure the plan around the PRD's user stories and acceptance criteria. Each test case should be
concrete enough that anyone could follow it — no ambiguity, no assumed knowledge.

```markdown
# QA Plan: [Feature Name]

**PRD**: plan/PRD.md
**Date**: [current date]
**Tester**: [to be filled by human]
**Environment**: [local / staging / production]

## Prerequisites
- [ ] [Environment setup step 1 — e.g., "Run docker-compose up"]
- [ ] [Environment setup step 2 — e.g., "Seed test data with npm run seed"]
- [ ] [Any config needed — e.g., "Set STRIPE_KEY in .env"]

---

## Test Suite 1: [User Story / Feature Area Name]

### TC-1.1: [Test Case Name — Happy Path]
**Priority**: Critical
**PRD Reference**: US-[N], AC-[N]

**Steps**:
1. [Exact action — e.g., "Navigate to http://localhost:3000/orders"]
2. [Exact action — e.g., "Click the 'New Order' button"]
3. [Exact action — e.g., "Fill in: Item = 'Margherita Pizza', Quantity = 2"]
4. [Exact action — e.g., "Click 'Submit Order'"]

**Expected Result**:
- [Specific observable outcome — e.g., "Toast notification: 'Order #[id] created successfully'"]
- [Specific state change — e.g., "Order appears in the orders list with status 'Pending'"]
- [Specific data — e.g., "Total shows €19.80 (2 × €9.90)"]

**Result**: [ ] Pass / [ ] Fail
**Notes**: _______________

---

### TC-1.2: [Test Case Name — Edge Case]
**Priority**: High
**PRD Reference**: Edge Case Table, Row [N]

**Steps**:
1. [Exact action]
2. [Exact action]

**Expected Result**:
- [Specific outcome per PRD edge case table]

**Result**: [ ] Pass / [ ] Fail
**Notes**: _______________
```

### Step 3: Cover All PRD Requirements

Systematically ensure coverage:

1. **Every user story** gets at least one happy-path test case
2. **Every acceptance criterion** is tested by at least one step
3. **Every edge case** from the PRD's edge case table gets a test case
4. **Every error state** gets a test case with specific error messages to verify
5. **Integration points** get test cases (API calls, Kafka messages, external services)

### Step 4: Detect the Stack and Tailor

Check the project context to provide accurate testing instructions:
- **Spring Boot / Kotlin**: Include curl commands or Postman instructions for API testing,
  reference actual ports and endpoints
- **NestJS / Next.js**: Include browser navigation steps, reference actual page routes,
  include API testing via browser devtools or curl
- **Frontend-heavy**: Include specific UI interactions, responsive testing notes,
  browser-specific checks

### Step 5: Add Non-Functional Tests

Include tests that go beyond feature correctness:

```markdown
## Non-Functional Tests

### NF-1: Performance
- [ ] [Action] completes within [N]ms (check browser devtools Network tab)
- [ ] Page load under [N]s with [N] records in the database

### NF-2: Error Recovery
- [ ] Stop [service/database] → perform action → verify graceful error message
- [ ] Restore service → verify feature recovers without manual intervention

### NF-3: Data Integrity
- [ ] After [action], verify database state with: `[specific SQL query or API call]`
- [ ] Check no orphaned records: `[specific query]`

### NF-4: Authorization
- [ ] Attempt [action] as unauthenticated user → expect [specific response]
- [ ] Attempt [action] as wrong role → expect [specific response]
```

### Step 6: Save the QA Plan

Save to `plan/qa-plan.md`.

Present a summary:
- Total test cases: [N]
- Critical priority: [N]
- High priority: [N]
- Medium priority: [N]
- Estimated testing time: [rough estimate]

### Step 7: Handle Failure Reports

When the user reports test failures, convert them to bug tickets:

```markdown
## Bug Tickets from QA

### BUG-[N]: [Descriptive title]
**Found in**: TC-[X.Y]
**Priority**: [Critical / High / Medium]
**PRD Reference**: [Which requirement is not met]

**Steps to Reproduce**:
1. [Exact steps from the failed test case]

**Expected Behavior**:
[What the PRD says should happen]

**Actual Behavior**:
[What the tester observed]

**Technical Notes**:
[Any relevant details — error messages, console output, screenshots described]

**Blocked by**: None (or existing ticket if applicable)
```

Save bug tickets to `plan/bugs.md` and also append them to `plan/tickets.json` with status "todo"
so the execution loop can pick them up.

Tell the user: "Bug tickets have been added to the board. Run the **execution-loop** skill to
start fixing them."

## QA Plan Quality Checklist

Before presenting the QA plan, verify:
- [ ] Every step includes exact URLs, button names, or commands — no "navigate to the page"
- [ ] Every expected result includes specific values, messages, or states — no "it should work"
- [ ] Prerequisites cover everything needed to start testing from scratch
- [ ] Test cases are ordered logically (setup → happy path → edge cases → errors → cleanup)
- [ ] Each test case references the specific PRD requirement it verifies

## Important Boundaries

- Do NOT run the tests yourself. This skill creates the plan for a human to execute.
- Do NOT mark tests as passed or failed. Only the human tester does that.
- Do NOT fix bugs directly. Convert failures to tickets for the execution loop.
- DO make test cases specific enough that someone unfamiliar with the feature could execute them.
- DO include cleanup steps if tests create data that might affect other tests.
- DO prioritize test cases so the most critical paths are tested first.
