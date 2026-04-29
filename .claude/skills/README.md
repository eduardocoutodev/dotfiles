# Claude Skills — Development Workflow

This is a personal playbook for how I chain skills together. Pick the flow that matches the work, not the other way around.

## Core principle

**`grill-with-docs` belongs near the front of every greenfield/feature flow.** It produces `CONTEXT.md` (domain glossary) and `docs/adr/` (architectural decisions). Every downstream skill — `prd-writer`, `kanban-generator`, `improve-codebase-architecture` — gets sharper when those exist. Without them, every PRD re-invents vocabulary and every architecture review re-litigates settled decisions.

## Execution conventions

Two non-negotiable defaults that override what individual skills suggest:

1. **Default to branch mode in `execution-loop`.** No worktrees unless I explicitly ask for them. I want one feature branch in my normal working directory so my IDE, git tooling, and muscle memory all keep working.
2. **Always stop after each ticket for review.** Never run tickets back-to-back autonomously. I review the diff after each task; small reviews compound, big PRs don't get reviewed.

These two rules are encoded directly in `execution-loop/SKILL.md`. If a flow below says "execution-loop", assume both rules apply.

## Flows

### Flow A — Greenfield feature

```
idea-expander → grill-with-docs → prd-writer → kanban-generator → execution-loop → qa-planner → code-review
```

- `idea-expander` only when the idea is vague. Skip it when the shape is already clear.
- `grill-with-docs` extends `CONTEXT.md` _before_ the PRD so the PRD uses real domain terms.
- `qa-planner` after the last ticket, before merging, to generate human test plans.
- `code-review` + `simplify` as the final gate before commit.

### Flow B — Building on an existing codebase

```
improve-codebase-architecture → (optional refactor) → grill-with-docs → prd-writer → kanban-generator → execution-loop
```

`improve-codebase-architecture` runs _first_ to surface friction before stacking new code on shallow modules. Two outcomes:

- **Friction is real** → deepen first via a refactor PR, then build on the deepened seam.
- **Friction is acceptable** → record an ADR ("we know this is shallow, building on it anyway because…") so future-me doesn't re-litigate.

### Flow C — Bug fix / small change

```
analyze-bug → fix → simplify → review-diff
```

No PRD, no kanban. <50 LOC changes don't need ceremony.

### Flow D — Pure refactor

```
improve-codebase-architecture → execution-loop
```

The grilling loop is built into `improve-codebase-architecture` now — no separate `grill-me` step. Pick a candidate, walk the design tree inside the skill, hand the resulting GitHub issue (or `tickets.json`) to `execution-loop`.

## Dropped / consolidated skills

- **`feature-planner`** — already backed up to `SKILL.MD.bk`. Keep it parked.
- **`grill-me` standalone** — mostly redundant. `prd-writer` grills for product, `improve-codebase-architecture` grills for architecture. Keep `grill-me` only for design conversations that aren't either.
- **`arch-simplifier` vs `improve-codebase-architecture`** — overlap. `improve-codebase-architecture` is the more rigorous skill (with `LANGUAGE.md` / `DEEPENING.md` / `INTERFACE-DESIGN.md` backing it). Drop or repurpose `arch-simplifier` for "scan only, no proposal" mode.

## Skill index

| Skill                           | Role in the flow                                                                  | Status |
| ------------------------------- | --------------------------------------------------------------------------------- | ------ |
| `idea-expander`                 | Scope a vague idea before PRD work                                                | Active |
| `grill-with-docs`               | Build/extend `CONTEXT.md` and ADRs                                                | Active |
| `prd-writer`                    | Grill into a Product Requirements Document                                        | Active |
| `kanban-generator`              | Break a PRD into blocked/unblocked tickets                                        | Active |
| `execution-loop`                | Implement tickets one at a time on a feature branch (stops for review after each) | Active |
| `improve-codebase-architecture` | Find deepening opportunities, run grilling loop                                   | Active |
| `qa-planner`                    | Human test plans before merge                                                     | Active |
| `research-cacher`               | Pre-load technical context into `research.md`                                     | Active |
| `throwaway-prototyper`          | Isolated UI/implementation experiments                                            | Active |

## Future skills to add

### `retro-extractor` (high priority)

After a feature ships, scan the diff + PR comments + test failures and propose updates to `CONTEXT.md` and `docs/adr/`. Closes the loop — without it, the docs `grill-with-docs` produces go stale and `improve-codebase-architecture` loses its grounding over time.

**Trigger:** "I just merged X, what should we capture?" or run on a cron after merges.

**Output:**

- Diff summary of `CONTEXT.md` term additions/sharpenings
- Draft ADRs for decisions made during implementation that weren't pre-recorded
- Notes on patterns worth promoting / anti-patterns worth flagging

**Where it sits:**

```
... → execution-loop → review → merge → retro-extractor → (CONTEXT.md / ADR updates)
```

### Other candidates (lower priority)

- **`adr-recorder`** — standalone "capture this decision now" without a full grilling session.
- **`migration-planner`** — multi-PR migrations too big for one ticket; sits between `kanban-generator` and `execution-loop`.
- **`release-notes`** — generate user-facing notes from a closed kanban column.
- **`prd-validator`** — sanity-check a PRD against `CONTEXT.md` before kanban breakdown to catch domain drift early.

## When in doubt

If a task feels too small for Flow A, it probably is. Use Flow C. If Flow B feels overkill for a tiny tweak, the friction probably isn't real — just build the thing. The flows are tools, not rituals.
