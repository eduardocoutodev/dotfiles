---
name: research-cacher
description: >
  Technical researcher that explores APIs, libraries, architectural patterns, or any unfamiliar
  technology and produces a comprehensive research.md document. The goal is to front-load all
  exploration so that downstream coding agents never need to search docs or guess. Use this skill
  when the user says "research this API", "I need to integrate with...", "how does X work",
  "look into this library", "I've never used X before", "gather docs on...", or when the
  idea-expander skill recommends a research phase. Also trigger when the user is about to build
  something involving an API, library, or pattern they haven't used before — even if they don't
  explicitly say "research". The output is a cached knowledge document that future skills and
  agent sessions can consume without re-searching.
---

# Research Cacher

The intelligence-gathering skill. When the idea involves something you (or the coding agent) don't
know well — a third-party API, an unfamiliar library, a complex architectural pattern — this skill
does the deep dive and writes it all down. The output is a `research.md` file that becomes the
single source of technical truth for the rest of the pipeline.

## Why This Matters

Coding agents hallucinate when they lack context. They'll invent API endpoints that don't exist,
use deprecated methods, and miss authentication requirements. A good research document eliminates
this entire class of failure by giving the agent verified, structured reference material.

## Workflow

### Step 1: Understand the Research Target

Ask the user:
1. What specifically needs researching? (API, library, pattern, architecture)
2. What's the end goal? (Knowing the goal helps focus the research)
3. Any specific version constraints? (e.g., "we're on Spring Boot 3.4", "must work with Node 20")

If `plan/scope.md` exists, read it — the scope document often contains the context you need.

### Step 2: Auto-Search and Gather Information

Use web search aggressively to find:
- **Official documentation** — API references, getting-started guides, changelogs
- **Authentication and authorization** — How to authenticate, API keys, OAuth flows, token management
- **Data models** — Request/response shapes, schemas, entity relationships
- **Code examples** — Official examples, popular open-source integrations
- **Known issues and gotchas** — GitHub issues, Stack Overflow common problems, migration guides
- **Rate limits and quotas** — Pricing tiers, throttling behavior, retry strategies
- **SDKs and client libraries** — Official vs community, which language/version

For each source, fetch the full page content when search snippets aren't enough. Prioritize official
docs over blog posts, and recent content over old.

### Step 3: Detect the Stack and Tailor Research

Check the project context:
- `pom.xml` / `build.gradle.kts` → Focus on Java/Kotlin libraries, Spring integrations
- `package.json` → Focus on npm packages, TypeScript types, Node.js compatibility
- Both or neither → Cover multiple angles

Tailor the research to the detected stack. For example, if researching Stripe:
- Spring Boot project → Focus on `stripe-java` SDK, Spring configuration patterns
- NestJS project → Focus on `stripe` npm package, NestJS module patterns

### Step 4: Write research.md

Structure the document so a coding agent can quickly find what it needs:

```markdown
# Research: [Topic Name]

> Researched on [date]. Sources verified against [version/docs URL].

## TL;DR
[3-5 sentences: what this is, why we need it, the key insight for our use case]

## Overview
[What this technology/API does, at a high level. 1-2 paragraphs.]

## Authentication
[How to authenticate. Include exact header formats, token types, env var names to use.]

## Key Endpoints / APIs / Methods
[The specific parts we'll actually use. For each:]

### [Endpoint/Method Name]
- **Purpose**: What it does
- **Method**: GET/POST/etc.
- **URL**: Full URL pattern
- **Request**: Key parameters (with types)
- **Response**: Key fields in the response (with types)
- **Example**: A minimal working example
- **Gotchas**: Anything non-obvious

## Data Models
[Entity relationships, schemas, key types we'll work with]

## Error Handling
[Common errors, status codes, retry strategies, rate limit behavior]

## Configuration
[Environment variables, config files, initialization code needed]

## SDK / Library Setup
[Which package to install, version, basic setup code]

## Edge Cases and Gotchas
[Things that aren't obvious from the docs. Known bugs, undocumented behavior,
common mistakes, version-specific issues.]

## Alternatives Considered
[If relevant: other libraries/approaches we looked at and why we chose this one]

## References
[Links to official docs, relevant GitHub repos, useful blog posts]
```

Not every section will apply to every research target. Skip sections that aren't relevant, but err
on the side of including too much — it's a cache, and future agents can skip what they don't need.

### Step 5: Save the Document

Save to `plan/research.md` (or `plan/research-[topic].md` if there are multiple research targets).

If `plan/` doesn't exist, create it.

### Step 6: Verify and Summarize

After writing, do a quick self-check:
- Could a coding agent build the integration using ONLY this document? If not, what's missing?
- Are there any "TODO" or "check this" items? Resolve them now or flag them clearly.
- Are the code examples syntactically correct for the detected stack?

Present a brief summary to the user:
- What was researched
- Key findings that affect architecture or approach
- Any surprises, blockers, or things that need human decision
- Recommended next step (usually: prototyping or PRD writing)

## Important Boundaries

- Do NOT write implementation code. Research documents contain examples and snippets, not features.
- Do NOT make architectural decisions. Present options and trade-offs for the human to decide.
- DO verify information across multiple sources when possible.
- DO flag uncertainty. If something seems undocumented or inconsistent, say so explicitly.
- DO include version numbers and dates so the research can be assessed for staleness later.
