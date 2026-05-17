---
feature: plan-evidence-drift-detection
folder: 002-plan-evidence-drift-detection
release: v0.2.19
created: 2026-05-17
last_updated_by: prd
readiness: ready_with_override
override_reason: Brownfield meta-PRD for plugin's own development. Scope reduced from original draft per Codex feedback — see Further Notes for scope-evolution journey.
source: retro + audit + codex
---

# PRD: Plan / Evidence / Drift Detection (v0.2.19 MVP)

**MVP scope:** capture durable execution record per slice. Answer one question: *does the record help detect drift and resume work after time?* Until 2-3 features prove value, no automation.

## Understanding

### Users / buyers / operators

- **Users:** AppMaker users running `/appmaker:tdd` slice-by-slice. Each slice now produces structured execution record in its backlog item.
- **Buyer:** same. OSS.
- **Operator:** Paweł, future contributors. Plus AppMaker dogfooding the new contract on its own slices.

### Domain invariants

- Plugin self-contained (v0.2.11 SoT).
- METHOD.md = upstream source of intent (v0.2.18 correction).
- SKILL.md bodies trend ≤200 lines; exceptions documented.
- Dogfood location: `dogfood/appmaker/` (v0.2.18 decision).
- Capture-first principle (v0.2.19 MVP): observation precedes automation.

### Identity model

N/A.

### Trust boundaries

- File-system writes via Bash tool.
- Git reads: `git rev-parse HEAD` (base_ref), `git status --short` (dirty detection), `git diff --name-only` (actual files at slice end).
- No external API calls.

### Non-delegable judgments

- METHOD.md changes — operator authority.
- Drift notes content (operator writes, no auto-generation).
- Decision to automate (v0.3+ candidate based on MVP evidence).

### Verifiable success criteria

Every `pcrit-*` has explicit verification mechanism.

### Failure modes / unacceptable outcomes

- **Section becomes write-once, never-read.** Mitigation: validate via 2-3 next-feature usage before justifying automation.
- **Operators skip filling Drift notes when scope changes.** Mitigation: tdd materialization mandatory (not optional); Drift notes default placeholder "- (none)" so absence is visible.
- **Performative artifact** (structured fields filled with garbage). Mitigation: smoke tests assert structural presence; semantic quality is human-review only.
- **Skill logic regression.** Mitigation: smoke suite must pass full v0.2.18 baseline (50/50) plus new pcrit assertions.
- **`base_ref` capture fails in edge case** (detached HEAD, no git, no commits). Mitigation: tdd falls back to `no_base_ref` marker + WARN; documented as known edge case.

## Clarifications

None outstanding. Codex pushed scope reduction (full subsystem → MVP capture-only); accepted.

## Solution

4 pcrits. Single `## Execution Record` section captures intent + outcome + drift notes in one cohesive block. `/appmaker:tdd` materializes initial fields before apply, final fields after verification. Version bump + METHOD.md status update round out the release.

## Criticisms

- **pcrit-001:** Backlog item template (`plugin/appmaker/resources/appmaker/templates/backlog-item-template.md`) adds `## Execution Record` section with 9 structured fields. Section appears between `## Acceptance criteria` and `## Blocked by`. Section format (per Codex):

  ```
  ## Execution Record

  **Base ref:** <sha | no_base_ref>
  **Dirty at start:** yes/no
  **Dirty files at start:**
  - ...

  **Planned files:**
  - ...

  **Planned tests:**
  - ...

  **Actual files:**
  - ...

  **Tests run:**
  - ...

  **AC completed:** <n>/<n>

  **Drift notes:**
  - ...
  ```

  - **Verification:** auto-check via regex on template — `## Execution Record` heading + all 9 bolded field labels present in example block.

- **pcrit-002:** `/appmaker:tdd` materializes `## Execution Record` to backlog item. **Initial fields** (Base ref, Dirty at start, Dirty files at start, Planned files, Planned tests) written AFTER user approves TDD plan in current step 3 (existing AskUserQuestion gate preserved), BEFORE first RED test in step 4. **Final fields** (Actual files from `git diff --name-only` against `base_ref`, including working-tree changes where applicable, minus `dirty_files` that were clearly unrelated; Tests run from suite output; AC completed count) populated in step 9 mark-done, BEFORE mv to `done/`. **Implementation note (deferred to slice 002 TDD):** committed delta = `git diff --name-only "$base_ref"..HEAD`; working-tree delta = `git diff --name-only`; actual files = union minus dirty-at-start; final shape resolved during slice 002 implementation. PRD does not promise `$base_ref..HEAD` alone suffices. **Drift notes** is operator-editable freetext (default placeholder `- (none)`). `base_ref` capture: `$(git rev-parse HEAD 2>/dev/null || echo no_base_ref)`. Dirty detection: `git status --short` — capture files + WARN, never refuse.
  - **Verification:** auto-check via regex on `tdd/SKILL.md` — (a) step writes initial Execution Record between approval gate and first RED, (b) step appends final fields in step 9 before mv to done, (c) uses `git rev-parse HEAD` for base_ref. Plus smoke test on stub backlog covering both write phases.

- **pcrit-003:** Release version bump 0.2.18 → 0.2.19. `plugin.json` + `marketplace.json` + `tests/smoke/test-version-sot.sh` `EXPECTED_RELEASE_VERSION` constant all = `0.2.19`. **In initial PRD scope per v0.2.18 lesson** (avoid addendum class when foreseeable).
  - **Verification:** auto-check via test-version-sot.sh extension — `EXPECTED_RELEASE_VERSION` bumped + plugin.json + marketplace.json values match.

- **pcrit-004:** METHOD.md "Open invariants" #2 (plan-vs-actual drift detection) status update from "v0.3 candidate" to "**MVP under validation in v0.2.19 — capture only, automation deferred pending 2-3 feature evidence**". Honest wording — does NOT claim full drift detection shipped; explicitly flags that review auto-diff + checklist enforcement remain v0.3+ candidates.
  - **Verification:** auto-check via grep on METHOD.md — phrase "MVP under validation" present in plan-vs-actual context; phrase "v0.3 candidate" no longer attached to plan-vs-actual.

## Implementation Decisions

| Decision | Verification | Traces |
|---|---|---|
| **One `## Execution Record` section** (combines what original draft split into Plan / Evidence / Plan-vs-Actual). Cohesive, single block per slice. | auto-check via template regex | pcrit-001 |
| TDD materializes in two phases: initial fields after approval / before RED, final fields in mark-done. **No new approval gate** — preserves existing TDD step 3 user-approval flow. | auto-check on skill body + human-review of behavior | pcrit-002 |
| `base_ref` capture with graceful fallback (`|| echo no_base_ref`). Dirty worktree → capture + WARN, never refuse. | human-review of edge case handling | pcrit-002 |
| **Operator writes Drift notes manually.** No auto-classification. Capture-only philosophy. | N/A (human-only content) | pcrit-002 |
| Version bump in initial PRD scope (v0.2.18 lesson). | auto-check via test-version-sot | pcrit-003 |
| METHOD.md status update — honest "MVP under validation", not "implemented". | grep | pcrit-004 |

## Testing Decisions

- **Test patterns:** scoped regex per pcrit (v0.2.18 lesson). Test-from-failure-mode (e.g., assert section missing fails). Extension > creation (`test-version-sot.sh` extended, not new).
- **Modules tested:** tdd skill (materialization steps with ordering), backlog template (section structure).
- **Smoke tests planned:**
  - `tests/smoke/test-backlog-execution-record.sh` — new file, pcrit-001 structural assertions
  - `tests/smoke/test-tdd-execution-record.sh` — new file, pcrit-002 skill body ordering + materialization presence
  - `tests/smoke/test-version-sot.sh` — **extend** (not new), pcrit-003 release-target

## Existing System Context

- Plugin v0.2.18 shipped (commit `33568a3` on `main`, pushed to remote `15fd4bf..33568a3`).
- 8 smoke suites / 50 assertions baseline.
- METHOD.md "Open invariants" #2 lists plan-vs-actual drift detection as v0.3 candidate.
- v0.2.18 retro lessons in `dogfood/appmaker/memory/` — informs this PRD's discipline.
- Audit `audits/2026-05-17-method-vs-plugin.md` identified plan.md as missing primitive (HIGH gap). v0.2.19 MVP partially addresses (capture phase); automation phase deferred.

## Out of Scope

| Deferred to | What |
|---|---|
| **v0.3+ candidate (evidence-driven, MVP must validate first)** | `/appmaker:review` auto-generated diff between Planned and Actual. `/appmaker:checklist` enforcement (FAIL on missing Execution Record). Hard FAIL rules for any drift. Classification logic (WARN cases). Semantic drift detection (beyond file/test-name). `features/NNN/slices/NN/` subfolder migration (slice-as-primary-unit). |
| **vNext (lower priority)** | Test name auto-extraction from source code (cross-language brittleness — JS/TS/Python/shell). Production code → AC inline linkage enforcement. Aviation metaphor framework. |
| **NOT scope** | Refactor of `/appmaker:tdd` or `/appmaker:review` beyond minimum needed for Execution Record materialization. Marker-based grandfathering (e.g., `artifact_contract`) — only needed when checklist enforcement ships. |

## Further Notes

- **Scope-evolution journey (operator-relayed Codex review):** Original v0.2.19 PRD draft attempted full drift detection subsystem (8 pcrits, 6 slices): Plan + Evidence + Plan-vs-Actual sections separately + TDD writes Plan + Review auto-classification (4 cases: planned-not-actual, actual-not-planned, planned-test-no-match, allowed-with-reason) + Checklist FAIL enforcement + `artifact_contract` marker + grandfathering. Codex pushed back: *"produkt w produkcie"* — too much surface for first iteration. Reduced to MVP: **single Execution Record section, captured by TDD only, no review/checklist automation, no marker, no classification**. Philosophy: capture first, automate later. 2-3 features using the section will reveal whether automation justified.

- **MVP validation criteria (what we're watching for):**
  - Does the section get filled in real slices, or skipped/forgotten?
  - Do operators (or future-Paweł reading old slices) actually use Base ref + Drift notes when resuming work?
  - Does cross-feature review surface drift through manual reading of these sections?
  - If yes → v0.3 ships review auto-diff + checklist enforcement.
  - If no → simplify or remove the section. Capture-only wasn't the right shape.

- **Self-applying meta-test:** slice 001 ships template change; slice 002 implements TDD materialization. Slices 002+ in this very feature will be the FIRST instances using the new template. If slice 002's backlog item has Execution Record filled honestly, that's the first dogfood evidence.

- **Pattern reuse from v0.2.18 retro (`dogfood/appmaker/memory/wiki/`):**
  - Scoped regex per test (anchor visual context).
  - Test from failure mode (assert section structure violation fails).
  - Test extension > creation (`test-version-sot.sh` for pcrit-003).
  - `source:` frontmatter label (`source: retro + audit + codex` makes origin queryable).

- **Risk: section feels bureaucratic on tiny slices.** Mitigation: section is mechanical to fill (9 fields, most auto-populated by tdd). Operator only writes Drift notes when slice actually deviates from plan — otherwise placeholder `- (none)` is honest signal. If even mechanical population feels heavy, that's evidence the section is wrong shape — surface in retro.

- **Honest framing for METHOD.md update (pcrit-004):** Method "Open invariants" #2 was "drift detection = v0.3 candidate". v0.2.19 MVP doesn't make it "implemented" — only "MVP under validation". This matters: future reader of METHOD.md should NOT think AppMaker has full drift detection. We have capture; automation is still candidate.

- **4-pcrit PRD size:** smallest meaningful release. Each pcrit independently verifiable. Decomposition produces 4 slices (one per pcrit; pcrit-001 + pcrit-002 are template + skill respectively, not bundled). No addendum pattern foreseen.
