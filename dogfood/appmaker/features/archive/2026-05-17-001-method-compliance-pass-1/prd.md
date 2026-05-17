---
feature: method-compliance-pass-1
folder: 001-method-compliance-pass-1
release: v0.2.18
created: 2026-05-17
last_updated_by: prd
readiness: ready_with_override
override_reason: Brownfield meta-PRD for plugin's own development. No /appmaker:interview phase needed — scope derived from audits/2026-05-17-method-vs-plugin.md.
source: audit
---

# PRD: Method Compliance Pass 1 (v0.2.18)

## Understanding

### Users / buyers / operators

- **Users:** AppMaker users (devs adopting the plugin for their projects). They consume PRDs produced by `/appmaker:prd` and downstream artifacts.
- **Buyer:** same. AppMaker is OSS — no separate purchaser.
- **Operator:** Paweł Dobrzyński (author, maintainer). Future contributors potentially.

Meta-context: this PRD is itself an AppMaker artifact. The plugin's first dogfood — AppMaker about AppMaker, using AppMaker's own newly-corrected Method.

### Domain invariants

- Plugin must remain **self-contained** (resources packaged, no manual `cp -r` for users).
- **Method as upstream source of intent** — plugin tracks Method, not vice versa (per METHOD.md correction 2026-05-17).
- SKILL.md bodies trend under 200 lines for reliable Claude recall (per memory `feedback-skill-size`). Existing exceptions: `init` (375), `status` (245), `review` (238), `tdd` (233), `token-audit` (200) — orchestration/safety code justifies. New or actively-touched skills aim for budget; growth in already-large skills needs justification.
- Caveman style mandatory for SKILL.md (per memory `feedback-caveman-style`).
- All side-effect skills have `disable-model-invocation: true` (v0.2.9 audit invariant).
- Version single source of truth: `plugin/appmaker/.claude-plugin/plugin.json` (v0.2.11 SoT).

### Identity model

N/A. AppMaker plugin source dev has no authentication / identity flow.

### Trust boundaries

- File-system writes by Claude (via Bash tool) — Claude Code permissions manage.
- No external API calls in this release. Pure text edits + new template sections.

### Non-delegable judgments

- METHOD.md changes (design authority is operator's).
- Constitution rule additions (project-level inviolable).
- Architecture decisions affecting v0.3 trajectory (e.g., committing to slice-as-primary-unit).

All other changes in this release = `autonomous` (text edits with deterministic verification).

### Verifiable success criteria

Every `pcrit-*` below has explicit verification mechanism (auto-check OR human-review-with-criteria). No vague goals.

### Failure modes / unacceptable outcomes

- **Regression:** existing plugin skills break (e.g., PRD template change confuses `/appmaker:decompose` reading the PRD).
- **Documentation lying:** README claims state plugin doesn't have.
- **Drift introduction:** new fields (`test:` per AC) without downstream skill awareness create stub data.
- **Self-test failure:** if THIS PRD doesn't satisfy its own pcrit-001 contract, Method correction was wrong.

## Clarifications

None outstanding. All decisions resolved during audit + Codex consultation 2026-05-17.

Per Method `## Clarifications` slot retained; `/appmaker:clarify` may populate if ambiguity surfaces during decompose/TDD.

## Problem Statement

Audit `audits/2026-05-17-method-vs-plugin.md` identified 9 gaps between plugin v0.2.17 and METHOD.md. v0.2.18 closes the **lowest-cost subset**: 2 MEDIUM (independent of slice-as-primary-unit architecture decision) + 6 LOW (documentation drift bugs). Defers HIGH cluster (slice consolidation) to v0.2.19+ pending plan.md / evidence.md evidence-gathering.

Plus one meta-criticism: AppMaker has never used itself. This PRD is the first dogfood instance.

## Solution

9 numbered `pcrit-*` items (Method contract): 8 initial + pcrit-009 addendum (release version bump, surfaced post-implementation 2026-05-17 — see Further Notes). Each is one tight statement of what the change must do. Verification mechanism per item.

## Criticisms

- **pcrit-001:** PRD template (`plugin/appmaker/skills/prd/SKILL.md`) emits explicit `## Criticisms` section with stable `pcrit-NNN` numbered list. **Self-referential:** this very document is the first instance — its existence with proper formatting demonstrates the change works for AppMaker itself.
  - **Verification:** auto-check via `rg '^## Criticisms' <prd-path>` AND `rg -c '^\s*-\s+\*\*pcrit-[0-9]+:\*\*' <prd-path>` > 0.

- **pcrit-002:** Backlog item template (`plugin/appmaker/resources/appmaker/templates/backlog-item-template.md`) AC checkbox format supports inline `test:` reference per AC. New schema: `- [ ] <description> (traces_to: pcrit-NNN, test: <test_file>::<test_name>)`. Test reference optional in template (added when AC has corresponding test), but format reserved.
  - **Verification:** auto-check via `rg 'test:\s*<test_file>::<test_name>' backlog-item-template.md` (placeholder in example).

- **pcrit-003:** `README.md` skill count reflects current state. Current text "18 dirs" is stale (real count is 19 after `next/` skill added v0.2.13).
  - **Verification:** auto-check via `rg '19 dirs' README.md` returns 1+ match AND `rg '18 dirs' README.md` returns 0.

- **pcrit-004:** `DESIGN.md` skill count reflects current state. Same shape as pcrit-003.
  - **Verification:** auto-check via `rg '19 dirs' DESIGN.md` returns 1+ match AND `rg '18 dirs' DESIGN.md` returns 0.

- **pcrit-005:** `plugin/appmaker/skills/init/SKILL.md` upgrade example uses placeholder or generic format, not hardcoded versions. Current "Upgrade: 0.1.1 → 0.2.11" violates v0.2.11 single-source-of-truth (version must be runtime-read from plugin.json).
  - **Verification:** auto-check via `rg 'Upgrade:\s+\d+\.\d+\.\d+\s+→\s+\d+\.\d+\.\d+' init/SKILL.md` returns 0; replacement uses `<previous>` / `<current>` or `${OLD_VERSION}` / `${PLUGIN_VERSION}` placeholders.

- **pcrit-006:** `plugin/appmaker/skills/start/SKILL.md` does not route to non-existent `/appmaker:spike`. Current row routes `prototype` category to `/appmaker:spike` which is TODO per README ("4 opt-in skills, all TODO"). Honest behavior: refuse + suggest `/appmaker:grill` with note that prototype flow is unimplemented.
  - **Verification:** auto-check via `rg 'spike' start/SKILL.md` — if mentioned, must be in context "TODO" or "not implemented yet" (manual review of matches).

- **pcrit-007:** `DESIGN.md` `.appmaker-version` example references avoid stale literal versions. Current decision 33 v0.2.6 sub-point references "0.2.7" in a status example; init/SKILL.md output section line ~338 hardcodes "0.2.11".
  - **Verification:** auto-check via `rg '0\.2\.(7|9|11)' DESIGN.md` — any matches in example/output blocks → replace with `<version>` placeholder. Real version references in decision-history numbering ("v0.2.11") remain — they are historical labels not stale examples.

- **pcrit-008:** README "skills written" sentences reflect current count. Current line ~65 "15 written" + line ~137 "← 18 dirs" + line ~199 "Plus a previous skill-format refactor" — ensure consistency: 15 core skills + 4 supporting (`afk`, `status`, `token-audit`, `next`) = 19 total dirs in `plugin/appmaker/skills/`.
  - **Verification:** auto-check via line count consistency: `rg '15 (written|skills written|core)' README.md` returns ≤1; explicit "19 skills (15 core + 4 supporting: afk, status, token-audit, next)" sentence present.

- **pcrit-009 (addendum 2026-05-17):** Plugin manifest reports release version `0.2.18`. Both `plugin/appmaker/.claude-plugin/plugin.json` `version` field AND `.claude-plugin/marketplace.json` `metadata.version` field equal `"0.2.18"` for this release. Manifest is single source of truth (v0.2.11 SoT decision); semantic consistency between release name and manifest is a release invariant — feature labeled v0.2.18 cannot ship while manifest reports 0.2.17. Gap surfaced post-implementation during archive prep; PRD amended explicitly rather than silent patch.
  - **Verification:** auto-check via extension of `tests/smoke/test-version-sot.sh` — adds release-target assertion `PLUGIN_VERSION == "0.2.18"` alongside existing equality check between plugin.json and marketplace.json.

## Implementation Decisions

| Decision | Verification | Traces |
|---|---|---|
| Extend PRD template in `prd/SKILL.md` with `## Criticisms` block + numbered `pcrit-NNN` convention. Add to ## Process step 4 template body. | auto-check (regex on template) | pcrit-001 |
| Extend `backlog-item-template.md` AC format with optional inline `test:` field. Document in field semantics table. | auto-check (regex on template) | pcrit-002 |
| Update README/DESIGN/init markdown via Edit tool. Pure text changes — no logic. | auto-check (regex on artifact) | pcrit-003 through pcrit-008 |
| `/appmaker:start` spike route: replace with "TODO — prototype flow not implemented yet. Use `/appmaker:grill` for now." | auto-check + human read | pcrit-006 |
| Do NOT add Plan / Evidence / Plan-vs-Actual sections to backlog template. **Defer to v0.2.19.** | scope discipline | (out of scope) |
| Do NOT migrate slice content to `features/NNN/slices/NN/` subfolder. **Defer to v0.3+ candidate, evidence-driven.** | scope discipline | (out of scope) |
| Bump `plugin/appmaker/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` version 0.2.17 → 0.2.18. Extend `tests/smoke/test-version-sot.sh` with release-target assertion. | auto-check (jq) | pcrit-009 |

## Testing Decisions

- **What makes a good test:** deterministic `rg` / `grep` / file existence check on artifact files. No LLM judgment in verification.
- **Modules being tested:** none. v0.2.18 is text-level changes only — no module logic, no behavioral tests.
- **Prior art:** existing `tests/smoke/test-version-sot.sh` (version SoT), `tests/smoke/test-glossary-extract.sh` (hook), `tests/smoke/test-hook.sh` (session-start). v0.2.18 may add `tests/smoke/test-prd-criticisms.sh` and `tests/smoke/test-doc-drift.sh`.

## Existing System Context

- **Plugin version at start:** v0.2.17 (per `plugin/appmaker/.claude-plugin/plugin.json`).
- **AppMaker repo dogfood state:** none prior to v0.2.18. This PRD is the first artifact in `appmaker/features/`. No `appmaker/init` was run; only `appmaker/features/<NNN>/` materialized manually because plugin source duplicating its own `resources/` templates creates drift surface.
- **Test harness:** `tests/smoke/` — bash, 22 assertions, ./run-all.sh entry point. v0.2.18 work may extend harness.
- **Affected skills:** `prd/SKILL.md` (template change), `start/SKILL.md` (route fix), `init/SKILL.md` (example fix). No skill logic changes.
- **Affected templates:** `backlog-item-template.md` (AC format extension).
- **Affected docs:** `README.md`, `DESIGN.md`.

## Out of Scope

| Deferred to | What |
|---|---|
| **v0.2.19** | `## Plan`, `## Evidence`, `## Plan vs Actual` sections in backlog item. `base_ref` capture at slice start. `/appmaker:tdd` writes Plan before apply. `/appmaker:review` auto-generates Plan-vs-Actual diff. |
| **v0.3 candidate (evidence-driven)** | Slice-as-primary-unit (`features/NNN/slices/NN/` subfolder). Trigger: v0.2.19 sections grow > 300 lines per backlog item OR multi-slice plan coordination need surfaces. |
| **vNext (low priority)** | Production code → AC linkage enforcement (audit L2). Aviation metaphor framework (audit deferred). |

## Further Notes

- **Self-applying meta-test:** pcrit-001 is the change that introduces explicit `## Criticisms` sections to PRDs. This document, by having a `## Criticisms` section with `pcrit-NNN` numbered list, IS the first instance demonstrating the change works. If I could write this document under the corrected Method, Method is real. If I struggled — Method has gaps to surface.

- **Brownfield AppMaker on itself:** plugin source repo is brownfield from AppMaker's perspective (existing code, no prior AppMaker discipline). Minimum dogfood is artifact discipline (this PRD); full operational dogfood (session-start hook, glossary extraction, etc.) deferred — duplicating plugin's own `resources/` into materialized `appmaker/` creates dual source of truth.

- **Method correction lineage:** Direct cause of this PRD is METHOD.md edit 2026-05-17 (PRD upstream / slice layout note). Without that correction, this PRD would have proposed slice subfolder migration AND been internally inconsistent (PRD-as-rollup error). Audit + Codex consultation surfaced the error before commit.

- **9-item PRD size (8 initial + pcrit-009 addendum):** Original intentional cap was 8. pcrit-009 added 2026-05-17 post-implementation when archive prep surfaced version-bump gap. Each pcrit independently verifiable. Decomposition produced 6 vertical slices total.

- **Risk:** pcrit-006 (start spike route) requires human judgment on phrasing ("TODO not implemented yet" vs "use `/appmaker:grill`"). Surface for review in TDD step. *(Resolved 2026-05-17: operator picked Option A via AskUserQuestion — route to `\`grill\`` with TODO note.)*

- **pcrit-009 addendum dogfood lesson:** PRD addendum after implementation is **honest correction, not failure**. The Method-disciplined alternative would have been silent backfill (just bump version during archive without amending PRD). Choosing explicit amendment preserves audit chain — the gap is discoverable from PRD, not invisible. Worth durable memory at retro: *"PRD addendums catch post-implementation gaps without breaking traceability."*
