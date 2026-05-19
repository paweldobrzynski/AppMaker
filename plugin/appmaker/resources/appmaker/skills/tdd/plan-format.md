# TDD Plan output format

Global style: `appmaker/skills/output-style.md`. TDD-specific rules below.

- **≥ 4 cycles** → use **markdown table** (compact, scannable).
- **≤ 3 cycles** → use **per-cycle `### Tn` headings** (more reading space for complex cases).
- **Never:** ASCII separators (`────`), `#:` prefix, stacked RED/GREEN/Traces lines.

## Table template (4+ cycles)

```markdown
## TDD Plan: <slice-id-slug>

**Interface:** `functionName(args) → returnType`
**Module:** `path/to/module.js` — pure logic per constitution rule 3
**Backlog:** `appmaker/backlog/NNN-slug.md`

| # | Type | RED (failing test) | GREEN (minimal impl) | Traces |
|---|---|---|---|---|
| T1 | tracer | `fn({k:'v'}) === 'Low'` | Create module, terminal short-circuit | SC1 |
| T2 | rule | All 4 terminal statuses → `'Low'` | Covered by T1 | SC1 |
| T3 | edge | `fn(null)` no throw, returns `null` | Add `data = data \|\| {}` | ID4 |

**Integration steps** (manual verification only — NOT TDD):
- Wire into `<caller path>`
- Verify happy path on real `<sample>` record
```

Column rules:

- `#` — `T1`, `T2`, ... (T = test/cycle).
- `Type` — `tracer` / `rule` / `edge` / `regression` / `integration-prep`.
- `RED` — single-line executable-looking pseudo-code.
- `GREEN` — single-line "what changes". "Covered by Tn" is valid.
- `Traces` — AC IDs (canonical `pcrit-NNN` OR project format like `SC1`/`ID4`).

## Heading template (≤ 3 cycles)

```markdown
## TDD Plan: <slice-id-slug>

**Interface:** `functionName(args) → returnType`
**Backlog:** `appmaker/backlog/NNN-slug.md`

### T1 — Tracer bullet

- **RED:** `fn({k: 'v'}) === 'expected'`
- **GREEN:** Create module, minimal early return
- **Traces:** SC1
- **Note:** establishes module shape; subsequent cycles extend.

### T2 — Rule for X

- **RED:** [single-line failing test]
- **GREEN:** [what changes]
- **Traces:** SC2, ID3
```
