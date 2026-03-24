---
name: execution-loop
description: >
  Autonomous execution agent that picks up unblocked tickets and writes production-ready code
  to resolve them. Use this skill when the user says "start building", "execute the next ticket",
  "pick up a ticket", "run Ralph", "start the execution loop", "work on the feature", "build
  this", or after the kanban-generator has produced tickets. Also trigger when the user returns
  to a project and says "continue where we left off", "what's next", or "keep going". One
  worktree is created per PRD (not per ticket) at plan/worktrees/<prd-name>, shared across all
  tickets of that PRD. Say "run in parallel" to work on multiple PRDs simultaneously, each in
  its own worktree. Committing and merging are always left to the user — Ralph never commits or
  merges. Changes accumulate unstaged in the worktree for review in VSCode.
---

# Execution Loop (Ralph)

The builder. Takes tickets from the board, writes production-ready code, verifies with tests,
and leaves changes unstaged in the PRD's worktree for the user to review and commit.

**One worktree per PRD, not per ticket.** All tickets belonging to the same PRD are
implemented in the same worktree, on the same branch. This keeps things simple: one feature,
one branch, one place to review. The worktree accumulates changes across tickets until the
user is ready to commit and merge the whole thing (or any slice of it).

**Parallel mode = multiple PRDs at once.** If you're working on two different PRDs
simultaneously, each gets its own worktree. That's the only reason to have more than one
worktree active at a time.

**Ralph never commits, never merges.** Both are the user's responsibility. Ralph writes code,
runs tests, and stops with changes unstaged in the worktree — ready to inspect in VSCode
before deciding to keep anything.

---

## Worktree Naming

One worktree per PRD, named after the PRD/feature — not after any individual ticket.

**Convention:**

- Path: `plan/worktrees/<prd-slug>`
- Branch: `feat/<prd-slug>` (or `fix/`, `chore/` as appropriate)

Worktrees live **inside the project** under `plan/worktrees/`. VSCode sees them automatically
in the same window — no second instance needed.

`plan/worktrees/` must be added to `.gitignore` so worktree checkouts are never accidentally
staged in the main tree.

**Examples:**

| PRD / Feature                | Worktree path                          | Branch                        |
| ---------------------------- | -------------------------------------- | ----------------------------- |
| Order Management             | `plan/worktrees/order-management`      | `feat/order-management`       |
| Authentication & Permissions | `plan/worktrees/auth`                  | `feat/auth`                   |
| KDS Integration              | `plan/worktrees/kds-integration`       | `feat/kds-integration`        |
| Menu Item Schema Migration   | `plan/worktrees/menu-schema-migration` | `chore/menu-schema-migration` |

The slug comes from the PRD title or the feature name, not from any ticket. Keep it short
and stable — it won't change as tickets are added or completed.

The worktree name is stored in `plan/tickets.json` at the PRD level (in metadata), not per
ticket, since all tickets share it.

---

## Execution Modes

- **Serial** (default) — one ticket at a time, all in the PRD's single worktree
- **Parallel** — multiple PRDs active simultaneously, each with its own worktree

In both modes, there is exactly one worktree per PRD. The only difference is how many PRDs
are in flight at once.

---

## Workflow

### Step 1: Load Context

Read these files in order:

1. `plan/tickets.json` — The ticket board (machine-readable)
2. `plan/PRD.md` — The full requirements
3. `plan/research.md` — Technical research (if it exists)

If `tickets.json` doesn't exist, check for `plan/tickets.md` and parse it. If neither exists,
stop and tell the user to run the **kanban-generator** skill first.

Also run:

```bash
git worktree list --porcelain
```

Check if a worktree for this PRD already exists. If it does, use it — don't create a new one.
If worktrees exist for tickets marked `in_progress`, report them:

```
Found an existing worktree for this PRD:
  plan/worktrees/order-management  →  feat/order-management

Resume work there?
```

### Step 2: Set Up the PRD Worktree (once per PRD)

If no worktree exists yet for this PRD, create it now — before touching any ticket:

```bash
# Branch from the correct base
git checkout main
git pull

# Ensure the directory exists and is gitignored
mkdir -p plan/worktrees
grep -qxF 'plan/worktrees/' .gitignore || echo 'plan/worktrees/' >> .gitignore

# Create the single worktree for this PRD
git worktree add plan/worktrees/order-management -b feat/order-management
```

Record the worktree in `plan/tickets.json` metadata (not on individual tickets):

```json
{
  "meta": {
    "prd": "Order Management",
    "worktree": "plan/worktrees/order-management",
    "branch": "feat/order-management"
  },
  "tickets": [...]
}
```

If the worktree already exists (resumed session), skip creation entirely and just `cd` into it.

### Step 3: Select the Next Ticket

Find the next eligible ticket:

1. `status: "todo"`
2. All `blocked_by` tickets are `"done"` or `"ready-for-review"`
3. Earliest in ordering among eligible tickets

Present it and ask: "Ready to execute this ticket, or would you prefer a different one?"

Update its status to `"in_progress"` in `plan/tickets.json`.

### Step 4: Detect the Stack

Check the project for stack-specific patterns (read from the worktree):

- **Spring Boot / Kotlin**: existing package structure, constructor injection, JUnit 5 / MockK
- **NestJS / Next.js**: existing module structure, decorators, Jest
- **General**: match conventions observed in the codebase

### Step 5: Plan Before Coding

Before writing any code, outline:

1. Which files will be created or modified (paths relative to the worktree root)
2. What the changes will be at a high level
3. Which existing patterns you'll follow
4. What tests you'll write

Share this plan briefly. Catches misunderstandings before code is written.

### Step 6: Execute

Write the code inside the PRD's worktree. All file operations happen within that path.

```bash
cd plan/worktrees/order-management
# all reads and writes happen here
```

Read `plan/PRD.md` and `plan/research.md` from the main tree before entering the worktree —
worktrees don't carry separate copies of the plan directory.

Principles:

- **Match existing patterns.** Consistency matters more than theoretical perfection.
- **Follow the PRD exactly.** Don't improvise requirements.
- **Use research.md for technical details.** API endpoints, auth methods, data shapes.
- **Write tests.** Every ticket must include tests verifying acceptance criteria.
- **Handle errors.** The PRD's edge case table tells you what to do.

### Step 7: Run Tests

Run the full relevant test suite within the worktree:

```bash
cd plan/worktrees/order-management

# Spring Boot / Kotlin
./gradlew test

# NestJS / Node
npm test

# General: check package.json, Makefile, or build files
```

If tests fail: read the output, fix, re-run. Repeat until green.

If an **existing** test (one you didn't write) fails, investigate before proceeding — your
change may have broken something. Do not delete or skip failing tests.

### Step 8: Leave Changes Unstaged for Review

Once tests are green, **do not commit**. Leave all changes unstaged so the user can inspect
the full diff in VSCode. Run a diff summary so they know what accumulated:

```bash
cd plan/worktrees/order-management
git diff --stat
```

Include this output in the handoff report.

### Step 9: Update the Board

Mark this ticket as `"ready-for-review"` in `plan/tickets.json`:

```json
{
  "id": "TICKET-003",
  "status": "ready-for-review"
}
```

- Do **not** set `"done"` — the user hasn't committed yet
- Unblock any tickets whose only blocker was this one — they can be picked up in the same
  worktree without waiting for a commit

Set `"done"` only when the user explicitly confirms they've committed and are satisfied.

### Step 10: Hand Off to the User

Report what changed in this ticket and the cumulative worktree state:

```
✓ TICKET-003 — Order creation endpoint  [ready for review]

  Worktree: plan/worktrees/order-management  (feat/order-management)
  Tests:    15 passed, 0 failed

  Changes from this ticket:
    M  src/main/kotlin/orders/OrderController.kt
    A  src/main/kotlin/orders/OrderService.kt
    A  src/test/kotlin/orders/OrderServiceTest.kt

  All unstaged changes in this worktree so far:
    M  src/main/kotlin/orders/OrderController.kt  (+120 -0)
    A  src/main/kotlin/orders/OrderService.kt     (+85 -0)
    A  src/test/kotlin/orders/OrderServiceTest.kt (+60 -0)

  Visible in VSCode under plan/worktrees/order-management
  To commit:   cd plan/worktrees/order-management && git add -A && git commit -m "feat(order-management): ..."
  To merge:    git checkout main && git merge feat/order-management --no-ff
  To clean up: git worktree remove plan/worktrees/order-management

Next eligible ticket: TICKET-004 — Add menu items endpoint (same worktree)
Ready to pick it up?
```

Note that the next ticket will continue in the **same worktree** — no setup needed.

---

## Worktree Hygiene

1. **One worktree per PRD, always.** Never create a second worktree for tickets in the same PRD.
   If the worktree already exists, reuse it.

2. **Never write to the main tree.** All code goes into the PRD's worktree.

3. **Track the worktree in tickets.json metadata.** The `meta.worktree` and `meta.branch`
   fields are the source of truth. Individual tickets do not need worktree fields.

4. **Detect existing worktrees on startup.** Run `git worktree list --porcelain` at the start
   of every session. If the PRD's worktree already exists, use it without re-creating.

5. **Never force-remove a worktree with unstaged changes.** The user may still want them.
   Only suggest cleanup after the user has committed and merged.

6. **Migrations are always serial.** Tickets that add database migrations must run one at a
   time — never pick up a second migration ticket while another is in progress.

7. **Parallel PRDs = one worktree each.** The maximum number of active worktrees equals the
   number of PRDs in flight. Flag if this exceeds 3 — it's manageable but worth noting.

---

## Guardrails

1. **Run tests before marking a ticket ready.** A ticket is not ready-for-review until tests pass.
2. **Don't modify files outside ticket scope.** Note issues for the user; don't fix them.
3. **Never skip error handling.** Use the PRD edge case table.
4. **Never invent requirements.** Ask if the PRD doesn't specify something.
5. **Never commit.** Leave changes unstaged for the user to review in VSCode.
6. **Never merge.** The user owns both the commit and merge steps.
7. **Never create more than one worktree per PRD.**

## Important Boundaries

- Do NOT execute tickets with unresolved blockers.
- Do NOT refactor or improve code outside the current ticket's scope.
- Do NOT search the web for technical information — use `research.md` instead. If it's
  missing critical information, stop and ask the user to update it.
- DO match existing codebase conventions, even if you'd prefer different ones.
- DO keep the user informed of progress, especially if something unexpected comes up.
- DO always read `plan/PRD.md` and `plan/research.md` from the main tree, not from the worktree.
