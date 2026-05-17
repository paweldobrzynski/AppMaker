# Integration Gotchas Wiki

Durable cross-feature integration insights for AppMaker. Seeded 2026-05-17 from feature 001 retro.

## Cross-slice review catches different errors than per-slice review

Per-slice review (v0.2.15 patch, manual or `/appmaker:review <id>`) catches **LOCAL errors**: test weakness, AC drift, code-quality issues in this slice's diff. Feature-level review catches **CROSS-SLICE COHERENCE**: PRD ↔ decomposition mapping, manifest sync across release artifacts, narrative drift (README/DESIGN reflecting current state), test brittleness across the suite.

**Real example (v0.2.18 dogfood, 2026-05-17):** 6 slices each had per-slice manual review (all PASS). Feature-level review caught: `README.md:19` + `DESIGN.md:3` Status lines still said `v0.2.17` while manifest bumped to `0.2.18`. Slice 003 (doc drift) didn't catch — narrative was correctly current at slice-003 time. Slice 006 (manifest bump) didn't propagate to narrative. **Cross-slice gap by construction.**

**Both gates necessary.** Per-slice alone misses coherence. Feature-level alone misses local detail. Codex's 6-point cross-slice rubric for feature review: (1) PRD pcrit ↔ slice mapping, (2) all done items have review, (3) manifest sync across files, (4) commitability, (5) test brittleness, (6) METHOD.md vs audit consistency.

**Drift class closure pattern:** When cross-slice drift surfaces, fix the instance AND extend a test to close the class. v0.2.18 example: README/DESIGN narrative drift closed by extending `test-version-sot.sh` to assert Status lines reference `$EXPECTED_RELEASE_VERSION`. Future releases automatically caught. Maps to lesson in `wiki/testing.md` (test extension > creation).

**Review form must scale with slice impact:** Subagent review (heavy gate, code-reviewer Agent invocation) was disproportionate for tiny text-only slices in v0.2.18. Lightweight manual/Codex review per-slice + feature-level cross-slice review covered the discipline. For features with logic changes (auth, payment, migrations), subagent per-slice may be right. Operator picks form per scale.

## PRD addendum as honest correction (not failure)

When implementation surfaces a PRD gap (item missing from original scope, foreseen post-decomposition), the Method-disciplined response is **explicit amendment**, not silent backfill.

**Pattern:**
1. Add new `pcrit-NNN` to PRD `## Criticisms` section with note about post-implementation discovery date.
2. Add slice to decomposition with `source: decompose-addendum` label (vs default `decompose`).
3. Update PRD `## Solution` line to reflect new total count (e.g., "9 pcrits: 8 initial + pcrit-NNN addendum").
4. Add Implementation Decisions row.
5. Add Further Notes paragraph explaining the gap + rationale for amendment.
6. Execute the slice with normal TDD discipline.

**Why explicit over silent:**
- Audit chain stays complete — future reader can see "what we missed and when we caught it"
- Amendment timestamp documents the discipline working (gap caught BEFORE archive)
- `source: decompose-addendum` makes the slice's origin queryable

**Real example (v0.2.18, slice 006):** Original PRD had 8 pcrits, all about content changes (Criticisms section, AC test refs, doc drift). Missed plugin manifest version bump — gap surfaced during archive prep when realizing release labeled v0.2.18 still had manifest=0.2.17. Codex endorsed explicit amendment over silent backfill: "release manifest consistency is invariant, not housekeeping". pcrit-009 added; slice 006 executed; archive proceeded cleanly.

**Anti-pattern (avoided):** Silent backfill — bump version during archive step without amending PRD. Future reader sees feature labeled v0.2.18 with 8 pcrits, no traceability for where manifest decision lived. Audit chain breaks.

**When NOT to use addendum:** if gap is COSMETIC (typo, comment fix). Reserve addendum class for real contract changes (new pcrit), not editorial polish caught during review.
