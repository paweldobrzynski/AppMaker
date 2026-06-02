# ECC skills → AppMaker: analiza adopcyjna (meta / orkiestracja / agentic)

Źródło: `/Users/pawel/Projects/ECC/skills/` (249 podkatalogów).
Filtr: tylko skille META — agentic engineering, orkiestracja, ewaluacja agentów,
kontekst/tokeny, pamięć, ciągłe uczenie, governance, koszty LLM, harness, autonomous
loops, introspekcja/debug, council. Skille czysto domenowe/technologiczne (android,
clickhouse, react-*, django-*, kotlin-*, homelab-*, scientific-*, ito-*, healthcare-*,
energy/logistics/inventory ops itd.) pominięto jako duplikaty gstacka.

AppMaker (kontekst — czego NIE proponować, bo już ma): start→interview→prd→decompose→
phase→tdd→qa→review→archive, grill/grill-brownfield, glossary+memory/wiki,
context/token-audit, diagnose/status/next/feedback/checklist/design-review.
AppMaker jest Claude-native (bez własnego runtime/binarki), provider-agnostic,
governance overlay.

---

## Tabela kandydatów

| Skill (ścieżka) | Substancja (lines / quality) | Co robi | ADOPCJA |
|---|---|---|---|
| `skills/santa-method/` | 306 / **bardzo wysoka** | Multi-agent adversarial verification: generator + 2 niezależni recenzenci (izolacja kontekstu, ten sam rubric), gate "oba muszą przejść", convergence loop max 3 iter, fresh agents co rundę, batch sampling, metryki (first-pass rate, escape rate). | **TAK** |
| `skills/council/` | 203 / **bardzo wysoka** | Rada 4 głosów (Architect/Skeptic/Pragmatist/Critic) do decyzji pod niejednoznacznością. Anti-anchoring przez świeże subagenty z samym pytaniem; jawne ujawnianie dissentu; reguła kiedy NIE używać. | **TAK** |
| `skills/autonomous-loops/` (≈ `continuous-agent-loop`, `ralphinho-rfc-pipeline`) | 610 / **bardzo wysoka** | Spektrum wzorców pętli autonomicznych: sequential `claude -p`, infinite agentic loop, continuous PR loop, de-sloppify, RFC-driven DAG z merge queue + eviction. Decision matrix, anti-patterns. | **MOŻE** (patrz uwagi) |
| `skills/agent-architecture-audit/` | 256 / **bardzo wysoka** | Diagnostyka 12-warstwowego stacku agenta (prompt, memory, tool discipline, hidden repair loops, rendering). Severity-ranked findings, rg-anti-pattern queries, schema JSON raportu, code-first fix order. | **TAK** |
| `skills/agent-introspection-debugging/` | 153 / wysoka | Self-debug agenta w 4 fazach: capture → diagnoza (tabela wzorców awarii) → contained recovery → introspection report. "Workflow skill, nie ukryty runtime". | **TAK** |
| `skills/eval-harness/` | 270 / wysoka | Eval-driven development dla sesji Claude Code: capability/regression evals, grader code/model/human, pass@k & pass^k, layout artefaktów `.claude/evals/`, progi release. | **MOŻE** (overlap z qa) |
| `skills/agent-eval/` | 145 / wysoka | Head-to-head benchmark agentów (Claude Code/Aider/Codex) na YAML-taskach, worktree isolation, metryki pass rate/koszt/czas/consistency. Wymaga zewn. binarki `agent-eval`. | **NIE** (standalone runtime, vendor-ish) |
| `skills/continuous-learning-v2/` | 360 / wysoka | Instynkty (atomic learned behaviors) z confidence scoring, project-scoped, hooki PreToolUse/PostToolUse, background observer (Haiku), evolve→skill/command, promote project→global. | **NIE/MOŻE** (wymaga hooków + tła + Python CLI) |
| `skills/context-budget/` | 135 / wysoka | Audyt zużycia okna kontekstu (agents/skills/MCP/rules/CLAUDE.md), heurystyki tokenów, klasyfikacja always/sometimes/rarely, raport z top oszczędnościami. | **MOŻE** (overlap z context/token-audit) |
| `skills/agent-harness-construction/` | 73 / średnia-wysoka (gęsta) | Projektowanie action space / tool definitions / observation format. Tool granularity, observation contract (status/summary/next_actions), error recovery contract, context budgeting. | **TAK** (dla autorów AppMaker-skilli) |
| `skills/agentic-engineering/` | 63 / średnia (zwięzła doktryna) | Operating principles: completion criteria first, decompose w 15-min units, model routing, eval-first loop, review focus dla AI-gen kodu. | **MOŻE** (overlap z filozofią AppMakera) |
| `skills/cost-aware-llm-pipeline/` | 183 / wysoka (ale Python-code) | Wzorce kosztowe LLM API: model routing wg złożoności, immutable cost tracking, narrow retry, prompt caching. To wzorzec do BUDOWANEJ aplikacji, nie do harnessa. | **NIE** (domenowe, nie meta-orkiestracja) |
| `skills/recursive-decision-ledger/` | 79 / wysoka | Ledger powtarzanych rolloutów: append-only JSONL, decision marks (accept/watch/reject), coherence mark vs prior, promotion gate (default dry-run/paper). Anti-"pętla = pewność". | **MOŻE** (nisza: stochastic/repeated decisions) |
| `skills/plan-orchestrate/` | 262 / **bardzo wysoka, ale ECC-specyficzna** | Czyta plan → dekompozycja kroków → dobiera łańcuch agentów z katalogu ECC → emituje gotowe `/orchestrate custom` linie. Mocno związane z agentami i namespace ECC. | **NIE** (sprzężone z runtime/agentami ECC, dubluje decompose) |
| `skills/rules-distill/` | 264 / wysoka | Skanuje skille, wyciąga zasady występujące w 2+ skillach i destyluje do plików rules (append/revise/new). "Deterministic collection + LLM judgment". | **MOŻE** (governance: utrzymanie constitution/rules) |
| `skills/skill-stocktake/` | 194 / wysoka | Audyt jakości skilli/commandów (Quick Scan / Full), subagent batch eval, werdykty Keep/Improve/Update/Retire/Merge, wymóg samowystarczalnego "reason". | **MOŻE** (higiena własnego katalogu skilli) |
| `skills/skill-scout/` | 140 / wysoka | Szukaj istniejących skilli (local/marketplace/GitHub/web) ZANIM stworzysz nowy; vetting bezpieczeństwa zewn. skilli; ranking; tabela decyzji use/fork/create. | **MOŻE** (meta dla autorów skilli) |
| `skills/skill-comply/` | 58 (+ scripts) / wysoka koncepcyjnie | Mierzy czy agent FAKTYCZNIE wykonuje skill/rule: auto-generuje scenariusze o malejącej strictness, uruchamia `claude -p`, klasyfikuje tool-calle vs spec, raport compliance. | **MOŻE** (świetny pomysł, ale wymaga `claude -p` + skryptów) |
| `skills/gateguard/` | 125 / wysoka | PreToolUse hook wymuszający fakty (importerzy, schema, instrukcja usera) PRZED Edit/Write/Bash. "Investigation > self-evaluation". Twierdzony +2.25 pkt jakości. | **NIE** (to hook, nie slash-command; ale idea cenna) |
| `skills/safety-guard/` | 75 / średnia | Guardraile przeciw destrukcyjnym operacjom (careful mode, scope-restrict, sensitive ops) dla trybu autonomicznego. | **NIE** (pokrywa gstack `careful`) |
| `skills/autonomous-agent-harness/` | 273 / wysoka, ale runtime-zależna | Zamienia Claude Code w persistent autonomous system: crony, dispatch, computer use, memory, task queue. Wymaga natywnych crons/dispatch/computer-use. | **NIE** (standalone autonomy, sprzeczne z lekkim overlayem) |
| `skills/agentic-os/` | 387 / wysoka, ale runtime-zależna | "Claude Code jako OS": kernel routujący do specjalistów, file-based memory, scheduled automation, JSON/md data layer. | **NIE** (cały framework/runtime, nie pasuje do overlay) |
| `skills/iterative-retrieval/` | 211 / wysoka | Wzorzec progresywnego doprecyzowania kontekstu dla subagentów (problem "nie wiem czego potrzebuję dopóki nie zacznę"). RAG-like po kodzie. | **MOŻE** (jeśli AppMaker orkiestruje subagenty) |
| `skills/strategic-compact/` | 131 / średnia | Sugeruje `/compact` na granicach faz zamiast auto. Decision table co przetrwa kompakcję. Część przez hook. | **NIE** (overlap z context/token-audit; część to hook) |
| `skills/parallel-execution-optimizer/` | 72 / średnia | Zamiana "zrób szybciej" w graf zależności lanes (parallel/sequential/gated) bez utraty poprawności. | **MOŻE** (lekki, dekompozycja równoległa) |
| `skills/benchmark-optimization-loop/` | 69 / średnia | "Zrób 20x szybciej" → bounded measured loop: baseline + correctness gate + metryka + iteracje. | **NIE** (nisza perf, nie core orkiestracji) |
| `skills/automation-audit-ops/` | 142 / wysoka, ale ECC-ops | Audyt żywych automatyzacji (joby/hooki/connectory/MCP) — keep/merge/cut/fix. Mocno sprzężony z workspace ECC. | **NIE** (ops-specyficzny dla ECC) |
| `skills/knowledge-ops/` | 154 / wysoka, ale ECC-ops | Wielowarstwowa pamięć (GitHub/Linear/MCP memory/KB repo/Supabase). Dużo założeń o stacku usera. | **NIE** (overlap z AppMaker memory/wiki + opinionated stack) |
| `skills/team-builder/`, `skills/claude-devfleet/`, `skills/dmux-workflows/`, `skills/nanoclaw-repl/` | 168/103/191/33 / mieszana | Pickery zespołów agentów / DevFleet MCP / dmux / NanoClaw REPL — wszystkie zależne od zewn. runtime (MCP, tmux, claw.js). | **NIE** (runtime/binary lock) |
| `skills/code-tour/`, `skills/codebase-onboarding/`, `skills/repo-scan/`, `skills/agent-sort/` | 236/233/78/? / wysoka | Onboarding/tour/audyt kodu i sortowanie ECC-surface. Częściowo overlap z grill-brownfield/Graphify; agent-sort/repo-scan ECC- lub binary-specyficzne. | **NIE** (overlap / domenowe) |
| `skills/ai-first-engineering/`, `skills/enterprise-agent-ops/` | 51/50 / niska-średnia (cienkie doktryny) | Krótkie listy zasad org/ops dla zespołów AI-first / long-lived agentów. Bez konkretnych instrukcji wykonawczych. | **NIE** (esej, nie wykonywalny workflow) |
| `skills/cost-tracking/`, `skills/ecc-tools-cost-audit/` | 147/160 / wysoka, ale niszowe | Analiza kosztów z lokalnej SQLite / audyt billingu konkretnej apki ECC-Tools. | **NIE** (wymaga ich infry/repo) |
| `skills/continuous-learning/` | 131 / **DEPRECATED** | v1 stop-hook extractor, jawnie oznaczony DEPRECATED, przekierowuje do v2. | **NIE** (wydmuszka — deprecated) |

---

## TOP kandydatów do adopcji (z uzasadnieniem dopasowania do filozofii AppMakera)

AppMaker = **governance overlay + dyscyplina cyklu życia, Claude-native, provider-agnostic,
bez własnego runtime**. Najlepsi kandydaci to skille, które są czystymi *workflow/prompt
protocols* (działają jako instrukcja dla modelu, nie wymagają binarki/MCP/crona) i wypełniają
lukę w warstwie *quality gate / decision / introspekcja*, której AppMaker jeszcze nie ma w tej formie.

1. **santa-method** (`skills/santa-method/`) — TOP 1.
   Dwóch niezależnych recenzentów + gate "oba muszą przejść" + convergence loop to dokładnie
   ten rodzaj dyscypliny, którego AppMaker review/qa nie kodyfikuje na poziomie *adversarial
   independence*. Czysto promptowy protokół (subagenty), provider-agnostic, bez runtime.
   Wzmacnia fazę review/qa o anti-author-bias. Najwyższa wartość/koszt.

2. **council** (`skills/council/`) — TOP 2.
   Strukturalny mechanizm decyzji pod niejednoznacznością z anti-anchoringiem. AppMaker ma
   grill (stress-test planu), ale nie ma *4-głosowej rady do go/no-go i tradeoffów*. Idealnie
   wpasowuje się między grill a decompose/prd ("którą ścieżką iść?"). Czysto Claude-native,
   jeden plik, zero zależności. Komplementarny, nie dublujący.

3. **agent-architecture-audit** (`skills/agent-architecture-audit/`) — TOP 3.
   Jeśli AppMaker buduje aplikacje LLM/agentowe, to ten 12-warstwowy audyt (wrapper regression,
   memory contamination, tool discipline, hidden repair loops) jest unikatowym *meta-review*
   dla agentowych projektów. Schema JSON raportu + severity model pasują do governance overlay.
   Brak odpowiednika w AppMakerze ani w gstacku.

4. **agent-introspection-debugging** (`skills/agent-introspection-debugging/`) — TOP 4.
   4-fazowy self-debug (capture → diagnoza → contained recovery → report) jako *workflow skill,
   nie runtime* — wprost deklaruje, że nie obiecuje rzeczy poza możliwościami harnessa. To
   idealny fit dla AppMaker diagnose/status: gdy pętla AppMakera utyka, ten skill daje
   ustrukturyzowaną procedurę naprawczą. Lekki, provider-agnostic.

5. **agent-harness-construction** (`skills/agent-harness-construction/`) — TOP 5.
   Zwięzła, gęsta doktryna projektowania tool/observation/recovery contract + context budgeting.
   Wartość META dla samego AppMakera: jak pisać jego skille/komendy, by agent się nie gubił
   (observation contract: status/summary/next_actions). Idealny "wiedza dla autorów overlay".

6. **rules-distill** (`skills/rules-distill/`) — TOP 6 (governance).
   Destyluje powtarzające się zasady z wielu skilli do plików rules ("2+ skille, actionable,
   violation risk"). Dla AppMakera = automatyczne utrzymanie *constitution/rules* na podstawie
   tego co faktycznie pojawia się w PRD/decompose/review. Czysto promptowy + drobne skrypty
   skanujące (zastępowalne Glob/Grep). Wpisuje się w governance overlay.

Kandydaci "drugiej linii" (warto, ale z zastrzeżeniami): **eval-harness** (mocny, ale częściowo
dubluje qa AppMakera — adoptować selektywnie pass@k/pass^k jako progi release), **skill-scout +
skill-stocktake** (higiena własnego katalogu skilli AppMakera — meta, ale niszowe),
**parallel-execution-optimizer** i **iterative-retrieval** (jeśli AppMaker realnie orkiestruje
subagenty), **recursive-decision-ledger** (gdy pojawią się powtarzalne/stochastyczne decyzje).

---

## Wydmuszki / słabe lub niepasujące (ze sprawdzonych)

- **continuous-learning** (`skills/continuous-learning/`, 131 lin.) — **wydmuszka adopcyjna**:
  jawnie `DEPRECATED 2026-04-28`, cała treść to "use v2" + archiwum. Nie adoptować.

- **ai-first-engineering** (51 lin.) i **enterprise-agent-ops** (50 lin.) — **cienkie eseje
  doktrynalne**: listy ogólnych zasad ("planning quality matters more than typing speed",
  "immutable deployment artifacts") bez wykonywalnego workflow, przykładów ani kroków. Wartość
  jako manifest, zero jako uruchamialny skill. Nie adoptować.

- **agentic-engineering** (63 lin.) — solidna, ale to w 80% *filozofia, którą AppMaker już
  ucieleśnia* (completion-criteria-first, decompose, model routing, eval-first). Nie wydmuszka,
  ale duplikat ducha AppMakera — nie wnosi nowego mechanizmu.

Skille, które są **substancjalne, ale zdyskwalifikowane przez zależności od runtime/binarki/MCP**
(nie wydmuszki jakościowo, lecz sprzeczne z "Claude-native, bez własnego runtime"):
`agent-eval` (binarka `agent-eval`), `autonomous-agent-harness` i `agentic-os` (persistent
runtime, crons, computer-use), `claude-devfleet` (MCP server), `team-builder`/`dmux-workflows`/
`nanoclaw-repl` (tmux/claw.js), `gateguard` i `strategic-compact` (PreToolUse hooki, nie
slash-commands), `cost-tracking`/`ecc-tools-cost-audit`/`automation-audit-ops` (wymagają infry/
repo ECC). `plan-orchestrate` jest świetnie napisany, ale twardo sprzężony z katalogiem agentów
i namespace `/orchestrate` ECC oraz dubluje AppMaker decompose → nie adoptować jako całość
(można podebrać sam *wzorzec tagowania kroków → łańcuch ról*, ale to już re-implementacja).
