---
name: throwaway-prototyper
description: >
  Rapid prototyper that generates 2-3 isolated implementations or UI layouts on throwaway routes
  so the user can impose their taste before committing to a formal spec. Use this skill when the
  user says "prototype this", "let me see a few options", "I want to try different approaches",
  "mock this up", "what would this look like", "let's experiment with...", "I need to see it
  before I decide", or when the idea-expander recommends exploring before committing. Also trigger
  when the user is making a UX decision, choosing between architectural approaches, or needs visual
  or behavioral feedback before writing a PRD. Speed and experimentation matter more than clean code
  here — these prototypes are explicitly disposable.
---

# Throwaway Prototyper

The taste-imposition skill. Before locking in a formal spec, you need to see and feel different
approaches. This skill generates quick, isolated prototypes so the user can compare options, iterate
rapidly, and arrive at a confident direction.

## Why This Matters

Specs written without prototyping tend to be either too abstract (leading to mismatched
implementations) or too prescriptive about the wrong things (over-specifying layout, under-specifying
behavior). Prototyping lets you make mistakes cheaply and discover what actually works.

## Core Philosophy

- **Speed over quality.** These prototypes exist to answer questions, not to ship.
- **Isolated by design.** Each prototype should be self-contained. Don't build on top of existing
  production code — use throwaway routes, standalone files, or temporary directories.
- **Diverge, then converge.** Start with 2-3 meaningfully different approaches. Don't make 3 versions
  of the same thing with minor CSS tweaks — each prototype should represent a genuinely different
  strategy or layout.
- **The user drives.** Present options, explain trade-offs, and let the user pick. Then iterate
  on the chosen direction until they're satisfied.

## Workflow

### Step 1: Understand What Needs Prototyping

Read `plan/scope.md` and/or `plan/research.md` if they exist. Ask the user:

1. What aspect needs prototyping? (UI layout, interaction pattern, data flow, API design)
2. What are the key variables? (What differs between approaches?)
3. Any strong preferences to start from? ("I definitely want a sidebar" or "no modals")
4. What does success look like? (How will you judge which prototype wins?)

### Step 2: Detect the Stack

Check the project context to know what kind of prototypes to build:
- **Next.js / React project** → Create prototype pages/components in a `/prototypes` directory
  or throwaway route (e.g., `/app/prototype/page.tsx`)
- **NestJS backend** → Create isolated endpoint prototypes, temporary controllers
- **Spring Boot / Kotlin** → Create prototype endpoints in a separate package
- **No project context** → Use standalone HTML files, or ask the user what format works

### Step 3: Generate 2-3 Prototypes

For each prototype:

1. **Name it clearly** — "Prototype A: Sidebar Navigation", "Prototype B: Tab-based Layout"
2. **Explain the strategy** — What's different about this approach and why someone would choose it
3. **Build it fast** — Prioritize visual/behavioral feedback. Hardcode data, skip error handling,
   use placeholder content. Comments like `// TODO: real data` are fine.
4. **Make it runnable** — The user should be able to see/test each prototype immediately

Place all prototypes in a `/prototypes` directory at the project root:
```
prototypes/
├── README.md           # Overview of all prototypes and how to run them
├── prototype-a/        # Self-contained
├── prototype-b/        # Self-contained
└── prototype-c/        # Self-contained (if applicable)
```

### Step 4: Present the Options

For each prototype, provide:
- **Screenshot or description** of what it looks/behaves like
- **Pros**: What this approach does well
- **Cons**: What it sacrifices or makes harder
- **Best for**: The use case where this approach shines

Then ask: "Which direction feels right? We can also mix elements from different prototypes."

### Step 5: Iterate on the Chosen Direction

Once the user picks a direction (or a hybrid), iterate:
- Apply their feedback quickly
- Don't refactor — just patch. This is still throwaway code.
- Keep rounds tight: make changes, show results, get feedback
- Stop when the user says "yes, this is the direction"

### Step 6: Document the Decision

When the user is satisfied, create a brief decision document:

```markdown
# Prototype Decision: [Feature Name]

## Chosen Approach
[Which prototype was selected, and any hybrid elements]

## Key Design Decisions
- [Decision 1]: [what and why]
- [Decision 2]: [what and why]

## Rejected Alternatives
- [Prototype X]: Rejected because [reason]

## Notes for PRD
[Anything the PRD writer should know — behavioral expectations, layout constraints,
interaction patterns that emerged during prototyping]
```

Save to `plan/prototype-decision.md`.

### Step 7: Clean Up

Ask the user: "Should I keep the prototype code for reference, or delete it?"
- If keep: Leave `/prototypes` as-is
- If delete: Remove the directory
- Either way, the decision document in `plan/` preserves the learnings

### Step 8: Recommend Next Step

Almost always: → **prd-writer** skill. The prototype decision gives the PRD writer concrete
direction instead of abstract requirements.

## Important Boundaries

- Do NOT build production-quality code. If you catch yourself writing tests or error handling, stop.
- Do NOT modify existing production code. Prototypes live in isolation.
- Do NOT spend more than a few minutes per prototype. If it's taking too long, simplify.
- DO make prototypes that are visually comparable — similar data, similar scenarios.
- DO prioritize the thing being prototyped. If it's a layout decision, the data can be fake.
  If it's a data flow decision, the UI can be ugly.
