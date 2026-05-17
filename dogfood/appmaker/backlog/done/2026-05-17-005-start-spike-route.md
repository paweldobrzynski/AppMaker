---
id: 005
slug: start-spike-route
status: done
completed: 2026-05-17
labels: [bug, ux]
execution_class: human_required
blocked_by: []
traces_to: [pcrit-006]
feature: 001-method-compliance-pass-1
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/skills/start/SKILL.md
    - tests/smoke/test-start-routes.sh
created: 2026-05-17
source: decompose
---

# 005: /appmaker:start spike route fix

## Parent

`dogfood/appmaker/features/001-method-compliance-pass-1/prd.md`

## What to build

`plugin/appmaker/skills/start/SKILL.md` macro action table routes "prototype" category to `/appmaker:spike`, which does not exist (per README "4 opt-in skills, all TODO" — includes `spike`).

User typing `/appmaker:start "try a new idea"` would get suggestion for non-existent command. Broken route. Honest behavior choices:

- **Option A:** Route to `/appmaker:grill` with note "prototype flow (`/appmaker:spike`) is TODO — using grill as best alternative for now"
- **Option B:** Refuse + clear "prototype flow not implemented yet (TODO in roadmap). No alternative — wait for `/appmaker:spike`."
- **Option C:** Route to `/appmaker:grill-brownfield` for brownfield projects (sharper than greenfield grill for exploring existing code)

**Phrasing decision = `human_required`.** Operator picks the phrasing that matches AppMaker's voice and honesty stance.

New smoke test `tests/smoke/test-start-routes.sh` asserts route does not unconditionally point to non-existent spike (regex check).

## Acceptance criteria

- [x] `start/SKILL.md` macro action table row for "prototype" routes to `\`grill\`` with explicit TODO note about `\`spike\`` status (traces_to: pcrit-006, test: `tests/smoke/test-start-routes.sh` — honest-route + grill-fallback assertions both PASS)
- [x] Replacement phrasing per operator-chosen Option A (`\`grill\` — prototype flow (\`spike\`) TODO/not yet implemented, use grill for exploration`) — graceful fallback + honest about TODO (traces_to: pcrit-006, human-review: operator picked Option A via AskUserQuestion 2026-05-17)
- [x] Output example block in start/SKILL.md uses BUG scenario, not prototype — no prototype-specific output example exists, so no relevant update needed (traces_to: pcrit-006, human-review: verified by inspecting start/SKILL.md output format section)
- [x] Full smoke suite passes via `bash tests/smoke/run-all.sh` — 8 suites, 47/47 PASS (44 pre-existing + 3 new), zero regression (traces_to: pcrit-006, test: `tests/smoke/run-all.sh`)

## Blocked by

None — can start immediately.

## Notes

Phrasing choice surfaced as risk in PRD `## Further Notes`. Operator's review point during TDD step 3 (planning / interface confirmation).

## Review (Self-check + operator decision captured, 2026-05-17)

**Status:** PASS pending operator/Codex sign-off
**AC coverage:** 4/4
**Scope:** diff against `start/SKILL.md` (1 line, macro action table row 39) + `tests/smoke/test-start-routes.sh` (new)

### Operator decision

Per `human_required` classification, operator picked Option A via AskUserQuestion 2026-05-17:
> Route prototype intent to `\`grill\`` with explicit TODO note about `\`spike\`` status. Rationale: graceful fallback + honest about TODO. Matches AppMaker constitution rule 1 (no silent fallbacks) — fallback is loud, not silent.

Alternatives B (refuse, no alternative) and C (route to grill-brownfield) were rejected — B is too restrictive for greenfield users, C is too brownfield-specific.

### Codex-style scoping in test

Test distinguishes:
- `"spike"` in trigger-keyword column (always present, OK)
- `\`spike\`` backtick form in suggestion column (route invocation — drift if without TODO context)

Honest-route assertion uses logical OR: pass if `\`spike\`` absent OR `\`spike\`` with TODO context. Generic enough to accept any operator choice (A/B/C) while catching unconditional spike routes.

### Findings

| Severity | Category | File:Line | Description |
|---|---|---|---|
| (none) | — | — | — |

### Notes

- Glossary: 0 violations
- Memory wiki gotchas: 0 repeated
- **Feature 001-method-compliance-pass-1 ready for archive** after this slice. All 8 pcrit closed: pcrit-001 (slice 001), pcrit-002 (slice 002), pcrit-003+004+007+008 (slice 003), pcrit-005 (slice 004), pcrit-006 (slice 005).
- Candidate for retro / memory wiki seed: **"Operator-decision via AskUserQuestion with previews proved efficient for human_required slices"** — visual preview of each phrasing option made the choice fast.

