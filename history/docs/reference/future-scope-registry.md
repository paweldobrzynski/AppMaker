# Future Scope Registry

Status: REFERENCE
Created: 2026-05-10
Purpose: Preserve future AppMaker scope ideas without expanding the current
work_unit.

This file is a parking lot for promising but deferred scopes. It is not an ADR,
not a mandate, and not an implementation plan. A scope listed here becomes active
only when a dedicated work_unit or ADR accepts it.

## Rules

1. Deferred scopes do not change current gates.
2. Deferred scopes do not authorize runtime dependencies.
3. Deferred scopes do not expand an active work_unit unless that work_unit's
   accepted contract explicitly says so.
4. Each future ADR must re-evaluate the scope, alternatives, risks, and rollback
   plan before adoption.
5. References to tools such as Graphify, Open Design, Caveman, CodeBurn,
   OpenBrain, Obsidian, Browser Harness, or Claude Code are inspiration or
   evaluation candidates, not dependencies.

Priority meanings:

- `core`: likely needed for AppMaker v1/v1.1 quality and gate reliability.
- `soon`: useful after current lifecycle pieces stabilize, but not a blocker.
- `conditional`: useful only when a concrete project, scale, or pain appears.
- `speculative`: preserve as an idea; do not design until a strong trigger exists.

Classification is a lightweight grouping label for review and deduplication; it
does not imply ownership, ordering, or activation.

## Current Lifecycle Context

AppMaker v1 is currently building a Level 6 harness-engineering system on top of:

- Level 3 context engineering
- Level 4 compounding engineering
- strict work_unit contracts
- explicit context-packs
- review/promote gates
- lessons.jsonl memory feedback
- schemas v1

Level 7 background agents and Level 8 autonomous agent teams are intentionally
deferred until gates, validators, safety hooks, and implementation runners are
proven.

## Deferred Scopes

### Agent-Native Project Interface

Priority: soon
Classification: context-interface

Trigger: first real project bootstrap, or when AppMaker must expose one project
interface across multiple agent tools.

Core synthesis: create a minimal agent-facing surface (`AGENTS.md`,
`.appmaker/context/`, copy-pasteable commands, task contracts) without replacing
constitution, ADRs, PRD, schemas, or work_unit contracts.

Future decisions: always-on vs on-demand context, tool-specific adapters,
human-readable vs agent-readable docs, and how much project state belongs in
`AGENTS.md`.

Hard boundaries: do not load all skills by default, do not create broad always-on
context, and do not make agent docs authoritative over promoted artifacts.

### Verifiability Standards

Priority: core
Classification: verification

Trigger: requirements become too subjective or too hard to verify during
implementation or UI work.

Core synthesis: convert vague requirements into either automated checks or
human-review-with-criteria. Subjective quality is allowed, but it must have
explicit review criteria.

Future decisions: verifiable requirement patterns, screenshot/layout checks,
accessibility checks, workflow completion checks, and a proxy catalog for
subjective goals.

Hard boundaries: no vague goals such as "beautiful UI" without a proxy; do not
pretend subjective judgment is automated; mark human-owned review explicitly.

### Evidence-First Fact Policy

Priority: core
Classification: evidence-governance

Trigger: stale references, hallucinated packages/tools, external-state mistakes,
or review findings caused by relying on model memory instead of evidence.

Core synthesis: classify claims by provenance (`model_assertion`,
`file_verified`, `schema_verified`, `parser_verified`, `web_verified`,
`human_verified`) and require direct source checks for high-risk claims.

Future decisions: dependency/package existence checks, quote verification,
source citation rules, current-information search rules, and uncertainty markers.

Hard boundaries: LLM memory is not evidence for external state, package
existence, current docs, APIs, laws, schemas, or local repo facts. Search results
are input evidence; critical sources must be read directly.

### Research Cache And Evidence Pack

Priority: core
Classification: evidence-management

Trigger: a work_unit depends on external APIs, unfamiliar libraries, current
documentation, vendor behavior, legal/security facts, or expensive repo
exploration.

Core synthesis: cache sprint/work_unit-scoped research with provenance, dates,
expiry, assumptions, and open uncertainties so agents do not repeatedly rediscover
the same evidence.

Future decisions: `.appmaker/research/<work-unit-id>/research.md`,
`evidence-manifest.yaml`, freshness rules, and safe-reuse vs must-recheck
markers.

Hard boundaries: research cache is not canonical truth; stale research must not
be reused silently; high-risk decisions still need direct source review.

### Context-Pack Schema

Priority: core
Classification: context-governance

Trigger: repeated context-pack drift or v1.1 context-compiler work.

Core synthesis: define context-packs as executable harness logic with required
sections, source provenance, R8 inclusions, context budgets, and lesson
traceability.

Future decisions: formal schema, validator, budget policy, and source-reference
format.

Hard boundaries: no full repo dumps, no stale history when compact source
artifacts exist, and no passive "notes" framing for load-bearing context.

### Context Development Lifecycle

Priority: soon
Classification: context-governance

Trigger: prompts, context-packs, skills, rulefiles, glossaries, research caches,
and decomposition artifacts become reusable operational assets.

Core synthesis: treat context like code: generate, evaluate, distribute, observe,
adapt. Context changes need tests, review, packaging, observability, and feedback
loops.

Future decisions: context eval suite, context package manifest, private registry,
context filter, context lint, probabilistic eval thresholds, and feedback loops
from logs/PRs/QA/prod incidents.

Hard boundaries: context artifacts are not trusted because they are popular or
repo-local; sandboxing does not protect against bad context already loaded by an
agent; feedback must improve source context, not only patch one-off outputs.

### Rulefile Governance

Priority: core
Classification: rule-governance

Trigger: `AGENTS.md`, `CLAUDE.md`, skills, or agent-specific rulefiles start
influencing generated artifacts.

Core synthesis: shared rulefiles are governance artifacts. Agents may draft
changes, but humans review meaning, scope, token cost, and evidence before
acceptance.

Future decisions: ownership, allowed sections, size budget, validation command
block, rule-change template, stale-rule removal, and rulefile evals.

Hard boundaries: no secrets or one-off session notes; keep always-on rules small;
move rare guidance to pullable references; enforce deterministic rules with
hooks/lints/schemas where possible.

### Ubiquitous Language Artifact

Priority: soon
Classification: domain-language

Trigger: PRD synthesis, brownfield onboarding, architecture review, or repeated
confusion over domain terms, lifecycle terms, or module names.

Core synthesis: maintain shared domain language so humans and agents use the same
terms for concepts, states, and lifecycle transitions.

Future decisions: `.appmaker/glossary.md`, aliases to avoid, canonical verbs,
term provenance, and glossary update checklist.

Hard boundaries: glossary terms are shared language, not hidden requirements;
agents must not invent canonical domain terms without human acceptance.

### Prototype And Spike Stage

Priority: conditional
Classification: discovery

Trigger: taste, UX, architecture, API behavior, testing strategy, or external
service behavior is too ambiguous to specify confidently.

Core synthesis: use throwaway prototypes/spikes to answer explicit questions
before PRD/decomposition hardens the plan.

Future decisions: spike plan, findings artifact, screenshots/recordings, option
comparison, and PRD/ADR decision integration.

Hard boundaries: spike output is evidence, not production code; every spike must
answer an explicit question; stale prototype code must not remain in production
paths without a later implementation WU.

### Design Exploration Stage

Priority: conditional
Classification: design

Trigger: UI-heavy project after PRD is accepted and before decomposition.

Core synthesis: generate PRD-driven design artifacts and prototypes to impose
human taste and design-system constraints before implementation.

Future decisions: design brief, screen map, prototype HTML, UX decisions, design
review scorecard, and whether tools like Open Design are evaluated.

Hard boundaries: no runtime dependency without ADR; prototypes are not production
code; every screen maps to PRD workflows; human review owns taste and UX fit.

### Graph-Based Context Compiler

Priority: speculative
Classification: context-indexing

Trigger: large repos, brownfield onboarding, or repeated context-pack bloat from
raw file reading.

Core synthesis: build a graph/index over code, docs, rationale, imports, calls,
and artifacts so agents can query structure without loading everything. The graph
can also guide attention by surfacing clusters, central concepts, weak links,
orphan concepts, contradictions, underdeveloped topics, and structural gaps.

Future decisions: graph JSON/report/HTML, query policy, stale-graph detection,
provenance for inferred edges, gap-analysis reports, graph-derived prompts,
research questions / next-WU candidates, and whether Graphify/InfraNodus-style
tools are evaluated.

Hard boundaries: graph output is an index, not source of truth; inferred edges are
not authoritative without provenance; canonical truth remains accepted artifacts
and source files. Graph gaps are heuristics; they must not create scope without
human review.

### LLM Wiki And Synthesized Knowledge Base

Priority: speculative
Classification: knowledge-synthesis

Trigger: AppMaker accumulates enough ADRs, PRDs, work_units, lessons, events,
research notes, transcripts, and external docs that raw retrieval becomes too
expensive and repetitive.

Core synthesis: use a hybrid memory architecture. Canonical sources remain
structured and source-grounded; wiki pages are compiled views that make
accumulated knowledge browsable, linkable, and cheap to load. AI maintains the
compiled view, not the truth itself.

Future decisions: synthesis timing (ingest-time, query-time, scheduled,
on-demand, hybrid), canonical store/manifest, wiki compiler, provenance rules,
contradiction preservation, and wiki lint.

Hard boundaries: wiki is not source of truth; pages should be regenerated from
sources; contradictions are signals and must not be smoothed into one narrative;
multi-agent markdown writes require locking or generated-view architecture.

### Project Standards Pack And Architecture Selection

Priority: conditional
Classification: architecture-governance

Trigger: after PRD and before decomposition for a new product, stack selection,
or major architecture decision.

Core synthesis: capture stack, standards, dependency policy, testing policy, and
maintenance expectations before implementation work expands.

Future decisions: standards YAML, architecture profile, decision matrix,
dependency policy, and testing policy.

Hard boundaries: prefer the simplest architecture that can survive expected
change; major choices need ADR alternatives and killed options; standards must be
enforceable by gates or explicit review.

### Architecture Deepening Protocol

Priority: conditional
Classification: architecture-governance

Trigger: legacy/brownfield onboarding or fast AI-assisted code growth increases
entropy faster than review can absorb.

Core synthesis: use agent-assisted scouting and human-led judgment to find
shallow modules, deepen boundaries, and improve locality, leverage, and testable
interfaces.

Future decisions: deepening report, module vocabulary, dependency notes,
gray-box module contracts, interface review checklist, adapter plan, and
test-boundary plan.

Hard boundaries: agents may identify candidates, but humans choose architecture
changes; no blind AFK refactors; optimize for locality/leverage/testability, not
fewer files or aesthetic neatness.

### Agent Modes And Context Budget

Priority: soon
Classification: execution-governance

Trigger: AppMaker has more than one runner mode or starts executing
implementation work_units.

Core synthesis: modes are enforceable permissions, not personas. Each mode gets a
purpose, write scope, tool scope, and context budget.

Future decisions: `research`, `plan`, `architect`, `implement`, `review`,
per-mode permissions, allowed tools, session reset rules, and unresolved question
format.

Hard boundaries: `plan` stays read-only; implementation starts only after an
accepted plan for non-trivial work; avoid theatrical roles before one mode works.

### Agent CLI Ergonomics And Session Operations

Priority: soon
Classification: operator-experience

Trigger: agent CLI session hygiene, token visibility, screenshots, notifications,
git safety, or worktrees affect throughput and correctness.

Core synthesis: standardize practical agent operations without binding AppMaker
to one vendor CLI.

Future decisions: repo-root guard, session start checklist, `/context`-style
token audit, `/clear`/`/resume`, screenshot evidence rule, notifications, git
checkpoint policy, worktree layout, safe permission defaults.

Hard boundaries: ergonomics must not bypass gates or write-scope rules; dangerous
skip modes only in disposable sandboxes; git is a safety net, not a substitute for
tests/review/rollback.

### Minimal Friendly CLI Interface

Priority: core
Classification: product-interface

Trigger: first CLI implementation WU or any attempt to expose AppMaker to users
outside the bootstrap authors.

Core synthesis: AppMaker's user-facing CLI should start from user intent, not
kernel artifact management. The happy path is `appmaker start "<request>"`,
followed by guided clarification, work classification, hidden context
compilation, agent run/handoff, verification, and concise review output.

Future decisions: exact command names, whether v0 runs agents directly or only
prepares handoff, interactive vs non-interactive mode, agent provider config,
review UI, and how micro-change / normal / high-risk lanes are surfaced.

Hard boundaries: manual context-pack copy-paste is debug fallback only; users
should not need to understand `work-unit.yaml`, JSONL logs, schema validators, or
promote gates for the default workflow. Friendly UX must not bypass R4/R5/R7/R8
enforcement; it wraps the kernel, it does not weaken it.

### Multi-Phase Execution Plan Protocol

Priority: soon
Classification: execution-planning

Trigger: implementation work is large enough to exceed one safe context window or
needs multiple reviewable phases.

Core synthesis: durable plan artifacts bridge context resets and make phase-by-
phase execution reviewable.

Future decisions: `.appmaker/work-units/<id>/plan.md`, phase checklist, status
markers, changed-files summary, verification results, context reset handoff, and
optional issue sync.

Hard boundaries: plans must not live only in chat; each phase must be reviewable;
context reset is allowed only after durable checkpoint artifacts are current.

### AFK Runner Topology

Priority: soon
Classification: execution-runner

Trigger: decomposition produces multiple non-blocked AFK/autonomous slices.

Core synthesis: run implementation as a controlled topology: planner selects
non-blocked work, implementers use isolated worktrees/sandboxes, reviewers run in
fresh context, and a merger integrates with verification.

Future decisions: planner/implementer/reviewer/merger prompts, sandbox policy,
worktree naming, max parallelism, branch policy, and per-issue closeout contract.

Hard boundaries: parallelism follows the relation graph; HITL slices return to
humans; reviewer must not rely on implementer's saturated context; review capacity
limits code generation.

### QA Feedback Loop And Repair Runner

Priority: soon
Classification: qa-repair

Trigger: implementation produces user-facing behavior or QA finds edge cases not
captured by PRD/issues.

Core synthesis: after implementation, generate a QA plan, let humans inspect real
outputs, convert feedback into bounded issues, and let repair runners fix them
with verification.

Future decisions: QA plan artifact, feedback issue template, repair runner input
contract, human-only labels, regression checklist, and commit-to-issue trace.

Hard boundaries: QA plan is not acceptance criteria; human QA owns product
judgment and UX feel; repair runners consume only bounded issues with
reproduction/observed behavior.

### Concise Output Policy

Priority: conditional
Classification: communication-governance

Trigger: review loops become noisy or output tokens degrade throughput.

Core synthesis: use concise output as a harness optimization while preserving
evidence, traceability, review findings, and required artifact structure.

Future decisions: verbosity levels, per-mode response budgets, final-answer vs
working-update rules, review finding format, and token-savings metrics.

Hard boundaries: concision must not weaken R8 context, R12 no-silent-fallbacks,
R13 verification, citations, or acceptance criteria. Caveman is inspiration only.

### Token Budget And Context Economy

Priority: soon
Classification: context-economy

Trigger: agents spend more tokens rediscovering, re-reading, or restating context
than doing useful work.

Core synthesis: maximize useful signal per token through tiered context,
on-demand references, summaries with provenance, source refs, prompt caching, and
token telemetry.

Future decisions: per-mode token budgets, context-pack hard/soft limits,
always-on allowlist, reference index, deduplication, summary format, reset
protocol, metrics, and budget exceptions.

Hard boundaries: do not hide evidence to save tokens; summaries do not replace
sources at gates; different artifact types need different density.

### Smart-Zone Work Sizing And Reset Protocol

Priority: soon
Classification: context-economy

Trigger: long sessions degrade decisions despite large context windows.

Core synthesis: size tasks to stay in a reliable context zone and prefer
clear/reset plus durable artifacts over repeated opaque compaction.

Future decisions: per-mode smart-zone budgets, decomposition task-size heuristic,
reset checklist, compact/handoff schema, token status reporting, and stale-
compaction risk checks.

Hard boundaries: larger context windows do not justify larger work_units; compact
summaries must carry provenance, unresolved questions, changed files,
verification state, and next action.

### Lazy Context And Project Memory Protocol

Priority: core
Classification: memory

Trigger: teams need continuity across sessions, but always-on memory and stale
plans begin to pollute fresh contexts.

Core synthesis: project memory is a lazy retrieval layer, not canonical truth and
not an always-on dump.

Future decisions: memory index, todos, session summaries, manifest with dates and
provenance, stale/active markers, source-of-truth hierarchy, and memory-to-
context selection rules.

Hard boundaries: promoted artifacts win over memory; old PRDs/plans/summaries
must not silently override current code or ADRs; no secrets in agent memory.

### Harness Evaluation And Ablation

Priority: conditional
Classification: harness-evaluation

Trigger: enough work_units exist to compare harness changes against real traces.

Core synthesis: evaluate the harness itself: catch rate, gate failures, token
trends, and which structures improve outcomes.

Future decisions: metrics, review catch-rate, context-pack trend, failure reason
taxonomy, raw trace retention, and ablation protocol.

Hard boundaries: optimize harness behavior, not model choice alone; preserve raw
traces; prune structure that does not improve outcomes.

### Metric-Driven Experiment Runner

Priority: conditional
Classification: harness-evaluation

Trigger: a prompt, context-pack, performance path, bundle, test runtime, browser
workflow, or other bounded surface has a cheap objective metric worth optimizing.

Core synthesis: establish a baseline first, define testable criteria, then run
auto-research-style loops: pick the weakest failing criterion, form a
hypothesis, make a bounded mutation, evaluate immutably, keep/revert, log the
result, and repeat within a time/cost budget.

Future decisions: criteria schema (exact condition, one variable, true/false
proxy), scalar metric format, baseline sampling, evaluator mode (deterministic
script preferred; LLM judge only with rubric/examples), immutable evaluator
contract, mutation surface policy, trial/iteration budget, sandbox/worktree
execution, scheduled experiment history, result log schema, Goodhart/overfitting
checks, and review gate for accepted improvements.

Hard boundaries: evaluator is read-only to the agent; metric must have direction
and be hard to game; criteria must not bundle multiple variables; delayed or
confounded real-world metrics require sample-size/confounder handling; scheduled
external-facing changes remain human-reviewed proposals until rollback and
statistical policy exists; no subjective UX/taste/architecture optimization
without human gate; no production secrets/data; accepted improvements still need
diff and test review.

### Review Protocol And Reviewer Principle

Priority: core
Classification: review-governance

Trigger: before implementation runner, or when review becomes ad hoc.

Core synthesis: independent review is a gate, not decoration. The generator must
not be the only reviewer of its own artifact.

Future decisions: reviewer independence rule, scorecard schema, cross-decision
checklist, cross-artifact checklist, and high-risk review policy.

Hard boundaries: self-check is useful but insufficient for promotion.

### Push/Pull Context Policy

Priority: soon
Classification: context-governance

Trigger: standards, skills, checklists, and rules become too large for always-on
context.

Core synthesis: implementers pull detailed context when relevant; reviewers get
standards pushed explicitly; enforceable rules move to hooks/lints/schemas.

Future decisions: context classes (`always_on`, `pull_on_demand`,
`push_to_reviewer`, `deterministic_guardrail`), reviewer bundle, skill discovery,
conflict checks, and instruction-budget review.

Hard boundaries: do not push every rule into every session; always-on context
contains only durable high-frequency constraints; non-delegable judgments must
remain visible to reviewers.

### Backpressure And Safety/Quality Hooks

Priority: core
Classification: safety-hooks

Trigger: before implementation runner promotes code.

Core synthesis: deterministic guardrails should enforce command choice, write
scope, destructive action blocks, formatting, package manager rules, dependency
boundaries, and verification loops.

Future decisions: pre-tool hooks, lint/type/test hooks, pre-commit policy,
security checks, dependency approval, changed-file risk classifier, and allowed
write policy.

Hard boundaries: if a rule can be enforced deterministically, do not rely on
prompt text alone; hooks fail closed and explain the allowed alternative; humans
still review high-risk changes.

### Validator Implementation

Priority: core
Classification: validation-tooling

Trigger: manual schema conformance becomes expensive or inconsistent.

Core synthesis: install real JSON Schema validation and expose it through CLI/CI.

Future decisions: validator choice, `appmaker validate`, schema reports, CI
integration, and error format.

Hard boundaries: do not pretend meta-validation exists before tooling exists;
validator install is implementation work, not investigation-only ADR.

### Schema Migration Tooling

Priority: conditional
Classification: schema-governance

Trigger: first schema v2 or breaking schema change.

Core synthesis: schema evolution needs migration policy, compatibility checks,
and historical artifact protection.

Future decisions: migration tool, archive policy, compatibility report, and
`appmaker migrate`.

Hard boundaries: historical audit artifacts remain valid under historical schema;
new schema versions must not silently reinterpret old artifacts.

### Voting Runner Protocol

Priority: speculative
Classification: execution-runner

Trigger: high-stakes decisions need multiple candidates or consensus scoring.

Core synthesis: use voting only when independent candidate generation materially
reduces risk.

Future decisions: `execution.mode: voting`, k-value, scoring format, red flags,
and consensus/failure semantics.

Hard boundaries: not for every work_unit; no silent fallback to single-agent when
voting is declared.

### Cross-Project Pattern Library

Priority: conditional
Classification: knowledge-reuse

Trigger: multiple projects produce enough lessons to make cross-project recall
valuable.

Core synthesis: preserve successful patterns and failed experiments with
provenance so future projects can reuse judgment without automatic adoption.

Future decisions: global lesson index, pattern ranking, recall command, failure
records, and provenance policy.

Hard boundaries: reused patterns are recommendations, not decisions.

### Output Routing And Artifact Consolidation

Priority: core
Classification: artifact-management

Trigger: skills, workflow chains, or work_units start producing outputs in
unpredictable locations or leaving important results only in chat/terminal
history.

Core synthesis: define a predictable artifact routing convention so every output
is written under the relevant project/client/work_unit/brief with source,
producer, timestamp, and review status.

Future decisions: output directory taxonomy, skill-output manifests,
brief-to-artifact linkage, temporary vs promoted artifact rules, and cleanup or
archive policy.

Hard boundaries: generated outputs are not promoted artifacts until a gate says
so; do not let agent convenience overwrite canonical ADR/PRD/WU locations; chat
history is not durable storage.

### MCP Server Interface

Priority: conditional
Classification: integration

Trigger: CLI workflow stabilizes and agent tools need dynamic access to AppMaker
operations.

Core synthesis: expose stable AppMaker operations over MCP after CLI semantics are
proven.

Future decisions: `context_compile`, `gate_check`, `record_event`, `get_profile`,
and `recall_pattern`.

Hard boundaries: CLI-first remains source capability; MCP must not invent
behavior unavailable in core.

### MCP Budget And Allowlist Policy

Priority: conditional
Classification: integration-governance

Trigger: MCP servers help with docs, browser control, design tools, emulators,
SaaS APIs, or validation loops but increase token, context, setup, or security
risk.

Core synthesis: MCPs are dependencies and context providers. Enable them per
project/work_unit with cost, provenance, and security review.

Future decisions: allowlist, install request template, enabled/disabled manifest,
token estimate, permission scopes, removal audit, and fallback policy.

Hard boundaries: no auto-install/global enablement without review; prefer local
scripts/direct commands when they give the same verification with less risk; MCP
output is evidence, not authority.

### Catalog Refresh And Trust Signals

Priority: conditional
Classification: catalog-governance

Trigger: advisor/catalog seeding expands beyond a small curated set.

Core synthesis: evaluate skills/tools by provenance, verification, freshness, and
conflict detection, not popularity.

Future decisions: metadata schema, trust score, source provenance, last verified
date, deprecation markers, and overlap/conflict detection.

Hard boundaries: stars are weak signals; deprecated/unverified/conflicting skills
must not auto-enable.

### Cost Analytics And Token Observability

Priority: conditional
Classification: observability

Trigger: cost, token use, or review-loop expense becomes hard to reason about
manually.

Core synthesis: local-first telemetry should show cost/token use per work_unit,
model, tool, MCP, context-pack, and review loop.

Future decisions: `.appmaker/metrics.jsonl`, dashboards/reports, cost
recommendations, and project/model/tool attribution.

Hard boundaries: cost metrics must not justify skipping gates; token reduction
must not degrade governance artifacts.

### Multimodal Evidence Intake

Priority: conditional
Classification: evidence-management

Trigger: investigations need recordings, screenshots, bug videos, walkthroughs,
diagrams, or audio transcripts.

Core synthesis: persist multimodal evidence with provenance, timestamps, summary,
redaction, and manifest so it can support investigation without becoming proof by
itself.

Future decisions: `.appmaker/evidence/<work-unit-id>/`, transcripts, key frames,
screenshot index, redaction checklist, and media processing policy.

Hard boundaries: evidence inputs are not proof; sensitive data needs redaction or
approval; no external media-processing service without ADR/privacy review.

### Browser Backpressure And UI Verification

Priority: conditional
Classification: ui-verification

Trigger: implementation work_units produce browser-visible UI or browser-
dependent workflows.

Core synthesis: combine deterministic browser tests with exploratory browser
assistance and screenshot/layout evidence.

Future decisions: Playwright commands, screenshot policy, layout/accessibility
checks, failed-selector lessons, and design-review integration.

Hard boundaries: deterministic tests remain primary for promote gates;
exploratory browser agents assist but do not replace acceptance criteria; flaky
paths become lessons, not silent retries.

## Next Expected Use

WU-007 / ADR-005 may reference this registry only as a non-binding source of
deferred scope. The current WU remains limited to Work_unit Decomposition and the
Matt Pocock `to-issues` pattern.
