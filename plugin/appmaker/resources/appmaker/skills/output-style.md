# AppMaker Output Style Guide

How AppMaker skills present information — both **agent-time chat** and **persisted artifacts** (PRD, decomposition, plans, reports, retro).

Goal: **scannable, simple, logical**. Reader's eyes find the answer fast. No prose walls. No ASCII art noise.

## Format priority (top → bottom)

1. **Tables** — when comparing multiple items with same fields (slices, checks, test cycles, findings)
2. **Headings + bullets** — when explaining sequential or hierarchical content (steps, sections, single-item details)
3. **Bulleted lists** — when sequence matters less than items themselves
4. **Numbered lists** — when sequence matters (steps, ordered process)
5. **Code blocks** — for commands, file content, exact syntax
6. **Prose paragraphs** — last resort, only when narrative flow is unavoidable (e.g. PRD Problem Statement)

Default to higher in this list. Fall to lower only when higher doesn't fit.

## Tables — usage rules

**DO use a table when:**
- ≥ 3 items have same fields (slices, tests, checks)
- Side-by-side comparison helps (PASS/FAIL/WARN per check)
- Eye needs to scan column for one column value (status, ID, traces)

**DON'T use a table when:**
- 1-2 items only (use bullets instead — table is overhead)
- Field values are multi-paragraph (table breaks readability)
- Items don't share structure (use headings per item instead)

**Table column rules:**
- ≤ 6 columns. More than 6 → split or use headings.
- Each cell ≤ 80 chars (mobile/narrow terminal friendly).
- No newlines inside cells. If needed, use bullets in cell with `<br>` or split row.
- Right-align numeric columns where it helps scan.
- Header row mandatory.

## Headings — usage rules

- `##` for major sections (Problem, Solution, Implementation Decisions)
- `###` for subsections (T1 — Tracer bullet, Check 5 — Trace Coverage)
- `####` rare, only 4-deep when truly necessary
- No emoji prefixes in headings — adds noise, reduces scannability
- Title-case OR sentence-case, but consistent per artifact

## Lists — usage rules

- `- ` for unordered bullets (most common)
- `1. ` for explicit sequence (steps, ordering)
- Indent nested bullets with 2 spaces
- Each bullet **single-line preferred**, multi-line OK if substance demands
- 4-5 nested levels max — deeper means restructure

## Code blocks — usage rules

- ` ```bash ` for shell commands (NOT ` ```! ` — that's dynamic injection, blocks permission)
- ` ```yaml ` / ` ```markdown ` / ` ```typescript ` etc. for file content
- Always specify language for syntax highlighting + readability
- Don't dump entire files — show relevant section, indicate `... (truncated)`

## Anti-patterns — communication noise

| ❌ Don't | ✅ Do |
|---|---|
| Heavy ASCII separators (`─────────`, `═════════`, `▓▓▓▓▓`) | Markdown tables / headings — they already segment |
| `#:` prefix for items | `T1` / `S1` / `C1` — short, unambiguous |
| Prose walls 5+ lines | Bullet list or table |
| Stacking RED/GREEN/Traces as 3 separate lines per cycle | Table row OR single heading block |
| Multi-line cells in tables | Single-line OR restructure to headings |
| Emoji decoration in headings (🚀 ✨ 🎯) | Plain text — emoji only when semantically necessary (PASS/FAIL indicators) |
| Repeated "Note:" / "Important:" / "Caveat:" labels | Bold key word inline: **Note:** ... — minimal disruption |
| Long YAML front-matter exceeding 15 fields | Split essential vs optional, document optional ones in template |
| ASCII art diagrams (boxes drawn with `+--+`) | Markdown table OR mermaid syntax OR external image |

## Agent-time chat communication

When responding in chat (not writing artifacts):

- **Lead with conclusion / answer.** Don't bury it after 3 paragraphs of context.
- **Status indicators** as inline labels: `[PASS]`, `[FAIL]`, `[WARN]`, `[TODO]`, `[✓]`, `[✗]`.
- **Tables for any multi-item summary** (skills produced, checks run, findings listed).
- **Headings (`##`, `###`) for response sections** even in chat — markdown renders.
- **Avoid:** "Let me explain..." "First, I should mention..." "It's worth noting that..." — get to point.
- **Don't apologize for length** — just be shorter.
- **Show file/line citations** as `path/to/file.ts:42` not "in the file at line 42".

## Compact report contract

**All AppMaker reports (checklist, review, retro, AFK) follow this contract.** Goal: 1-screen scan, no prose walls.

**Rules:**

1. **Frontmatter ≤ 4 fields.** Pick from: `scope`, `status`, `created`. Never include counts in frontmatter — they belong in the summary line.
2. **Summary = 1 line.** Format: `**N PASS / M FAIL / K WARN**` (checklist) or `**Status:** PASS|FAIL` (review). No companion-paragraph explanations.
3. **One canonical place per fact.** If a finding is in the main table, it does NOT also get a deep-dive section AND a "Suggested Next" callout. Pick one location.
4. **Evidence cells ≤ 80 chars.** Compress: `slice 007: 4/9 ACs ticked, 5 stray [ ] in description` not `Slices 001 (9/9), 002 (6/6), 003 (7/7)... Slice 007: 4 ACs ticked + 5 unchecked [ ] lines inside Check B description (lines 45-49 of [done/2026-05-11-007-...])`.
5. **Skip empty sections.** No `## Blockers — None.` filler. If empty, omit the heading entirely.
6. **Warnings/Findings = bullet list, 1 line per item.** Format: `- **<id>**: <fact, ≤ 120 chars>. Fix: <path or action>.` No "What:" / "Why it matters:" / "Fix:" sub-blocks.
7. **No "Suggested Next" section in reports.** If the table's Fix column tells the user what to do, the meta-suggestion is duplication. Save next-action for the chat reply, not the persisted file.

**Compact report skeleton (canonical):**

```markdown
---
scope: <feature 001-foo | backlog 042 | project | archive 001-foo>
status: PASS | FAIL | WARN
created: 2026-05-11
---

# <Report Title>

**N PASS / M FAIL / K WARN**

## Checks

| ID | Status | Check | Evidence | Fix |
|---|---|---|---|---|
| trace-coverage | WARN | PRD IDs traced | `ID2` missing in slice 002/003 traces_to | add `ID2` to traces_to |

## Warnings  ← only if K > 0
- **trace-coverage**: `ID2` not traced by any slice. Fix: add to slices 002 + 003 `traces_to`.

## Blockers  ← only if M > 0
- **review-gate**: feature missing `review.md`. Fix: run `/appmaker:review feature <NNN>`.
```

That's the entire report. No further sections.

## Verdict vocabulary (v0.2.27)

Every gate and decision artifact carries a machine-readable `verdict:` frontmatter field. One value, fixed vocabulary — so `next`, `checklist`, and humans can branch on it without parsing prose. Two families:

**Quality gates** — "is this artifact/code good enough?" (`checklist`, `review`, `qa`, `design-review`, `security-scan`):

| Verdict | Meaning | Effect on lifecycle |
|---|---|---|
| `PASS` | No blocking issues; suggestions allowed. | Proceed. |
| `WARN` | Non-blocking issues; accepted risk must be named. | Proceed with recorded caveat. |
| `FAIL` | ≥ 1 blocking issue. | Stop. Fix, or explicit override (`*_status: failed_overridden` + reason). |

**Decision gates** — "which path / should we proceed at all?" (`council`):

| Verdict | Meaning | Effect on lifecycle |
|---|---|---|
| `SHIP` | Proceed with the recommended path. | Hand off to next phase (e.g. `decompose`). |
| `NEEDS_WORK` | Decision not ready — named gaps must close first. | Loop back (more grill/research/prd) before proceeding. |
| `BLOCKED` | Cannot proceed — external dependency, missing input, or non-delegable human judgment. | Halt; surface the blocker to the human. |

Rules:
- **Quality gates never emit `SHIP`/`NEEDS_WORK`/`BLOCKED`; decision gates never emit `PASS`/`FAIL`.** Don't cross the vocabularies.
- The verdict in frontmatter is the single source of truth. The summary line restates it for humans; it does not redefine it.
- `next` reads `verdict:` to decide remediation-vs-advance. A missing verdict on a gate artifact = treat as not-yet-run.

## Provenance schema (v0.2.27)

Generated artifacts carry a provenance block so a future reader knows who produced a claim and how much to trust it — the foundation of the deferred Evidence-First fact policy, started here at near-zero cost. Four fields, in frontmatter:

```yaml
provenance:
  author: appmaker:prd          # appmaker:<skill> | human | subagent:<type> (who/what wrote it)
  created: 2026-06-02           # ISO date
  source: interview-result.md   # upstream input(s) this was derived from; "conversation" if none
  confidence: file_verified     # see vocabulary below — the WEAKEST link in the artifact
```

`confidence` vocabulary (ordered weakest → strongest):

| Value | Meaning |
|---|---|
| `model_assertion` | Claude's reasoning only; not checked against code/docs/web. |
| `web_verified` | Backed by an external source (Ref / docs / fetched page). |
| `file_verified` | Backed by reading the actual repo files (`rg`/Read evidence). |
| `human_confirmed` | A human explicitly approved the claim/decision. |

Rules:
- **Report the weakest link.** An artifact mixing a verified fact and a guess is `model_assertion` until the guess is checked.
- Provenance is additive — it never replaces existing fields. Backlog items keep their own `source:`/`created:`; the `provenance:` block sits alongside and may reference them.
- Decision gates (`council`) with a `SHIP` verdict must meet `council_min_confidence` (config) — default `file_verified`. A `SHIP` resting on `model_assertion` is downgraded to `NEEDS_WORK`.

## Artifact-specific templates

Each skill that produces an artifact has its own template. See:
- **TDD plan** — `appmaker/skills/tdd/` (table for 4+ cycles, headings for ≤ 3)
- **PRD** — Understanding section (7 subsections), Implementation Decisions table, Testing Decisions table
- **Decomposition** — slices table, dependency graph (markdown OR mermaid)
- **Checklist report** — PASS/FAIL/WARN table, scope and reasoning per check
- **Review findings** — Critical / Suggestions / Constitution compliance / AC coverage (separate tables)
- **Retro** — Q&A table (4 default questions, answer column), Lessons extracted as bullet list
- **Context packet** — Summary bullets, Relevant Communities table, Key Files table, Risks bullets

## When in doubt

**Reader's question: "Where is the answer to my question?"** If they have to scan 3 paragraphs of prose to find it — restructure. Tables and bullets win over prose when comparing or listing.

**Reader's question: "How is this organized?"** If structure isn't obvious from headings — restructure. Hierarchy should self-explain.

**Reader's question: "Can I skip this section?"** If yes — make it skippable. Front-load the essential, defer details to optional subsections.

## Examples

### ❌ Before — prose wall, ASCII separators, stacked fields

```
#: T1 (tracer)
RED test: computeBpsRisk({mgcStatus:'closed after VR'}) === 'Low'
GREEN impl: Create domain/bps-rules.js with terminal-status short-circuit → returns 'Low'; everything else null
────────────────────────────────────────
#: T2
RED test: All 4 terminal statuses return 'Low'
GREEN impl: Already covered by T1 implementation
────────────────────────────────────────
```

### ✅ After — table

```markdown
| # | Type | RED (failing test) | GREEN (minimal impl) | Traces |
|---|---|---|---|---|
| T1 | tracer | `computeBpsRisk({mgcStatus:'closed after VR'}) === 'Low'` | Create `domain/bps-rules.js`, terminal short-circuit | SC1 |
| T2 | rule | All 4 terminal statuses → `'Low'` | Covered by T1 (`isStatusTerminal`) | SC1 |
```

Same content, 60% less vertical space, scannable in 2 seconds.

---

**Reference this style guide from any skill that produces output.** Override only with documented reason (e.g., "this skill needs prose because X").
