---
description: Maintain project ubiquitous language at appmaker/glossary.md. Invoked explicitly by user (`/appmaker:glossary`) after deterministic stub extraction flags candidate terms. Writes are visible to user (no autonomous invocation). Format adopted from Matt Pocock deprecated/ubiquitous-language skill.
disable-model-invocation: true
---

Bridge human-domain-expert ↔ LLM-developer language. Shared vocabulary for project. **Two-tier maintenance:**

1. **Deterministic stub extraction** (v0.2.11) — `appmaker/hooks/glossary-extract.sh <artifact>` scans bold-uppercase patterns in generated artifacts (PRD, decomposition, etc.) and appends stubs for new candidate terms. **Verifiable bash, no agent trust.** Called by parent skills (prd, decompose, tdd, grill) as a post-step.
2. **Semantic review** (this skill) — explicit user slash-command invocation. Resolves stubs (define / reject / merge with existing / flag ambiguity). **Best-effort agent reasoning, NOT deterministic.**

Adopted from Matt Pocock's `deprecated/ubiquitous-language` skill (format) plus AppMaker two-tier pattern. Replaces the prior "auto-maintained byproduct" framing (v0.2.8 and earlier) which was misleading — extraction is now bash, semantic update remains agent-driven and explicit.

## When to invoke

- Explicit user: `/appmaker:glossary` — review stubs, define / reject / merge / fix ambiguity
- Suggested by parent skills after `glossary-extract.sh` appends stubs (best-effort, depends on conversation context being rich enough)
- AFK-safe: NO — semantic review needs user judgment for ambiguous cases
- Required state: `appmaker/glossary.md` exists (created by `/appmaker:init`); typically stubs present from extraction step
- Required input: glossary file (extracted stubs); conversation context for definitions

## Process

### Stub review mode (typical entry point)

1. Read existing `appmaker/glossary.md`.
2. Find entries with `**Status:** stub` — these were extracted by `glossary-extract.sh` but lack definitions.
3. For each stub:
   - Show context (source artifact path is in the stub).
   - Use conversation history + codebase reads to propose a definition.
   - Use AskUserQuestion: accept proposed def / edit / reject (remove stub) / mark as ambiguous (needs domain expert).
   - On accept: replace stub block with full entry. Remove `**Status:** stub` line. Add `**Source:**` line if relevant.
4. Update frontmatter: `last_updated: <ISO date>`, `last_updated_by: glossary`.
5. Output one-line summary: `Glossary: 3 stubs resolved (2 accepted, 1 rejected, 0 ambiguous). Current term count: 12.`

### Manual invoke mode

1. Read existing glossary.
2. Show user current state grouped by section.
3. Use AskUserQuestion: review / add term / remove term / merge synonyms / fix ambiguity / quit.
4. Apply user edits.
5. Update header timestamps.

## Output format

`appmaker/glossary.md`:

```md
---
last_updated: 2026-05-11
last_updated_by: interview
term_count: 12
---

# Project Ubiquitous Language

## Lifecycle

| Term | Definition | Aliases to avoid |
|---|---|---|
| **Materialize** | Convert ghost entity to real entity by creating its on-disk representation | "create on disk", "realize", "make real" |
| **Ghost lesson** | Lesson that exists in DB but not on file system | "draft lesson", "planned lesson" |

## Actors

| Term | Definition | Aliases to avoid |
|---|---|---|
| **Domain expert** | Human who decides product behaviour | "user", "stakeholder" |

## Relationships

- A **Materialization cascade** triggers when **real lesson** added to **ghost course** → assigns file path → cascades up.
- A **Ghost course** can contain only **ghost lessons** until materialized.

## Example dialogue

> **Dev:** "When user materializes ghost lesson inside ghost course, what happens to course?"
> **Domain expert:** "Materialization cascade fires. Course becomes real. Section becomes real."
> **Dev:** "What if user only wants real lesson, not real course?"
> **Domain expert:** "Not allowed. Cascade enforces."

## Flagged ambiguities

- "section" used for both filesystem directory AND DB row grouping. Disambiguate: **filesystem section** = directory, **logical section** = DB row group.
```

## Auto-maintenance contract (called by other commands)

Other commands MUST:
1. Read `appmaker/glossary.md` at start (if exists).
2. Reference existing terms (don't invent synonyms).
3. After main work done, invoke `/appmaker:glossary` with conversation context.
4. Glossary command appends new terms, returns summary.

Other commands MUST NOT:
- Modify glossary directly. Always go through this command.
- Invent canonical domain terms without flagging for user acceptance.

## Guardrails

- **Be opinionated.** Multiple words for same concept → pick best, list aliases.
- **Flag conflicts explicit.** Same word different concepts → "Flagged ambiguities" section.
- **Domain terms only.** Skip generic programming (array/function/endpoint).
- **One sentence definitions.** Define what it IS, not what it does.
- **Group naturally.** Subdomains, lifecycle, actors. Each group own table.
- **Show relationships.** Bold term names. Cardinality where obvious.
- **Example dialogue mandatory.** 3-5 exchanges. Show terms used precisely.
- **Skip code identifiers.** Module/class names not domain terms unless meaningful in domain.
- **Don't auto-resolve ambiguities.** Flag for human decision.
- **Don't include implementation terms** ("repository", "service") unless domain is software architecture itself.
- **Don't bloat with every noun.**
- **Don't omit aliases-to-avoid.**

## Caveat (Matt Pocock deprecated standalone)

Matt deprecated his standalone `ubiquitous-language` skill (reason unstated). Likely cause: stale-glossary maintenance overhead. AppMaker mitigation (v0.2.11): two-tier pattern. Tier 1 (deterministic stub extraction via `glossary-extract.sh`) catches candidate terms; Tier 2 (explicit `/appmaker:glossary` review) keeps definitions current. `last_updated_by` tracks freshness; user prunes stale via explicit invoke.
