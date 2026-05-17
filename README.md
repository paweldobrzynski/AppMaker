# AppMaker

**A spec + governance layer on top of Claude Code's runtime.**

AppMaker doesn't replace Claude Code — it adds **process discipline** (PRD → AC → test traceability), **deterministic gates** (checklist, review compliance), and **lifecycle artifacts** (feature folders, archive, retro) ON TOP of what Claude Code already does well: tool calls, agent invocation, session management, context handling.

When Claude Code ships a better primitive — Agent View, `/goal`, `/ultra-review`, improved compaction — AppMaker delegates to it instead of re-implementing. The durable AppMaker value is **what Claude Code doesn't do**: spec discipline, AC-test traceability, constitution-enforced quality bars, glossary-canonical vocabulary, audit-trail-preserving archive flow.

**Positioning (v0.2.12+):**
- **Below AppMaker (Claude Code runtime):** Skills, hooks, Agent View, `/goal`, `/review` + `/ultra-review`, compaction, plugin marketplace
- **AppMaker layer adds:** PRD/decompose/checklist/archive lifecycle, `traces_to` AC linkage, constitution + glossary governance, retro → memory wiki, context packets, deterministic gates
- **Above AppMaker (your project):** Concrete features built with the discipline

Optionally pairs with [Graphify](https://github.com/safishamsi/graphify) for read-only codebase intelligence and [Forest's andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) for universal agent baseline.

**Form:** Claude Code plugin at `plugin/appmaker/`. Skills loaded via `--plugin-dir` flag or marketplace install.
**Convention:** `/appmaker:<name>` (colon namespace per Claude Code plugin spec — like OpenSpec `/opsx:propose`).
**Philosophy:** minimal, single-purpose, opt-in everywhere. Delegate to Claude Code built-ins where they exist.
**Status:** v0.2.19. 19 skills (15 core + afk + status + token-audit + next). **Execution Record MVP** — backlog slices now carry a durable capture-only execution record (base ref, dirty state, planned/actual files, tests, AC completed, drift notes), and `/appmaker:tdd` instructs agents to fill it before and after apply. Review auto-diff and checklist enforcement remain deferred until the MVP proves useful. 10 smoke test suites, 72+ assertions. See `DESIGN.md`, `METHOD.md`, and `dogfood/appmaker/features/002-plan-evidence-drift-detection/prd.md`.

## Install

**Plugin is self-contained.** No manual copy of templates or supporting files — `/appmaker:init` materializes everything from packaged resources.

```bash
# 1. Open project + load plugin for the session:
cd /path/to/your-project
claude --plugin-dir /Users/pawel/Projects/AppMaker/plugin/appmaker

# 2. In Claude Code session:
/help                # Verify /appmaker:* commands appear in menu
/appmaker:init       # Materialize appmaker/ from plugin resources
                     # (creates constitution, glossary, config.yaml, .appmaker-version,
                     #  templates/, skills/tdd/, memory/wiki/, context/, checklists/,
                     #  diagnostics/, afk/, backlog/, features/)
```

**Re-running `/appmaker:init` on existing project = UPGRADE mode.** Refreshes plugin-owned resources (templates, supporting files) while preserving user-owned state (constitution, glossary, memory, backlog, features, config). Detected via `appmaker/.appmaker-version` marker.

For permanent activation per project: add to `.claude/settings.json` (TBD — manual `--plugin-dir` per session for now).

Future: publish to plugin marketplace for `/plugin install appmaker` style.

## What it does

### Core (15 skills)

```
/appmaker:init                  → bootstrap appmaker/ in fresh project
/appmaker:start "<intent>"      → smart routing: feature, bug, refactor, research, review, prototype
/appmaker:grill "<topic>"       → general-purpose relentless questioning (Matt's grill-me)
/appmaker:grill-brownfield      → brownfield variant (reads code/docs/glossary/memory/context first)
/appmaker:interview             → feature-specific entry, structured output to features/<NNN-slug>/
/appmaker:prd                   → synthesize PRD with Understanding section + Clarifications
/appmaker:decompose             → vertical slices with execution_class, items go to backlog/
/appmaker:tdd <backlog-id>      → test-first implementation per slice
/appmaker:diagnose              → bug/perf diagnosis loop with repro + hypotheses + regression
/appmaker:review <scope>        → invokes critic subagent (code-reviewer)
/appmaker:checklist             → deterministic PASS/FAIL/WARN gate across artifacts
/appmaker:archive               → close out feature, move to features/archive/
/appmaker:context "<topic>"     → Graphify-aware context packet, fallback to file reads
/appmaker:feedback "<desc>"     → quick capture from QA → backlog item
/appmaker:glossary              → ubiquitous language (deterministic stub extraction + best-effort semantic review)
```

19 written: 15 core (above) + 4 supporting (afk, status, token-audit, next).

### Opt-in deepening (4 skills, all TODO)

```
/appmaker:clarify               → extra questions for ambiguous areas, populates PRD ## Clarifications
/appmaker:research              → cache external research with freshness markers
/appmaker:spike                 → throwaway prototypes (Matt's prototype: logic OR ui variant)
/appmaker:plan                  → durable plan artifacts for large work units (multi-phase)
```

### Layer 4 — AFK runner

```
/appmaker:afk                   → controlled autonomous loop for autonomous backlog items
/appmaker:sync-github           → push/pull backlog ↔ GitHub issues (optional adapter) [TODO]
```

## Invocation control (per skill)

Each skill declares `disable-model-invocation` in frontmatter:

| Skill | `disable-model-invocation` | Why |
|---|---|---|
| init | `true` | Side effect: creates files |
| start | `false` | Entry point — Claude can route based on intent |
| grill | `false` | Pure thinking aid, OK to auto-invoke |
| grill-brownfield | `false` | Interactive thinking aid grounded in existing code/docs |
| interview | `true` | Side effect: allocates feature folder, writes artifact |
| prd | `true` | Side effect: writes PRD artifact |
| decompose | `true` | Side effect: writes backlog items |
| tdd | `true` | Side effect: writes code/tests, big change |
| diagnose | `true` | Side effect: writes diagnostics, may add tests/instrumentation |
| review | `true` | Side effect: writes review.md / appends to backlog (v0.2.9 fix — was `false`, caused silent-write risk) |
| checklist | `true` | Side effect: writes checklist report |
| archive | `true` | Side effect: moves files (irreversible) |
| context | `true` | Side effect: writes context packet snapshots |
| feedback | `true` | Side effect: writes backlog item |
| glossary | `true` | Side effect: writes glossary.md (v0.2.9 fix — was `false`; now invoked explicitly by parents via Skill tool) |
| status | `true` | Read-only filesystem inspection (no writes, but explicit user trigger) |
| token-audit | `true` | Read-only diagnostic (parses session logs, no writes) |
| afk | `true` | Side effect: runs bounded autonomous work loop |

**Why some skills keep `false` (intentional, not oversight):**

- `start` is the **entry point** — model auto-routing user intent to it is the entire point. It only classifies + suggests; no writes.
- `grill` / `grill-brownfield` are **conversational thinking aids**. Auto-invocation when user says "let's discuss X" / "I'm planning a refactor" is the feature, not a risk. Neither writes to filesystem directly — they may call `/appmaker:glossary` via Skill tool when new terms surface (and glossary is `true`, so that write is explicit).
- Any **side-effect skill** (writes files, moves files, runs subagent that writes) must be `true`. Audit-flagged on v0.2.8: `review` and `glossary` were incorrectly `false` → fixed in v0.2.9.

## File layout

### Plugin source (this repo)

```
AppMaker/
├── plugin/appmaker/
│   ├── .claude-plugin/plugin.json      ← manifest
│   ├── hooks/
│   │   └── session-start.sh            ← v0.2.6: prints 1-line status on session start
│   ├── resources/                        ← packaged resources, materialized by /appmaker:init
│   │   ├── appmaker/
│   │   │   ├── config.yaml.template
│   │   │   ├── memory/                  ← Karpathy-style wiki seed files
│   │   │   ├── skills/
│   │   │   │   ├── output-style.md     ← v0.2.3: global Compact report contract
│   │   │   │   └── tdd/                 ← Matt Pocock supporting (deep-modules, mocking, ...)
│   │   │   └── templates/
│   │   │       ├── backlog-item-template.md
│   │   │       ├── context-packet-template.md
│   │   │       └── decomposition-template.md
│   │   └── graphify/.graphifyignore.template
│   └── skills/                          ← 19 dirs (15 core + afk + status + token-audit + next)
│       ├── init/SKILL.md
│       ├── start/SKILL.md
│       ├── grill/SKILL.md
│       ├── grill-brownfield/SKILL.md
│       ├── interview/SKILL.md
│       ├── prd/SKILL.md
│       ├── decompose/SKILL.md
│       ├── tdd/SKILL.md
│       ├── diagnose/SKILL.md
│       ├── review/SKILL.md
│       ├── checklist/SKILL.md
│       ├── archive/SKILL.md
│       ├── context/SKILL.md
│       ├── feedback/SKILL.md
│       ├── glossary/SKILL.md
│       ├── afk/SKILL.md
│       ├── status/SKILL.md             ← v0.2.6: compact state snapshot
│       ├── token-audit/SKILL.md        ← v0.2.8: session log diagnostic
│       └── next/SKILL.md               ← v0.2.13: lifecycle orchestrator (user-explicit chain trigger)
├── DESIGN.md / README.md / REFERENCES.md
├── tests/
└── history/                             ← archived prior iterations
```

### In your project (after `/appmaker:init`)

```
your-project/
├── CLAUDE.md                            ← optional Forest's universal agent baseline
└── appmaker/                            ← project state (materialized from plugin resources)
    ├── .appmaker-version                ← plugin resource version marker (current: "0.2.9")
    ├── hooks/session-start.sh           ← copied from plugin; prints status 1-liner
    ├── config.yaml                      ← project config (commands, providers, integrations)
    ├── constitution.md                  ← 5-7 rules MAX (project principles, user-owned)
    ├── glossary.md                      ← ubiquitous language (stubs auto-flagged by hooks, definitions explicit)
    ├── context/                         ← small context packets from Graphify/file discovery
    ├── templates/                       ← per-project overrides (materialized from plugin)
    │   ├── backlog-item-template.md
    │   └── decomposition-template.md
    ├── skills/                          ← supporting reference files (materialized from plugin)
    │   └── tdd/                         ← Matt Pocock supporting
    ├── memory/
    │   ├── architecture.md
    │   ├── decisions.md
    │   ├── lessons.md
    │   ├── index.md
    │   ├── schema.md
    │   ├── log.md
    │   ├── raw/
    │   └── wiki/
    ├── backlog/
    │   ├── NNN-slug.md                  ← active items
    │   └── done/                        ← completed
    ├── reviews/                         ← optional diff-level review reports
    ├── checklists/                       ← PASS/FAIL/WARN gate reports
    ├── diagnostics/                      ← bug diagnosis reports
    ├── afk/                              ← bounded autonomous run reports
    └── features/
        ├── NNN-slug/                    ← per-feature artifacts
        └── archive/                     ← completed features
```

## Four layers (each opt-in)

1. **Plugin skills** (Matt Pocock-style markdown) — work standalone via `--plugin-dir`
2. **Orchestrator** (`/appmaker:start`) — smart routing for the above
3. **Graphify pair** — optional context layer. AppMaker reads Graphify data and writes small context packets.
4. **AFK runner** — bounded autonomous execution loop over `execution_class: autonomous` items

Profile A = only Layer 1. Profile E = all 4 layers ("wszystko zepnie").

## Recommended pairings

AppMaker handles project-specific governance (constitution, glossary, lifecycle). For universal agent behavior baseline, pair with these standalone tools:

- **[forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)** — single CLAUDE.md (65 lines) with 4 universal principles distilled from Karpathy's observations: think before coding, simplicity first, surgical changes, goal-driven execution. Complementary to AppMaker constitution. `/appmaker:init` offers to install it.
- **[safishamsi/graphify](https://github.com/safishamsi/graphify)** — knowledge graph for codebases. Pairs with `/appmaker:context` for efficient retrieval. `/appmaker:init` offers to install it (privacy warning: docs/PDFs/images may use model API during extraction). AppMaker treats Graphify as read-only; durable artifacts link to `appmaker/context/*.md` packets, not raw `graph.json`.

These are NOT bundled with the plugin — they have separate concerns (universal agent behavior, codebase context retrieval). AppMaker references them; user opts in per project via `/appmaker:init` flow.

## History

Earlier heavyweight iteration (5 ADRs, 18 constitutional rules, 3 JSON Schemas, propagation chains, JSONL streams) lives at `history/`. Kept for reference; not part of current design. Plus a previous skill-format refactor (`.claude/skills/appmaker/`) and slash-command-in-subdir attempt (`.claude/commands/appmaker/`) were corrected to plugin format per Claude Code official spec — slash commands need plugin namespace prefix to use `:` separator. See `DESIGN.md` decision 28.

## Inspirations

- **[Matt Pocock Skills](https://github.com/mattpocock/skills)** (canonical) — markdown skills, single-purpose, "Skills for Real Engineers". AppMaker adopts: `grill`, `grill-with-docs`, `to-prd`, `to-issues`, `tdd` (with 5 supporting files), `diagnose`, `caveman` (style guide), `prototype`, `deprecated/ubiquitous-language` (format).
- **[OpenSpec](https://github.com/Fission-AI/OpenSpec)** — per-feature folder + archive flow + fluid iteration philosophy + slash command form factor (`/opsx:*`)
- **[Spec Kit](https://github.com/github/spec-kit)** — constitution layer + opt-in deepening commands + cross-artifact analyze pattern + slash command form factor (`/speckit.*`)
- **[Graphify](https://github.com/safishamsi/graphify)** — context layer (optional pair)
- **[Forest's CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills)** — universal agent behavior (recommended pairing)
- **[Aider](https://github.com/Aider-AI/aider)** — repo-map algorithm reference (tree-sitter + PageRank)
