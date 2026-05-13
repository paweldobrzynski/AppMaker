# Project Strategy Notes

Status: REFERENCE
Created: 2026-05-10
Purpose: Preserve strategic project-level feedback without changing current
work_unit scope, gates, or accepted ADRs.

This file is not an ADR, not a mandate, and not an implementation plan. A note
becomes actionable only when a dedicated work_unit or ADR accepts it.

## 2026-05-10 — Advisor Feedback: Avoid A Fortress Without A City

Source: external advisor feedback shared by Paweł, plus local sanity check of
current AppMaker artifacts.

Summary: AppMaker is architecturally promising as a process kernel / harness for
disciplining AI agents, but it is currently at risk of becoming a self-hosted
governance system whose only real client is itself.

What is strong:

- The direction is serious: treating agent drift, context decay, and disappearing
  decisions as engineering problems rather than prompt problems.
- The `harness > model` thesis is sound: models will change; durable gates,
  schemas, logs, and review loops retain value.
- `R12` no silent fallbacks and `R5` fail-closed are load-bearing rules.
- Append-only audit, `PROMOTED_WITH_EXCEPTION`, adapter boundaries, and the
  constitution rule cap are healthy design constraints.
- Self-hosting has value during bootstrap because it exposes contradictions in
  the system's own governance.

Main risks:

- Meta-weight is high. Work_units and context-packs are already ceremony-heavy
  before the system has a real non-meta consumer.
- Real usage is missing. No real PRD has been decomposed for an external project
  yet, so several schemas and gates are still based on expected use rather than
  observed use.
- Enforcement is still mostly manual. ADRs, schemas, and constitution exist, but
  the minimal CLI/kernel that actually rejects invalid promote paths does not.
- Lessons currently come mostly from AppMaker building AppMaker. That is useful
  for bootstrap but becomes unhealthy if it remains the dominant learning source.
- Codex/external critic is de facto part of quality control. If self-check keeps
  missing important contradictions, external review should be acknowledged as
  architecture, not treated as incidental help.

Local sanity check on 2026-05-10:

- ADR-001 through ADR-004 exist.
- `WU-002` through `WU-006` are promoted.
- `WU-007` is accepted, with ADR-005 execution not yet complete.
- `.appmaker/lessons.jsonl` has 19 entries and `.appmaker/events.jsonl` has 12
  entries.
- No minimal `appmaker` CLI/source kernel was found in the local tree during the
  check.

Recommended strategic constraint:

After WU-007 / ADR-005, avoid starting ADR-006 / ADR-007 / ADR-008 / ADR-009 as
more meta-design by default. First force contact with reality through one of:

- **Minimal AppMaker CLI Gate**: a small implementation WU that makes
  `appmaker validate`, `appmaker status`, and `appmaker promote --dry-run`
  actually read schemas/logs/artifacts and fail closed.
- **Pilot On Real Project**: use AppMaker on a real project such as ClaimCompass
  or `mgc-web` through Interview -> PRD -> Decomposition and capture lessons from
  that external use.

Preferred sequence: finish WU-007 / ADR-005, build the minimal CLI gate, then run
the real-project pilot. Future lessons should increasingly come from using
AppMaker on non-AppMaker projects.

## 2026-05-10 — Advisor Feedback: Governance Must Scale Down

Source: external advisor feedback shared by Paweł, plus Codex synthesis.

Summary: AppMaker's governance model is strong for significant agentic work, but
may become too rigid, dogmatic, and unpleasant for everyday developer tasks if it
does not scale down to small changes and system repair.

Main risks:

- **Ceremony overload.** Mandatory Interview, ADRs with killed alternatives, rich
  work_units, and fail-closed gates are appropriate for significant product or
  architecture work, but may be excessive for typo fixes, tiny database changes,
  and low-risk patches.
- **System repair catch-22.** If the kernel, validator, or promote gate breaks,
  AppMaker may be unable to repair itself through the normal path. Overuse of
  break-glass would eventually weaken discipline unless it is treated as an
  audited maintenance lane.
- **False safety from tests.** A passing command proves that a check passed, not
  that the change is correct. Agents can break untested business logic or weaken
  tests unless gates distinguish exit-code evidence from product correctness.
- **Loss of big picture.** Small context-packs reduce context bloat, but overly
  narrow context can produce locally correct changes that violate broader
  architecture, domain invariants, or accepted ADR constraints.
- **Constitution cap pressure.** R17's 25-rule cap is healthy, but reaching 18
  rules during bootstrap is a warning. Without a placement policy, future teams
  may cram multiple principles into one rule or weaken the cap.

Implications:

- AppMaker needs work-size lanes, not one ceremony level for all changes:
  `micro_change`, `normal_implementation`, `architecture_or_significant_change`,
  and `emergency_system_repair`.
- Break-glass should be an official maintenance path: explicit reason, narrow
  scope, event log entry, mandatory follow-up retro, and system fix if the normal
  path was blocked by AppMaker itself.
- Verification gates should record evidence class: test pass, test-diff,
  invariant check, coverage impact, screenshot/browser evidence, and human
  product judgment. Exit code `0` is necessary evidence, not sufficient proof.
- Context strategy should be layered: local files plus relevant ADR constraints,
  domain glossary, architecture invariants, and graph/index references where
  needed. Avoid both full repo dumps and blind micro-context.
- The constitution should stay reserved for constitutional rules. Operational
  guidance belongs in ADRs, hooks, schemas, standards packs, rulefiles, or future
  context-pack schema work.

Recommended strategic constraint:

Before AppMaker is used broadly, define an ergonomics layer that lets governance
scale down as well as up. A practical target is a minimal patch lane with small
but nonzero audit, plus a maintenance lane for fixing AppMaker itself without
normal-gate deadlock.

## 2026-05-10 — Advisor Feedback: Stop Meta Bootstrap And Build Enforcement

Source: external advisor feedback shared by Pawel, plus Codex synthesis.

Summary: AppMaker should stop adding meta-process ADRs after ADR-005 until it
has been used on a real non-AppMaker project and until at least a minimal CLI
actually enforces the rules that the constitution currently describes.

Priority changes proposed:

1. **Moratorium on new meta ADRs.** Do not start ADR-006, ADR-007, ADR-008, or
   ADR-009 as more self-bootstrap by default. First run AppMaker on a real
   project such as ClaimCompass or `mgc-web`: Interview Phase, real `prd.md`,
   decomposition into 3-5 work_units, and implementation of at least one slice.
2. **Minimal CLI before more theory.** Build a small `appmaker` CLI now instead
   of waiting for another architecture ADR. Minimum useful commands:
   `appmaker promote <wu-id>`, `appmaker validate <file>`,
   `appmaker context compile <wu-id>`, and `appmaker log append <stream>`.
3. **Be honest about enforcement.** If R4, R5, R7, and R8 are marked
   `auto-check`, they need working tooling. Until then, either implement the
   checks or downgrade the hook classification to cultural/manual.
4. **Shrink ceremony.** Replace verbose `lessons_applied` prose with a compact
   shape such as `{source, influence_class, one_line}`. Move large YAML header
   comments into structured fields. Add ADR size budgets: soft cap around 12k
   characters and hard cap around 20k characters, with explicit exception path.
5. **Turn critic behavior into verification discipline.** Do not make Codex a
   constitutional dependency. Instead, encode the behaviors that caught real
   errors: active pairwise decision diff, line-by-line wording scan, and
   cross-artifact field checks.
6. **Classify lessons by signal source.** Add `lesson_class: meta | domain |
   infra`. Today the stream is mostly `meta`; healthy AppMaker adoption should
   drive `meta` below 30 percent over time as real project and tooling lessons
   appear.
7. **Clean up declared-but-missing base artifacts.** ADR-001 references
   `north-star.md`, `appmaker.config.yaml`, and `.appmaker/profile.yaml`; either
   create minimal dogfood versions or explicitly defer/remove them from the v1
   model. Also grep casing consistency for `promoted_with_exception` vs
   `PROMOTED_WITH_EXCEPTION`.

Preferred next sequence:

1. Keep ADR-005 promoted as the end of bootstrap governance design.
2. Record a temporary moratorium on new meta-process ADRs.
3. Build the minimal CLI gate.
4. Run a real-project pilot.
5. Let the pilot determine whether the next accepted work should be strictness
   lanes, repo map, critic gate, schema cleanup, or implementation runner.

Constitution candidate, not yet accepted:

> After bootstrap, every new architecture ADR must cite a concrete trigger:
> real-project work_unit, failed gate, production incident, tooling gap, or
> repeated lesson pattern. Bootstrap-only ADRs are exhausted by ADR-001 through
> ADR-005.

This should not be added directly as R19 without a dedicated amendment WU. It is
parked here as a strategic candidate because adding more constitutional rules is
itself part of the risk being flagged.

## 2026-05-10 — Product Direction: Minimal Friendly Interface

Source: Paweł product direction during CLI discussion, synthesized by Codex.

Summary: AppMaker's public interface must be simple and intuitive. Internal
kernel artifacts such as `work-unit.yaml`, `context-pack.md`, `verification.log`,
schemas, and JSONL streams are implementation details. Users should not need to
copy context into an agent manually or understand AppMaker governance to get
work done.

Public UX principle:

- The primary command should express user intent, not kernel mechanics:
  `appmaker start "Dodaj eksport faktur do CSV"`.
- The system should classify the work, ask only necessary clarifying questions,
  generate the work_unit/context internally, run or prepare the configured agent,
  collect verification, and present a short result.
- Debug/admin primitives such as `validate`, `context compile`, `log append`, and
  `promote --dry-run` may exist, but they are not the main product workflow.
- Manual copy-paste of context-pack content is acceptable only as a debug
  fallback for v0, not as the intended user experience.

Minimal friendly command set candidate:

- `appmaker start "<request>"` — guided intake, classification, clarification,
  work_unit creation, context compilation, and agent handoff/run.
- `appmaker status` — show active work, blocked work, verification state, and
  required human actions.
- `appmaker review <wu-id>` — show changed files, acceptance criteria,
  verification evidence, critic findings, and unresolved risks.
- `appmaker approve <wu-id>` — human approval for work that passed checks but
  touches human-owned judgment or risk surfaces.

Design constraint:

The first CLI implementation should still expose the kernel primitives needed
for enforcement, but the product-facing happy path should be designed around
`start/status/review/approve`. Otherwise AppMaker risks becoming a tool for
people who enjoy AppMaker's process rather than people who want to ship a
project reliably.
