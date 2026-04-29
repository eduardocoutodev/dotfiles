---
name: execution-loop
description: >
  Autonomous execution agent that picks up unblocked tickets and writes production-ready code
  to resolve them. Use this skill when the user says "start building", "execute the next ticket",
  "pick up a ticket", "run Ralph", "start the execution loop", "work on the feature", "build
  this", or after the kanban-generator has produced tickets. Also trigger when the user returns
  to a project and says "continue where we left off", "what's next", or "keep going". Supports
  two modes: **branch mode** (default) checks out a feature branch directly in the working
  directory without creating a worktree; **worktree mode** creates an isolated git worktree per
  PRD at plan/worktrees/<prd-name>. Say "use worktree mode" or "run with worktrees" to activate
  worktree mode. Say "run in parallel" to work on multiple PRDs simultaneously (worktree mode
  only). **Always stops after each ticket for review** — never runs tickets back-to-back
  autonomously. Committing and merging are always left to the user — Ralph never commits or merges.
  Changes accumulate unstaged for review in VSCode.
---

# Execution Loop (Ralph)

The builder. Takes tickets from the board, writes production-ready code, verifies with tests,
and leaves changes unstaged for the user to review and commit.

**Two isolation modes — pick one per session:**

|                       | Branch mode (default)                                     | Worktree mode                                     |
| --------------------- | --------------------------------------------------------- | ------------------------------------------------- |
| **Isolation**         | Checkout in the main working directory                    | Separate directory per PRD                        |
| **Parallel PRDs**     | ❌ No — only one branch active at a time                  | ✅ Yes — each PRD gets its own worktree           |
| **VSCode experience** | Single directory, switch branches to compare              | Both trees visible simultaneously                 |
| **When to use**       | Default for single-PRD focus and normal IDE/git workflow  | Multiple PRDs in flight, or prefer full isolation |

Mode is chosen **once per session** and applies to all tickets in that run. If `plan/tickets.json`
already records a worktree, that implies worktree mode was used before — resume in worktree mode.
Otherwise default to **branch mode**.

**Ralph never commits, never merges.** Both are the user's responsibility. Ralph writes code,
runs tests, and stops with changes unstaged — ready to inspect in VSCode before deciding to keep
anything.

**Ralph always stops after each ticket.** Never run tickets back-to-back without an explicit
"continue" / "next ticket" / "keep going" from the user. After every ticket: hand off, surface
the diff, and wait. The user reviews each diff before the next ticket starts — small reviews
compound, big PRs don't get reviewed.

---

## Mode: Branch (default)

No worktree is created. Ralph checks out the feature branch directly in the main working
directory and all file operations happen there. This is the default — only switch to worktree
mode when the user explicitly asks for it or when `tickets.json` already records a worktree.

**Convention:**

- Branch: `feat/<prd-slug>` (or `fix/`, `chore/` as appropriate)
- Working directory: repo root (wherever the user normally works)

**Setup:**

```bash
git checkout main
git pull
git checkout -b feat/order-management   # or git checkout feat/... if branch already exists
```

**Constraints in branch mode:**

- Only one PRD can be active at a time (no parallel execution — that requires worktrees).
- Switching between PRDs means switching branches; warn the user before doing so.
- The user's working directory will reflect the feature branch — any unrelated local changes
  should be stashed or committed first.

The branch is stored in `plan/tickets.json` at the PRD level (`meta.branch`). `meta.worktree`
is omitted in branch mode.

---

## Mode: Worktree

One isolated checkout per PRD, placed inside the project directory. Use only when the user
explicitly asks for worktree mode or when resuming a session that already created one.

**Convention:**

- Path: `plan/worktrees/<prd-slug>`
- Branch: `feat/<prd-slug>` (or `fix/`, `chore/` as appropriate)

`plan/worktrees/` must be added to `.gitignore` so worktree checkouts are never accidentally
staged in the main tree.

The slug comes from the PRD title or the feature name, not from any ticket. Keep it short
and stable — it won't change as tickets are added or completed.

The worktree path and branch are stored in `plan/tickets.json` at the PRD level
(`meta.worktree`, `meta.branch`) — not per ticket, since all tickets share them.

---

## Execution Modes (Parallelism)

- **Serial** (default) — one ticket at a time
- **Parallel** — multiple PRDs active simultaneously, **worktree mode only**

In parallel mode there is exactly one worktree per PRD. Flag if more than 3 PRDs are in
flight simultaneously — it's manageable but worth noting.

Branch mode is always serial.

---

## Workflow

### Step 1: Load Context

Read these files in order:

1. `plan/tickets.json` — The ticket board (machine-readable)
2. `plan/PRD.md` — The full requirements
3. `plan/research.md` — Technical research (if it exists)

If `tickets.json` doesn't exist, check for `plan/tickets.md` and parse it. If neither exists,
stop and tell the user to run the **kanban-generator** skill first.

**Determine the isolation mode:**

1. If the user explicitly said "worktree mode" / "use worktrees" → **worktree mode**.
2. If `plan/tickets.json` has `meta.worktree` set → **worktree mode** (resuming).
3. Otherwise → **branch mode** (default). No prompt needed; just confirm the choice in the handoff.

Only fall back to asking the user if branch mode setup hits a blocker (e.g. dirty working tree
that can't be safely stashed).

**Check for existing state:**

_Worktree mode:_

```bash
git worktree list --porcelain
```

If a worktree for this PRD already exists, use it — don't create a new one.

_Branch mode:_

```bash
git branch --list feat/<prd-slug>
git status
```

If the branch already exists, check it out. If the working directory has uncommitted changes,
warn the user and pause — do not switch branches with dirty state.

### Step 2: Set Up Isolation (once per PRD)

**Worktree mode:**

```bash
git checkout main
git pull

mkdir -p plan/worktrees
grep -qxF 'plan/worktrees/' .gitignore || echo 'plan/worktrees/' >> .gitignore

git worktree add plan/worktrees/order-management -b feat/order-management
```

Record in `plan/tickets.json`:

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

**Branch mode:**

```bash
git checkout main
git pull
git checkout -b feat/order-management   # skip -b if branch already exists
```

Record in `plan/tickets.json` (no `worktree` field):

```json
{
  "meta": {
    "prd": "Order Management",
    "branch": "feat/order-management"
  },
  "tickets": [...]
}
```

If the setup already happened (resumed session), skip creation and confirm current state:

```
Resuming in branch mode on feat/order-management
Current branch: feat/order-management ✓
```

### Step 3: Select the Next Ticket

Find the next eligible ticket:

1. `status: "todo"`
2. All `blocked_by` tickets are `"done"` or `"ready-for-review"`
3. Earliest in ordering among eligible tickets

Present it and ask: "Ready to execute this ticket, or would you prefer a different one?"

Update its status to `"in_progress"` in `plan/tickets.json`.

### Step 4: Detect the Stack

Check the project for stack-specific patterns:

- **Spring Boot / Kotlin**: existing package structure, constructor injection, JUnit 5 / MockK
- **NestJS / Next.js**: existing module structure, decorators, Jest
- **General**: match conventions observed in the codebase

In worktree mode, read the codebase from inside the worktree. In branch mode, read from the
working directory (already on the feature branch).

### Step 5: Plan Before Coding

Before writing any code, outline:

1. Which files will be created or modified (paths relative to the project root)
2. What the changes will be at a high level
3. Which existing patterns you'll follow
4. What tests you'll write

Share this plan briefly. Catches misunderstandings before code is written.

### Step 6: Execute

Write the code in the correct location:

- **Worktree mode**: all file operations inside `plan/worktrees/<prd-slug>/`
- **Branch mode**: all file operations in the working directory (already on the feature branch)

```bash
# Worktree mode
cd plan/worktrees/order-management
# ... write files here

# Branch mode
# already in the right directory — no cd needed
# ... write files here
```

Read `plan/PRD.md` and `plan/research.md` from the main tree before entering a worktree —
worktrees don't carry separate copies of the plan directory. In branch mode, the plan directory
is already accessible.

Principles:

- **Match existing patterns.** Consistency matters more than theoretical perfection.
- **Follow the PRD exactly.** Don't improvise requirements.
- **Use research.md for technical details.** API endpoints, auth methods, data shapes.
- **Write tests.** Every ticket must include tests verifying acceptance criteria.
- **Handle errors.** The PRD's edge case table tells you what to do.

### Step 7: Run Tests

```bash
# Worktree mode
cd plan/worktrees/order-management
./gradlew test   # or npm test, etc.

# Branch mode (already in working directory)
./gradlew test   # or npm test, etc.
```

If tests fail: read the output, fix, re-run. Repeat until green.

If an **existing** test (one you didn't write) fails, investigate before proceeding — your
change may have broken something. Do not delete or skip failing tests.

### Step 8: Leave Changes Unstaged for Review

Once tests are green, **do not commit**. Leave all changes unstaged and run a diff summary:

```bash
# Worktree mode
cd plan/worktrees/order-management && git diff --stat

# Branch mode
git diff --stat
```

Include this output in the handoff report.

### Step 9: Update the Board

Mark this ticket as `"ready-for-review"` in `plan/tickets.json`.

- Do **not** set `"done"` — the user hasn't committed yet.
- Unblock any tickets whose only blocker was this one.

Set `"done"` only when the user explicitly confirms they've committed and are satisfied.

### Step 10: Hand Off to the User

**Worktree mode:**

```
✓ TICKET-003 — Order creation endpoint  [ready for review]

  Mode:     Worktree
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

**Branch mode:**

```
✓ TICKET-003 — Order creation endpoint  [ready for review]

  Mode:   Branch
  Branch: feat/order-management
  Tests:  15 passed, 0 failed

  Changes from this ticket:
    M  src/main/kotlin/orders/OrderController.kt
    A  src/main/kotlin/orders/OrderService.kt
    A  src/test/kotlin/orders/OrderServiceTest.kt

  All unstaged changes on this branch so far:
    M  src/main/kotlin/orders/OrderController.kt  (+120 -0)
    A  src/main/kotlin/orders/OrderService.kt     (+85 -0)
    A  src/test/kotlin/orders/OrderServiceTest.kt (+60 -0)

  To commit:   git add -A && git commit -m "feat(order-management): ..."
  To merge:    git checkout main && git merge feat/order-management --no-ff
  To clean up: git branch -d feat/order-management

Next eligible ticket: TICKET-004 — Add menu items endpoint (same branch)
Ready to pick it up?
```

---

## Worktree Hygiene (worktree mode only)

1. **One worktree per PRD, always.** Never create a second worktree for the same PRD. Reuse it.
2. **Never write to the main tree.** All code goes into the PRD's worktree.
3. **Track the worktree in tickets.json metadata.** `meta.worktree` and `meta.branch` are the
   source of truth.
4. **Detect existing worktrees on startup.** Run `git worktree list --porcelain` at the start
   of every session.
5. **Never force-remove a worktree with unstaged changes.** Only suggest cleanup after the user
   has committed and merged.
6. **Parallel PRDs = one worktree each.** Maximum active worktrees = number of PRDs in flight.
   Flag if this exceeds 3.

## Branch Mode Hygiene

1. **Check for dirty state before checkout.** If `git status` shows uncommitted changes,
   pause and warn the user — never switch branches with dirty state.
2. **One branch per PRD, no parallel execution.** If the user wants to work on a second PRD,
   they must commit or stash current work first.
3. **Confirm active branch at session start.** Run `git branch --show-current` and report it.
4. **Never switch branches mid-ticket.** Finish (or explicitly abandon) the current ticket
   before switching.

---

## Guardrails

1. **Run tests before marking a ticket ready.** A ticket is not ready-for-review until tests pass.
2. **Don't modify files outside ticket scope.** Note issues for the user; don't fix them.
3. **Never skip error handling.** Use the PRD edge case table.
4. **Never invent requirements.** Ask if the PRD doesn't specify something.
5. **Never commit.** Leave changes unstaged for the user to review in VSCode.
6. **Never merge.** The user owns both the commit and merge steps.
7. **Never create more than one worktree per PRD.**
8. **Never switch branches in branch mode without checking for dirty state first.**
9. **Never start the next ticket without explicit user confirmation.** After each ticket, hand
   off, surface the diff, and wait. The user reviews each diff before saying "next" / "continue"
   / "keep going". No back-to-back ticket execution under any circumstances.

## Important Boundaries

- Do NOT execute tickets with unresolved blockers.
- Do NOT refactor or improve code outside the current ticket's scope.
- Do NOT search the web for technical information — use `research.md` instead. If it's
  missing critical information, stop and ask the user to update it.
- DO match existing codebase conventions, even if you'd prefer different ones.
- DO keep the user informed of progress, especially if something unexpected comes up.
- DO always read `plan/PRD.md` and `plan/research.md` from the main tree (worktree mode) or
  the working directory (branch mode).
