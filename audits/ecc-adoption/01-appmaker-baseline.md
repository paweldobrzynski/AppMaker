# AppMaker — Autorytatywny inwentarz zdolności (baseline)

Źródło: `/Users/pawel/Projects/AppMaker`
Wersja: **v0.2.26** (`plugin/appmaker/.claude-plugin/plugin.json`, mirror `.claude-plugin/marketplace.json`)
Forma: Claude Code **plugin** (`plugin/appmaker/`), ładowany przez `--plugin-dir` lub marketplace. Komendy `/appmaker:<name>`.
Filozofia (potwierdzona w kodzie): **spec + governance layer ON TOP of Claude Code runtime**. Świadomie BRAK własnego runtime/CLI/binarki — wszystko żyje jako SKILL.md (markdown) + bash hooks/scripts + konwencje plikowe `appmaker/`. Provider-agnostic (`review_subagent` konfigurowalny, `--driver=goal` deleguje do `/goal`). Paruje z Graphify (read-only) + Forest's CLAUDE.md.

Dualność dokumentacji: `METHOD.md` = dyscyplina myślenia niezależna od pluginu; `DESIGN.md` = implementacja pluginu. METHOD jawnie mówi: „jeśli nie da się przyjąć dyscypliny samym markdownem, Method to fikcja, a plugin to faktyczny produkt".

---

## 1. Inwentarz zdolności (skille)

22 napisanych skilli (17 core + 5 supporting). Wszystkie w `plugin/appmaker/skills/<name>/SKILL.md`.

### Core lifecycle (17)

| Skill | `disable-model-invocation` | Etap cyklu | Co robi (1 linia) |
|---|---|---|---|
| `init` | true | bootstrap | Materializuje drzewo `appmaker/` z resources (przez `init-materialize.sh`), tworzy config/version/constitution, opcjonalne integracje; upgrade nie nadpisuje user-owned. |
| `start` | **false** | entry / routing | Klasyfikuje intent (feature/bug/prototype/refactor/research/review), wykrywa kontekst, sugeruje łańcuch komend — emituje dokładne slash-commands (nie wywołuje side-effect skilli). |
| `grill` | **false** | discovery | Bezlitosne pytania 1-na-raz (Matt Pocock `grill-me` 1:1), z rekomendowaną odpowiedzią; zero artefaktu, wzbogaca kontekst. |
| `grill-brownfield` | **false** | discovery (brownfield) | Wariant grill czytający najpierw kod/glossary/constitution/wiki/context; krok 5 pisze `interview-result.md` (`source: grill-brownfield`) by domknąć kontrakt PRD. |
| `interview` | true | feature entry | Wrapper nad `grill`; alokuje `features/NNN-slug/`, pisze ustrukturyzowany `interview-result.md` z readiness gate. |
| `prd` | true | spec | Syntetyzuje PRD (NIE pyta) z `interview-result.md`: Understanding (7 podsekcji) + Clarifications + Implementation/Testing Decisions; Architecture Options Research gate. |
| `decompose` | true | planowanie | Tnie PRD na vertical slices (Matt `to-issues`), pisze backlog items z `execution_class`, `traces_to`, cycle detection; Tier-1 glossary post-step. |
| `tdd` | true | implementacja | RED-GREEN-REFACTOR per slice (Matt `tdd` 1:1); zapisuje Approved TDD Plan + Execution Record do backlog item, AC checkbox tracking, przenosi done → `backlog/done/`. |
| `diagnose` | true | bugfix/perf | Pętla diagnostyczna (Matt `diagnose`): repro → hipotezy → 1 zmienna naraz → fix z regresją; raport do `diagnostics/`. |
| `review` | true | critic gate | Wywołuje subagent (domyślnie `code-reviewer`, konfigurowalny) na scope (backlog/feature/diff); `--mode=local\|ultra` (ultra deleguje do `/ultra-review`); pisze `review.md`, PASS/FAIL. |
| `qa` | true | QA | Diff-aware QA wg `## QA / Smoke Plan`, opcjonalne browser/screenshot evidence (gstack); raport do `qa/`. |
| `design-review` | true | QA (UI) | Wizualny/design compliance gate dla zmian UI: reuse CSS/komponentów, stany interakcji, screenshot evidence; raport do `reviews/`. |
| `checklist` | true | gate (deterministyczny) | PASS/FAIL/WARN cross-artifact gate (Spec Kit `/analyze`): pliki/trace/status/blokery/context/memory wiki/Graphify freshness; scope `feature\|backlog\|phase\|project\|archive\|memory`. |
| `archive` | true | zamknięcie | Weryfikuje all-done + review pass, przenosi backlog → `done/`, feature → `features/archive/<date>-NNN-slug/`, opcjonalny retro → `memory/decisions.md` + `lessons.md`. |
| `context` | true | wsparcie | Pobiera kontekst kodu (Graphify read-only lub fallback file discovery), pisze małe pakiety `context/<date>-<topic>.md`. |
| `feedback` | true | capture | Szybki QA/user feedback → backlog item (bez pełnego PRD). |
| `glossary` | true | governance | Tier-2 semantyczny przegląd stubów glossary (define/reject/merge/flag); format Matt `ubiquitous-language`. |

### Supporting (5)

| Skill | `disable-model-invocation` | Etap | Co robi |
|---|---|---|---|
| `status` | true | obserwowalność | Snapshot stanu (read-only FS): wersja, aktywny feature, postęp slice'ów, checklist, opcjonalna telemetria tokenów + LLM-grounded refinement next-action. |
| `token-audit` | true | diagnostyka | Parsuje `~/.claude/projects/<dashes>/*.jsonl`: per-session totals, tool breakdown, per-skill cost (heurystyka), top tool-results, file-read hotspots. Wymaga `jq`. |
| `next` | true | dispatcher | Wykrywa stan (10-wierszowa state machine), proponuje następną fazę via AskUserQuestion, emituje DOKŁADNY slash-command (NIE wywołuje przez Skill tool). |
| `phase` | true | Layer 4 orchestrator | Dry-run (przez `phase-plan.sh`) buduje bezpieczne fale; execute dispatchuje 1 subagent/item falami, integruje, verify→repair→review/QA→evidence. Stany PLANNED→RUNNING→VERIFYING→REVIEWING→DONE/FAILED. |
| `afk` | true | Layer 4 runner | Ograniczona autonomiczna pętla TYLKO nad `execution_class: autonomous`; checklist przed TDD, review po; cost/iter caps; `--driver=loop\|goal`; stop na pierwszym FAIL. |

### Wspólny wzorzec skilli
- Caveman style (Matt Pocock), SKILL.md < ~200 linii dla niezawodnego recall.
- Sekcje: `## When to invoke` (manual/auto/AFK-safe), `## Process`, `## Guardrails`.
- 8 skilli generatorów ma `### 0. Pre-flight: read memory wiki (MANDATORY)` (grill, grill-brownfield, interview, prd, decompose, tdd, diagnose, review).
- **Invocation boundary (kluczowe):** side-effect skille mają `disable-model-invocation: true` → NIE dają się wołać przez Skill tool; routery (`start`, `next`) muszą wypisać dokładny `/appmaker:<name>` i się zatrzymać (potwierdzone fiasko `Skill appmaker:tdd cannot be used... due to disable-model-invocation`).

---

## 2. Konwencje plikowe

### UWAGA o nazewnictwie: `appmaker/` vs `.appmaker/`
Aktualny plugin materializuje **`appmaker/`** (bez kropki) w katalogu projektu. `.appmaker/` (z kropką) to **stara, zarchiwizowana** konwencja heavyweight iteracji żyjąca w `history/.appmaker/` (work-units, jsonl streams, schemas) oraz w future-scope-registry. Future-scope-registry nadal pisze `.appmaker/...` — to scope-do-zrobienia, nie obecny stan.

### Drzewo `appmaker/` (po `/appmaker:init`)
Tworzone deterministycznie przez `init-materialize.sh:29`:
```
appmaker/{templates,skills,memory/raw,memory/wiki,context,backlog/done,
          features/archive,reviews,checklists,diagnostics,afk,phase-plans,hooks}
```
Pełna struktura:
```
appmaker/
├── .appmaker-version          # marker wersji resource (= plugin.json version)
├── config.yaml                # konfiguracja projektu (patrz niżej)
├── constitution.md            # 10 bounded rules (user-owned)
├── glossary.md                # ubiquitous language (stuby + definicje)
├── templates/                 # backlog-item, decomposition, context-packet
├── skills/                    # ref files: output-style.md, context-budget.md,
│                              #   architecture-options-research.md, tdd/*, review/*, status/*, init/*
├── memory/                    # index.md, schema.md, log.md, decisions.md,
│                              #   lessons.md, architecture.md, raw/, wiki/
│   └── wiki/                  # architecture, domain-model, testing,
│                              #   integration-gotchas, feature-index (.md)
├── context/                   # pakiety context <date>-<topic>.md
├── backlog/
│   ├── NNN-slug.md            # aktywne
│   └── done/<YYYY-MM-DD>-slug.md
├── reviews/ checklists/ diagnostics/ qa/ afk/ phase-plans/
├── hooks/session-start.sh     # kopiowany z pluginu
└── features/
    ├── NNN-slug/{interview-result.md, prd.md, decomposition.md, slices/, retro.md, review.md}
    └── archive/YYYY-MM-DD-NNN-slug/
```

### Formaty
- **Wszystko markdown + YAML frontmatter.** ŚWIADOMIE BRAK JSONL/JSON Schema w obecnym designie (DESIGN.md „Co świadomie NIE robimy": `decisions.jsonl/events.jsonl/lessons.jsonl` → markdown w `memory/`; JSON Schemas → struktura w skill markdown).
- JSON pojawia się TYLKO jako efemeryczny output `status-json.sh` i `phase-plan.sh --json` (dla Studio/adapterów) — NIE jako source of truth.
- **Backlog item** (`templates/backlog-item-template.md`): bogaty frontmatter — `id, slug, status, labels, execution_class, blocked_by, phase_id, parallel_group, agent_profile, write_scope, depends_on, integration_risk, traces_to, feature, user_stories_covered, context_packets, touches, edit_scope, created, source`. Body: Parent, What to build, Acceptance criteria (checkbox z `traces_to:`/`test:`/`human-review:`), Implementation Decisions/Gray Areas, **Architecture Options Research**, **Brownfield Impact Audit**, **Approved TDD Plan**, **TDD Plan Check**, **QA/Smoke Plan**, **Execution Record** (base ref, dirty-at-start, planned/actual files+tests, AC completed, drift notes).
- **Slice contract (METHOD)**: 5 plików `requirements/blueprint/acceptance/plan/evidence.md` — ALE patrz LUKI: plugin obecnie materializuje to jako SEKCJE w backlog item, nie jako osobne pliki w `slices/NN/`.

### Wersja — single source of truth (v0.2.11)
`plugin.json` jest kanoniczny. Init czyta `jq -r .version`. `config.yaml.template` używa `${VERSION}`. Bump w 2 miejscach: `plugin.json` + `marketplace.json`.

---

## 3. Mechanizmy

### Hooki (`plugin/appmaker/hooks/`)
- **`session-start.sh`** — SessionStart hook (instalowany do `.claude/settings.json` przez init, z merge przez `jq` + backup). Read-only FS inspector: drukuje 1 linię statusu (`▸ AppMaker vX │ feature NNN (D/T slices done) │ checklist: STATUS │ /appmaker:status for detail`). Silent exit gdy brak `appmaker/`. Liczy slice'y z `backlog/*.md` ORAZ `backlog/done/*.md`. Nigdy nie blokuje sesji (errors → exit 0). Wyłączalny: `session_hook_enabled: false`.
- **`glossary-extract.sh <artifact>`** — Tier-1 deterministyczna ekstrakcja: skanuje `**Bold-Uppercase**` (3-40 znaków), porównuje z `glossary.md`, dopisuje STUBY dla nowych (definicji NIE generuje). Idempotentny, `set +e`. Wołany jako post-step przez prd/decompose/tdd/grill. Wyłączalny: `glossary_hook_enabled: false`.

### Scripts (`plugin/appmaker/scripts/`)
- **`init-materialize.sh`** — masowa materializacja drzewa, `cp -n`/`cp -rn` (nigdy nie nadpisuje user-owned), auto-detekcja komend per typ projektu (package.json→npm, pyproject→pytest, Cargo→cargo, go.mod→go), zapis `.appmaker-version`, czytanie flag hooków.
- **`phase-plan.sh <phase-id> [--json]`** — deterministyczny planner faz: czyta `backlog/*.md`, waliduje (write_scope, agent_profile, traces_to, human_required=FAIL, unresolved deps, broad-scope WARN), wykrywa konflikty write_scope, buduje fale ≤ `max_parallel_agents` bez nakładania scope, wypisuje `phase-plans/*-dry-run.md` + opcjonalnie JSON. PASS/WARN/FAIL.
- **`status-json.sh [--project-dir]`** — read-only JSON snapshot (bez `jq`): version, active_feature, backlog{total,done,open_ids}, checklist, phase, git{dirty,changed_count}.

### Studio (`plugin/appmaker/studio/`) — Layer 5, lokalny GUI
- **`server.mjs`** — Node HTTP server (domyślnie `127.0.0.1:19773`). Endpointy: `GET /api/status` (→ `status-json.sh`), `GET /api/phase-plan?phase_id=` (→ `phase-plan.sh --json`), `/health`, static z `public/`. Tryb `--api status|phase-plan` (non-listening, dla testów/adapterów). Path-traversal guard.
- **`public/`** — statyczny cockpit (index.html, styles.css, app.js).
- Zasada: `appmaker/` pozostaje source of truth; Studio to tylko view/control plane nad deterministycznymi JSON API.

### Integracja z Graphify (Layer 3, opt-in)
- Graphify = read-only intelligence. AppMaker czyta `graphify-out/GRAPH_REPORT.md` + CLI `graphify query/path/explain`; NIE reimplementuje grafu, NIE persystuje `graph.json`.
- `/appmaker:context` pisze małe pakiety `context/<date>-<topic>.md` (query, communities, key files, risks, confidence). PRD/decompose/backlog/TDD/review/archive linkują pakiety.
- Config: `graphify_enabled, graphify_out_dir, graphify_context_packet_dir, graphify_stale_after_commits, graphify_use_cli, graphify_commit_output`. Checklist ostrzega o stale graph (>N commitów za HEAD).
- `init` oferuje instalację (z privacy warning). `.graphifyignore.template` w resources.

### Test harness
`tests/smoke/` — 28 suite, 467 asercji (run-all.sh). Pokrywa hooki, glossary-extract, version SoT, init materialization, skill body diet, phase dry-run/execute/runtime, engine JSON API, Studio UI, gstack browser adapter, rigor config, checklist execution-record gates, side-effect invocation boundaries.

---

## 4. Governance

### Constitution (`resources/appmaker/constitution.md.seed`)
**10 bounded rules** (user-owned, seedowane na init, nigdy nie nadpisywane na upgrade):
1. No silent fallbacks. 2. Verifiable success criteria (auto-check OR human-review-with-criteria). 3. Real boundaries in integration tests (no mocking DB/file/API). 4. One thing well per slice (vertical, demoable). 5. Glossary terms canonical. 6. Non-delegable judgments explicit (identity/trust/money/irreversible = `human_required`). 7. Test first, promote green. 8. No broken windows. 9. KISS/YAGNI. 10. Understand before changing.
(Świadome odejście od starych 18 rules. DESIGN.md guardrail: max 7 w seed — niespójność z 10 w pliku; nie jest lintowane → LUKA L1.)

### Bramki review / promotion
- **Tier 1 (deterministyczny):** `/appmaker:checklist` (PASS/FAIL/WARN przez `test -f`/`rg`/`find -mtime`), `phase-plan.sh`, glossary-extract, test harness.
- **Tier 2 (udokumentowane kryterium ludzkie):** constitution (10 rules), Matt's „hard-to-reverse AND surprising-without-context" filter dla `memory/decisions.md`.
- **Tier 3 (LLM judgment):** `/appmaker:review` (subagent critic), `--mode=ultra` (deleguje do `/ultra-review`), glossary semantic review.
- **Per-slice review gate (v0.2.15):** `next` wykrywa `UNREVIEWED_DONE` (done bez `## Review`/`review_status:`) i wymusza `/appmaker:review <id>` zanim ruszy kolejny slice — łapie drift wcześnie.
- Override: review FAIL → user fix LUB `review_status: failed_overridden` + reason.

### Role (provider-agnostic)
- **Planner** = `decompose` (tnie na slice'y) + `phase-plan.sh` (buduje fale).
- **Implementer** = `tdd` (RED-GREEN-REFACTOR) / subagenty fal w `phase --execute` / `afk` loop.
- **Critic/Reviewer** = `review` subagent (domyślnie `code-reviewer`, ale `review_subagent` konfigurowalny → ŻADNA rola nie zahardkodowana pod konkretny LLM; potwierdza zasadę „no vendor lock for critic"). `review_mode: subagent\|external\|manual`.
- Reviewer independence: generator NIE jest jedynym recenzentem własnego artefaktu (Constitution rule 6 spirit, Spec Kit `/analyze`).

### Traceability (rdzeń governance)
Łańcuch: PRD `pcrit-*` (lub project-specific `SC1`/`ID4`) → backlog `traces_to:` → AC checkbox `(traces_to: pcrit-NNN, test: file::name)` → test → kod. Drift = zerwany link. METHOD discipline test: weź dowolną linię kodu, idź w górę do PRD.

### Anti-bureaucracy / rigor
`rigor_level: light\|standard\|strict` w config — light (bugfix/small), standard (pełny lifecycle), strict (auth/payments/security/migrations). METHOD field rule: nowe pole musi albo automatyzować evidence albo zamykać named drift class, inaczej zostaje optional.

---

## 5. JAWNE LUKI / FUTURE-SCOPE / niezaimplementowane

### A) Skille zadeklarowane jako TODO (DESIGN.md:84-101, README.md:84-99)
- **`/appmaker:clarify`** — TODO (Spec Kit `/speckit.clarify`): dodatkowe pytania dla ambiguous areas → PRD `## Clarifications`. (PRD ma już slot `## Clarifications (auto-populated by /appmaker:clarify if invoked)` ale skill nie istnieje — `prd/SKILL.md:119`.)
- **`/appmaker:research`** — TODO: cache zewnętrznego researchu z freshness markers (≠ wbudowany Architecture Options Research gate).
- **`/appmaker:spike`** — TODO (Matt `prototype`, 3 pliki SKILL+LOGIC+UI): throwaway prototypy logic OR ui.
- **`/appmaker:plan`** — TODO: durable plan artifacts dla dużych work units (multi-phase).
- **`/appmaker:sync-github`** — TODO (Layer 4): push/pull backlog ↔ GitHub issues. Status snapshot: „Layer 4 TODO: 1 (sync-github)". (`afk` zaimplementowany.)

### B) Method-vs-Plugin gaps (audyt `audits/2026-05-17-method-vs-plugin.md`, v0.2.17)
Wszystkie 3 HIGH klastrują wokół jednego root cause: **slice NIE jest pierwotną durable jednostką w pluginie**.
- **H1 (HIGH):** slice'y żyją w `backlog/NNN-slug.md`, NIE w `features/NNN/slices/NN-slug/` (`audit:53-54`).
- **H2 (HIGH):** 5-plikowy slice contract NIE honorowany — `plan.md` + `evidence.md` brak jako named files, pozostałe 3 rozproszone (`audit:55`, Contract 1 tabela).
- **H3 (HIGH):** `plan.md` (R2 dry-run) NIE persystowany jako artefakt — TDD plan żyje w konwersacji (`audit:107`). *Częściowo złagodzone od audytu: backlog item ma teraz sekcje `## Approved TDD Plan` + `## Execution Record` — patrz METHOD „MVP under validation" niżej.*
- **M1 (MEDIUM):** PRD nie ma explicit `## Criticisms` z stabilnymi `pcrit-NNN` jako numerowana lista — `traces_to:` referuje coś, czego template PRD strukturalnie nie emituje (`audit:42,89`).
- **M2 (MEDIUM):** AC ↔ test name mapping nie-durable (`audit:45`). *Złagodzone: backlog template dodał `test: file::name` inline w AC.*
- **M3 (MEDIUM):** debrief drift detection (plan-vs-actual diff) brak — bo brak `plan.md` (`audit:110`).
- **L1 (LOW):** constitution rule count nie lintowany. **L2 (LOW):** production code → AC linkage tylko konwencja. **L3 (LOW):** archive rozdziela feature folder (`features/archive/`) od backlog items (`backlog/done/`).
- Otwarte pytanie v0.3 (`audit:176`): „lift plugin to match Method" vs „revise Method to match validated plugin" — NIEROZSTRZYGNIĘTE.

### C) METHOD.md „Open invariants worth testing" (METHOD.md:297-309) — hipotezy w walidacji
1. Konsolidacja 5 artefaktów slice w jednej lokalizacji (`slices/NN/` subfolder LUB sekcje backlog) — decyzja v0.3, audit-driven, NIEROZSTRZYGNIĘTA.
2. **Plan-vs-actual drift detection = „MVP under validation"** — backlog ma `## Approved TDD Plan` + `## Execution Record`; checklist warnuje gdy brak/drift. Kryteria walidacji: czy sekcja się wypełnia w realnych slice'ach, czy operatorzy jej używają przy wznawianiu, czy review surfacuje useful drift. „If no, simplify before automating further."
3. Aviation metaphor unification — do podniesienia do języka Method, jeszcze nie zrobione.

### D) DESIGN.md jawnie SKIPPED / deferred (per wersja)
- **Cole-style auto-hook session-end summary** (Claude Agent SDK) — deferred (v0.2.17). Wedge przeciw decyzji 32: „explicit + auditable, NOT invisible + automatic".
- **`auto_session_summary: false` opt-in flag** — deferred (czeka na friction signal).
- **Memory wiki vs Claude Mem hybrid integration** — deferred (większa decyzja filozoficzna, po drugim caseman lifecycle).
- **`--mode=ultra` / `--driver=goal` test coverage** — nie unit-testowalne (wymaga Claude Code 2.1.86+ / Pro-Max / `/goal`), manual verification.
- **`memory/raw/`** — user-owned drop folder; lifecycle ręczny lub archive-retro compile (był dead seed do v0.2.17).

### E) Future Scope Registry (`history/docs/reference/future-scope-registry.md`) — parking lot, NIE-binding
27 deferowanych scope'ów. Priorytety `core/soon/conditional/speculative`. Najważniejsze `core` jeszcze nie-zaimplementowane jako pełne mechanizmy:
- **Evidence-First Fact Policy** (core) — klasyfikacja claimów przez provenance (`model_assertion/file_verified/web_verified/...`); obecnie tylko dyscyplina w markdown.
- **Research Cache And Evidence Pack** (core) — `.appmaker/research/<wu-id>/research.md` + `evidence-manifest.yaml`; = przyszły `/appmaker:research`.
- **Context-Pack Schema** (core) — formalna executable schema + validator; obecnie pakiety to luźny markdown.
- **Verifiability Standards** (core) — proxy catalog dla subiektywnych celów; częściowo w prd discipline.
- **Validator Implementation** (core) — realna JSON Schema walidacja + `appmaker validate` CLI/CI. JAWNE: „do not pretend meta-validation exists before tooling exists". (Świadomie odrzucone w obecnym markdown-only designie.)
- **Backpressure And Safety/Quality Hooks** (core) — pre-tool hooks, write-scope enforcement deterministyczny, dependency approval; obecnie tylko `write_scope`/`edit_scope` jako konwencja + phase-plan walidacja.
- **Review Protocol And Reviewer Principle** (core) — scorecard schema, cross-decision checklist; częściowo w `review`.
- **Minimal Friendly CLI Interface** (core) — `appmaker start "<request>"`. JAWNIE odłożone: AppMaker świadomie NIE ma CLI (cała filozofia plugin-only). Registry to relikt starej iteracji.
- Pozostałe (soon/conditional/speculative): Agent-Native Project Interface (`AGENTS.md`), Context Development Lifecycle, Rulefile Governance, Multi-Phase Execution Plan, AFK Runner Topology, QA Feedback Loop & Repair Runner, Token Budget/Context Economy, Smart-Zone Work Sizing, Harness Evaluation/Ablation, Metric-Driven Experiment Runner, Voting Runner Protocol, Cross-Project Pattern Library, MCP Server Interface, MCP Budget/Allowlist, Cost Analytics, Multimodal Evidence Intake, Browser Backpressure, Schema Migration Tooling, Graph-Based Context Compiler, LLM Wiki, Project Standards Pack, Architecture Deepening Protocol, Agent Modes & Context Budget, Push/Pull Context Policy, Catalog Refresh & Trust Signals, Design Exploration Stage, Prototype & Spike Stage.

### F) Paused/superseded ADRs (`history/`)
Stary heavyweight kernel (5 ADR, 18 constitutional rules, 3 JSON Schemas, propagation chains, JSONL streams, work_units wu-002..wu-008) — ZARCHIWIZOWANY, nie część obecnego designu (REFERENCES.md: „~80% artefaktów miało niską wartość praktyczną").
- **WU-008 superseded** (`history/.appmaker/work-units/wu-008/work-unit-superseded-cli-implementation.yaml`): „Minimal CLI Gate" zastąpiony przed ACCEPT — strategiczna korekta: AppMaker potrzebuje product UX przed kodem implementacji; CLI primitives stały się INTERNAL/ADMIN. **ADR-006/007/008/009 PAUSED** do czasu wylądowania minimal CLI gate (który nigdy nie powstał — pivot do plugin-only).
- ADR-001..005 (process kernel, interview, schemas, PRD, decomposition) — ACCEPTED w starej erze, „bootstrap exception", już nie obowiązują operacyjnie.

### G) Open questions (DESIGN.md:492-496)
- Distribution model po MVP: marketplace plugin? (na razie lokalna git clone / `--plugin-dir`).
- GitHub issues adapter: kiedy budować (po walidacji local backlog).
- Pierwszy real Level C test: czy plugin loaduje + `/appmaker:init` w slash menu — PENDING user execution.
- Permanent activation per projekt w `.claude/settings.json` — TBD (na razie manual `--plugin-dir` per sesja).

---

## Kluczowe wnioski dla porównania z ECC
1. AppMaker = **markdown + bash + konwencje plikowe**, zero runtime/CLI/binarki (świadomy wybór, nie brak).
2. Governance overlay (constitution + glossary + traceability + deterministyczne gate'y) to potwierdzony rdzeń produktu.
3. Provider-agnostic potwierdzony w kodzie (`review_subagent` konfigurowalny, `--driver=goal`/`--mode=ultra` delegują do Claude Code built-ins).
4. Najgłębsza znana luka architektoniczna (z własnego audytu): **slice nie jest pierwotną durable jednostką** (3× HIGH) — nierozstrzygnięta decyzja v0.3.
5. Walidacja realna: tylko 1 produkcyjny case (caseman BPS, 5/7 slice'ów), pierwszy pełny lifecycle przez archive jeszcze nie domknięty.
6. Cała ciężka maszyneria (JSONL streams, JSON Schemas, validators, voting, MCP interface, CLI) jest albo zarchiwizowana w `history/`, albo deferowana w future-scope — to mapa „czego AppMaker świadomie NIE robi".
