---
name: kanban-generator
description: >
  Technical Lead that breaks a finalized PRD into specific, actionable execution tickets with
  explicit blocking relationships. Use this skill when the user says "break this into tickets",
  "create issues from the PRD", "generate tasks", "turn this into a kanban board", "what are
  the tickets", "break this down", or after a PRD is finalized and approved. Also trigger when
  the user asks "what should we build first?" or "what's the execution order?" for an existing
  PRD. The output is a structured markdown file with tickets that are small enough for a single
  agent session to execute, with clear dependency chains. These can be manually copied to Linear
  or any project management tool.
---

# Kanban Issue Generator

The decomposition skill. Takes a PRD and breaks it into execution-ready tickets that are ordered
by dependency, scoped for single-agent execution, and detailed enough that no additional context
is needed beyond the ticket + PRD + research.

## Why Ticket Quality Matters

A coding agent given a vague ticket will produce vague code. A ticket that says "implement user
authentication" could mean anything. A ticket that says "Create POST /auth/login endpoint that
accepts {email, password}, validates against bcrypt-hashed passwords in the users table, returns
a JWT with {userId, role} claims, 15-minute expiry, and returns 401 with {error: 'Invalid
credentials'} on failure" — that produces correct code on the first pass.

## Workflow

### Step 1: Load Context

Read the following files:
- `plan/PRD.md` — **Required**. If it doesn't exist, stop and tell the user to create one first.
- `plan/research.md` — Optional but valuable for technical tickets.
- `plan/scope.md` — Optional, for additional context.

Also scan the existing codebase to understand:
- Project structure and naming conventions
- Existing patterns (how controllers, services, repositories are organized)
- Test patterns (what test framework, where tests live, naming conventions)

### Step 2: Identify Execution Phases

Group the PRD into phases that represent natural build order:

1. **Foundation** — Schema changes, config, shared utilities. Everything else depends on this.
2. **Core Backend** — API endpoints, business logic, service layer.
3. **Integration** — Kafka producers/consumers, external API clients, Flink jobs.
4. **Frontend** — UI components, pages, state management.
5. **Polish** — Error handling improvements, loading states, edge case handling.
6. **Testing & QA** — Integration tests, E2E tests, manual QA plans.

Not every phase applies to every feature. Skip phases that aren't relevant.

### Step 3: Generate Tickets

For each piece of work, create a ticket. Each ticket must be:

- **Atomic**: Completable in a single focused agent session (roughly 15-30 minutes of agent time)
- **Self-contained**: All context needed is in the ticket + PRD + research
- **Testable**: There's a clear way to verify it's done correctly
- **Ordered**: Explicit about what it depends on

Ticket format:

```markdown
### [PHASE-NUMBER] [Ticket Title]

**Phase**: [Foundation / Core Backend / Integration / Frontend / Polish / Testing]
**Blocked by**: [ticket IDs that must complete first, or "None"]
**Estimated scope**: [S / M / L — where S < 15min, M < 30min, L < 60min agent time]

**Description**:
[2-3 sentences describing what this ticket accomplishes]

**Requirements**:
1. [Specific, verifiable requirement]
2. [Specific, verifiable requirement]
3. [Specific, verifiable requirement]

**Technical Notes**:
- [Implementation hint — which file to modify, which pattern to follow]
- [Reference to research.md section if applicable]

**Acceptance Criteria**:
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

**Files likely affected**:
- `path/to/file1`
- `path/to/file2`
```

### Step 4: Detect the Stack and Tailor

Check the project context:
- **Spring Boot / Kotlin**: Use package naming conventions, reference existing service/repository
  patterns, mention which microservice module each ticket belongs to
- **NestJS / Next.js**: Reference module structure, decorator patterns, page routes
- **Both / Unknown**: Keep file references generic but note where stack-specific decisions apply

### Step 5: Map the Dependency Graph

After generating all tickets, produce a dependency summary:

```markdown
## Dependency Graph

### Critical Path
[ticket] → [ticket] → [ticket] → ... → [Done]

### Parallelizable Work
After [ticket(s)] complete, these can run in parallel:
- [ticket A]
- [ticket B]
- [ticket C]

### Blocking Relationships
| Ticket | Blocked By |
|--------|-----------|
| F-1    | None      |
| F-2    | None      |
| CB-1   | F-1       |
| CB-2   | F-1, F-2  |
| ...    | ...       |
```

### Step 6: Estimate Total Effort

Provide a summary:
- Total tickets: [N]
- Breakdown by phase: Foundation [N], Core [N], ...
- Estimated agent sessions: [N] (accounting for parallelism)
- Critical path length: [N] tickets (minimum sequential work)

### Step 7: Save the Output

Save to `plan/tickets.md`.

Also generate a machine-readable version at `plan/tickets.json`:
```json
{
  "feature": "[Feature Name]",
  "generated": "[date]",
  "prd": "plan/PRD.md",
  "tickets": [
    {
      "id": "F-1",
      "title": "...",
      "phase": "Foundation",
      "blocked_by": [],
      "scope": "S",
      "status": "todo",
      "requirements": ["..."],
      "acceptance_criteria": ["..."],
      "files_affected": ["..."]
    }
  ]
}
```

This JSON is consumed by the **execution-loop** skill to pick the next unblocked ticket.

### Step 8: Review with the User

Present the ticket breakdown and ask:
- "Does this ordering make sense?"
- "Are any tickets too large or too small?"
- "Anything missing from the PRD that isn't covered?"
- "Ready to start execution?"

Recommend: → **execution-loop** skill to start picking up tickets.

## Ticket Sizing Guide

These are guidelines, not rules — use judgment:

**Small (S)** — ~15 min agent time:
- Add a column to an existing table
- Create a simple DTO/type
- Add a config value
- Write a unit test for an existing function

**Medium (M)** — ~30 min agent time:
- Create a new API endpoint with validation
- Build a UI component with state
- Write a Kafka consumer for a new topic
- Create a database migration with seed data

**Large (L)** — ~60 min agent time:
- Build a complete CRUD flow (controller + service + repository)
- Implement a complex business logic module with edge cases
- Create an integration with an external API (using research.md)

If a ticket feels like it would take longer than L, split it.

## Important Boundaries

- Do NOT write implementation code. Tickets describe work, they don't do it.
- Do NOT create tickets for work outside the PRD scope.
- DO reference specific files and patterns from the existing codebase.
- DO make ticket descriptions specific enough that an agent with no project familiarity
  could execute them by reading only the ticket + PRD + research.
- DO flag any PRD ambiguities you discover during decomposition — surface them to the user.
