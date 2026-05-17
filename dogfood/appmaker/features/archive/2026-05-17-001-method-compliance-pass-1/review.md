---
feature: 001-method-compliance-pass-1
created: 2026-05-17
scope: feature
status: PASS (after pre-archive fixes)
reviewer: Manual cross-slice (Claude + Codex 6-point review rubric)
ac_coverage: 9/9 pcrit closed across 6 slices
---

# Feature Review: 001-method-compliance-pass-1 (v0.2.18 release)

Cross-slice coherence audit. Per-slice reviews already captured local concerns (in each `dogfood/appmaker/backlog/done/*-00N-*.md ## Review` section). This review checks **integration across slices**: release artifacts consistent, drift between layers (PRD → docs → manifest → tests) absent.

## Codex 6-point rubric

| # | Check | Initial | Final | Evidence |
|---|---|---|---|---|
| 1 | PRD 9 pcrit ↔ decomp 6 slice mapping | ✓ | ✓ | 9 pcrit list items (PRD lines 79, 82, 85, 88, 91, 94, 97, 100, 103); coverage table in decomposition maps all 9 → 6 slices, no orphans. False alarm earlier (10 vs 9) was regex artifact catching meta-mention in `## Further Notes` line 153, not real pcrit. |
| 2 | All 6 done backlog items have `## Review` section | ✓ | ✓ | grep verified: 1+ `## Review` heading in each of 6 `dogfood/appmaker/backlog/done/2026-05-17-00N-*.md` |
| 3 | Manifest 0.2.18 sync across release artifacts | **FAIL** | ✓ | plugin.json + marketplace.json + test EXPECTED_RELEASE_VERSION all `0.2.18` ✓. **DRIFT caught:** README:19 + DESIGN:3 Status lines still said `v0.2.17` — slice 003 was correctly current at that time, slice 006 didn't propagate to narrative. Fix below. |
| 4 | dogfood/ tree commitable (escapes .gitignore) | ✓ | ✓ | `git check-ignore -v dogfood/appmaker` returns "not ignored". `.gitignore` line 31 anchors `/appmaker/` to repo root only, not `dogfood/appmaker/`. |
| 5 | New tests not brittle or over-broad | ✓ | ✓ | All 5 new test files use Codex-scoped regex patterns: slice 001 strengthened post-finding (list item, not prose); slice 003+004 use layout-anchor `← X dirs` + EOL-anchor `→ X.Y.Z$`; slice 005 distinguishes backtick `\`spike\`` route from quoted `"spike"` keyword. |
| 6 | METHOD.md correction consistent with audit | ✓ | ✓ | METHOD.md "PRD upstream, never rollup of slices" + layout note. Audit's 3 HIGH gaps stand as intentional v0.3 deferrals (slice-as-primary-unit, plan.md, drift detection). No contradiction. |

## Findings

| Severity | Category | File:Line | Description | Status |
|---|---|---|---|---|
| HIGH | cross-slice drift | `README.md:19`, `DESIGN.md:3` | Status narrative says `v0.2.17` while manifest = `0.2.18`. Per-slice reviews didn't catch — slice 003 (doc drift) correctly addressed slice-003-era drift; slice 006 (version bump) didn't propagate from manifest to narrative. | **FIXED (this review)** |

## Fixes applied during review

### Fix 1: README.md:19 Status narrative

Before: `**Status:** v0.2.17. 19 skills... Memory wiki linting + memory/raw/...`
After: `**Status:** v0.2.18. 19 skills... **First dogfood feature** — Method applied to AppMaker itself via dogfood/appmaker/. Release brings: PRD ## Criticisms section..., backlog AC inline test:/human-review: refs, doc drift cleanup..., spike route honesty, release version bump (pcrit-009 addendum). 8 smoke test suites, 50 assertions.`

### Fix 2: DESIGN.md:3-4 Status + Last updated

Before: `Status: ... v0.2.17 — memory wiki linting + memory/raw/ lifecycle.` + `Last updated: 2026-05-14.`
After: `Status: ... v0.2.18 — first dogfood feature (Method applied to AppMaker itself, dogfood/appmaker/). PRD ## Criticisms section, backlog AC inline test:/human-review: refs, doc drift cleanup, /appmaker:start spike route fix, release version bump (pcrit-009 addendum). 8 smoke suites, 50 assertions.` + `Last updated: 2026-05-17.`

### Fix 3: Test extension closes drift class

`tests/smoke/test-version-sot.sh` extended with 2 new assertions:
- `README Status narrative references release target` — grep for `**Status:** v$EXPECTED_RELEASE_VERSION`
- `DESIGN Status narrative references release target` — grep for `v$EXPECTED_RELEASE_VERSION ` (space-anchored)

Future releases now catch narrative drift automatically: bump `EXPECTED_RELEASE_VERSION` in test → RED until README+DESIGN narratives updated. Closes the cross-slice drift class permanently.

**Re-verified post-fix:** test-version-sot 8/8 PASS (was 6/6 + 2 RED); full suite 8 suites, 50/50 assertions PASS, zero regression.

## Lessons (not findings — operator observations for retro)

- **Cross-slice drift class fundamentally different from local class.** Per-slice reviews (v0.2.15 patch + manual Codex-style) caught LOCAL test/AC weakness. Cross-slice drift required a separate gate (feature-level review). Both layers necessary; neither alone sufficient. Validates Codex framing.
- **Test extension as drift-class closure.** Instead of fixing drift once and leaving it as recurring failure mode, extending existing test (test-version-sot.sh) closes the class. Single addition becomes the regression sentinel for all future releases. Mapping: drift discovery → fix instance → test the rule (not just the instance).
- **Bump checklist now 3 places.** plugin.json (canonical), marketplace.json (mirror), test-version-sot.sh `EXPECTED_RELEASE_VERSION` (release-target sentinel). Plus README:19 + DESIGN:3 narratives must mention the version (asserted by extended test). Net: bump operation per release = 3 file edits + narrative refresh.

## Notes

- Glossary: 0 violations.
- Memory wiki gotchas: 0 repeated.
- AC coverage: 9/9 PRD pcrit closed (8 initial + pcrit-009 addendum). Each maps to a slice (decomposition coverage table verified). Each slice has its `## Review` in backlog/done/.
- **Optional next step:** invoke `/appmaker:review feature 001-method-compliance-pass-1 --mode=local` to layer code-reviewer subagent on top of this manual review. Decision: skip for v0.2.18 (text-level changes, no logic; manual review surfaced the cross-slice gap that mattered). Operator decision; current review status PASS pending operator sign-off.
- **Ready for retro + archive** after operator approves this review.
