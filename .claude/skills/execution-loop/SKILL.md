---
name: execution-loop
description: >
  Autonomous execution agent that picks up unblocked tickets and writes production-ready code
  to resolve them. Use this skill when the user says "start building", "execute the next ticket",
  "pick up a ticket", "run Ralph", "start the execution loop", "work on the feature", "build
  this", or after the kanban-generator has produced tickets. Also trigger when the user returns
  to a project and says "continue where we left off", "what's next", or "keep going". This skill
  reads the ticket board, finds the next unblocked ticket, writes the code, runs tests, one ticket per session. 
  It relies strictly on the PRD and research.md for context rather than searching the web or guessing.
---

# Execution Loop (Ralph)

The builder. Takes one ticket at a time from the board, writes production-ready code, verifies it
with tests. This skill is designed to run semi-autonomously — the user kicks
it off and reviews the output, but the actual coding happens without hand-holding.

## Why One Ticket at a Time

Building an entire feature in one session leads to compounding errors. A mistake in the database
schema cascades through every endpoint and every component. By working ticket-by-ticket:

- Each change is small enough to review quickly
- Errors are caught early before they cascade
- The user can course-correct between tickets
- Git history tells a coherent story

## Workflow

### Step 1: Load Context

Read these files in order:

1. `plan/tickets.json` — The ticket board (machine-readable)
2. `plan/PRD.md` — The full requirements
3. `plan/research.md` — Technical research (if it exists)

If `tickets.json` doesn't exist, check for `plan/tickets.md` and parse it. If neither exists,
stop and tell the user to run the **kanban-generator** skill first.

### Step 2: Find the Next Ticket

Scan the ticket board for the next ticket that:

1. Has `status: "todo"` (not "in_progress", "done", or "blocked")
2. Has all `blocked_by` tickets in `status: "done"`
3. Is the earliest in the ordering among eligible tickets

If multiple tickets are eligible, pick the one in the earliest phase (Foundation before Core
Backend before Integration, etc.).

Present the selected ticket to the user:

- Ticket ID and title
- What it involves
- What it depends on (and confirmation those are done)

Ask: "Ready to execute this ticket, or would you prefer a different one?"

If the user has specified a particular ticket, use that instead.

### Step 3: Detect the Stack

Check the project for stack-specific patterns:

- **Spring Boot / Kotlin**: Follow existing package structure, use constructor injection,
  follow existing test patterns (JUnit 5 / MockK / etc.)
- **NestJS / Next.js**: Follow existing module structure, use decorators consistently,
  follow existing test patterns (Jest / etc.)
- **General**: Match the conventions you observe in the existing codebase

### Step 4: Plan Before Coding

Before writing any code, outline your plan:

1. Which files will be created or modified
2. What the changes will be at a high level
3. Which existing patterns you'll follow
4. What tests you'll write

Share this plan with the user briefly. This catches misunderstandings before code is written.

### Step 5: Execute

Write the code to resolve the ticket. Follow these principles:

- **Match existing patterns.** If the codebase uses a repository pattern, use it. If there's an
  existing error handling approach, follow it. Consistency matters more than theoretical perfection.
- **Follow the PRD exactly.** If the PRD says the error message should be "Order failed: [reason]",
  use those exact words. Don't improvise requirements.
- **Use research.md for technical details.** API endpoints, authentication methods, data shapes —
  get these from the research document, not from memory.
- **Write tests.** Every ticket should include tests that verify the acceptance criteria. Match
  the existing test framework and patterns.
- **Handle errors.** Don't leave empty catch blocks or TODO comments for error handling.
  The PRD's edge case table tells you what to do.

### Step 6: Run Tests

Before marking complete, run the full relevant test suite:

```bash
# Detect and run appropriate test command
# Spring Boot / Kotlin:
./gradlew test
# or
./mvnw test

# NestJS / Node:
npm test
# or
npm run test:e2e

# General:
# Look for test scripts in package.json, Makefile, or build files
```

If tests fail:

1. Read the failure output carefully
2. Fix the issue
3. Run tests again
4. Repeat until green

If an existing test (not one you wrote) fails, it might indicate your change broke something.
Investigate before proceeding.

### Step 6: Update the Board

Update `plan/tickets.json`:

- Set this ticket's status to `"done"`
- Note the commit hash and branch name
- Update any tickets that were blocked only by this one — they may now be unblocked

### Step 7: Report and Recommend

Tell the user:

- What was built
- What tests pass
- What the next eligible ticket is

Ask: "Want to review this before I pick up the next ticket?"

Recommend: If all tickets are done → **qa-planner** skill for comprehensive testing.
If tickets remain → continue with the next eligible ticket.

## Guardrails

These are non-negotiable safety constraints:

1. **Run tests before marking complete.** A ticket is not done until tests pass. This includes
   both new tests written for this ticket AND the existing test suite.
2. **One ticket, one PR.** Each ticket gets its own commit and (if applicable) its own PR.
   Don't combine tickets into a single change. The user must commit and push after each ticket before you pick the next one.
3. **Don't modify files outside ticket scope.** If you notice an issue in unrelated code, note
   it for the user — don't fix it. Scope creep in individual tickets undermines the whole system.
4. **Never skip error handling.** The PRD has an edge case table. Use it.
5. **Never invent requirements.** If the ticket and PRD don't specify something, ask — don't guess.

## Important Boundaries

- Do NOT execute tickets that have unresolved blockers.
- Do NOT refactor or improve code outside the current ticket's scope.
- Do NOT search the web for technical information — use research.md instead. If research.md
  is missing critical information, stop and tell the user to update it.
- DO match existing codebase conventions, even if you'd prefer different ones.
- DO keep the user informed of progress, especially if something unexpected comes up.
