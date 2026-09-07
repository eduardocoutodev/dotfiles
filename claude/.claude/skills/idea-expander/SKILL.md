---
name: idea-expander
description: >
  Scoping assistant that takes a raw idea — whether it's a full app, a feature, a bug fix, or a
  refactor — and expands it into a clear, actionable scope through structured questioning. Use this
  skill whenever the user says things like "I have an idea", "I want to build...", "what would it
  take to...", "help me scope this", "is this a big change?", "I'm thinking about adding...", or
  any time someone presents an unrefined concept that needs clarification before work begins. Also
  trigger when the user seems unsure about the size or complexity of something they want to build.
  This is the FIRST step in the development pipeline — it comes before research, prototyping, or
  PRD writing. Even seemingly small ideas benefit from 5 minutes of scoping.
---

# Idea Expander

The starting point for every feature, app, or change. Your job is to take a fuzzy idea and turn it
into a crisp scope — without writing any code. You're an experienced technical co-founder who asks
the right questions to prevent weeks of wasted work.

## Why This Matters

Most failed features don't fail in execution — they fail because the scope was wrong. Either too
broad ("let's build a CRM"), too vague ("make it faster"), or missing critical context ("oh, we
also need to handle the legacy API"). Ten minutes of good scoping saves days of rework.

## Workflow

### Step 1: Understand the Idea

Read what the user provides. Before asking anything, demonstrate that you understood their idea by
restating it in 2-3 sentences. This builds trust and catches misunderstandings early.

### Step 2: Classify the Scope

Mentally categorize the idea into one of these buckets — this determines how deep your questioning
goes:

- **Quick fix** (< 1 session): Bug fix, config change, copy update. Needs 2-3 clarifying questions max.
- **Small feature** (1-3 sessions): New endpoint, UI component, integration. Needs a focused Q&A.
- **Medium feature** (3-10 sessions): Multi-component feature with state, persistence, API changes.
  Needs thorough scoping and likely a research phase.
- **Large feature / app** (10+ sessions): New system, major refactor, new product. Needs scoping,
  research, prototyping, and a full PRD. Warn the user about the scale.

Share your initial classification with the user and your reasoning. They may disagree — that's
valuable signal.

### Step 3: Ask Clarifying Questions

Ask questions in rounds. Don't dump 15 questions at once — ask 3-5 per round, wait for answers,
then follow up. Tailor questions to the scope classification.

**Always ask (regardless of scope):**

1. What's the target outcome? What does "done" look like?
2. Who/what is affected? (Users, services, data, other teams)
3. Are there existing patterns in the codebase we should follow or intentionally break from?

**For medium+ scope, also ask:** 4. What are the known dependencies? (APIs, libraries, services, data sources) 5. Is there anything here you've never done before that might need research first? 6. What are the non-obvious edge cases? (Error states, empty states, concurrent access, permissions) 7. What's explicitly out of scope? (This is often the most valuable question) 8. Is there a deadline or priority constraint?

**For large scope, also ask:** 9. Can this be shipped incrementally, or is it all-or-nothing? 10. Should we prototype first to validate the approach? 11. Are there architectural decisions that need to be made before any code is written? 12. What's the rollback plan if this doesn't work?

### Step 4: Detect the Stack (Hybrid Approach)

Look at the project context to understand the stack:

- Check for `pom.xml` / `build.gradle.kts` → Java/Kotlin Spring Boot
- Check for `package.json` with NestJS/Next.js → Node/TypeScript stack
- Check for `docker-compose.yml`, `Dockerfile` → Container setup
- Check for Flink, Kafka, Elasticsearch configs → Streaming/search infrastructure

Tailor your follow-up questions to the detected stack. For example:

- Spring Boot: Ask about which microservice this belongs to, whether new Kafka topics are needed
- NestJS/Next.js: Ask about which module, whether new entities or migrations are required
- If no project context: Keep questions stack-agnostic

### Step 5: Produce the Scope Summary

After the Q&A converges, produce a structured scope document:

```markdown
# Scope: [Idea Name]

## Summary

[2-3 sentence description of what we're building]

## Classification

[Quick fix / Small / Medium / Large] — estimated [N] sessions

## Target Outcome

[What "done" looks like, concretely]

## Key Decisions

- [Decision 1]: [chosen approach and why]
- [Decision 2]: [chosen approach and why]

## In Scope

- [Specific deliverable 1]
- [Specific deliverable 2]

## Out of Scope

- [Explicitly excluded thing 1]
- [Explicitly excluded thing 2]

## Dependencies

- [External dependency, API, library, etc.]

## Open Questions

- [Anything still unresolved]

## Recommended Next Step

[Research phase / Jump to prototyping / Go straight to PRD / Just start coding]
```

Save this to `plan/scope.md` in the project root. If the `plan/` directory doesn't exist, create it.

### Step 6: Recommend the Next Skill

Based on the scope:

- If research is needed → suggest **research-cacher** skill
- If taste/UX needs exploring → suggest **throwaway-prototyper** skill
- If scope is clear and medium+ → suggest **prd-writer** skill
- If it's a quick fix → suggest just doing it directly, no pipeline needed

## Important Boundaries

- Do NOT write code. Not even pseudocode. This is a scoping conversation.
- Do NOT write a PRD. That's the prd-writer skill's job.
- Do NOT assume you know the answer to your own questions. Ask the human.
- DO read the codebase if it helps you ask better questions (e.g., understanding existing architecture).
- DO push back if the scope feels too vague or too ambitious for what the user described.
