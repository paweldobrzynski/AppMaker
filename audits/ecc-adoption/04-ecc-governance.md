# ECC — analiza warstwy orkiestracji / governance / multi-harness (pod adopcję do AppMakera)

Źródło: `/Users/pawel/Projects/ECC` (ECC = "Everything Claude Code", v2.0.0-rc.1, fork `affaan-m/everything-claude-code`).
Skala: 63 agentów, 79 komend, 13 legacy-shimów, 249 skilli, ~14 MCP-configów, 11 adapterów harness.

---

## 1. Model orkiestracji ECC

### 1.1 Trzy warstwy zasobów (a `skills/` jest kanonem)
ECC rozdziela powierzchnie i ma jawną politykę "skills-first":

- **`agents/`** — wyspecjalizowane subagenty (delegacja). Format: Markdown + YAML frontmatter (`name`, `description`, `tools`, `model`, opcjonalnie `color`). Każdy agent ma wklejony "Prompt Defense Baseline" (6 reguł anty-injection) na początku ciała — to jest **wstrzykiwane do KAŻDEGO agenta i reguły** (zob. `agents/*.md`, `.claude/rules/*.md`, `CLAUDE.md`).
- **`skills/`** — kanoniczna powierzchnia workflow. Polityka z `AGENTS.md`: *"`skills/` is the canonical workflow surface. New workflow contributions should land in `skills/` first. `commands/` is a legacy slash-entry compatibility surface."*
- **`commands/`** — slash-entry, dziś głównie cienkie wejścia delegujące do skilla/agenta.
- **`rules/`** + `.claude/rules/` — always-on guardrails ładowane co sesję (system-injected, "LLM nie może zignorować").
- **`hooks/`** — deterministyczne wymuszanie (PreToolUse/PostToolUse/SessionStart/Stop).

Wyzwalanie agentów: opisowo przez `description` ("When to Use") + jawna tabela w `AGENTS.md` ("Agent Orchestration", sekcja "Use agents proactively without user prompt"). Mapowanie komenda→agent jest skodyfikowane w `docs/COMMAND-AGENT-MAP.md`.

### 1.2 Model orkiestracji = hub-and-spoke + opcjonalny council
Nie ma jednego "orchestratora-runtime". Są **trzy wzorce koordynacji**:

1. **Sekwencyjny handoff** (`commands/feature-dev.md`, legacy `orchestrate.md`): planner → tdd-guide → code-reviewer → security-reviewer → architect, z ustrukturyzowanym blokiem handoffu (`FILES CHANGED / TEST RESULTS / SECURITY STATUS / RECOMMENDATION: SHIP|NEEDS WORK|BLOCKED`).
2. **Równoległy fan-out** dla niezależnych checków ("Run simultaneously: code-reviewer, security-reviewer, architect → Merge Results").
3. **GAN council (nowatorskie)** — trójka `gan-planner` / `gan-generator` / `gan-evaluator` (`agents/gan-*.md`), inspirowana "Anthropic harness design paper, March 2026". Planner pisze spec + **rubrykę ewaluacji z wagami** do `gan-harness/spec.md` i `eval-rubric.md`; Generator implementuje; Evaluator testuje **żywą aplikację** przez Playwright i punktuje przeciw rubryce, z jawną instrukcją "Be Ruthlessly Strict / fight your tendency to be generous". To pętla adwersarialna generator↔krytyk z wymiernym progiem zdawalności.

### 1.3 Operator / control-plane (ECC 2.0)
- **`ecc2/`** — alpha-owy control-plane w Ruście (komendy `dashboard/start/sessions/status/stop/resume/daemon`).
- **`loop-operator`** (agent) — prowadzi autonomiczne pętle z jawnymi warunkami stopu: required checks (`quality gates active`, `eval baseline exists`, `rollback path exists`, `branch/worktree isolation`) + warunki eskalacji (brak progresu w 2 checkpointach, powtarzalne identyczne stack-trace'y, dryf kosztu poza budżet).
- **`harness-optimizer`** (agent) — tuninguje konfigurację harnessa (nie kod produktu): `/harness-audit` → baseline score → top-3 dźwignie (hooks/evals/routing/context/safety) → minimalne odwracalne zmiany → delta przed/po.
- **Handoff "CONTROL PLANE"** — w długich sesjach (worktree/tmux) handoff zawiera bloki Sessions/Diffs/Approvals/Telemetry (legacy `orchestrate.md`). Snapshoty: `scripts/orchestration-status.js`.

### 1.4 Pętla wartości (jak ECC sam się opisuje)
`docs/architecture/platform-value-loop.md` definiuje trzy warstwy produktu: (1) **meta-harness** (przenośne skille/reguły/hooki/MCP/release-gates/evals/security-evidence), (2) **dedykowany agent ECC** operujący na zasobach, (3) **control-pane / agentic IDE**. Plus jawny 7-krokowy "Value Loop" (product team buduje skill pack → publiczny pack działa na public/local data → gated access do live → użycie generuje nowe wzorce → sanityzacja → lepsze skille/evale/gate'y → dystrybucja/sponsoring). To "OSS infra playbook": darmowy rdzeń jako standard, płatne = team memory, observability, managed evals, release gates, security/policy.

### 1.5 Pętla samouczenia (continuous-learning v2)
Osobny, ciekawy mechanizm promocji wiedzy (`docs/continuous-learning-v2-spec.md`, komendy `learn / evolve / promote / instinct-*`):
1. Hook-based observation capture (PreToolUse obserwuje wzorce użycia).
2. Background observer → scoring → trwałe "instynkty".
3. `/evolve` klastruje instynkty w wyższe struktury: **instynkt → command** (gdy user-invoked), **→ skill** (gdy auto-triggered), **→ agent** (gdy złożony multi-step).
4. `/promote` awansuje instynkt z project-scope do global-scope gdy: występuje w ≥2 projektach i przekracza próg pewności.

To jest **promotion gate na poziomie wiedzy** — dokładnie ten typ bramki, który AppMaker robi na poziomie artefaktów (review→promotion).

---

## 2. Komendy, skille, shimy/migracja

### 2.1 Model komendy
Komenda = Markdown + frontmatter (`description:` wymagany; często `command: true`, `name`). Trend: komenda jest cienka, ciało deleguje "Apply the `<skill>` skill". Przykład `/promote`, `/evolve` — komenda to praktycznie wrapper na `python3 .../instinct-cli.py promote ...` z fallbackiem `CLAUDE_PLUGIN_ROOT` → `~/.claude/...` (deterministyczna logika w skrypcie, nie w LLM).

### 2.2 Mechanizm shimów / kompatybilności wstecznej (WARTE UWAGI)
`legacy-command-shims/` (13 plików) to wzorzec migracji muscle-memory:
- Każdy shim ma frontmatter `description: Legacy slash-entry shim for the <X> skill. Prefer the skill directly.`
- Ciało: nagłówek "(Legacy Shim)", sekcja "Canonical Surface" (gdzie żyje maintainowana wersja, np. `skills/tdd-workflow/SKILL.md`), `## Arguments: $ARGUMENTS`, `## Delegation` (deleguj do skilla, nie duplikuj playbooka).
- `legacy-command-shims/README.md`: shimy **nie są ładowane domyślnie** — user musi świadomie skopiować pojedynczy plik do swojego katalogu komend. To "opt-in deprecation", nie hard-break.
- `/orchestrate` → deleguje do `dmux-workflows` + `autonomous-agent-harness`; `/tdd` → `tdd-workflow`. Jeden stary alias może mapować na kilka kanonicznych skilli.

Cykl deprecjacji: aktywna komenda → shim (z wskazaniem kanonu) → kandydat do usunięcia. Idealny do AppMakera, gdzie zestaw slash-commandów będzie ewoluował.

---

## 3. Formaty kontekstu / schematy vs AppMakerowy context-packet

### 3.1 `contexts/` — tryby behawioralne (lekkie)
`contexts/{dev,research,review}.md` to **profile zachowania**, nie pakiety danych: Mode / Focus / Behavior / Priorities / Tools to favor / Output Format. To jest analog AppMakerowych "behavioral-modes", a nie context-packetu z danymi. Bardzo tani wzorzec do przełączania nastawienia agenta.

### 3.2 `schemas/` — twarde kontrakty instalacji/stanu (10 schematów JSON)
ECC schematyzuje *infrastrukturę*, nie kontekst zadania: `ecc-install-config`, `install-components/modules/profiles/state`, `hooks`, `package-manager`, `plugin`, `provenance`, `state-store`. Kluczowy dla AppMakera jest **`provenance.schema.json`**: dla każdego learned/imported skilla wymaga `source`, `created_at` (ISO8601), `confidence` (0–1), `author`. To minimalny, wymuszalny "paszport pochodzenia" artefaktu.

### 3.3 Manifest instalacji (component model)
`manifests/install-{profiles,modules,components}.json` + `scripts/install-plan.js` / `install-apply.js`:
- **moduł** = `{id, kind, description, paths[], targets[], dependencies[], defaultInstall, cost: light|..., stability: stable|...}`.
- **profil** = nazwana lista modułów (`minimal/core/developer/security/research/full`).
- `targets[]` per moduł wymienia harnessy (`claude, cursor, codex, zed, qwen, ...`) — instalacja jest selektywna i deklaratywna.

Porównanie z context-packet AppMakera: ECC nie ma per-zadaniowego pakietu kontekstu jak Graphify; jego "kontekst" to (a) lekkie tryby behawioralne, (b) schematyzowany stan instalacji/sesji, (c) provenance artefaktów. AppMakerowy context-packet (Graphify) jest bogatszy semantycznie; od ECC wartością jest **schematyzacja provenance + cost/stability/dependencies jako metadane każdego artefaktu**.

### 3.4 Ewaluacja i self-assessment
- **`EVALUATION.md`** — porównanie "repo vs aktualny `~/.claude/`": tabela gap-analysis (komponent → current vs repo), rekomendacje per profil instalacyjny, "What the Current Setup Does Well". To jest **diff-owy self-audit instalacji**.
- **`REPO-ASSESSMENT.md`** — ocena zdrowia repo/forka: status synca z upstream, tabela priority additions (highest ROI), opcje (tracker/customize/npm). Tabela "Question → Answer" jako TL;DR.
- **Rubryka ECC w GAN** — `eval-rubric.md` z wagami (Design 0.3 / Originality 0.2 / Craft 0.3 / Functionality 0.2) konsumowana wprost przez Evaluatora. To wymierna bramka jakości.
- **`scripts/harness-audit.js`** + `/harness-audit` — scorecard konfiguracji harnessa (baseline → delta).

---

## 4. Mechanizm multi-harness (jeden-do-wielu)

### 4.1 Zasada źródła
`docs/architecture/cross-harness.md`: *"ECC is the reusable workflow layer. Harnesses are execution surfaces."* Durable behavior żyje raz w `skills/` (`SKILL.md` = "most portable unit": frontmatter `name/description/origin`, "when to use", bez sekretów, repo-relative przykłady). **Reguła twarda**: *"If a change requires editing three harness copies of the same workflow, the shared source is in the wrong place."* Adaptery mają być cienkie i tylko: ładować zasób, adaptować kształt eventów, mapować nazwy komend, obsługiwać limity platformy.

### 4.2 Jak adaptery powstają (3 mechanizmy, nie jeden generator)
ECC NIE ma jednego, czystego generatora "1 źródło → N luster". To hybryda:
- **Transformatory frontmatteru** — `scripts/gemini-adapt-agents.js`: mapuje nazwy tooli Claude→Gemini (`Read→read_file`, `Bash→run_shell_command`, `mcp__x__y → mcp_x_y`), usuwa nieobsługiwane `color:`. Deterministyczny rewrite plików w `.gemini/agents`.
- **Build/transpile** — `scripts/build-opencode.js`: kompiluje TS adaptera OpenCode (`.opencode/` ma własny `package.json`, pluginy `ecc-hooks.ts`, tools, eventy).
- **Install-targets** — `scripts/lib/install-targets/{claude-home,codex-home,cursor-project,gemini-project,zed-project}.js` sterowane manifestem (`targets[]`) — kopiują/adaptują wybrane moduły do układu danego harnessa.

### 4.3 Rejestr zgodności jako single source of truth (NAJMOCNIEJSZY ELEMENT)
`scripts/lib/harness-adapter-compliance.js` to **zamrożona tablica `ADAPTER_RECORDS`** (11 harnessów) z polami: `id, harness, state, supported_assets[], unsupported_surfaces[], install_or_onramp[], verification_commands[], risk_notes[], last_verified_at, owner, source_docs[]`. Cztery stany dojrzałości:
- **Native** (Claude Code, Terminal-only) — ECC instaluje/weryfikuje bezpośrednio.
- **Adapter-backed** (OpenCode, Cursor, Zed, dmux) — cienki adapter, parytet różni się.
- **Instruction-backed** (Codex, Gemini) — guidance/pliki tak, ale brak runtime-hook surface do enforcement.
- **Reference-only** (Orca, Superset, Ghast) — tylko presja projektowa/benchmark, brak installera.

Z tej tablicy **generowana jest dokumentacja** (`renderMarkdownTable()` wstrzykiwany między markery `<!-- harness-adapter-compliance:matrix-start/end -->` w `docs/architecture/harness-adapter-compliance.md`), a `validateDocumentation()` + `--check` w CI **fail-uje gdy doc rozjedzie się z kodem**. Walidacja wymusza komplet pól, unikalne id, format daty. To wzorzec "kod = źródło prawdy, doc = generowane, CI pilnuje synca".

Kluczowe: ECC jawnie deklaruje **degradację do Terminal-only** jako "fallback contract; every higher-level adapter should degrade to it".

---

## WZORCE DO ADOPCJI (dla AppMakera)

Każdy wzorzec: wartość → JAK po AppMakerowemu (provider-agnostic, Claude-native, governance) → ostrzeżenie.

### A. GAN council — generator/krytyk z wymierną rubryką + próg zdawalności
- **Wartość**: adwersarialna pętla planner→generator→evaluator z **wagowaną rubryką** i twardym progiem ("Ruthlessly Strict, fight generosity") to ostrzejsza wersja AppMakerowego `review`/`grill`. Evaluator testuje DZIAŁAJĄCY artefakt, nie kod.
- **JAK**: nie kopiuj 3 agentów GAN. AppMaker ma już sloty `critic/planner/implementer` — dodaj do bramki `review`/`qa` **opcjonalny artefakt `eval-rubric` z wagami** (per fazę/PRD), który critic-slot konsumuje. Rola "evaluator" = slot konfiguracyjny (dowolny LLM), nie agent pod Claude. Próg zdawalności zapisz w `.appmaker/` jako część definicji bramki promotion.
- **Ostrzeżenie**: nie wprowadzaj własnego runtime pętli GAN ani harness-papierowej terminologii. Trzymaj to jako bramkę w istniejącym cyklu (`qa→review`), nie nowy podsystem. Wagowane rubryki łatwo się przeradzają w teatr metryk — trzymaj 3–4 kryteria max.

### B. Legacy-command-shims — opt-in deprecation slash-commandów
- **Wartość**: gdy zestaw komend AppMakera ewoluuje, shim zachowuje muscle-memory bez utrzymywania dwóch playbooków. Wzorzec: frontmatter "Legacy shim", sekcja "Canonical Surface", `## Delegation`, brak domyślnego ładowania (user świadomie kopiuje).
- **JAK**: dla AppMakera (Claude-native slash-commands) to wprost przenośne — stara komenda → cienki plik delegujący do nowego skilla/komendy + jednolinijkowy `description` "Prefer X". Kanon = AppMakerowy skill; shim tylko mapuje nazwę. Wpisz cykl deprecjacji do constitution.md jako regułę governance.
- **Ostrzeżenie**: nie ładuj shimów domyślnie (kontekst + dezorientacja). ECC trzyma je poza domyślną powierzchnią — rób tak samo.

### C. Adapter-compliance registry — kod jako źródło prawdy + CI-validated doc
- **Wartość**: zamrożony rejestr ze stanami dojrzałości (Native/Adapter/Instruction/Reference), polami `verification_commands`, `risk_notes`, `last_verified_at`, `owner` i CI-checkiem syncu doc↔kod. To governance-grade traceability.
- **JAK**: nawet jeśli AppMaker zostaje Claude-only, **ten wzorzec stosuje się do dowolnej macierzy zdolności** — np. rejestr slotów ról (planner/critic/implementer) × providerów, albo rejestr bramek z `owner`/`last_verified_at`. Generuj sekcję tabeli w docs z jednego źródła i waliduj w CI. Wprost wspiera "provider-agnostic": tablica `provider × rola × stan-wsparcia` z degradacją do "instruction-only" gdy provider nie ma danej funkcji.
- **Ostrzeżenie**: NIE adoptuj samego multi-harness (11 adapterów) — to sprzeczne z "Claude-native, BEZ runtime". Adoptuj wzorzec REJESTRU, nie listę harnessów.

### D. Provenance schema dla learned/imported artefaktów
- **Wartość**: `{source, created_at, confidence, author}` jako wymagany paszport każdego wygenerowanego/zaimportowanego skilla. Wymuszalny, minimalny, audytowalny.
- **JAK**: AppMaker ma memory/wiki + generuje artefakty (PRD, ADR, decompozycje). Dodaj analogiczny `provenance` blok do artefaktów `.appmaker/` (kto/co/kiedy/jaka pewność/skąd) — szczególnie do rzeczy generowanych przez critic/planner-sloty (provider-agnostic: `author` = nazwa slotu+modelu). To zasila governance i ADR-y.
- **Ostrzeżenie**: nie rozdmuchuj schematu — ECC trzyma 4 pola wymagane + `additionalProperties: true`.

### E. Continuous-learning promotion gate (instynkt → skill/command/agent, project→global)
- **Wartość**: jawne reguły awansu wiedzy: klastrowanie obserwacji w struktury wg typu (user-invoked→command, auto-triggered→skill, multi-step→agent) i promocja project→global po progu (≥2 projekty + confidence).
- **JAK**: AppMaker już ma memory/wiki i bramki promotion dla artefaktów. Zastosuj **ten sam kształt bramki do wiedzy operacyjnej**: powtarzalny wzorzec w ≥N projektach → kandydat do promocji do globalnego skilla/komendy. Decyzja awansu = bramka governance (wpis do constitution/ADR), nie auto-magia. Kryterium typu (command vs skill vs subagent) jest gotowym drzewem decyzyjnym.
- **Ostrzeżenie**: ECC robi to skryptem Python (`instinct-cli.py`) = własny mini-runtime. AppMaker (BEZ runtime) powinien zostawić to jako **skill-przewodnik decyzyjny + ręczna bramka**, nie demon w tle.

### F. Lekkie tryby kontekstu (`contexts/*.md`) + ustrukturyzowany handoff "SHIP/NEEDS WORK/BLOCKED"
- **Wartość**: tani przełącznik nastawienia (dev/research/review: Mode/Focus/Behavior/Priorities/Output) oraz znormalizowany blok handoffu między fazami z werdyktem `SHIP|NEEDS WORK|BLOCKED` (+ opcjonalny blok CONTROL PLANE: Sessions/Diffs/Approvals/Telemetry).
- **JAK**: AppMaker ma behavioral-modes — werdykt `SHIP/NEEDS WORK/BLOCKED` to gotowy, twardy output bramek `review`/`qa` w cyklu. Wpisz go jako wymagany format wyjścia bramki w `.appmaker/`. Handoff między `phase→tdd→qa→review` standaryzuj na tym bloku.
- **Ostrzeżenie**: blok CONTROL PLANE (tmux/worktree/telemetry) jest dla operatora long-running sesji — pomiń, jeśli nie wchodzisz w orkiestrację wielosesyjną.

### G. Profile/moduły instalacyjne z metadanymi `cost/stability/dependencies`
- **Wartość**: deklaratywny `module = {paths, dependencies, defaultInstall, cost, stability}` + nazwane profile (minimal→full). Selektywny, audytowalny zestaw zdolności.
- **JAK**: AppMaker może opisać własne komendy/skille jako moduły z `dependencies` i `stability` (stable/experimental) — bramka governance może blokować promocję artefaktu zależnego od modułu `experimental`. To "capability surface selection" sterowane manifestem.
- **Ostrzeżenie**: nie buduj instalatora-runtime jak ECC (`install-plan/apply.js`). Trzymaj manifest jako deklaratywne metadane czytane przez skille AppMakera.

### Pozostałe nowatorskie role agentów ECC (inwentarz, których AppMaker nie ma)
`harness-optimizer` (tuning konfiguracji harnessa, nie kodu), `loop-operator` (autonomiczne pętle z warunkami stopu/eskalacji), `silent-failure-hunter` (zero-tolerance dla połkniętych błędów/fałszywych fallbacków — świetny preset dla critic-slota), `type-design-analyzer`, `code-explorer`, `comment-analyzer`, `conversation-analyzer`, `pr-test-analyzer`, `code-simplifier` (analog AppMakerowego `simplify`), `code-architect` vs `architect` (rozdział "design systemu" od "design kodu"), oraz domenowe (`a11y-architect`, `network-*`, `homelab-architect`, `opensource-{forker,packager,sanitizer}`). Dla AppMakera najwartościowsze jako **presety critic-slota**: `silent-failure-hunter`, `type-design-analyzer`, `code-simplifier`, `pr-test-analyzer`.

---

## Główne ostrzeżenie nakładania (anti-overlap)
ECC jest **dużym, runtime'owym, multi-harness monolitem** z własnym control-plane (`ecc2/` w Ruście), CLI, demonami i instalatorem. AppMaker celowo jest odwrotnością: Claude-native slash-commands + konwencje `.appmaker/`, BEZ runtime. Adoptuj **wzorce governance/format** (rubryka, shim, rejestr-jako-prawda, provenance, promotion gate, werdykt handoffu), a NIE infrastrukturę (instalator, multi-harness, demony, GAN-runtime). Każdy adoptowany wzorzec musi zmieścić się w pętli `interview→prd→decompose→phase→tdd→qa→review→archive` jako bramka lub format artefaktu, nie jako nowy podsystem.
