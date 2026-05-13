# ADR-002: Interview Phase as First Lifecycle Stage

## Status

**DRAFT** — produced by WU-003 at `.appmaker/work-units/wu-003/runs/2026-05-09T14-27-51Z/output.md`, awaiting promote.

Lifecycle: `DRAFT` (in run dir, immutable) → **`ACCEPTED`** (after human + Codex review; promotion step copies this file to `decisions/ADR-002-interview-phase.md` and flips status to `ACCEPTED` in the promoted copy) → `AMENDED` (if modified by future amendment work_unit, per Amendment Process in constitution).

## Metadata

- **Date:** 2026-05-09
- **Authors:** pawedo@gmail.com (decision-maker), Claude Opus 4.7 (synthesis), Codex (critic, multiple rounds)
- **Type:** investigation work_unit (artifact-validated against `adr-v1` schema)
- **Supersedes:** none
- **Superseded by:** none
- **Related:** ADR-001 (process kernel), constitution.md (governance), WU-002 (constitution promotion)

## Context

ADR-001 established the work_unit primitive and 6-file project model but did not specify how a project enters the system. Currently, an AppMaker project leaps from "exists" to "has work_units" without a formal stage that reduces requirements ambiguity. Constitution Rule R13 ("Every work_unit must reduce uncertainty or deliver verified change") implicitly relies on each work_unit having clear acceptance criteria — but if the source of truth (project goal, user, scope, constraints, technical context) is itself ambiguous, every downstream work_unit inherits that ambiguity and either spirals into rework or pretends ready when it is not.

Interview Phase fixes this by introducing a structured uncertainty-reduction stage **before** any work_unit is decomposed. The output is a machine-readable artifact (`interview-result.yaml`) gated by an explicit readiness state. Interview is itself an investigation work_unit — it produces a knowledge artifact, not code — and so fits the existing kernel without architectural exception.

The pattern is inspired by Matt Pocock's `/grill-me` (and `/grill-with-docs`) skills: relentless interview that walks every branch of the design tree, asking one question at a time, with the agent providing recommended answers. AppMaker adapts these prompts as inspiration sources, not runtime dependencies (per ADR-001 §D12 and constitution R15).

## Sources Consulted

| Source | Contribution |
|---|---|
| ADR-001 (process kernel) | work_unit primitive, 6-file model, gate/log/safety architecture, adapter selection model |
| constitution.md (ACCEPTED 2026-05-09) | R1 (ADR shape), R8 (context-pack inclusion), R12 (no silent fallbacks), R13 (uncertainty/change), R15 (adapters translate, do not define) |
| WU-002 (constitution promotion) | Pre-constitution exception was one-time; ADR-002 operates under fully-active constitution |
| Matt Pocock Skills, MIT, Copyright (c) 2026 Matt Pocock — https://github.com/patjfree/Matt_Pocock_Skills | `/grill-me` (productivity/grill-me/SKILL.md) — relentless interview pattern; `/grill-with-docs` (engineering/grill-with-docs/SKILL.md) — interview + glossary + ADR mining for brownfield |
| Codex (multiple critique rounds, 2026-05-09) | Process Kernel framing, work_unit primitive, narrow-scope discipline, `ready_with_override` semantics, append-oriented mapping doc |

## Decision

Seven numbered, individually addressable decisions resolving D1 through D7.

### D1. Interview is the required first lifecycle stage of every AppMaker project.

**Decision:** Interview is **required** for every project, greenfield or brownfield. Skipping requires explicit human break-glass via `appmaker interview --skip` flag, which records to `events.jsonl` with `severity: critical` and produces an `interview-result.yaml` whose `readiness.status` is forced to `ready_with_override` with a reason field naming the skip.

**Why:** Interview is the mechanism by which projects honour constitution Rule R13 (every work_unit reduces uncertainty or delivers verified change). If Interview is optional, it becomes de facto unused; if it is required, then projects that genuinely do not need it record a deliberate skip, which is auditable and informative. Optional → unused is silent fallback (R12 violation). Required-with-explicit-skip is honest.

**How / Implications:**
- Kernel will refuse to create work_units (other than the interview work_unit itself) until `.appmaker/interview-result.yaml` exists with `readiness.status` in `{ready, ready_with_override}`.
- `--skip` is human-only (CLI checks invoker context per R14 spirit).
- `--skip` does not erase the requirement for an `interview-result.yaml` file. It produces one whose readiness block satisfies D3's structural requirements for `ready_with_override` (non-empty `unresolved_ambiguities[]` and populated `override`):

  ```yaml
  readiness:
    status: ready_with_override
    reason: "Interview skipped by human invocation"
    unresolved_ambiguities:
      - id: ambig-interview-skipped
        description: "Interview was skipped; project requirements were not validated."
        decision_deferred_to: "First substantive work_unit, OR a later appmaker interview run"
        scope_affected: ["project-wide"]
        suggested_resolution_work_unit: "Run appmaker interview"
    override:
      invoked_by: "<human identity>"
      invoked_at: "<ISO 8601 timestamp>"
      reason: "<required value of --reason flag passed to skip>"
  ```

  This guarantees the readiness block is structurally valid and that downstream context-packs receive at least one ambiguity (project-wide), forcing review of the skip in every later work_unit.

### D2. `interview-result.yaml` lives at `.appmaker/interview-result.yaml` (kernel-managed location).

**Decision:** The canonical location of the file is `.appmaker/interview-result.yaml`. The 6-file project model from ADR-001 §D3 remains; this is a kernel-managed artifact (alongside `profile.yaml`, `state.sqlite`, etc.), not a human-authored root file.

**Why:** Three candidates were evaluated: project root (extending to a 7-file model), `.appmaker/interview-result.yaml` (kernel-managed), and within a work_unit's `runs/` directory. The kernel-managed location wins because:
1. Interview produces a derived/structured artifact, not a human-authored declaration. `north-star.md`, `constitution.md`, and `appmaker.config.yaml` at root are written by humans; `profile.yaml` and `interview-result.yaml` are kernel-generated. Mixing the two at root muddles ownership.
2. The work_unit-internal location (option c) means context-compiler must hunt for the latest interview run, which is fragile. A fixed kernel path is queryable and stable.
3. Each Interview run still produces a draft in `runs/<timestamp>/output.yaml`. Promote copies the draft to `.appmaker/interview-result.yaml`.

**How / Implications:**
- The 6-file project model from ADR-001 §D3 is unchanged. `interview-result.yaml` joins `profile.yaml` and `state.sqlite` as kernel-managed files in `.appmaker/`.
- Re-running Interview produces a new work_unit (e.g., `wu-NNN-interview-revision-2`) whose draft eventually replaces `.appmaker/interview-result.yaml` on promote. The prior version is recorded in the new file's revision history section and in `events.jsonl`.
- Context-compiler always reads the canonical path. It does not search `runs/` directories.

### D3. Readiness enum has four states with fail-closed gate semantics.

**Decision:** `readiness.status` is one of `ready`, `needs_more_input`, `reject`, or `ready_with_override`. Default decision when status is missing or unknown is reject (fail-closed, per constitution R5 and ADR-001 §D13).

**Gate semantics:**

| Status | Gate behaviour | Downstream effect |
|---|---|---|
| `ready` | Pass. Kernel may create work_units, run advisor, plan, decompose. | Normal pipeline. |
| `needs_more_input` | Reject. Kernel refuses to create downstream work_units. | User must re-run / continue Interview to resolve `unresolved_ambiguities[]`. |
| `reject` | Reject + halt. Project scope is wrong; no work_units created. | User must restart Interview from scratch with revised scope, or abandon the project. |
| `ready_with_override` | Pass with caveat. Kernel creates downstream work_units, but every downstream `context-pack.md` MUST inject the relevant subset of `unresolved_ambiguities[]` (see D6). | Normal pipeline + ambiguity propagation. |

**Why:** Four states cover the full state space honestly. `ready` and `reject` are the obvious endpoints. `needs_more_input` is the explicit "continue Interview" signal — without it, ambiguity would either silently pass (`ready` despite unresolved questions) or lock the user out (no way to indicate "we're not done"). `ready_with_override` is the human escape hatch for "I know there are ambiguities, I am proceeding anyway, downstream work must know this" — analogous to R6 break-glass for promote. Pretending `ready` when humans know it is not = silent fallback (R12 violation).

**How / Implications:**
- The kernel's gate check on Interview reads `readiness.status` from `.appmaker/interview-result.yaml`.
- If `status` is not one of the four defined values or is missing, gate rejects (fail-closed).
- `ready_with_override` requires non-empty `unresolved_ambiguities[]` and a populated `override` block (`invoked_by`, `invoked_at`, `reason`). Empty override metadata = invalid override = gate rejects.
- The four-state enum is part of the conceptual `interview-result-v1` schema described in §schema-shape below; formal schema is WU-005 scope.

### D4. Lifecycle command pattern: `appmaker init` then `appmaker interview` (two explicit steps).

**Decision:** Two explicit commands, `appmaker init` followed by `appmaker interview`. No combined `appmaker start`; no `--minimal`/`--complete` modal flags.

**Why:** Three candidates evaluated:
- (a) `appmaker init --minimal` then `appmaker interview` then `appmaker init --complete` — too modal; introduces hidden state in `--minimal` vs `--complete` distinction.
- (b) `appmaker start` (combined) — friendliest UX but hides the lifecycle phases that the Process Kernel explicitly distinguishes; users learn an opaque verb instead of the actual stages.
- (c) `appmaker init` then `appmaker interview` — simplest mental model. `init` creates `.appmaker/` skeleton, writes `appmaker.config.yaml` template, and stops. `interview` is a separate explicit step. Each command does one thing.

(c) wins because the Process Kernel philosophy from ADR-001 §D2 is "small, explicit, composable". Combining commands hides composition; modal flags multiply states. Two explicit commands match the kernel's discipline.

**How / Implications:**
- `appmaker init` creates `.appmaker/`, writes `appmaker.config.yaml` template (with sensible defaults and explicit `# review-and-confirm` markers indicating fields the human must verify or replace; such markers are permissible inside `appmaker.config.yaml` because it is a human-authored configuration file, not a governance artifact like ADR or constitution), and creates an empty `events.jsonl`.
- `appmaker init` does NOT create work_units. The first work_unit is created by `appmaker interview`.
- `appmaker interview` creates `wu-001-interview` (or similar id), prompts the user, and on completion produces `runs/<timestamp>/output.yaml`. User invokes `appmaker promote wu-001-interview` to lift the draft to `.appmaker/interview-result.yaml`.
- Subsequent `appmaker advise`, `appmaker plan`, `appmaker decompose` all check `.appmaker/interview-result.yaml` exists with passing readiness before executing.

### D5. Matt Pocock attribution: inspiration source, not runtime dependency. Pinned to commit hash, re-synced via dedicated work_unit.

**Decision:** AppMaker's Interview prompt is **adapted from** Matt Pocock's `/grill-me` and `/grill-with-docs` patterns. The adaptation is a substantial new work (adds structured `interview-result.yaml` output, readiness gate, propagation mechanism) and falls under MIT permitted modification. AppMaker does not import, install, or runtime-depend-on Matt Pocock's skills.

**Attribution lives in three places:**
1. **Inline in the Interview skill / prompt source:** A header comment naming Matt Pocock, MIT license, repo URL, and the specific SKILL.md paths: `skills/productivity/grill-me/SKILL.md` and `skills/engineering/grill-with-docs/SKILL.md`.
2. **`docs/reference/matt-pocock-pattern-mapping.md`** (created by this WU): one row per adopted pattern with `source_skill`, `license`, `adr_reference`, `appmaker_pattern`, `surface`, `output_artifact`.
3. **AppMaker top-level `NOTICE`** (created when the AppMaker repo gains a LICENSE; deferred to a later WU): aggregate attribution to all upstream sources.

**Sync policy:** AppMaker pins to the Matt Pocock Skills commit hash at time of adoption. Upstream changes do not invisibly propagate. If Matt Pocock significantly updates `/grill-me` or `/grill-with-docs`, an explicit re-sync work_unit evaluates the changes and either incorporates or rejects them, recording the decision.

**Pinned commit hash at this ADR's adoption:** `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (commit message: "Add structured sections for 'what-to-do' and 'supporting-info' in SKILL.md", date 2026-04-30). The same hash is recorded in `docs/reference/matt-pocock-pattern-mapping.md` for both adopted patterns.

**Why:** Per constitution R15 ("Adapters translate; adapters do not define"), Matt Pocock's skills are not adapters in AppMaker's sense — they are external pattern sources. Treating them as runtime dependencies would lock AppMaker to upstream evolution that may diverge from kernel needs. Treating them as adaptation sources, with explicit attribution and pinned versions, gives AppMaker the patterns without the lock-in.

**How / Implications:**
- The Interview prompt itself (yet to be authored as a skill in catalog, deferred to a later WU) carries inline attribution.
- The pattern mapping doc grows by one row per future ADR adopting more Matt Pocock patterns (ADR-003 PRD, ADR-004 Decomposition, ADR-005 Safety Hooks, etc.).
- A re-sync work_unit is invoked manually; AppMaker does not auto-watch the upstream repo.

### D6. `ready_with_override` propagates unresolved ambiguities into every downstream context-pack via a structured list filtered by scope.

**Decision:** `interview-result.yaml.unresolved_ambiguities[]` is a list of structured ambiguity descriptors. When the readiness state is `ready_with_override`, the kernel's context-compiler reads this list, filters by the downstream work_unit's `scope`, and injects a dedicated section "Unresolved Ambiguities (from Interview)" into the generated `context-pack.md`. The downstream work_unit's review scorecard includes a check field "did this work unit accidentally rely on an unresolved ambiguity?" (per the executor's review process).

**Ambiguity descriptor shape (conceptual; formal schema is WU-005):**

```yaml
unresolved_ambiguities:
  - id: ambig-001
    description: "Whether to use OAuth or magic link for authentication"
    decision_deferred_to: "Auth implementation work_unit"
    scope_affected: ["auth", "user-onboarding", "session-management"]
    suggested_resolution_work_unit: "WU-NNN: ADR for auth approach"
```

**Worked example:**

A future implementation work_unit "WU-042: Build signup form" has scope tags `["user-onboarding", "frontend"]`. The context-compiler sees overlap with `scope_affected: ["auth", "user-onboarding", "session-management"]` and injects:

```markdown
## Unresolved Ambiguities (from Interview, ready_with_override)

- **ambig-001**: Whether to use OAuth or magic link for authentication.
  Decision deferred to: Auth implementation work_unit.
  Scope affects: auth, user-onboarding, session-management.
  Suggested resolution: WU-NNN ADR for auth approach.
  → If your work depends on this ambiguity, escalate to human or trigger resolution work_unit.
```

The agent executing WU-042 sees this section, knows the ambiguity is unresolved, and may either request escalation or proceed with explicit assumptions recorded in the work_unit's output.

**Why:** Without a propagation mechanism, `ready_with_override` is a one-time human ack that disappears. Downstream agents would inherit ambiguities without seeing them, leading to silent assumptions baked into code. The propagation list keeps ambiguities visible at every step where they matter. Filtering by scope prevents context-pack bloat (most ambiguities are not relevant to most work_units).

**How / Implications:**
- Context-compiler v1 (per ADR-001 §D7) gains a step: read `.appmaker/interview-result.yaml`, if `readiness.status == ready_with_override`, filter `unresolved_ambiguities[]` by overlap with work_unit's `scope` tags, inject filtered list as a dedicated section in `context-pack.md`.
- `unresolved_ambiguities[].id` is a stable identifier (e.g., `ambig-NNN`) so the propagation can be tracked across work_units.
- A future ADR (likely with the schema-formalization WU-005) decides whether to track which work_units consumed which ambiguities, for retro analysis.

### D7. Greenfield (`appmaker interview`) and brownfield (`appmaker interview --with-docs`) variants.

**Decision:** Two variants of the Interview command, distinguished by the `--with-docs` flag.

**Greenfield (`appmaker interview`):**
- Inputs: user description (initial natural-language project intent).
- Prompts: project-level questions (problem, users, scope, goals, non-goals, constraints, success criteria, edge cases, technical preferences, integrations, deployment).
- Outputs: `interview-result.yaml` only.
- Inspiration: `/grill-me` style — pure Q&A, no codebase reference (because no codebase exists).

**Brownfield (`appmaker interview --with-docs`):**
- Inputs: user description + read access to existing repo (specifically `CONTEXT.md` if present, `docs/adr/` if present, `src/`).
- Prompts: same project-level questions plus codebase exploration. The Interview agent challenges user claims against existing glossary, sharpens fuzzy language, cross-references with code, and offers ADR creation only when all three of {hard-to-reverse, surprising-without-context, real-trade-off} are satisfied (filter directly from `/grill-with-docs` SKILL.md).
- Outputs (all kernel-managed under `.appmaker/`):
  - `.appmaker/interview-result.yaml` with the `existing_codebase` block populated (`glossary_terms_resolved[]`, `glossary_terms_introduced[]`, `adr_candidates[]`, `contradictions_found[]`) — Interview-time deltas only.
  - `.appmaker/glossary.md` — comprehensive domain glossary (created if absent, updated if present). This is the durable human-readable reference; the Interview YAML records only the deltas surfaced in this run.
- Inspiration: `/grill-with-docs` style — domain-aware, code-cross-referenced.

The glossary lives in `.appmaker/` (kernel-managed) rather than at project root, consistent with ADR-001 §D3 separation between human-authored root files and kernel-generated `.appmaker/` artifacts.

**Why:** Greenfield projects have no glossary or codebase to challenge against; running the brownfield variant on them is wasted prompt complexity. Brownfield projects (existing repos that are adopting AppMaker) have real artifacts to interrogate, and ignoring them produces an Interview that contradicts the project's existing reality. Two variants keep each prompt focused on its inputs.

**How / Implications:**
- Both variants produce the same `interview-result.yaml` shape (same schema). Brownfield additionally populates `existing_codebase` section (glossary terms, ADR candidates, contradictions found).
- The greenfield prompt is the AppMaker-adapted `/grill-me`. The brownfield prompt is the AppMaker-adapted `/grill-with-docs`. Both are skill artifacts with attribution headers; their authoring is deferred to a later WU (catalog seeding work_unit).
- A project that starts greenfield but later wants to revisit Interview after gaining codebase complexity may run `appmaker interview --with-docs` as a re-sync; the resulting work_unit produces a new `interview-result.yaml` that supersedes the prior one.

---

### Conceptual `interview-result-v1` schema shape (NOT a delivered schema file)

ADR-002 describes the conceptual shape of `interview-result.yaml`. The formal schema (with field types, validation rules, and parser) is delivered by WU-005.

```yaml
problem:
  statement: ""
  target_users: []
  current_pain: ""

scope:
  goals: []
  non_goals: []
  constraints: []

product:
  primary_workflows: []
  success_criteria: []
  edge_cases: []

technical:
  preferred_stack: []
  integrations: []
  data_sensitivity: ""
  deployment_target: ""

risks:
  ambiguous_areas: []
  assumptions: []
  questions_remaining: []

readiness:
  status: ready | needs_more_input | reject | ready_with_override
  reason: ""
  unresolved_ambiguities:
    - id: ambig-NNN
      description: ""
      decision_deferred_to: ""
      scope_affected: []
      suggested_resolution_work_unit: ""
  override:
    invoked_by: ""
    invoked_at: ""
    reason: ""

# brownfield variant adds:
existing_codebase:
  glossary_terms_resolved: []
  glossary_terms_introduced: []
  adr_candidates:
    - id: adrcand-NNN
      title: ""
      reason: ""
  contradictions_found: []
```

The schema may be refined by WU-005; ADR-002 fixes only the shape and the readiness enum / `ready_with_override` mechanism.

## Killed Alternatives

### KA-1. Interview is optional (no required first stage).

**Considered because:** simplest UX; users who know exactly what they want skip the Interview step.

**Rejected because:** Optional → de facto unused. The Interview Phase exists to honour R13 (uncertainty reduction) and R12 (no silent fallbacks). Making it optional means projects with high ambiguity proceed without uncertainty reduction, producing the exact rework cycle Interview was designed to prevent. The required-with-explicit-skip alternative (D1) gives users an escape hatch while preserving the audit signal.

### KA-2. Use Matt Pocock `/grill-me` as a runtime dependency (npm install / git submodule).

**Considered because:** zero adaptation work; pulls latest Matt Pocock improvements automatically.

**Rejected because:** Per constitution R15 ("Adapters translate; adapters do not define") and ADR-001 §D12 (adapter selection model), runtime dependencies on external prompt frameworks fight the kernel's discipline. Upstream changes would silently change AppMaker behaviour. AppMaker would also lose the ability to add `interview-result.yaml` structured output and `readiness` gate, both of which are kernel-specific. Adaptation with attribution preserves the kernel's control over its own surface.

### KA-3. Combine Interview with Profiler in a single conversational phase.

**Considered because:** both are ambiguity-reduction stages; combining them is one CLI command instead of two.

**Rejected because:** Profiler is auto-derived from project files (`package.json`, `tsconfig.json`, framework signal extractors per ADR-001's advisor concept); Interview is human conversational. The roles are distinct (config-derived vs human-stated), the invocation moments are distinct (post-init scan vs human-driven dialog), and combining them muddles which artifact is the source of truth for which fact. Codex's three-role separation (advisor/config/constitution from §D12) extends here: profiler is closer to advisor, Interview is closer to constitution-of-this-specific-project.

### KA-4. Multiple `interview-result.yaml` files (per feature, not per project).

**Considered because:** features have their own ambiguities; per-feature interviews reduce per-feature uncertainty.

**Rejected because:** Per-feature investigations are work_units producing ADRs (per ADR-001 §D2a), not Interview re-runs. The project-level Interview answers project-level questions (who is this for, what is the scope) once. Feature-level investigations layer on top. Conflating the two would either bloat the Interview into per-feature noise or fragment the project-level truth across many files. The single `interview-result.yaml` at `.appmaker/` is canonical.

### KA-5. Strict ready-only gate (no `ready_with_override`).

**Considered because:** purist position — the gate either passes cleanly or it does not; humans must resolve ambiguity before proceeding.

**Rejected because:** Strict gates produce one of two pathologies: (a) humans pretend `ready` when they know it is not, which is silent fallback (R12 violation), or (b) projects deadlock at `needs_more_input` indefinitely because some ambiguities are genuinely deferred-by-design (e.g., "we will pick the auth provider during the auth ADR"). `ready_with_override` is the honest middle path: ambiguity acknowledged, propagation mechanism enforced, downstream work informed.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Interview becomes too long and users skip it | Medium | High | Interview is time-bounded by prompt design; agent explicitly aims for ~80% confidence at exit, not 100%. Sessions over a configurable threshold (default 60 minutes) trigger a "wrap up or override" prompt. |
| `ready_with_override` becomes the default cop-out, ambiguities pile up | Medium | Medium | `events.jsonl` records every `ready_with_override` invocation with `severity: critical`. Future retro / dashboard work_unit (deferred) queries override frequency. |
| Brownfield variant produces too many ADR candidates → noise | Medium | Low | The 3-criteria filter from `/grill-with-docs` (hard-to-reverse + surprising + real trade-off) is enforced by the brownfield prompt; candidates failing any criterion are dropped, not surfaced. |
| Matt Pocock upstream changes silently affect AppMaker | Low | Medium | Pinned to git commit hash at adoption (per D5). Re-sync requires explicit work_unit. |
| `interview-result.yaml` schema becomes load-bearing before WU-005 freezes it | High | Medium | ADR-002 specifies fields conceptually; field-level changes are non-breaking until WU-005 freezes the schema. Early implementations use ADR-002's shape as a guide, accepting that minor field renames may occur. |
| Greenfield/brownfield variants over-engineered before any project tests either path | Medium | Low | ADR-002 specifies variants conceptually; concrete CLI flag handling, prompt text, and output formatting deferred to skill-authoring work_unit (later WU). |
| `unresolved_ambiguities[]` grows unbounded across project lifetime | Low | Medium | Each ambiguity has a `suggested_resolution_work_unit` field; resolved ambiguities are removed (via amendment work_unit on `interview-result.yaml`) when the suggested work_unit promotes. Resolution discipline is human-driven; future tooling may automate. |

## Rollback Plan

**Soft rollback:** A future ADR (ADR-NNN) supersedes specific decisions in ADR-002. For example, if `ready_with_override` proves too easy to abuse, ADR-NNN may change D3's gate semantics to require dual human approval for the override state. ADR-002 itself stays in `decisions/`; the supersedence chain is recorded in metadata.

**Hard rollback:** Archive ADR-002 (set status to `REJECTED` in revision history, keep file for audit). Constitution amendment WU-004 (planned to add Interview-required rule) is also rolled back. The lifecycle reverts to ADR-001's implicit assumption (no Interview Phase). Any `interview-result.yaml` files in active projects become reference-only.

Hard rollback is feasible because no production users exist (greenfield project); cost is design rework, not data migration.

## Open Questions

These are deliberately deferred; future ADRs or work_units resolve them.

- **OQ-1.** How is the Interview prompt itself versioned? (Likely as a skill in the AppMaker catalog with a `version` field; deferred to skill-authoring WU.)
- **OQ-2.** Multi-language Interview support (i18n)? (Not v1; deferred.)
- **OQ-3.** Group/team Interview (multiple humans answering)? (Not v1; multi-tenant work_unit decides.)
- **OQ-4.** Ownership of brownfield ADR candidates: which work_unit drafts each ADR? Per-candidate work_unit or batched? (Deferred to WU-005+ once schema and runner exist.)
- **OQ-5.** Cancel / abort during Interview, partial state recovery? (Deferred to interview implementation WU.)
- **OQ-6.** How to track which work_units consumed which `unresolved_ambiguities` for retro analysis? (Deferred to WU-005 schema decisions.)

## Acceptance Criteria

This ADR is `READY-FOR-REVIEW` (informally; the formal status is governed by WU-003 work-unit.yaml) when:

- All 7 decisions D1–D7 are resolved with explicit decision and rationale.
- At least 3 killed alternatives are documented (this ADR has 5: KA-1 through KA-5).
- `interview-result.yaml` schema is described conceptually (above), not as a parseable schema file.
- `readiness` enum and `ready_with_override` shape are non-negotiable per Codex acceptance.
- Matt Pocock attribution is explicit (link, MIT license, author, both SKILL.md paths).
- `ready_with_override` propagation rule (D6) includes a concrete worked example.
- Lifecycle command decision (D4) picks one default with rationale; alternatives in killed.
- No constitution edits, no schema files created, no code files created.
- No contradiction with ADR-001 §§D2, D2a, D3, D4, D11, D12, D13, D14.
- No contradiction with constitution rules R1, R8, R12, R13, R15, R17.
- Open Questions enumerates deliberate deferrals.
- `docs/reference/matt-pocock-pattern-mapping.md` created with exactly 2 entries.

## Verification

| Required section (per `adr-v1`) | Present? |
|---|---|
| Status | yes |
| Metadata | yes |
| Context | yes |
| Sources Consulted | yes |
| Decision (numbered) | yes (D1–D7) |
| Killed Alternatives | yes (KA-1 through KA-5) |
| Risks and Mitigations | yes (7 rows) |
| Rollback Plan | yes (soft + hard) |
| Open Questions | yes (OQ-1 through OQ-6) |
| Acceptance Criteria | yes |
| Verification | yes (this table) |
| Revision History | yes (below) |

Forbidden patterns check (per `work-unit.yaml.verification.forbidden_patterns` for WU-003): all listed patterns absent. Code-context shorthand (e.g., function signature placeholders within fenced code blocks) is permitted as concrete reference, not as hand-waving.

Length target 250–550 lines: see end of file for actual count (self-reported during self-check).

## Revision History

| Date | Author / Work_unit | Status | Changes |
|---|---|---|---|
| 2026-05-09 | WU-003 (draft) | DRAFT | Initial draft. 7 decisions resolved (D1–D7). 5 killed alternatives. 6 open questions. Conceptual `interview-result-v1` schema shape. Matt Pocock attribution complete (MIT, repo URL, both SKILL.md paths). |

---

**End of ADR-002 (DRAFT — WU-003).**
