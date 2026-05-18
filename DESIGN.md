# AppMaker — Current Design (P-Hybrid plugin)

Status: 19 skills (15 core + afk + status + token-audit + next). v0.2.21 — anti-bureaucracy patch: `rigor_level` config, Execution Record factual-field auto-fill guidance, checklist gates limited to invariant breakage, and METHOD.md field rule for new artifacts. 12 smoke suites, 90 assertions. Test harness covers hooks + glossary-extract + version SoT (with release-target), rigor config, checklist Execution Record gates.
Last updated: 2026-05-18.

## Esencja (v0.2.12+ pozycjonowanie)

**AppMaker = spec + governance layer ON TOP of Claude Code runtime.**

AppMaker NIE re-implementuje agent infrastructure. Claude Code dostarcza runtime (tool calls, Agent View, `/goal`, `/review` + `/ultra-review`, compaction, plugin/marketplace, hooks). AppMaker dodaje to czego Claude Code nie ma:

- **Lifecycle discipline:** init → grill → interview → prd → decompose → tdd → review → archive
- **Traceability:** PRD `pcrit-*` IDs → backlog `traces_to` → AC checkboxes → tests
- **Governance:** constitution (5-7 rules) + glossary (ubiquitous language) + deterministic checklist gates
- **Audit trail:** archive flow preserves all artifacts; retro feeds memory wiki; memory wiki is explicit + auditable (Karpathy-style, NOT automatic-invisible)

**Delegation principle (v0.2.12):** when Claude Code ships a better primitive, AppMaker delegates. v0.2.12 introduces:
- `/appmaker:review --mode=ultra` → invokes `/ultra-review`, AppMaker adds compliance layer
- `/appmaker:afk --driver=goal` → uses `/goal` instead of custom loop
- `wiki_preflight_mode: auto|always|never` → respect smarter compaction when available
- `/appmaker:status` → hint at `cloud agents` for multi-session view

AppMaker layer remains durable; runtime layer evolves with Claude Code. Pair'uje z Graphify (optional read-only codebase intelligence) i Forest's CLAUDE.md (optional universal agent baseline).

## Pozycjonowanie (P-Hybrid)

Cztery warstwy, każda niezależna i opt-in:

```
LAYER 1: Plugin skills (Matt Pocock-style markdown)
  Located: plugin/appmaker/skills/<name>/SKILL.md
  Loaded via: claude --plugin-dir /path/to/AppMaker/plugin/appmaker
  Invoked: /appmaker:<name> [args]

LAYER 2: Optional orchestrator
  /appmaker:start — smart routing, klasyfikuje user intent.
  Świadomy Graphify dla lepszego routing.

LAYER 3: Optional Graphify pair (separate tool)
  Standalone tool (pip install graphifyy). AppMaker zna jego output
  convention (graphify-out/GRAPH_REPORT.md + graph.json), czyta Graphify CLI/report,
  zapisuje małe `appmaker/context/*.md` packets. Graphify remains read-only.

LAYER 4: Optional AFK runner
  /appmaker:afk — bounded autonomous loop for explicit `execution_class: autonomous` backlog items.
```

Profile:
- **A** (Layer 1 only) = Pocock mode, manual workflow
- **B** (Layer 1+2) = guided mode, no graph
- **C** (Layer 1+3) = smart context, manual workflow
- **D** (Layer 1+2+3) = full opinionated workflow
- **E** (Layer 1+2+3+4) = "wszystko zepnie" — full lifecycle + AFK execution

## Skills

### Core (15 skills, 15 written)

| Skill | Status | `disable-model-invocation` | Inspiration | Purpose |
|---|---|---|---|---|
| `/appmaker:init` | ✓ | true | Custom | Bootstrap fresh AppMaker setup, optional integrations |
| `/appmaker:start` | ✓ | false | Smart routing | Entry point — klasyfikuje intent, sugeruje workflow |
| `/appmaker:grill` | ✓ | false | Matt Pocock `productivity/grill-me` 1:1 | General-purpose relentless questioning |
| `/appmaker:grill-brownfield` | ✓ | false | Matt Pocock `engineering/grill-with-docs` 1:1 | Brownfield variant |
| `/appmaker:interview` | ✓ | true | Composition over grill + structured output | Feature-specific entry |
| `/appmaker:prd` | ✓ | true | Matt Pocock `to-prd` + AppMaker extensions | PRD with Understanding section + Clarifications |
| `/appmaker:decompose` | ✓ | true | Matt Pocock `to-issues` + AppMaker extensions | Vertical slices, execution_class, backlog items |
| `/appmaker:tdd` | ✓ | true | Matt Pocock `tdd` (5 supporting files) + AppMaker | Test-first per slice, AC checkbox tracking |
| `/appmaker:diagnose` | ✓ | true | Matt Pocock `diagnose` 1:1 | Bug investigation flow |
| `/appmaker:review` | ✓ | true | Custom (subagent invocation) | Critic gate, invokes code-reviewer subagent + writes review.md (v0.2.9: was `false`, fixed) |
| `/appmaker:checklist` | ✓ | true | Spec Kit `/speckit.analyze` | Deterministic cross-artifact gate |
| `/appmaker:archive` | ✓ | true | OpenSpec `/opsx:archive` + AppMaker retro | Close out feature, optional retro |
| `/appmaker:context` | ✓ | true | Custom (Graphify-aware) | Codebase context packet retrieval |
| `/appmaker:feedback` | ✓ | true | Matt's QA feedback button | Quick capture → backlog item |
| `/appmaker:glossary` | ✓ | true | Matt Pocock `deprecated/ubiquitous-language` | Ubiquitous language, best-effort maintained via parent invocation (v0.2.9: was `false`, fixed) |

### Opt-in deepening (4 skills, all TODO)

| Skill | Inspiration | Purpose |
|---|---|---|
| `/appmaker:clarify` | Spec Kit `/speckit.clarify` | Extra questions for ambiguous areas |
| `/appmaker:research` | Future-scope: Research Cache | Cache external research with freshness markers |
| `/appmaker:spike` | Matt Pocock `prototype` (SKILL+LOGIC+UI) | Throwaway prototypes (logic OR ui variant) |
| `/appmaker:plan` | Future-scope: Multi-Phase Execution | Durable plan artifacts for large work units |

### Layer 4 — AFK runner

| Skill | Inspiration | Purpose |
|---|---|---|
| `/appmaker:afk` | Matt's Sandcastle / Ralph loop | Bounded autonomous loop over autonomous backlog items |
| `/appmaker:sync-github` | Custom adapter | TODO: push/pull backlog ↔ GitHub issues (optional) |

## File layout

### Plugin source (this repo)

```
AppMaker/
├── plugin/appmaker/                      ← PLUGIN ROOT (load via --plugin-dir or marketplace install)
│   ├── .claude-plugin/
│   │   └── plugin.json                   ← manifest (name, description, version, author, license)
│   ├── hooks/
│   │   └── session-start.sh              ← v0.2.6: 1-line status print on session start
│   ├── resources/                        ← packaged data materialized by /appmaker:init
│   │   ├── appmaker/
│   │   │   ├── memory/                   ← Karpathy-style wiki seed files
│   │   │   ├── templates/                ← backlog-item, decomposition, context-packet templates
│   │   │   ├── skills/
│   │   │   │   ├── output-style.md       ← v0.2.3: global Compact report contract
│   │   │   │   └── tdd/                  ← Matt Pocock supporting (deep-modules, mocking, ...)
│   │   │   └── config.yaml.template      ← seed config (auto-detected fields filled at init)
│   │   └── graphify/.graphifyignore.template
│   └── skills/                           ← 19 dirs (15 core + afk + status + token-audit + next)
│       ├── init/SKILL.md                 ← /appmaker:init
│       ├── start/SKILL.md                ← /appmaker:start
│       ├── grill/SKILL.md                ← /appmaker:grill
│       ├── grill-brownfield/SKILL.md     ← /appmaker:grill-brownfield
│       ├── interview/SKILL.md            ← /appmaker:interview
│       ├── prd/SKILL.md                  ← /appmaker:prd
│       ├── decompose/SKILL.md            ← /appmaker:decompose
│       ├── tdd/SKILL.md                  ← /appmaker:tdd
│       ├── diagnose/SKILL.md             ← /appmaker:diagnose
│       ├── review/SKILL.md               ← /appmaker:review
│       ├── checklist/SKILL.md            ← /appmaker:checklist
│       ├── archive/SKILL.md              ← /appmaker:archive
│       ├── context/SKILL.md              ← /appmaker:context
│       ├── feedback/SKILL.md             ← /appmaker:feedback
│       ├── glossary/SKILL.md             ← /appmaker:glossary
│       ├── afk/SKILL.md                  ← /appmaker:afk
│       ├── status/SKILL.md               ← /appmaker:status (v0.2.6)
│       └── token-audit/SKILL.md          ← /appmaker:token-audit (v0.2.8)
├── DESIGN.md / README.md / REFERENCES.md
├── tests/
└── history/                              ← archived prior iterations (skill format, slash command format)
```

### In your project (after `/appmaker:init`)

```
your-project/
├── CLAUDE.md                             ← optional Forest's universal agent baseline
└── appmaker/                             ← project state (materialized by /appmaker:init from plugin resources)
    ├── .appmaker-version                 ← plugin resource version marker (current: "<version>")
    ├── config.yaml                       ← project config (commands, providers, integrations)
    ├── constitution.md                   ← 5-7 rules MAX (project principles, user-owned)
    ├── glossary.md                       ← ubiquitous language (deterministic stub extraction + explicit semantic review)
    ├── templates/                        ← per-project overrides (materialized from plugin)
    │   ├── backlog-item-template.md
    │   └── decomposition-template.md
    ├── skills/                           ← supporting reference files (materialized from plugin)
    │   └── tdd/                          ← Matt Pocock supporting (deep-modules, mocking, ...)
    ├── memory/                           ← lazy retrieval, per-area (user-owned, NEVER overwritten on upgrade)
    │   ├── architecture.md
    │   ├── decisions.md
    │   ├── lessons.md
    │   ├── index.md
    │   ├── schema.md
    │   ├── log.md
    │   ├── raw/
    │   └── wiki/
    ├── context/                          ← context packets from Graphify/file discovery (snapshots)
    ├── backlog/
    │   ├── NNN-slug.md                   ← active items
    │   └── done/                         ← archived after completion (timestamp prefix)
    ├── reviews/                          ← optional diff-level review reports
    ├── checklists/                        ← PASS/FAIL/WARN gate reports
    ├── diagnostics/                       ← bug diagnosis reports
    ├── afk/                               ← bounded autonomous run reports
    └── features/
        ├── NNN-slug/                     ← per-feature artifacts (numbered)
        │   ├── interview-result.md
        │   ├── prd.md                    ← includes `## Clarifications`
        │   ├── decomposition.md
        │   ├── slices/
        │   └── retro.md                  ← optional, post-feature
        └── archive/
            └── YYYY-MM-DD-NNN-slug/
```

### Backlog item format

```yaml
---
id: 001
slug: add-dark-mode
status: open                   # open | in_progress | done | blocked
labels: [feature, ui]          # feature | bug | feedback | refactor | architecture
execution_class: autonomous    # human_required | autonomous | conditional
blocked_by: []                 # list of item IDs
traces_to: [pcrit-001, ...]    # PRD acceptance criteria IDs
feature: NNN-slug              # links to appmaker/features/<NNN>/
created: 2026-05-11
source: decompose              # decompose | feedback | manual
---
```

See full template w `appmaker/templates/backlog-item-template.md`.

## Decyzje ustalone (current era — 30+; foundational 1-29 archived)

Decisions 1-29 (foundational architecture: plugin form, Matt Pocock minimalism, P-Hybrid, 15-skill core, OpenSpec lifecycle, memory wiki, AFK runner, plugin refactor, Self-contained materializer) are archived in [DESIGN-history.md](DESIGN-history.md). They are stable — referenced for design rationale during audits and onboarding, not for current work.

Current-era decisions (real-world hardening, production validation, patches v0.2.1–v0.2.10):

30. **Self-contained plugin + materializer + config + version (2026-05-11).** Reviewer's critical finding: plugin nie był samowystarczalny — `appmaker/templates/` + `appmaker/skills/tdd/` żyły poza pluginem, wymagały manual `cp -r` przed użycia. Refactor: (a) resources spakowane do `plugin/appmaker/resources/appmaker/{templates,skills/tdd,config.yaml.template}`; (b) `/appmaker:init` materializes project tree z `${CLAUDE_SKILL_DIR}/../../resources/` (no manual copy); (c) `appmaker/config.yaml` (project config — backlog_provider, test/lint/typecheck/build commands, review_mode, graphify_enabled, afk safety caps) auto-created z template, fields auto-detected per project type (Node/Python/Rust/Go); (d) `appmaker/.appmaker-version` marker — detects fresh init vs upgrade; (e) upgrade rules: NEVER overwrite user-owned files (constitution, glossary, memory, backlog, features, config); REFRESH plugin-owned files (templates, supporting reference) with user confirmation if customized; diff new config fields and append with defaults + comment.
31. **Graphify read-only intelligence + context packets (2026-05-11).** Graphify data is used, but not owned. AppMaker reads `GRAPH_REPORT.md` and uses `graphify query/path/explain`; it does not reimplement graph traversal or persist raw `graph.json` in AppMaker state. `/appmaker:context` writes small `appmaker/context/<date>-<topic>.md` packets containing query, relevant communities, key files, risks, and confidence. PRD/decomposition/backlog/TDD/review/archive link packets. Memory gets only durable synthesis during archive, never raw graph dumps.
32. **Core completion + deterministic gates + memory wiki + AFK (2026-05-11).** Core set is now 15/15. Added `/appmaker:grill-brownfield`, `/appmaker:diagnose`, `/appmaker:checklist`, `/appmaker:feedback`, and Layer 4 `/appmaker:afk`. `/appmaker:checklist` is PASS/FAIL/WARN gate with deterministic file/trace/status/blocker/context/memory checks. Memory upgraded from loose notes to Karpathy-style compiled wiki: `memory/index.md`, `memory/schema.md`, `memory/log.md`, `memory/raw/`, `memory/wiki/{architecture,domain-model,testing,integration-gotchas,feature-index}.md`. AFK is bounded and opt-in: autonomous items only, checklist before TDD, review after TDD, stop on first FAIL.

    **Compiler analogy (v0.2.17 framing, per Cole Medin's Karpathy synthesis):** `memory/raw/` = source code (user-owned drops, optional pre-flight context), `/appmaker:archive` retro = compiler (extracts durable synthesis), `memory/wiki/*.md` = compiled executable (queried by generator skills via pre-flight read), `/appmaker:checklist memory` = test suite (broken `[[links]]`, stale pages, raw orphans). AppMaker's stance vs Cole's auto-hook capture: **explicit + auditable**, NOT invisible + automatic. User-explicit compile via archive retro retained; Cole-style auto-summary on session-end deferred (philosophical wedge — see v0.2.12 "Memory wiki vs Claude Mem hybrid integration" deferred decision).

33. **Plugin hardening through real-world use (caseman BPS session, 2026-05-11).** Sequential patches from production session findings:
    - **v0.2.1:** Removed dynamic injection (` ```! `). Claude Code permission system blocks pre-execution even for read-only blocks. All shell commands moved to Bash tool invocation post-confirmation.
    - **v0.2.2:** zsh shell safety + PRD ID format flexibility. `status`/`path`/`argv`/`argc` are read-only in zsh — checklist now guides safe variable names (`check_state`, `result`). PRD criteria accept any stable ID scheme (canonical `pcrit-NNN` OR project-specific like `SC1`/`ID4`).
    - **v0.2.3:** Packaged `output-style.md` global visual guide. Tables > headings > lists > prose. Anti-patterns documented (ASCII separators, `#:` prefix, prose walls, emoji decoration). Adopted by tdd/prd/review/checklist/archive with skill-specific templates.
    - **v0.2.4:** MANDATORY persistence patches in review/context/afk. Fixes silent failure pattern (BPS session: 10 review invocations + 0 files persisted, 9 context + 0 packets, 6 AFK + 0 reports). Explicit Bash heredoc per artifact path + `test -f` verification.
    - **v0.2.5:** Report Diet — compact report contract in `output-style.md` (single source of truth) referenced by checklist/review/archive-retro/afk. Concrete rules: frontmatter ≤ 4 fields (no counts), summary = 1 line, evidence cells ≤ 80 chars, no `## Suggested Next` in persisted reports, no per-WARN deep-dive blocks duplicating the table, skip empty sections. Triggered by user feedback: "raporty wygladaja ciezko w checklist i innych miejscach" on the actual `2026-05-11-feature-001-bps-risk-compute-post-archive.md` (3 WARN deep-dived as full What/Why/Fix paragraphs after already being in the table).
    - **v0.2.6:** Session-start status line + `/appmaker:status` command. Closes the "post-`/clear` blank-slate" gap — user no longer wonders whether AppMaker is active or what feature is in flight. Hook (`appmaker/hooks/session-start.sh`) is a read-only filesystem inspector that prints one line on session start (`▸ AppMaker v0.2.6 │ feature <NNN-slug> (5/7 slices done) │ checklist: WARN │ /appmaker:status for detail`). Silent exit if no `appmaker/` folder. New `/appmaker:status` skill prints the full phase table on demand. Inspiration: Ron Demerit's "explicit state-declaration moment" pattern from his solopreneur rig — reframed for AppMaker (user IS the orchestrator, so this is a status snapshot for the user, not a role-lock for the agent).
    - **v0.2.17:** Memory wiki linting + `memory/raw/` lifecycle. Surfaced 2026-05-14 by Cole Medin's video on Karpathy-style LLM personal knowledge bases (compiler analogy: raw → wiki → query, with linting test suite). Two gaps identified, both same pattern as decisions.md pre-v0.2.16 (slot exists, no lifecycle):
      1. **`/appmaker:checklist memory` scope + 3 new deterministic checks.** The single pre-existing "Memory wiki health" row was vague ("missing core pages = WARN"). v0.2.17 splits into 4 specific checks: (a) Memory wiki health (existing), (b) Memory broken links — `[[name]]` references in `memory/**` that don't resolve to existing file = FAIL, (c) Memory stale pages — `memory/wiki/*.md` mtime > 30 days = WARN, (d) Memory raw orphans — `memory/raw/*.md` older than 30 days not referenced in `memory/log.md` = WARN. New positional scope arg `memory` runs JUST these checks for cheap audit; `project` scope still includes them. Bash detection via `rg -no '\[\[[^]]+\]\]'` + `find -mtime +30` + `rg -l "<stem>" appmaker/memory/log.md`.
      2. **`memory/raw/` user-owned drop folder lifecycle.** Pre-v0.2.17 audit: directory created by init, ZERO references in any skill — dead seed (same pattern as decisions.md before v0.2.16). v0.2.17 keeps it (option D, per user choice) and beefs up `resources/appmaker/memory/raw/README.md` with explicit Cole/Karpathy framing: "user-owned drop folder for source material before synthesis". Lifecycle: user drops → manual or archive-retro compile → wiki/. Audit via new checklist memory raw-orphan check catches stale entries.
      3. **Compiler analogy explicit in DESIGN.md decision 32.** Cole's "compiler" framing (raw=source, archive retro=compiler, wiki=executable, generator pre-flight=runtime, checklist memory=test suite) sharpens existing AppMaker architecture without new code. 1-line addition.

      Skipped (out of v0.2.17 scope):
      - Cole-style auto-hook session-end summary via Claude Agent SDK. Wedge against decision 32 (explicit + auditable, NOT invisible + automatic). Deferred (see v0.2.12 "Memory wiki vs Claude Mem hybrid integration").
      - `auto_session_summary: false` opt-in config flag implementing Cole's pattern as escape hatch. Adds surface area before friction signal exists. Wait for caseman second lifecycle or explicit user request.
      - Test harness assertion for memory linting checks. Memory check bash is inline in checklist SKILL.md (rg/find/test); concrete enough to verify on next `/appmaker:checklist memory` run. If broken-link false positives surface in real use, add then.

    - **v0.2.16:** Close two ubiquitous-language + decisions.md visibility gaps surfaced 2026-05-14 by direct comparison to Matt Pocock's `grill-with-docs` video (skills/grill-with-docs replacing skills/grill-me with bounded-context + ADR layer). Both gaps were quiet: AppMaker already had `/appmaker:glossary` + `/appmaker:grill-brownfield` doing the work, but downstream visibility was broken. Patch:
      1. **CLAUDE.md pointer (new `init` step 2f, idempotent, default-on).** Project-root `CLAUDE.md` is the file Claude Code auto-reads every session. Without an AppMaker pointer, ambient Claude has no signal that `appmaker/glossary.md` / `appmaker/constitution.md` / `appmaker/memory/decisions.md` exist — they only enter context when a specific skill cats them. v0.2.16 adds a 4-bullet section to `CLAUDE.md` listing the four durable artifacts (glossary, constitution, features, decisions). Runs AFTER Forest's CLAUDE.md handling so destructive curl doesn't clobber the pointer. Idempotent via `^## AppMaker` grep; opt-out via post-init delete (won't be re-added unless section absent on next upgrade).
      2. **`memory/decisions.md` lifecycle wired in `archive` retro (new substep 5; old "Update memory wiki" renumbered to 6).** Pre-v0.2.16 audit: stub created by init, ZERO references in any skill — pure dead seed file. Meanwhile `grill-brownfield` step 5 (v0.2.14) wrote "Architectural decisions surfaced" into `interview-result.md`, but those died with feature archive. v0.2.16 wires: archive retro reads `interview-result.md` + retro answers, filters via Matt's criteria (hard-to-reverse AND surprising-without-context), appends qualifying entries to `memory/decisions.md`. Init seed beefed up with same criteria + format template inline (heredoc replaces old one-liner stub). Explicitly NOT introducing ADR ceremony — same markdown, same memory tree, opt-in via filter.

      Skipped (out of v0.2.16 scope):
      - `grill-brownfield` direct write to `decisions.md`. Pre-implementation decisions are still hypothetical; Matt's "hard-to-reverse" applies post-build. Surfacing stays in `interview-result.md` → archive reads it during retro. No premature writes.
      - `claude_md_pointer_enabled` config flag. Pointer is 4 lines, additive, idempotent. Opt-out is post-init delete. Config flag adds surface area without clear failure mode.
      - Test harness assertion for pointer block. Hook + glossary-extract + version SoT cover bash-script paths; the pointer is inline init bash with idempotent grep — lower risk surface, manual verification on next `/appmaker:init` run suffices.

    - **v0.2.15:** Per-slice review gate in `/appmaker:next` state machine. Surfaced in caseman session (Pawel, 2026-05-13): orchestrator chained `tdd` slices back-to-back with no code-review between them — feature-level `/appmaker:review` only fired after ALL slices done, meaning constitution / glossary / AC-coverage / memory-regression issues in slice 1 propagated through 6 dependent slices before any independent reviewer looked. Patch:
      1. **New state-machine row** in `plugin/appmaker/skills/next/SKILL.md` (priority above "TDD next slice"): `Done slice without per-slice review → /appmaker:review <id>`. Detection in step 1 adds `UNREVIEWED_DONE` (oldest done item for current feature with no `## Review` heading AND no `review_status:` YAML field).
      2. **review.md path resolver fix** in `plugin/appmaker/skills/review/SKILL.md` — was hardcoded `appmaker/backlog/NNN-slug.md`, but `tdd` step 9 moves done items to `appmaker/backlog/done/<YYYY-MM-DD>-NNN-slug.md`. Now resolves by ID across both locations.
      3. **Same critic gate as feature-level review** — backlog-item scope (review/SKILL.md step 2) reads backlog file + parent PRD + `context_packets` + diff. No new checklist, no new subagent. Existing override flow unchanged: review FAIL → user fix or `review_status: failed_overridden` + reason.

      Tradeoff: each slice now pays one review cost before next tdd starts. Mitigated by `--mode=local` default (tokens-only, single subagent invocation). For features where slices are highly independent (no shared infra), this is pure overhead — user can stop chain and skip via "show alternatives" in AskUserQuestion. For features where slices build on shared scaffolding (typical of vertical slice decomp), catching issues at slice N is dramatically cheaper than slice N+M. No new skills.

    - **v0.2.14:** Close brownfield → PRD contract gap. Surfaced in real caseman session: agent ran `/appmaker:grill-brownfield`, then `/appmaker:prd` refused because `interview-result.md` was missing (grill-brownfield only wrote glossary + memory wiki notes, no feature folder + structured artifact). Agent's pragmatic workaround: synthesize fake `interview-result.md` with `readiness: ready_with_override, source: grill-brownfield`. v0.2.14 makes this **canonical**:
      1. **`grill-brownfield` step 5 (NEW, MANDATORY when proceeding to PRD):** allocate feature folder + write `interview-result.md` with `source: grill-brownfield, readiness: ready_with_override, override_reason` documenting that brownfield grilling covered interview dimensions. Same artifact shape as interview output + brownfield-specific sections (Existing System Context, Glossary terms resolved, Architectural decisions surfaced, Open risks).
      2. **`prd` input contract** (clarified): accepts `interview-result.md` with `source: interview` OR `source: grill-brownfield`. PRD synthesis does NOT branch on source — same logic, source is audit metadata.
      3. **Glossary post-step** added to grill-brownfield (Tier 1 of v0.2.11 two-tier pattern) on the just-written artifact.

      Closes the "brownfield-direct workflow has no artifact" gap. Two valid paths now produce same artifact:
      - Wrapped: `/appmaker:interview` → invokes grill-brownfield internally → structures output
      - Direct: `/appmaker:grill-brownfield` → writes its own artifact in step 5

    - **v0.2.13:** `/appmaker:next` lifecycle orchestrator skill. Resolves real-session friction: side-effect skills (`prd`, `decompose`, `tdd`, `archive`, etc.) have `disable-model-invocation: true` (v0.2.9 audit fix preventing silent writes), so agent could not chain phases automatically — user had to type each slash command manually. Tension between safety (v0.2.9) and flow (Pawel's caseman session) resolved by adding **explicit user-triggered orchestrator** that owns the chain. `/appmaker:next` (itself `disable-model-invocation: true`, single user entry) detects current state via filesystem, picks next phase deterministically (10-row state machine), confirms via AskUserQuestion, invokes target via Skill tool, loops on user "continue chain" choice. Side-effect skills retain audit-safe property; chain convenience comes from orchestrator. Modes: default (per-phase confirmation), `--auto` (skip confirms, still stops on FAIL gate, valid only with `afk_enabled: true`). Stop conditions: any review/checklist FAIL ends chain; ambiguous state surfaces via AskUserQuestion. Plugin now 19 skills (was 18). README + DESIGN layout updated.

    - **v0.2.12:** Strategic pivot — **AppMaker = spec/governance layer ABOVE Claude Code runtime**, not parallel framework. Triggered by Anthropic's wave of agentic Claude Code features (Agent View, `/goal`, `/ultra-review`, improved compaction) which overlap with AppMaker's runtime-layer patches. Response: delegate runtime to Claude Code built-ins, keep AppMaker focused on spec discipline + traceability + governance.
      1. **`/appmaker:review --mode=local\|ultra`** — `local` (default) keeps current single-subagent path; `ultra` invokes Claude Code's `/ultra-review` (parallel reviewer fleet, reproduced bugs) and AppMaker layers compliance checks (AC coverage, constitution, glossary, traceability, context packets) on top. Combined findings persist in single review.md. Fallback to local with explicit warning when `/ultra-review` unavailable.
      2. **`/appmaker:afk --driver=goal\|loop`** — `loop` (default) keeps custom bounded autonomous loop; `goal` delegates execution to Claude Code's `/goal` (persistent outcome-based execution) by formatting AppMaker completion conditions as the goal string. Benefits: native Agent View observability, mobile monitoring, `/goal`-aware Claude Code tooling.
      3. **`wiki_preflight_mode: auto\|always\|never`** config flag — controls pre-flight wiki cat in 8 generator skills. Was mandatory in v0.2.7; now responsive to Claude Code's improved compaction. Default `auto` (currently behaves like `always` until context-aware signal exists); user can set `never` if compaction reliably preserves sensitive instructions. Test in caseman will inform default for v0.2.13.
      4. **`/appmaker:status` Agent View hint** — when >1 recent session detected in `~/.claude/projects/<dashes>/`, status output adds `**Multi-session view:** \`cloud agents\`` row. Compact, omitted otherwise.

      **Repositioning text** (README + DESIGN top): explicit "AppMaker = spec + governance layer ON TOP of Claude Code runtime". Durable AppMaker value (lifecycle, traceability, governance, audit trail) vs. shifting infrastructure (Claude Code adds it). When better primitives arrive, delegate. Don't compete with runtime.

      **Skipped (out of v0.2.12 scope):**
      - Test harness coverage for new flags — `--mode=ultra` requires Claude Code 2.1.86+ + Pro/Max account, not unit-testable; `--driver=goal` similarly requires `/goal` availability; manual verification in caseman planned.
      - Memory wiki vs Claude Mem hybrid integration — bigger philosophical decision (auditable+explicit vs invisible+automatic), defer until after caseman second lifecycle test.
      - Skill Creator usage for future skills — adoption pattern, not v0.2.12 code change.

    - **v0.2.11:** Hardening pass after second external audit. Eight findings (3 HIGH, 3 MEDIUM, 2 LOW) + 2 structural improvements + test harness MVP. **No new skills**, no new features beyond fixing previously-overclaimed ones. Big-picture insight from audit: "still more prompt-OS than product framework — too many promises live in markdown as 'agent should'". v0.2.11 addresses three:
      1. **HIGH — DESIGN.md safety table out-of-sync** (review + glossary). Table claimed `false` after v0.2.9 set both `true`. Fixed; security contract now matches frontmatters.
      2. **HIGH — `/appmaker:token-audit` overclaim**. v0.2.8 description promised "per-skill cost"; implementation had only pseudocode. v0.2.11: **real implementation** — walks jsonl in order, detects `/appmaker:<name>` in user-role text, opens skill window, sums assistant `usage` tokens until next user message. Bucket `__none__` captures non-AppMaker work. Caveats explicit: skill chains bleed (sub-Skill-tool calls count toward originating slash command). Verified on AppMaker logs: 41 turns, 2.65M tokens, all `__none__` (Pawel builds plugin, doesn't `/appmaker:*` it).
      3. **HIGH — "auto-byproducts" honest reframe + deterministic post-step**. Prior wording ("auto-maintained", "auto-byproduct") implied determinism that didn't exist. v0.2.11 introduces **two-tier glossary maintenance**: (Tier 1) `appmaker/hooks/glossary-extract.sh` — verifiable bash that scans bold-uppercase patterns in artifacts and appends stubs to glossary, idempotent; (Tier 2) `/appmaker:glossary` — explicit semantic review converting stubs to definitions, best-effort agent reasoning. Parent skills (prd/decompose/tdd/grill) now invoke Tier 1 as deterministic post-step + optionally Tier 2 via Skill tool. Wording across SKILL.md + README + DESIGN.md updated to match mechanism.
      4. **MEDIUM — session hook merge logic.** Prior init only wrote `.claude/settings.json` if missing; existing-file path just printed manual-merge instruction. v0.2.11: if `jq` available, merge SessionStart entry preserving existing settings (with `.bak` backup). Idempotent — re-runs detect existing entry and skip. If `jq` missing, surfaces 3 options to user (skip / overwrite / install jq).
      5. **MEDIUM — `session_hook_enabled` + `glossary_hook_enabled` config flags.** Was: deleting hook script "disabled" hook, but upgrade reinstalled. Now: config flags read by init; if `false`, skip install (and on upgrade, respect user choice). Trustworthy disable path.
      6. **MEDIUM — case-study honest split.** Verdict section reorganized into explicit `### ✓ Validated (with evidence)` table + `### ✗ Not yet validated (hypotheses for next run)` table. Each hypothesis names a concrete test for the next caseman session.
      7. **LOW — status examples 0.2.7 → 0.2.11** (one-line sed fix).
      8. **LOW — skill body diet deferred to v0.2.12.** init grew to 325 lines from v0.2.11 safety code (hook merge, version SoT, config respect) — trimming would reduce safety. Plan: v0.2.12 refactor moves long bash blocks to separate scripts (like glossary-extract.sh, session-start.sh pattern), keeping skill bodies as documentation only.

      Plus 2 structural improvements addressing audit's "prompt-OS vs product framework" critique:

      9. **Version single source of truth.** `plugin.json` is now canonical. Init reads version via `jq -r .version` at runtime; `config.yaml.template` uses `${VERSION}` placeholder substituted at materialization; init/SKILL.md no longer hardcodes a version constant. Bump checklist reduced from 4 places to 2 (plugin.json + marketplace.json).
      10. **Test harness MVP** at `tests/smoke/`. Three test suites (`test-hook.sh`, `test-glossary-extract.sh`, `test-version-sot.sh`) + `run-all.sh` runner with color output and per-suite exit codes. Total: 22 assertions covering hook silent-exit, feature-pick correctness, done-counting via `backlog/done/`, glossary stub append idempotency, version SoT contract. All green on v0.2.11. Foundation for CI-style verification.

      Skipped (out of v0.2.11 scope):
      - "Produktowy framework rewrite" — would require moving more skill-body bash to executable scripts; staged via #8 deferral to v0.2.12.
      - Second lifecycle test through `/appmaker:archive` — user action in caseman, not code.

    - **v0.2.10:** Three safe wins (no measurement required, low risk):
      1. **Skip empty wiki pages in pre-flight read.** Pre-flight bash blocks in 8 generator skills (`grill`, `grill-brownfield`, `interview`, `prd`, `decompose`, `tdd`, `diagnose`, `review`) now guard with `[ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]`. Header-only seed files (≤ 5 lines) skip the `cat`. Greenfield/fresh-init projects save 5-30k tokens per generator invocation when wiki is unpopulated. Measure-after-data: token-audit on caseman post-fix will confirm magnitude.
      2. **DESIGN.md history archive.** Decisions 1-29 (foundational stable architecture) moved to `DESIGN-history.md`. Active `DESIGN.md` retains decisions 30+ (current-era patches) + reference to history file. Reduces active-document token cost on `/appmaker:init` upgrade flow and casual reads. Foundational rationale preserved verbatim for audits.
      3. **Document intentional `false` flags in README.** Explanation added for why `start` / `grill` / `grill-brownfield` keep `disable-model-invocation: false` — they're auto-routable conversational skills with no side effects. Prevents future audit feedback loop on this point.
    - **v0.2.9:** Five bugfixes surfaced by external audit before adding more features. **No new functionality** — pure correctness pass on runtime semantics.
      1. **HIGH — side-effect flags corrected:** `review/SKILL.md` and `glossary/SKILL.md` had `disable-model-invocation: false` despite writing files (review.md, glossary.md). Model could auto-invoke and silently mutate state. Both now `true`; glossary description rewritten to clarify it's invoked explicitly (by user or parent skill via Skill tool), not autonomously.
      2. **MEDIUM — slice counting includes `backlog/done/`:** session-start.sh + status/SKILL.md iterated only `appmaker/backlog/*.md`, but `tdd` moves completed items to `appmaker/backlog/done/`. Result: post-TDD status showed `0/N done`. Fixed both files to iterate `*.md` + `done/*.md`.
      3. **MEDIUM — newest feature selection:** loop `for d in appmaker/features/*/ ... break` picked alphabetically first, not newest. Replaced with `ls -1d ... \| sort -r` (numeric descending via zero-padded NNN names). Fix applied in hook + status skill identically.
      4. **MEDIUM — "production-grade" claim toned down:** `tests/case-study-caseman-bps-2026-05-11.md` Verdict section overclaimed. Rewritten to "validated on the critical path" with explicit list of what's NOT yet validated (lifecycle through archive, persistence patches hold, memory wiki proactive read reduces setup time).
      5. **LOW — docs drift:** README/DESIGN layouts updated to show `status/`, `token-audit/`, `hooks/session-start.sh`, `output-style.md`. `.appmaker-version` example "0.2.0" → "0.2.9". Test template "16 dirs" → "18 dirs" (15 core + afk + status + token-audit).

      Trigger: external audit identified all 5 before next feature work. Lesson reinforced: **plugin runtime semantics must be bulletproof** — small bugs in state-read paths erode user trust faster than missing features.
    - **v0.2.8:** `/appmaker:token-audit` diagnostic skill (additive, no breaking changes). Measure-first response to "how do we save tokens" question — refuses to optimize before measuring. Parses `~/.claude/projects/<dashes>/*.jsonl` and reports per-session totals, tool call breakdown, per-skill cost attribution (heuristic — detects `/appmaker:*` invocations and sums tokens between user messages), top-10 largest tool results, file-read hotspots, Bash first-word frequency. Caveats explicit in output: gross volume not cost, format internal not public-stable, attribution bleeds across skill chains. Smoke test on AppMaker repo's own logs: 2.7M tokens across 2 sessions, avg 56-73k/turn (10× typical), top reads = DESIGN.md (24k), constitution.md (22k), init/SKILL.md (12k). This is the diagnostic baseline; v0.2.9+ patches (wiki summaries, DESIGN history split, skip-empty-pages in pre-flight) will follow when there's enough data to target high-impact low-risk wins.
    - **v0.2.7:** Three reinforcement patches addressing gaps surfaced in the v0.2.6 review:
      1. **Pre-flight memory wiki read (MANDATORY)** added to 7 generator skills — `grill`, `grill-brownfield`, `interview`, `prd`, `decompose`, `tdd`, `diagnose`, plus strengthened from "when relevant" to "mandatory" in `review`. Each skill's `## Process` now starts with `### 0. Pre-flight: read memory wiki (MANDATORY)` containing a Bash loop that cats relevant wiki pages BEFORE generation. Citation expected: "per `wiki/<page>.md`: ...". Directly addresses Ron Demerit's acknowledged failure ("I have to remind it to read its memory") — AppMaker had wiki infrastructure but skills only mentioned it as lazy/optional read. v0.2.7 makes it part of the contract. Tests Pawel's case-study hypothesis: *"Memory wiki teaches agent caseman patterns → faster setup on next feature"*.
      2. **Token usage telemetry in `/appmaker:status`** (best-effort, optional). Reads `~/.claude/projects/<dashes>/*.jsonl` and sums `usage.{input,cache_creation_input,cache_read_input,output}_tokens` via `jq`. Displays as compact `X.YM across N sessions`. Caveats: format is Claude Code internal not public-stable; degrades silently on `jq`-missing or parse failure; number is **volume not cost** (cache reads ~10% of input cost). Useful telemetry signal, not a billing source — for that point users at `ccusage`.
      3. **LLM-grounded next-action refinement in `/appmaker:status`**. Keeps deterministic suggestion table as baseline. Optional refinement layer reads `git log -5`, recent backlog mtime, latest review findings; emits a `**Refined:**` line ONLY when refinement diverges from deterministic baseline (silent agreement). Solves: "filesystem says slice X is next, but review.md has an open critical from slice X-1 — addressing that should come first" class of cases. Refinement never overrides filesystem facts; only re-prioritizes.

34. **First production validation (caseman BPS Risk Score, 2026-05-11).** AppMaker v0.2.x used end-to-end on real Apps Script production project. Concrete evidence:
    - Feature `001-bps-risk-compute` (replace operator-manual BPS Risk Score with deterministic compute)
    - All 16 plugin commands invoked (15 core + AFK)
    - 7 vertical slices decomposed (6 autonomous + 1 human_required, cycle-checked, 8/8 SC coverage)
    - **5/7 slices shipped to production** (commits `64bfcc7`, `031a4bf`, `66c7663`; library v224→v227 across 4 deploys)
    - 21 unit tests passing on `bps_compute.test.js` (real RED→GREEN cycles in log)
    - Glossary auto-populated with 5 rich domain terms (file refs + line numbers — explore-over-ask validated)
    - Session duration ~5h 30min (setup + decomposition + 5 slice TDD ≈ 30min/slice)
    - Graphify integration: 799-node graph built using Gemini key (budget workaround for pass-3)
    - Persistence gaps discovered → patched in v0.2.4
    - 2 slices remaining (006 + 007); archive pending → first lifecycle closure not yet
    - Full case study: `tests/case-study-caseman-bps-2026-05-11.md`

**Why this is P0 (reviewer):** Without packaged resources + materializer + config + version, plugin distribution is "częściowo iluzoryczna" — slash commands load but `/appmaker:init` has no obvious source to copy templates/reference files. Plus config + version are foundation for upgrade path (otherwise users stuck with frozen v0).

**Version single source of truth (v0.2.11):**

`plugin/appmaker/.claude-plugin/plugin.json` is canonical. Init reads via `jq -r .version` at runtime; `config.yaml.template` uses `${VERSION}` placeholder substituted at materialization; init/SKILL.md no longer hardcodes a version constant.

**Bump checklist (2 places):**
1. `plugin/appmaker/.claude-plugin/plugin.json` — `version` field (CANONICAL)
2. `.claude-plugin/marketplace.json` — `metadata.version` field (mirror; consider sync script in future)

Previously 4 places (init/SKILL.md and config.yaml.template were also hardcoded). v0.2.11 consolidated to runtime read.

## Style guide dla pisania skills (caveman mode)

Wszystkie AppMaker skills pisane w **caveman style** (per Matt Pocock `caveman` skill):

- Drop articles (a/an/the), filler (just/really/basically), pleasantries (sure/certainly)
- Drop conjunctions; fragments OK; short synonyms (big not extensive)
- Abbreviate common terms (DB/auth/config/req/res/fn/impl)
- Pattern: `[thing] [action] [reason]. [next step].`
- Use arrows for causality (X -> Y)
- Keep SKILL.md <200 lines for reliable Claude recall

**Wyjątki**: security warnings, destructive op confirmations, multi-step sequences, error messages quoted exact.

Cel: ~75% token reduction vs prose, full technical accuracy preserved.

## Skill frontmatter convention (plugin format)

```yaml
---
description: One-line description of what the skill does and when to use it. Recommended (Claude uses to decide when to apply skill).
disable-model-invocation: true   # or false; true for side-effect skills, false for read-only/informational
---
```

Body sections (mandatory unless noted):
- `## When to invoke` (NEW per reviewer feedback) — manual/auto/AFK-safe annotations
- `## Process` — numbered steps
- `## Output format` (optional) — what user sees
- `## Guardrails` — do's and don'ts

## Templates do bezpośredniego adoptowania (nie wynajdywać koła)

- **`/appmaker:glossary`** = adopt Matt Pocock's `deprecated/ubiquitous-language` (format: tables, dialogue, ambiguities). Save to `appmaker/glossary.md`.
- **`/appmaker:interview`** = composition wrapper over `/appmaker:grill`.
- **`/appmaker:prd`** = adapt Matt Pocock's `to-prd` + Understanding section + Clarifications.
- **`/appmaker:decompose`** = adapt Matt Pocock's `to-issues` + execution_class + traces_to + cycle detection.
- **`/appmaker:tdd`** = adapt Matt Pocock's `tdd` (5 supporting files in project tree `appmaker/skills/tdd/`).
- **`/appmaker:diagnose`** = adapt Matt Pocock's `diagnose`.
- **`/appmaker:spike`** = adapt Matt Pocock's `prototype` (TODO, 3 files: SKILL.md + LOGIC.md + UI.md).
- **`/appmaker:archive`** = adapt OpenSpec `/opsx:archive` + optional retro.

## Co świadomie NIE robimy

- ❌ Constitution z 18 rules → 5-7 max
- ❌ 4-state readiness enum z propagation chain → każda skill ma swoje "ready/not-ready"
- ❌ JSON Schemas (3 sztuki) → struktura w skill markdown
- ❌ `decisions.jsonl` / `events.jsonl` / `lessons.jsonl` streams → markdown w `memory/`
- ❌ ACTIVE cross-decision/cross-artifact checks mandatory → opt-in `/appmaker:checklist`
- ❌ ADRs jako numerowana sekwencja z 12 wymaganymi sekcjami → markdown notes
- ❌ Adapter pattern → use Graphify as-is, don't wrap
- ❌ Rebuild Graphify → reference it
- ❌ Copy `graph.json` into AppMaker memory → write small context packets only
- ❌ Bootstrap exception (akademicki problem)
- ❌ Custom validator / schema migration tooling
- ❌ Cross-tool memory, verbatim recall, knowledge bases — over-engineered
- ❌ Telegram/Discord access, VPS/Claude Cloud hosting — agency-scale, off-topic
- ❌ Brand context as must-have — opt-in dla content/marketing użytkowników
- ❌ Unbounded scheduled autonomous loops — `/appmaker:afk` is manual, bounded, explicit opt-in only
- ❌ Skills format `.claude/skills/<name>/SKILL.md` (auto-invocation by Claude) → plugin skills (`/<plugin-name>:<skill>`) per decision 29
- ❌ Slash commands w `.claude/commands/<prefix>/<name>.md` (subdirs not namespaces per docs) → plugin format per decision 29

## Best-of dystylacja

### Z Matt Pocock
- Każda skill = jeden markdown plik → adopted
- Single-purpose discipline → adopted
- Inspiracja > runtime dependency → adopted (plugin loads files; nie wraps Matt'owy package)
- Vertical slice "tracer bullet" → adopted w `/appmaker:decompose`
- HITL/AFK → adopted as `execution_class`
- Caveman style → adopted as mandatory writing style
- Multi-file pattern (improve-codebase-architecture, prototype, tdd) → adopted w project tree `appmaker/skills/<name>/`

### Z OpenSpec
- Per-change folder → adopted jako per-feature folder
- Archive flow → adopted jako `/appmaker:archive`
- Brownfield-first design → adopted
- "Agree before you build" → adopted (PRD as light gate)
- Fluid iteration (no rigid phase gates) → adopted
- Plugin namespace `colon` separator (`/opsx:propose`) → adopted as `/appmaker:<name>`

### Ze Spec Kit
- Constitution layer → adopted (5-7 rules)
- Optional deepening commands → adopted (4 opt-in)
- Cross-artifact analyze pattern → adopted as `/appmaker:checklist`
- (Świadomie NIE adopted: 5 sequential phases, Python runtime, extensions ecosystem)

### Z naszego dorobku (selektywnie)
- **Understanding section z 7 subsections** w PRD — adopted
- **Verifiability discipline** (auto-check OR human-review-with-criteria) — adopted
- **execution_class per slice** — adopted (lepsze niż HITL/AFK acronyms)
- **Lessons capture** — adopted w lighter form (memory/lessons.md, nie central jsonl)
- **External critic via subagent** — adopted (`/appmaker:review` invokes Agent)
- **traces_to: pcrit-id** — adopted (every AC links to PRD criterion)

### Z future-scope-registry (top 7)
- Lazy Context / Project Memory → memory/ z lazy retrieval
- Output Routing / Artifact Consolidation → per-feature folder convention
- Verifiability Standards → discipline w prd.md
- Review Protocol → `/appmaker:review`
- Backpressure / Safety Hooks → optional .claude/settings.json hooks
- Minimal Friendly CLI → `/appmaker:start` jako entry
- Evidence-First Fact Policy → discipline w skill markdown

### Z Agentic OS video (top 5 z 9)
- Session start hook → optional w .claude/settings.json
- Multi-project inheritance via parent CLAUDE.md → opt-in layout
- Skills <200 lines + progressive disclosure → reinforcement Matt Pocock
- Self-learning via learnings file → memory/lessons.md
- Output consolidation → per-feature folder

### Z Karpathy auto-research
- Layer 4 AFK runner concept validated → implemented as bounded manual loop
- ProgramMD framing — adopted (README mentions explicitly)
- Required guardrails dla Layer 4: cost cap, max iterations, human review on promote-to-main, baseline-degrade detection

## Open questions

- [ ] Distribution model po MVP: marketplace plugin? Lokalna git clone instruction zostaje OK na razie.
- [ ] GitHub issues adapter: kiedy buduujemy? (po validation local backlog)
- [ ] Pierwszy real Level C test wyniki — czy plugin loads + `/appmaker:init` w slash menu? (test report template w `tests/`)

## Status snapshot

```
Plugin skills written: 15/15 core
Plugin skills TODO: 0
Opt-in skills TODO: 4 (clarify, research, spike, plan)
Layer 4 implemented: afk
Layer 4 TODO: 1 (sync-github)

Critical path: 9/9 ✓ (init → start → grill → interview → prd → decompose → tdd → review → archive)

Plugin validation: claude plugin validate PASSES (with author warning fixed)
ClaimCompass setup: clean state, awaits fresh /appmaker:init
Real Level C test: pending user execution

Refactor history:
- Decision 28: skills → slash commands (2026-05-10)
- Decision 29: slash commands → plugin format (2026-05-11)
```

## Next steps (priority order)

1. **Real Level C test w ClaimCompass** — validation: `claude --plugin-dir /path/to/plugin/appmaker` w ClaimCompass, check `/appmaker:init` w slash menu, run research scenario. Test report template w `tests/level-c-test-report-2026-05-10.md`.
2. **Hardening pass for `/appmaker:checklist`** after first real findings.
3. **Write 4 opt-in skills:** clarify, research, spike (z multi-file LOGIC.md + UI.md), plan.
4. **GitHub sync adapter:** `/appmaker:sync-github` after local backlog proves useful.
5. **Marketplace submission:** Anthropic plugin marketplace po MVP validation.
