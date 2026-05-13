# AppMaker Constitution

## Status

**DRAFT** — produced by WU-002 at `.appmaker/work-units/wu-002/runs/<timestamp>/output.md`, awaiting promote.

Lifecycle: `DRAFT` (current, in run dir) → `ACCEPTED` (after human review; promotion step copies this file to project root `constitution.md` and flips status to `ACCEPTED` in the promoted copy) → `AMENDED` (if modified by future amendment work_unit, per Amendment Process).

## Purpose

This document is the governance layer of AppMaker projects. It states the rules
AppMaker (the system) enforces and the rules agents working within a project
must obey. Constitution exists because (1) without explicit rules, agents
drift toward training-data norms rather than project needs; (2) configuration
expresses what is chosen, constitution expresses what cannot be chosen
otherwise; (3) without a written rulebook, governance lives in conversation
history and evaporates at session boundaries. Constitution is loaded into
every `context-pack.md` (per R8) so no work_unit ever executes without
seeing it.

## Scope

### In scope

- Rules constraining the behaviour of AppMaker (the system): when it must
  reject, when it must require human approval, when it must fail closed.
- Rules constraining the behaviour of agents working inside an AppMaker
  project: which actions they may not take, which artifacts they must produce,
  which validations they must run.
- Process governance: how ADRs are structured, how amendments to this
  document occur, how exceptions are recorded.

### Out of scope

The constitution does **not** cover:

- **Configuration choices** — which Spec adapter to use, which provider, which
  model. Those live in `appmaker.config.yaml` (per ADR-001 §D12).
- **Recommendations** — what skills a project should activate. That is the
  Advisor's job; recommendations are not rules.
- **Taste and style** — naming conventions, indentation, comment style. These
  belong in linters, formatters, and culture, not in governance.
- **Tutorials and how-tos** — `README.md` and per-skill documentation cover
  usage. The constitution does not teach.
- **Aspirational manifestos** — every rule is testable or auditable. "We strive
  to" language without a concrete check is rejected.

## Rules

Each rule has the form: **statement**, then `Why:` (rationale), then
`How to apply:` (enforcement mechanism, including which AppMaker component
performs the check).

---

### R1. Architectural Decision Records require minimum 3 alternatives, explicit killed options, and risks with mitigations.

**Why:** A decision presented without alternatives is a position, not a
choice. Killed options name the paths considered and rejected, which protects
future readers from re-litigating settled questions. Risks with mitigations
prove the author thought past the happy path.

**How to apply:** Investigation work_units producing ADR artifacts use
`artifact_schema: adr-v1`. The schema validator counts alternatives,
checks for a Killed Alternatives section with at least one entry, and
checks for a Risks table. Promote rejects if any check fails.

---

### R2. The bootstrap exception is one-time and was consumed by ADR-001.

**Why:** AppMaker's discipline is that artifacts emerge from work_units
passing through gates. ADR-001 was authored manually because no kernel yet
existed to run that workflow. Allowing further bootstrap exceptions would
turn the exception into a habit, which dissolves the discipline.

**How to apply:** Cultural rule, enforced by review. Any future ADR or
artifact claiming bootstrap status is rejected. The only document permitted
to invoke bootstrap is ADR-001 itself.

---

### R3. Every work_unit declares `type: investigation` or `type: implementation`.

**Why:** Investigation work_units produce knowledge artifacts and are
verified against an artifact schema. Implementation work_units produce code
changes and are verified against passing commands. Mixing the two leads to
ADRs without alternatives or code without tests, because the wrong
verification mode is applied.

**How to apply:** `work-unit.yaml` schema (defined in WU-003) makes `type`
required with these two values. The runner selects verification mode by
type. Promote rejects work_units missing or with unknown type.

---

### R4. Promote is impossible without a recorded verification result.

**Why:** Promotion is the moment a work_unit becomes part of the project's
truth. A promoted work_unit without verification is a lie about the
project's state, and downstream work_units inherit the lie.

**How to apply:** `appmaker promote <work-unit-id>` reads
`runs/<timestamp>/verification.log` (or equivalent for investigation
artifacts) and rejects if the file is missing, empty, or recorded a
failure. There is no flag that bypasses this check except R6 break-glass.

This rule encodes Founding Principle P2.

---

### R5. Gates fail closed. Three layers of enforcement: rule, config, hook.

**Why:** A gate that fails open silently lets bad work pass. The cost of a
false-reject (re-do the work) is much smaller than the cost of a
false-accept (the system now contains a defect that downstream work assumes
absent).

**How to apply:** Three layers per ADR-001 §D13: (1) this constitution rule;
(2) every gate definition declares `default_decision: reject`,
`on_missing_field: reject`, `on_error: reject`; (3) `appmaker promote`
requires explicit pass signals — absence is failure, not silence.

This rule encodes Founding Principle P4.

---

### R6. Break-glass is human-only and produces `promoted_with_exception` state, never `promoted`.

**Why:** There must be a path for humans to override gates, but the system
must never confuse override with clean pass. Downstream work_units depending
on a `promoted_with_exception` artifact know they build on contested ground.

**How to apply:** Break-glass is invoked as
`appmaker promote <id> --break-glass --reason="<text>"`. The CLI checks
invoker context and rejects break-glass from non-human callers (agents,
scripts, CI). The reason is appended to `events.jsonl` with
`severity: critical`. The resulting state is the literal string
`promoted_with_exception`; dependent work_units must reference the
exception explicitly.

---

### R7. Machine-readable artifacts must pass parser or lint validation before being marked `VERIFIED` or otherwise eligible for promotion.

**Why:** An artifact that semantically expresses the right contract but
fails to parse is worthless to the kernel. Discovering parse failures at
consumption time wastes context and trust. (Learned during WU-002 itself.)

**How to apply:** Verification step for any work_unit whose output is
machine-readable invokes the canonical parser for the format. For YAML this
is at minimum `python -c "import yaml; yaml.safe_load(open('FILE'))"` or
`ruby -ryaml -e "YAML.load_file('FILE')"`. For JSON, `jq empty < FILE`. For
TypeScript, `tsc --noEmit`. The verification record stores parser output.
Failure means the artifact does not advance state.

---

### R8. Every `context-pack.md` includes the constitution, the relevant recent ADRs, and the work_unit's acceptance criteria.

**Why:** A context-pack is the complete input to a work_unit's execution.
If it omits constitution, the agent forgets governance. If it omits ADRs,
the agent re-litigates settled decisions. If it omits acceptance criteria,
the agent does not know when to stop.

**How to apply:** The context-compiler (CLI: `appmaker context compile
<work-unit-id>`) refuses to produce a pack missing any of these three
inputs. The lone exception is the pre-constitution condition documented
in WU-002's context-pack, which expired at WU-002's promotion. No further
exceptions.

This rule encodes Founding Principle P1.

---

### R9. The three log streams `decisions.jsonl`, `events.jsonl`, and `lessons.jsonl` remain separate and are never merged.

**Why:** Decisions are sparse and high-signal. Events are dense and
operational. Lessons are sparse and reflective. These streams have
different consumers (architects, operators, retro-readers) and different
cadences. Merging them degrades all three: audit becomes noisy, ops loses
context, lessons drown.

**How to apply:** The kernel writes only to the appropriate stream for
each event type. Per-execution detail (stdout, stderr, scorecards) does
not duplicate into events; it lives only in `runs/<timestamp>/`, with
`events.jsonl` carrying short references via `artifact_ref`. ADR-001
§D14 fixes the boundary.

---

### R10. All log streams are append-only. Rewriting history requires a dedicated work_unit and an audit entry.

**Why:** Audit trails that can be silently edited are not audit trails.
The discipline of append-only is what makes the logs trustworthy as a
record of what happened.

**How to apply:** The kernel never offers a rewrite primitive. If a log
entry is wrong, the correction is a new entry referencing the prior
entry's `artifact_ref`. If a stream truly must be edited (legal hold,
secrets leak), the edit happens via a dedicated implementation work_unit
whose acceptance criteria include a written justification appended to
`decisions.jsonl`.

---

### R11. Changes touching schema, authentication, secrets, or production systems require human approval at the promote gate.

**Why:** These four surfaces are where an agent error becomes catastrophic
and irreversible — wrong schema migration corrupts data, wrong auth opens
accounts, leaked secrets cannot be unsent, wrong prod deploy creates
incidents. Speed of an agent is not worth the cost of these failures.

**How to apply:** The work_unit schema includes a `risk_surface` field
that is a list possibly containing `schema`, `auth`, `secrets`, `prod`.
When non-empty, the promote gate requires a human review entry
(`review_required_from` includes `human`) and rejects without it.
Heuristics in the kernel auto-flag risk surfaces from `allowed_files`
patterns (e.g., paths matching `migrations/`, `.env`, `infra/prod/`),
which the human author can confirm or remove.

This rule encodes Founding Principle P3.

---

### R12. No silent fallbacks. A missing capability produces an explicit error.

**Why:** Silent fallbacks hide the gap between what the user requested
and what the system did. "It worked, but not how you asked" is worse than
"it didn't work, here's why".

**How to apply:** When `work-unit.yaml` requests `mode: voting` but the
v1 runner only supports `single`, the runner exits with the error
*"voting runner not implemented in v1; see ADR-001 §D8"* and refuses to
execute. The same pattern applies to every feature gap: explicit error,
no quiet substitution.

This rule encodes Founding Principle P5.

---

### R13. Every work_unit must reduce uncertainty or deliver a verified change.

**Why:** This is the value test. A work_unit that produces neither a
knowledge artifact nor a verified change is theater. Theater consumes
context, time, and money without moving the project. AppMaker's whole
design philosophy assumes that small, valuable steps compose into useful
outcomes; that assumption fails if zero-value steps are accepted.

**How to apply:** At promote, the gate requires evidence of one of:

- An investigation artifact whose schema validates and whose required
  sections are populated, OR
- An implementation change whose `verification_commands` all exited zero
  on the recorded run.

If neither, the gate rejects with status `REJECTED`, not `PROMOTED`.

This rule encodes Founding Principle P6.

---

### R14. Agents may not invoke `git push`, `git commit`, `rm -rf`, package publishing, or production deployment.

**Why:** These five action classes have effects that escape the AppMaker
project boundary or destroy local work irreversibly. A wrong agent
invocation here cannot be unwound by reverting a file.

**How to apply:** The agent runner's PreToolUse hook blocks these
commands. The block is configured per `agent-role.yaml` (defined in
WU-003+) with `blocked_actions` listing the patterns. Human invocation
is unaffected. Adding a new action class to the allowlist requires an
ADR.

---

### R15. Adapters translate. Adapters do not define.

**Why:** AppMaker's value is its own work_unit format and pipeline. If
adapters defined the work_unit shape, AppMaker would degrade into a
wrapper around whichever adapter is currently in use, and switching
adapters would mean rebuilding the project. The adapter pattern is
specifically chosen so that the kernel survives when adapters die.

**How to apply:** Each adapter under `appmaker/adapters/<name>/` exposes
exactly two operations: `import` (foreign format → AppMaker work_unit)
and `export` (AppMaker work_unit → foreign format). Adapters may not
add fields to the AppMaker work_unit schema; new fields require a kernel
change with an ADR.

---

### R16. The constitution may forbid classes of adapters. Specific adapter selection lives in `appmaker.config.yaml`.

**Why:** Constitution-as-rules and config-as-execution-choices are
different concerns (per ADR-001 §D12). Encoding "we use Spec Kit"
in the constitution would make every adapter swap a constitutional
amendment, which is too heavy. Encoding "no proprietary cloud-only spec
tools" as a class-level prohibition is appropriate constitutional
material.

**How to apply:** This constitution may add a sub-section under "Rules"
forbidding specific classes (none today; future amendments may). The
Advisor recommends, `appmaker.config.yaml` decides, the constitution
constrains. Three roles, no overlap.

---

### R17. The constitution stays under 25 rules. Rule count growth is a smell.

**Why:** A constitution that grows unbounded becomes a swamp; rules
contradict each other, exceptions multiply, and the document loses force
because no one reads it end-to-end. Discipline against bloat is itself a
governance principle.

**How to apply:** When proposing a new rule via amendment work_unit, if
the post-amendment rule count would exceed 25, the work_unit's
acceptance criteria must include a refactoring step that merges or
removes existing rules. The constitution-v1 schema validator counts
top-level `### R<n>` headings under "Rules" and rejects violation.

---

## Amendment Process

Constitution is changed through amendment work_units:

1. **Propose** — `type: investigation` work_unit whose `acceptance_criteria` lists each amended, added, or removed rule with a one-line rationale.
2. **Brief** — context-pack must include the current constitution, ADR-001, and any work_units whose execution surfaced the need for the amendment.
3. **Draft** — produce a candidate document. Same validation as WU-002 applies (forbidden patterns, bounds, parser-clean, all founding principles encoded).
4. **Review** — at minimum one human reviewer plus the critic role. Amendments touching R4, R5, R6, R8, R11, or R13 (core safety and verification) require a second human reviewer.
5. **Promote** — on pass, the new constitution replaces the old; prior version appended to Revision History.

**Meta-rules for amendments:**

- Each modified or added rule carries `Why:` and `How to apply:`; rules without both are rejected.
- An amendment may not silently delete a Founding Principle (P1–P6); removing one requires explicitly superseding ADR-001's listing.
- Amendments may not retroactively invalidate already-promoted work_units; transitional rules specify how pre-existing artifacts are treated.

---

## Verification Hooks

Each rule's enforcement is `auto-check` (command or schema validation),
`human-review` (named role approves), or `cultural` (norm reinforced by
review, not by code).

| Rule | Enforcement | Hook details |
|---|---|---|
| R1  | auto-check + human-review | `adr-v1` schema validator + human reviewer |
| R2  | cultural | review-time check during ADR creation |
| R3  | auto-check | `work-unit.yaml` schema requires `type` field |
| R4  | auto-check | `appmaker promote` reads verification record |
| R5  | auto-check | gate config defaults plus CLI hook |
| R6  | auto-check + human-review | CLI checks invoker context; human-only |
| R7  | auto-check | parser validation in verification step |
| R8  | auto-check | context-compiler refuses pack missing inputs |
| R9  | auto-check | kernel writes only to appropriate stream |
| R10 | cultural + auto-check | kernel offers no rewrite primitive |
| R11 | auto-check + human-review | risk_surface field + human gate |
| R12 | auto-check | runner exits with explicit error on missing capability |
| R13 | auto-check | promote gate checks artifact or verification result |
| R14 | auto-check | PreToolUse hook blocks listed commands |
| R15 | cultural + auto-check | adapter interface enforces import/export only |
| R16 | cultural | review-time check during adapter addition |
| R17 | auto-check | constitution-v1 schema counts R-headings |

Rules marked `cultural` are enforced through review attention, not code. As
the kernel matures, cultural rules may migrate to `auto-check` via dedicated
work_units.

---

## Revision History

| Date | Author / Work_unit | Status | Changes |
|---|---|---|---|
| 2026-05-09 | WU-002 (draft) | DRAFT | Initial draft. 17 rules. All 6 Founding Principles (P1–P6 from ADR-001 discussion) encoded. Verification Hooks classify each rule as auto-check, human-review, or cultural. |

---

**End of Constitution (DRAFT — WU-002).**
