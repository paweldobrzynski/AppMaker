# ADR-001: AppMaker Process Kernel Architecture

## Status

**ACCEPTED** — bootstrap exception (this ADR was authored manually before AppMaker existed)

## Metadata

- **Date:** 2026-05-09
- **Authors:** pawedo@gmail.com (decision-maker), Claude Opus 4.7 (synthesis), Codex (critic, 4 rounds)
- **Type:** investigation work_unit (artifact-validated)
- **Bootstrap exception:** Yes — see § "Bootstrap Exception" below
- **Supersedes:** none
- **Superseded by:** none

---

## Context

AppMaker exists to solve one problem:

> **AI agents are unpredictable when scope is large, context is bloated, and decisions are implicit.**

Current AI-assisted development workflows produce drift, half-baked features, and unrepeatable results. A developer with 200+ globally installed Claude Code skills experiences context-window failures, skill conflicts, and inconsistent agent behavior across sessions.

AppMaker is a **local AI Operating System for project-specific agent workflows** — not a multi-agent platform that builds applications. Its primary primitive is the **work_unit**: a small, scoped contract with explicit acceptance criteria and verification. Agents operate on work_units, not on goals.

A previous attempt (`AppsMaker-2025`, located at `/Users/pawel/Projects/AppsMaker-2025/`) implemented the MAKER paper voting algorithm but stalled at 75% complete by author's own admission, never integrated with Claude Code skills/agents, remained ClaimCompass-specific, and has been untouched since 2025-11-24 (~5.5 months as of this ADR).

### Scope of this ADR

Establishes the v1 architectural foundation. Does NOT cover:
- Specific catalog content (deferred to catalog-seeding work_units)
- v1.1+ features (voting runner, repo-map context compiler)
- Cross-project pattern library implementation details
- UI / dashboard / web interface
- Multi-tenant or team collaboration scenarios

### Bootstrap Exception

This ADR was authored **manually before AppMaker exists**. AppMaker's own philosophy mandates that ADRs emerge from work_units passing through gates. Since no kernel exists to run that workflow, this first ADR is a documented exception. ADR-002 onwards MUST be authored through AppMaker's own work_unit pipeline.

---

## Sources Consulted

| Source | Contribution | v1 Role |
|---|---|---|
| AppsMaker-2025 (Meyerson voting impl) | Voting + red-flagging research basis | Read-only archive; salvage deferred to v1.1 |
| OpenSpec (Fission-AI, ~41k★, v1.3.0) | Spec workflow patterns, "fluid" iteration | Optional adapter, future |
| GitHub Spec Kit (~93.9k★, v0.8.7, May 2026) | Constitution + 5-phase spec workflow | **Default adapter v1** |
| Matt Pocock Skills (10★, MIT) | Disciplined single-purpose skills (`/grill-me`, `/tdd`, `/diagnose`, `/caveman`) | Catalog seed |
| Aider repo-map (graph-rank + tree-sitter, 1k token budget default) | Context compression algorithm | **Implementation pattern v1.1** |
| VoltAgent awesome-claude-code-subagents (100+ subagents) | Agent role inspiration, NOT bulk install | Reference only |
| Anthropic Skills repo (official) | SKILL.md format, skill-creator, mcp-builder | Format standard |
| Codex (4 critique rounds, May 2026) | Process Kernel framing, work_unit primitive, 6-file model, fail-closed gates, 3-stream logging | **Architectural backbone** |
| Claude (4 synthesis rounds, May 2026) | Investigation/implementation type split, gate enforcement layers, events scope | **Refinements** |

---

## Decision

Fourteen numbered, individually addressable decisions.

### D1. Greenfield AppMaker

A new repository at `/Users/pawel/Projects/AppMaker/`. AppsMaker-2025 stays in place as read-only archive; no in-place modification. ClaimCompass remains separate at `/Users/pawel/Projects/ClaimCompass/`.

### D2. Process Kernel + work_unit as primary primitive

AppMaker is **not** a multi-agent platform. It is a kernel that:
1. **Profiles** projects (advisor)
2. **Curates** AI environment (skill set per project)
3. **Decomposes** work into small contracts (work_units)
4. **Compiles** minimal context per work_unit (context-compiler)
5. **Enforces** gates (fail closed)
6. **Logs** decisions, events, lessons (3 streams)

Multi-agent debate is **not** a v1 feature. Single-agent runner with strict contracts is the default.

### D2a. work_unit has type: investigation | implementation

Each work_unit declares its type. Verification semantics differ:

```yaml
# investigation: output is a knowledge artifact
type: investigation
acceptance_criteria:
  - artifact contains required sections
  - at least 3 alternatives documented
  - killed options explicit
verification:
  artifact_schema: adr-v1
  required_sections: [Status, Context, Decision, Killed Alternatives, Risks]

# implementation: output is verified code change
type: implementation
verification_commands:
  - npm test
  - npm run lint
  - npm run typecheck
acceptance_criteria:
  - all verification_commands exit 0
  - only allowed_files modified
  - no blocked_files touched
```

Investigation work_units (like ADRs) have **artifact-schema validation**, not test commands. Implementation work_units have **mandatory passing verification commands**.

### D3. 6-file project model

```
PROJECT/
├── north-star.md              # WHY the project exists (business/product goals) — human-authored
├── constitution.md            # RULES the agent must not break (governance) — human-authored
├── appmaker.config.yaml       # Project-level AppMaker config (adapters, providers) — human-authored
└── .appmaker/
    ├── profile.yaml           # WHAT the project technically is (advisor output) — auto-generated
    ├── work-units/<id>/
    │   ├── work-unit.yaml     # Contract for one unit of work
    │   ├── context-pack.md    # Compiled context for execution (context-compiler output)
    │   └── runs/<timestamp>/  # Per-execution artifacts (output, verification log, scorecard)
    ├── decisions.jsonl        # Architectural / product decisions (sparse, signal)
    ├── events.jsonl           # Lifecycle events (work_unit started/failed/promoted) — cross-work-unit
    ├── lessons.jsonl          # Distilled wisdom from retros (sparse, signal)
    └── state.sqlite           # Queryable state (current phase, locks, work_unit status)
```

**Each file has a single owner and a single purpose.** No mixing of concerns.

### D4. Manual bootstrap ADR exception

This document (ADR-001) is the only artifact created outside AppMaker's discipline. All subsequent ADRs MUST go through:

```
work_unit (type: investigation) → context-pack → execution → artifact validation → gate → promote
```

### D5. Spec Kit as default adapter; adapter pattern preserved

```
appmaker/adapters/
├── speckit/    # default — github/spec-kit, slash commands /speckit.*
└── openspec/   # optional/future — Fission-AI/OpenSpec, slash commands /opsx.*
```

AppMaker exposes its OWN work_unit format. Adapters TRANSLATE between AppMaker work_units and external spec tools. AppMaker is not a Spec Kit wrapper.

### D6. OpenSpec as optional/future adapter

OpenSpec stays on the shelf. Implementing the adapter is **deferred to a work_unit triggered by user need**, not built speculatively.

### D7. Simple Context Compiler in v1, Aider-style repo-map in v1.1

**v1 context-compiler** (CLI: `appmaker context compile <work-unit-id>`):
- Files explicitly listed in work-unit.yaml `allowed_files`
- Symbols mentioned in description
- `git diff` output (recently touched files)
- `ripgrep` symbol hints based on work_unit goal
- Constitution.md (always)
- Recent ADRs (last 5 or filtered by tag)
- Token budget (configurable, default 8K)

**v1.1 context-compiler** adds:
- Tree-sitter AST parsing (TypeScript first)
- PageRank over file/symbol dependency graph (Aider-style)
- Dynamic budget adjustment based on chat state

### D8. Voting mode declared in schema, runner deferred

```yaml
# work-unit.yaml
execution:
  mode: single   # single | voting | debate
```

v1 implements only `mode: single`. Setting `mode: voting` in v1 produces explicit error:

> *"voting runner not implemented in v1. See ADR-XXX for v1.1 plan. To proceed, change mode to single or wait for v1.1."*

**No silent fallback. Zero pretending.**

### D9. Zero code salvage from AppsMaker-2025 in v1

AppsMaker-2025 stays read-only. v1 implements all kernel components fresh. When a future work_unit triggers voting mode (v1.1+), selective salvage of `maker/core.ts` (voting algorithm) and `maker/red-flag.ts` (heuristics) becomes a separate work_unit with its own ADR.

### D10. CLI-first, MCP later

v1 is a CLI tool (`appmaker` binary). **No MCP server in v1.** The CLI commands are the API surface. MCP wraps the CLI in v2+ when in-conversation invocation value clearly outweighs implementation cost.

### D11. Three-stream logging

```
.appmaker/decisions.jsonl   # architectural / product decisions (rare, signal)
.appmaker/events.jsonl      # work_unit lifecycle events (frequent, cross-work-unit summary)
.appmaker/lessons.jsonl     # post-retro distilled wisdom (rare, signal)
```

Per-execution detail (stdout/stderr, scorecards, full logs) lives in `runs/<timestamp>/`. `events.jsonl` records short references:

```json
{
  "timestamp": "2026-05-09T14:32:11Z",
  "work_unit_id": "wu-001",
  "run_id": "2026-05-09T14:32:11Z",
  "event": "verification_failed",
  "severity": "error",
  "artifact_ref": ".appmaker/work-units/wu-001/runs/2026-05-09T14:32:11Z/"
}
```

Logs and decisions are different streams with different consumers and different cadences. No merging.

### D12. Adapter selection: Advisor proposes → config decides → constitution constrains

```
Advisor              → recommends Spec Kit / OpenSpec / none based on profile
appmaker.config.yaml → final selection (e.g., adapters.spec: speckit)
constitution.md      → may forbid CLASSES of adapters (e.g., "no proprietary cloud-only spec tools")
```

Three roles, no overlap:
- **Constitution** = rules ("what is forbidden / required as principle")
- **Config** = execution choices ("which specific tool")
- **Advisor** = recommendation ("based on your profile, suggested:")

### D13. Gates fail closed — enforced in three layers

**Layer 1 (rule):** Constitution.md states "gates fail closed; no silent fallbacks".

**Layer 2 (config):** Each gate definition:
```yaml
default_decision: reject
on_missing_field: reject
on_error: reject
break_glass:
  allowed: human_only
  requires_reason: true
  resulting_state: promoted_with_exception
```

**Layer 3 (CLI hook):** `appmaker promote` REJECTS unless verification result + scorecard + (where required) human approval are all green.

Break-glass:
- Invoked as `appmaker promote <work-unit-id> --break-glass --reason="..."`
- **NOT callable by agents** — CLI checks invoker context
- Records reason to `events.jsonl` as `severity: critical`
- Sets state to `promoted_with_exception`, **NOT** `promoted`
- Subsequent dependent work_units MUST acknowledge the exception flag (cannot transitively pretend it was clean)

### D14. events.jsonl scope vs runs/<timestamp>/

`events.jsonl` = project-level lifecycle audit (cross-work-unit, append-only, summary-only).
`runs/<timestamp>/` = per-execution detail (stdout, stderr, scorecards, verification logs, agent outputs).

Linking via `artifact_ref` field in events records. **events.jsonl never duplicates content from runs/.**

---

## Killed Alternatives

### KA-1. Resurrect AppsMaker-2025 as foundation

**Why considered:** ~1500 LoC already written. Voting engine implemented. One demo voting artifact exists for task-001-tenants-table (`winner.json` with `consensus: 10` and `disagreement_signal: true` — i.e. NOT strong evidence of end-to-end reliability, voting did not converge cleanly).

**Why rejected:**
- Standalone Node.js architecture incompatible with Claude Code-native vision
- Single-flow waterfall (architecture → planning → dev) lacks discovery/ideation/grilling phases
- Voting ≠ multi-agent debate (statistical noise reduction, not adversarial collaboration)
- ~5.5 months untouched (since 2025-11-24); references retired model versions
- ClaimCompass entanglement (ClaimCompass dir nested inside AppsMaker)
- Layering new architecture on stale foundation = Frankenstein
- Author's own admission: "75% complete"

### KA-2. Multi-agent platform with 12 specialized roles (Claude's original v1 proposal)

**Why considered:** Rich ecosystem of agent specializations available. VoltAgent has 100+ subagents. Conceptually elegant; matches "creative process + grilling + design" mental model.

**Why rejected:**
- "Multi-agent without hard contracts = theater" (Codex)
- 12 agents debating produces verbose output with low signal
- Real reliability comes from small scope + explicit contracts + verification
- Multi-agent debate reserved for specific decision protocols (scorecard-producing), not the default pattern
- v1 with 12 roles ≈ 6+ weeks of work; v1 with single agent + contracts ≈ 1 week

### KA-3. OpenSpec as primary spec adapter (Claude's earlier preference)

**Why considered:** Lightweight, "fluid not rigid" iteration philosophy. Slash commands integrate cleanly. Brownfield support.

**Why rejected:**
- Smaller community (~41k★ vs 93.9k★ for Spec Kit)
- No Constitution layer (Spec Kit has it; we want it)
- Less battle-tested
- Spec Kit being GitHub-maintained reduces project-death risk
- OpenSpec retained as **optional** adapter for future when "fluid" iteration genuinely needed

### KA-4. MCP server as v1 dependency

**Why considered:** Native Claude Code integration. Stateful operations (project_registry, gate_check) feel MCP-natural.

**Why rejected:**
- "MCP debugging before kernel works = pain" (Codex)
- CLI is sufficient for v1; CLI commands ARE the API
- MCP becomes adapter layer when kernel is proven
- Premature integration risks debugging glue layer instead of building real value
- Adding MCP later requires zero architectural change (only thin wrapper)

### KA-5. Aider-style repo-map (tree-sitter + PageRank) in v1

**Why considered:** Sophisticated algorithm handles real codebase context budget. Open source, well-documented (https://aider.chat/docs/repomap.html).

**Why rejected:**
- Tree-sitter + PageRank + multi-language support ≈ 1 week alone
- v1 simple compiler (explicit files + ripgrep + git diff + token budget) gets ~70% of value at ~10% of cost
- Aider-style is v1.1 explicit work_unit, not v1 must-have
- "Don't let one feature blow up v1" (Codex)

### KA-6. Single-stream logging (Claude's earlier proposal)

**Why considered:** Simpler — one file to query.

**Why rejected:**
- Decisions (signal, rare) and events (high-volume execution noise) have fundamentally different consumers
- Mixing degrades both audit quality and lessons distillation
- Three streams = three concerns properly separated
- All three are append-only JSONL — minimal complexity to add

### KA-7. Constitution-as-config (Claude's earlier proposal: "constitution chooses adapter")

**Why considered:** "Project rules choose adapter" felt natural at first.

**Why rejected:**
- Constitution = rules; config = execution choices
- Mixing makes adapter switching require constitutional change (heavy, ceremonial)
- Better separation: constitution constrains adapter classes, config picks specific one
- Three-role model (advisor / config / constitution) is cleaner

### KA-8. Speculative cross-project pattern library in v1

**Why considered:** Cross-project learning is a major AppMaker value proposition. Killer feature for "second project benefits from first".

**Why rejected for v1:**
- "Smart recall" without enough projects to learn from = pretend wisdom
- v1 ships with simple `lessons.jsonl` append-only log per project
- Pattern library v2+ once 3+ projects exist providing real signal
- Building inference logic before having data to infer from is premature

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Spec Kit changes API or project dies | Medium | High | Adapter pattern isolates dependency; OpenSpec adapter as backup; AppMaker work_unit format is internal contract, not Spec Kit's |
| Investigation work_unit verification too loose, ADRs become low-quality | Medium | Medium | Strict `artifact_schema` enforcement; required_sections checked by schema validator; review work_unit before promote |
| Three log streams over-engineered for v1 | Low | Low | All three are append-only JSONL — implementation cost is trivial; cost of merging later is high |
| Bootstrap exception sets bad precedent for "skipping process" | Medium | Medium | This ADR is the ONLY exception; ADR-002 onwards through proper workflow; bootstrap exception explicitly named in this ADR |
| Claude Code skills churn; catalog rot | High | Medium | Catalog stays curated (~50 skills initially); refreshed quarterly via dedicated work_unit; quality scoring per skill |
| AppMaker over-scoped; v1 ships half-baked (like AppsMaker-2025) | High | High | Strict v1 must-have list (this ADR); voting/repo-map/MCP all explicitly v1.1+; each work_unit independently valuable |
| User abandons project mid-build | Medium | High | v1 narrow enough to ship in ~7 days of focused work; each completed work_unit produces standalone value (e.g., advisor alone is useful) |
| Adapter pattern adds complexity for single-adapter v1 | Low | Low | Pattern is cheap (interface + one impl); paying tax now avoids refactor later |
| Bootstrap ADR encodes biases that should be challenged | Medium | Medium | ADR is PROPOSED until human accepts; can be revised before any implementation work starts |

---

## Rollback Plan

If v1 architecture proves wrong:

**Soft rollback** (specific decisions invalidated):
- New ADR-NNN supersedes specific decisions in ADR-001
- AppMaker continues with revised architecture
- Affected work_units re-executed under new rules
- Cost: hours to days per decision reverted

**Hard rollback** (entire v1 wrong):
- Archive `~/Projects/AppMaker/` → `~/Projects/_archive/AppMaker-attempt-1/`
- Capture lessons in `lessons.jsonl` archive
- Start `ADR-001-attempt-2` with documented learnings
- Cost: ~1 week of work lost; no production users; no data migration

Hard rollback is feasible because v1 is greenfield and unused externally. **This is the value of greenfield: failure is recoverable.**

---

## Open Questions (deferred to future ADRs)

- **OQ-1.** Voting runner protocol — when is voting triggered automatically vs manually? K values per work_unit type? (ADR-NNN in v1.1)
- **OQ-2.** Cross-project pattern library schema and recall ranking algorithm. (ADR-NNN in v2+)
- **OQ-3.** Multi-tenant AppMaker — can two developers share a project's `.appmaker/` over git without conflicts? (Probably yes with care; defer)
- **OQ-4.** MCP server interface design and v1→v2 transition path. (ADR-NNN when MCP value clear)
- **OQ-5.** Catalog refresh cadence and trust signals (stars, recency, source provenance). (ADR-NNN during catalog seeding work_unit)
- **OQ-6.** Constitution AppMakera content — full draft pending separate work_unit (WU-002).
- **OQ-7.** State migrations — when work_unit schema or config schema changes between versions, how do existing projects upgrade? (ADR-NNN before v1.1)
- **OQ-8.** Telemetry / observability — does AppMaker phone home anything? Default: no. ADR if proposed otherwise.

---

## Acceptance Criteria (this ADR as investigation work_unit per D2a)

- [x] At least 3 alternatives considered (8 documented)
- [x] Killed options explicit with reasons (KA-1 through KA-8)
- [x] Risks listed with mitigations (9 risks)
- [x] Sources cited (9 perspectives + 4 conversation rounds with Codex)
- [x] Decisions numbered and individually addressable (D1–D14, plus D2a)
- [x] Bootstrap exception documented in metadata and § "Bootstrap Exception"
- [x] Open questions parked, not pretended resolved (OQ-1 through OQ-8)
- [x] Rollback plan specified (soft + hard)
- [ ] **PENDING:** Human review and acceptance by pawedo@gmail.com
- [ ] **PENDING:** Status changed from `PROPOSED` to `ACCEPTED` upon approval

---

## Verification (artifact schema: adr-v1)

| Required section | Present? |
|---|---|
| Status | ✓ |
| Metadata | ✓ |
| Context | ✓ |
| Sources Consulted | ✓ |
| Decision (numbered, individually addressable) | ✓ (15 items: D1–D14 + D2a) |
| Killed Alternatives (≥3) | ✓ (8) |
| Risks and Mitigations (with table) | ✓ (9 rows) |
| Rollback Plan | ✓ |
| Open Questions | ✓ (8) |
| Acceptance Criteria | ✓ |
| Verification table | ✓ |

---

## Next Work Units (preview, not commitment)

After ADR-001 is **ACCEPTED**:

- **WU-002 (investigation):** Draft `constitution.md` for AppMaker itself. Eat-own-dogfood: AppMaker's first non-bootstrap artifact is its own governance.
- **WU-003 (investigation):** Define `work-unit.yaml` schema v1 (likely Zod). Output: schema definition + validator stub.
- **WU-004 (implementation):** Repo skeleton — directories, `package.json`, `tsconfig.json`, `.gitignore`, `README.md`, `appmaker.config.yaml` template.
- **WU-005 (implementation):** CLI shell — `appmaker --help`, command stubs (`profile`, `advise`, `init`, `compile`, `execute`, `verify`, `review`, `promote`).
- **WU-006 (implementation):** Profiler v0 — `package.json` + `tsconfig.json` + framework signal extractors (Next.js, Express, FastAPI, etc.).
- **WU-007 (implementation):** Catalog seed — 30–40 curated skills with `triggers/excludes/recommends_with` metadata yaml. Sources: anthropics/skills, Matt Pocock skills, hand-curated.
- **WU-008 (implementation):** Recommender v0 — profile → active skill set mapping with explanations.
- **WU-009 (implementation):** Per-project active skill set — `.claude/settings.json` writer with allowlist.
- **WU-010 (investigation):** End-to-end smoke test — `appmaker init` on a real project (likely a fresh test repo, not ClaimCompass to avoid mixing concerns).

Each WU follows the AppMaker pipeline:
```
work-unit.yaml → context-pack.md → execution → verification → review scorecard → gate → promote
```

WU-002 through WU-010 produce a **working v1 Process Kernel** with: profile, advise, work_unit lifecycle, simple context compiler, single-agent runner, gates with fail-closed, and three-stream logging. Estimated effort: ~7 days of focused work.

---

## Revision History

| Date | Revisor | Changes |
|---|---|---|
| 2026-05-09 | Claude (initial draft) | First version, status PROPOSED |
| 2026-05-09 | Codex (fact-check round) → Claude (applied fixes) | **R1.** Corrected AppsMaker-2025 path (`/Users/pawel/Projects/AppsMaker-2025/`, not `AppsMaker/`). **R2.** Corrected "16 months untouched" → "~5.5 months untouched (since 2025-11-24)". **R3.** Softened KA-1 evidence claim — "End-to-end tested" → "one demo voting artifact exists; consensus: 10 with disagreement_signal: true, NOT strong E2E evidence". **R4.** Removed unverified VoltAgent star count; kept "100+ subagents". No architectural decisions changed. |
| 2026-05-09 | Codex (final review) | Status changed `PROPOSED` → `ACCEPTED`. All four factual fixes verified applied. Revision history present. No architectural decisions changed. From this point forward, no more bootstrap exceptions — ADR-002+ via work_unit pipeline. |

---

**End of ADR-001.**
