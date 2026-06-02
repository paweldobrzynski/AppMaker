# ECC — Analiza mechanizmów technicznych (dla adopcji w AppMakerze)

Zakres: hooks/, scripts/, src/, ecc2/ (runtime Rust), install.sh/ps1, ecc_dashboard.py, mcp-configs/manifests/config, oraz machineria instinct / continuous-learning / memory-persistence / observability / security scanning (AgentShield/InsAIts).
NIE obejmuje skilli (robi inny agent) — tu analizuję wyłącznie automatyzacje/runtime/plumbing.

Root projektu: `/Users/pawel/Projects/ECC`

---

## 1. Hooki — architektura zdarzeniowa

### 1.1 Graf hooków
- Produkcyjny graf: `hooks/hooks.json` (49 KB) — definicje wszystkich hooków zmapowanych na eventy.
- Kontrakt lifecycle (czytelny, audytowalny): `hooks/memory-persistence/hooks.json` + `hooks/memory-persistence/README.md`. To stabilny "interface" dla SessionStart / PreCompact / observe / activity / SessionEnd, oddzielony od wykonywalnego grafu.
- Implementacje skryptów: `scripts/hooks/` (49 plików).

Eventy używane (z `hooks/README.md` i memory-persistence):
- **PreToolUse** — blokowanie (exit 2) lub ostrzeżenia (stderr, exit 0).
- **PostToolUse** — analiza wyniku, nie blokuje.
- **Stop** — po każdej odpowiedzi Claude (cost-tracker, pattern-extraction, desktop-notify, console-log audit).
- **SessionStart / SessionEnd** — granice sesji.
- **PreCompact** — zapis stanu przed kompakcją kontekstu.

### 1.2 Profile i sterowanie runtime (KLUCZOWY wzorzec)
`hooks/README.md` + `scripts/hooks/run-with-flags.js:1-8` + `scripts/lib/hook-flags.js` (`isHookEnabled`):
- `ECC_HOOK_PROFILE=minimal|standard|strict` — profil hooków.
- `ECC_DISABLED_HOOKS="pre:bash:tmux-reminder,post:edit:typecheck"` — wyłączanie po ID.
- `ECC_GATEGUARD=off`, `ECC_SESSION_START_CONTEXT=off`, `ECC_SESSION_START_MAX_CHARS=4000`, `ECC_CONTEXT_MONITOR_COST_WARNINGS=off`.
- Każdy hook odpalany przez `run-with-flags.js <hookId> <script> [profilesCsv]` — gate'owanie przez env BEZ edycji hooks.json. To czyste sterowanie deklaratywne.

### 1.3 Wzorzec "dispatcher" (jeden matcher → wiele hooków)
`scripts/hooks/pre-bash-dispatcher.js`, `post-bash-dispatcher.js`, `bash-hook-dispatcher.js` — pojedynczy hook na `Bash` rozdziela do wielu pod-checków (dev-server-block, tmux-reminder, git-push-reminder, commit-quality). Minimalizuje liczbę procesów per tool-call.

### 1.4 Konwencja I/O hooków
Wszystkie hooki: czytają JSON ze stdin, **muszą wypisać stdin z powrotem na stdout** (pass-through), warn = stderr+exit 0, block = exit 2. Cross-platform przez Node.js (Windows/macOS/Linux). Przykład dyscypliny: `cost-tracker.js` kończy `process.stdout.write(raw)` nawet po błędzie ("never fail the Stop hook").

---

## 2. Memory persistence + continuous-learning (instincts)

### 2.1 Lifecycle pamięci (hooki)
`hooks/memory-persistence/README.md`:
- `SessionStart` → `scripts/hooks/session-start.js` (24 KB) — ładuje *ograniczony* kontekst poprzedniej sesji.
- `PreCompact` → `pre-compact.js` — zapis stanu przed kompakcją.
- `PreToolUse`/`PostToolUse` → `observe-runner.js` — rejestracja obserwacji tool-use.
- `PostToolUse` → `session-activity-tracker.js` — metryki per-sesja dla ECC2.
- `SessionEnd` → `session-end.js` — podsumowanie sesji.

### 2.2 SessionStart — wstrzykiwanie pamięci do kontekstu
`scripts/hooks/session-start.js:28-34`:
```
INSTINCT_CONFIDENCE_THRESHOLD = 0.7
MAX_INJECTED_INSTINCTS = 6
MAX_INJECTED_LEARNED_SKILLS = 6
DEFAULT_SESSION_START_CONTEXT_MAX_CHARS = 8000
DEFAULT_SESSION_RETENTION_DAYS = 30
```
Mechanizm: na starcie sesji wstrzykuje przez stdout (1) podsumowanie ostatniej sesji, (2) instinkty o confidence ≥ 0.7 (max 6), (3) wyuczone skille (max 6), z twardym budżetem znaków (`ECC_SESSION_START_MAX_CHARS`) i trybami `startup|resume|clear|compact` (`session-start.js:108-120`). Pamięć jest **lokalna**, opt-out przez env.

### 2.3 Observer continuous-learning (mechanizm, NIE skill)
`scripts/hooks/observe-runner.js` (cienki most Node→bash) deleguje do `skills/continuous-learning-v2/hooks/observe.sh`:
- `observe.sh` parsuje stdin (Python), **scrubuje sekrety regexem** przed zapisem (`_SECRET_RE`, observe.sh ~linia z "api_key|token|secret|password|authorization"), zapisuje do `${PROJECT_DIR}/observations.jsonl`.
- **Project-scoped**: wykrywa git-root z `cwd` i przypisuje obserwacje do projektu (`observe.sh` — `CLAUDE_PROJECT_DIR`).
- **Auto-purge** plików obserwacji > 30 dni, **archiwizacja** przy > 10 MB (atomic rename).
- **5-warstwowy guard przeciw self-loop**: entrypoint (cli/sdk-ts/desktop), `ECC_HOOK_PROFILE=minimal`, `ECC_SKIP_OBSERVE=1`, `agent_id` (subagenty pomijane), wykluczenia ścieżek (`observer-sessions,.claude-mem`). To zapobiega obserwowaniu własnych sesji obserwatora (Haiku).
- **Lazy-start observera w tle** (`start-observer.sh`) z lockiem (flock/lockfile/mkdir fallback) i throttlingiem sygnału SIGUSR1 co N=20 obserwacji (`ECC_OBSERVER_SIGNAL_EVERY_N`).

### 2.4 Instinct CLI (zarządzanie pamięcią długoterminową)
`skills/continuous-learning-v2/scripts/instinct-cli.py` — komendy: `status|import|export|evolve|promote|projects|prune`.
- Storage: `~/.local/share/ecc-homunculus/` (XDG-aware, override `CLV2_HOMUNCULUS_DIR`), struktura: `projects/`, `projects.json`, `instincts/{personal,inherited}/`, `evolved/`, `observations.jsonl`.
- Project-scope przez hash ścieżki repo (`_project_hash` = sha256[:12]), normalizacja remote URL ze ściąganiem credentiali (`_strip_remote_credentials`).
- `evolve` = klastrowanie instynktów w skille/komendy/agentów; `promote` = project → global; `prune` = TTL 30 dni dla pending.
- Komendy-frontend: `commands/instinct-{status,export,import}.md`, `commands/{evolve,promote,learn,learn-eval}.md`.

### 2.5 Pattern extraction (Stop hook)
`scripts/hooks/evaluate-session.js` — na Stop liczy wiadomości user w transcripcie (`min_session_length`=10), i jeśli sesja długa, **sygnalizuje** Claude'owi by ocenił sesję pod kątem wyciągalnych wzorców (zapis do `learned_skills_path`). Czytane z `skills/continuous-learning/config.json`. Lekkie — sam hook nie analizuje, tylko wyzwala ocenę.

---

## 3. ecc2/ — runtime w Rust (control-plane, ALPHA)

`ecc2/README.md`: warstwa NAD pojedynczą instalacją harnessa — zarządza wieloma sesjami agentów z jednej powierzchni. Binarka `ecc-tui` (Cargo, `clap` CLI + `ratatui` TUI). Wprost zaznaczone "alpha, nie GA".

Co istnieje (z kodu):

### 3.1 Session daemon — `ecc2/src/session/daemon.rs`
Pętla `run()` (linie 20-56) co `heartbeat_interval_secs`:
- `resume_crashed_sessions` (58) — wykrywa martwe PIDy (`pid_is_alive`, 476) i wznawia.
- `check_sessions` (95) — `enforce_session_heartbeats`.
- `maybe_run_due_schedules` (100) — cron-like scheduling (`cron` crate w Cargo.toml).
- `maybe_run_remote_dispatch` (108) — zdalne żądania dispatch.
- `coordinate_backlog_cycle` (145) — auto-dispatch backlogu + rebalans zespołów + recovery; logika anty-saturacji (`prefers_rebalance_first`, `dispatch_cooloff_active`).
- `maybe_auto_merge_ready_worktrees` (368) / `maybe_auto_prune_inactive_worktrees` (431) — automatyczny merge/prune worktree.
Wszystko gated configiem (`auto_dispatch_unread_handoffs`, `auto_merge_ready_worktrees`).

### 3.2 Session store — SQLite
`ecc2/src/session/store.rs` (`rusqlite` bundled). Trzyma stan sesji, metryki daemon-passów (`record_daemon_dispatch_pass`, `record_daemon_rebalance_pass`, `record_daemon_auto_merge_pass`), tabelę `governance_events`. To trwała, lokalna baza stanu.

### 3.3 Worktree management — `ecc2/src/worktree/mod.rs` (~1500 linii, git2)
Bogaty zestaw operacji git per-sesja:
- `create_for_session` (96) — worktree na sesję; `sync_shared_dependency_dirs` (151) — symlinkuje współdzielone `node_modules` itp. z fingerprintem zależności (`dependency_fingerprint`, 1344).
- Stage/unstage/reset **per hunk** (`stage_hunk`, `git_status_patch_view`).
- `merge_readiness` (722), `branch_conflict_preview` (811), `health` (835) → `Clear|InProgress|Conflicted`.
- `merge_into_base` (858), `rebase_onto_base` (913).
- `create_draft_pr_with_gh` (533) — PR przez `gh`, `github_compare_url` (519).

### 3.4 Observability / risk-scoring — `ecc2/src/observability/mod.rs`
`ToolCallEvent::compute_risk` (60) — **deterministyczny scoring ryzyka** (0.0-1.0) sumujący: base tool risk (121), file sensitivity (133), blast radius (171), irreversibility (207). `SuggestedAction::from_score` (108) mapuje na `Block|Confirm|Review|Allow` względem `Config::RISK_THRESHOLDS`. `log_tool_call` (295) zapisuje do store. To engine governance/ryzyka.

### 3.5 Notifications — `ecc2/src/notifications.rs`
Desktop notify cross-platform (`notify-send` na Linux, osascript na macOS — `sanitize_osascript` 427) + webhooki (`send_webhook_request` 405). Event-driven (`NotificationEvent`).

### 3.6 Comms (agent-to-agent) — `ecc2/src/comms/mod.rs`
`MessageType`, `TaskPriority`, `send`/`parse`/`preview`/`handoff_priority` — protokół handoffów między sesjami zapisywany w store.

### 3.7 TUI dashboard — `ecc2/src/tui/dashboard.rs`
Ratatui dashboard wielosesyjny (widoki sesji, output, risk).

---

## 4. ecc_dashboard.py — GUI (Tkinter)

`ecc_dashboard.py` (40 KB) — desktopowy GUI w Tkinter. NIE jest to dashboard observability — to **przeglądarka/manager komponentów ECC**: zakładki Agents/Skills/Commands/Rules/Settings. Skanuje katalogi (`load_agents` 29, `load_skills` 93, `load_commands` 173, `load_rules` 222), parsuje YAML frontmatter, pozwala filtrować i otwierać terminal (`scripts/lib/ecc_dashboard_runtime.launch_terminal`). Katalog = source of truth (komentarz: "AGENTS.md drifts out of sync"). To narzędzie eksploracyjne, nie runtime.

---

## 5. Observability / cost tracking (po stronie hooków — bez Rust)

Lekki, plikowy pipeline metryk (działa bez ecc2):
- `scripts/hooks/cost-tracker.js` (Stop) — sumuje usage z transcript JSONL, liczy koszt wg `RATE_TABLE` (haiku/sonnet/opus, z cache write/read), preferuje autorytatywny `cost.total_cost_usd` z cache statusline (`harness-cost-<session_id>.json`, świeże ≤300 s), fallback = suma z transcriptu. Zapis: `~/.claude/metrics/costs.jsonl`. Komentarz dokumentuje bug-fix (2340 wierszy zerowych — payload Stop nie ma `usage`, trzeba czytać transcript).
- `scripts/hooks/ecc-metrics-bridge.js` (PostToolUse) — agregat sesji w `/tmp/ecc-metrics-{session}.json` (pliki dotknięte, recent tools, hash inputów) — żeby nie skanować JSONL przy każdym wywołaniu.
- `scripts/hooks/ecc-context-monitor.js` (PostToolUse) — czyta bridge, wstrzykuje ostrzeżenia: context exhaustion (35%/25%), koszt ($5/$10/$50), scope creep (>20 plików), tool-loop (≥3 powtórzeń), debounce co 5 wywołań.
- `scripts/hooks/ecc-statusline.js` — statusline czytający bridge.

---

## 6. Security scanning

Dwa niezależne mechanizmy, OBA jako external pakiety wywoływane lokalnie (wzór "no own runtime"):

### 6.1 InsAIts (PreToolUse monitor)
`scripts/hooks/insaits-security-wrapper.js` (most Node→Python) → `scripts/hooks/insaits-security-monitor.py`:
- Wymaga `pip install insa-its`, włączane przez `ECC_ENABLE_INSAITS=1` (domyślnie OFF → pass-through).
- Detekcja lokalna (100% local): credential exposure, prompt injection, hallucination chains, behavioral anomalies, ~20 typów. Exit 0 = clean, **exit 2 = block**, stderr = warn. Fail-open na błędach (timeout/ENOENT/signal → przepuszcza).
- Audyt do `.insaits_audit_session.jsonl`. Konfiguracja: `INSAITS_FAIL_MODE=open|closed`, `INSAITS_MODEL`.

### 6.2 AgentShield (skan setupu agenta)
External npm scanner, NIE binarka w repo. Wywoływany przez slash-command `/security-scan` (`.opencode/commands/security-scan.md:24-34`):
```
npx ecc-agentshield scan --path "${TARGET_PATH:-.}" --format text
```
Skanuje: hooki, MCP config, permissions, sekrety, prompt-injection w plikach agentowych. `--fix` aplikuje tylko safe/auto-fixable. Zasada: "Do not invent findings. Use AgentShield output as source of truth". Repo: github.com/affaan-m/agentshield. To wzór **deterministyczny engine + LLM-judgment overlay** odpalany przez komendę.

### 6.3 GateGuard (fact-forcing) — `scripts/hooks/gateguard-fact-force.js` (27 KB)
PreToolUse gate który NIE pyta "are you sure?", tylko **wymusza fakty** przed edycją/destrukcyjnym Bashem: lista importerów, dotknięte API, schematy danych, rollback plan, cytowanie aktualnej instrukcji. Stan per-sesja w `~/.gateguard/` (TTL 30 min). Pełna wersja: `pip install gateguard-ai`. Gated `ECC_GATEGUARD=off`.

### 6.4 Governance capture — `scripts/hooks/governance-capture.js`
Pre/PostToolUse, włączane `ECC_GOVERNANCE_CAPTURE=1`. Wykrywa secret_detected (AWS/JWT/GitHub token/private key — `SECRET_PATTERNS`), policy_violation, security_finding, approval_requested i zapisuje do tabeli `governance_events` w state store (ten sam store co ecc2). To pomost hooki→audyt.

---

## 7. Selektywna instalacja (manifest-driven)

Model w pełni deklaratywny, 3 manifesty (`manifests/`):
- `install-modules.json` — atomowe moduły (`rules-core`, `agents-core`, `commands-core`, `hooks-runtime`, `platform-configs`, ...) z polami `targets[]` (claude, cursor, codex, zed, qwen...), `dependencies[]`, `defaultInstall`, `cost` (light/...), `stability` (stable/...), `paths[]`.
- `install-components.json` — user-facing komponenty grupujące moduły (np. `baseline:hooks` → `[hooks-runtime]`).
- `install-profiles.json` — profile: `minimal` (bez hooków), `core`, `developer`, `security`, ... = listy modułów.

Runtime instalatora:
- `install.sh` / `install.ps1` — cienkie wrappery: resolują root przez symlinki, auto `npm install`, delegują do `scripts/install-apply.js`.
- `scripts/install-plan.js` — **dry-run/inspekcja** planu (`--list-profiles`, `--list-modules`, `--profile X --with/--without`, `--json`) bez mutacji.
- `scripts/install-apply.js` — aplikacja: `--target`, `--profile`, `--modules`, `--with/--without <component>`, `--skills <ids>`, `--locale`, `--dry-run`, `--json`. Multi-target (claude/claude-project/cursor/codex/...).
- `config/project-stack-mappings.json`, `mcp-configs/mcp-servers.json` — katalog MCP i mapowania stacku.

Wzór: **plan / apply split** + deklaratywne manifesty z metadanymi kosztu/stabilności + per-target.

---

# WZORCE DO ADOPCJI (po AppMakerowemu)

Legenda realizacji: SC=slash-command, H=hook, S=skrypt (Bash przez Claude). AppMaker = plugin (slash+skille) + `.appmaker/`, BEZ standalone runtime/CLI; ma już: hooki (glossary-extract, session-start), scripts, studio GUI (server.mjs node), memory/wiki, parowanie z Graphify.

### A. Profile + runtime-gating hooków przez env  ⭐⭐⭐
**Wartość:** włączanie/wyłączanie hooków bez edycji configu — kluczowe dla governance overlay (różne rygory per projekt/faza).
**Jak:** odtworzyć `run-with-flags.js` + `hook-flags.js` jako wrapper `.appmaker/scripts/run-with-flags.js`, sterowany `APPMAKER_HOOK_PROFILE=minimal|standard|strict` i `APPMAKER_DISABLED_HOOKS`. Każdy hook w settings.json wołany przez wrapper. Czyste, deklaratywne, zero binarki.
**Ostrzeżenie:** AppMaker ma już session-start/glossary-extract hooki — wprowadzić gating *wstecznie kompatybilnie* (brak env = wszystko on), żeby nie złamać istniejących.

### B. Deterministyczny risk-scoring tool-calli → governance gate  ⭐⭐⭐
**Wartość:** rdzeń "governance overlay". ECC ma to w Rust (`observability/mod.rs`), ale logika jest czysto regułowa (base risk + file sensitivity + blast radius + irreversibility → Block/Confirm/Review/Allow).
**Jak:** przepisać `compute_risk` jako PreToolUse **H** w Node (`.appmaker/hooks/risk-gate.js`): czyta JSON stdin, scoruje, exit 2 = block / stderr = warn. Progi w `.appmaker/governance.json`. To provider-agnostic i bez runtime.
**Ostrzeżenie:** nie duplikować z GateGuard/AgentShield jeśli AppMaker je adoptuje — risk-gate to lekki, wbudowany default; AgentShield to głęboki external skan. Rozdzielić role.

### C. Continuous-learning observer (project-scoped, secret-scrubbed)  ⭐⭐⭐
**Wartość:** pamięć/instynkty wyciągane z realnych sesji — silnie synergiczne z memory/wiki AppMakera i z Graphify (obserwacje → graf wiedzy).
**Jak:** Pre/PostToolUse **H** (`observe.js`) zapisujący do `.appmaker/memory/observations.jsonl` (project-scoped przez git-root), z regex-scrubem sekretów. "Evolve/promote" jako **SC** (`/appmaker-instinct-evolve`) wołający **S** w Pythonie (wzór `instinct-cli.py`). SessionStart **H** wstrzykuje top-N instynktów ≥ próg confidence z budżetem znaków.
**Ostrzeżenie KRYTYCZNE:** ECC ma 5-warstwowy guard przeciw self-loopowi (subagenty/observer-sessions pomijane) — AppMaker MUSI to skopiować, inaczej obserwator będzie obserwował własne sesje analizy. Druga kolizja: AppMaker pairuje z Graphify — uważać by nie budować *drugiego* magazynu wiedzy równolegle do grafu; observations.jsonl powinien być *źródłem* dla Graphify, nie konkurencją.
**Bez runtime:** ECC ma lazy-start observera w tle (daemon-like) — w AppMakerze NIE odtwarzać background-daemona; zamiast tego "evolve" jako jawna komenda on-demand (batch), nie ciągły proces.

### D. Plikowy cost/context tracker + bridge  ⭐⭐⭐
**Wartość:** observability bez serwera; ostrzeżenia o koszcie/kontekście/scope-creep/tool-loop wprost w sesji.
**Jak:** Stop **H** `cost-tracker.js` (suma usage z transcriptu → `.appmaker/metrics/costs.jsonl`) + PostToolUse **H** bridge (`/tmp/appmaker-metrics-{session}.json`) + context-monitor **H** wstrzykujący progi. Studio GUI (server.mjs) może to renderować zamiast Tkinter/TUI.
**Ostrzeżenie:** uważać na bug który ECC udokumentował — payload Stop NIE ma `usage`, trzeba czytać `transcript_path`. Rate-table się starzeje (Opus >200K tier) — preferować autorytatywny `cost.total_cost_usd` ze statusline jak ECC. Nie odpalać przy każdym message (UserPromptSubmit) — tylko Stop, dla wydajności.

### E. AgentShield-style: deterministyczny external skan + LLM overlay  ⭐⭐
**Wartość:** wzorcowy dla AppMakera — engine jako `npx`/skrypt, komenda jako interpretacja. ECC robi to dokładnie "po AppMakerowemu" (`/security-scan` → `npx ecc-agentshield`).
**Jak:** **SC** `/appmaker-security-scan` wołający external scanner (lub własny `.appmaker/scripts/scan.js`) przez Bash, z `--format json` dla CI i `--fix` tylko safe. Zasada "scanner = source of truth, LLM = remediation plan".
**Ostrzeżenie:** to czysty wzór architektury (oddziel fakty od osądu) — nie musi to być akurat AgentShield. AppMaker powinien skanować swoje własne powierzchnie: `.appmaker/`, hooki, MCP config, sekrety w plikach skilli.

### F. Selektywna instalacja: manifest + plan/apply split  ⭐⭐⭐
**Wartość:** AppMaker jako plugin może chcieć instalować podzbiory (profile minimal/governance/full) per-target i per-projekt. Manifesty z metadanymi (cost/stability/dependencies) to dojrzały wzór.
**Jak:** `.appmaker/manifests/{modules,components,profiles}.json` + **S** `plan.js` (dry-run, `--json`) i `apply.js`. Wołane przez **SC** `/appmaker-install --profile governance`. To zwykłe pliki + node — bez binarki.
**Ostrzeżenie:** AppMaker jest świadomie "no own CLI" — instalator powinien być *opcjonalnym* skryptem wywoływanym przez Claude/Bash, nie głównym entrypointem produktu (inaczej AppMaker dryfuje w stronę CLI jak ECC). Plan/apply split jest tu ważniejszy niż sam instalator: "pokaż co zrobię" przed mutacją to dobry governance default.

### G. Dispatcher pattern dla hooków  ⭐⭐
**Wartość:** jeden hook per matcher (Bash/Edit) rozdziela do wielu checków — mniej procesów, łatwiejsze profile.
**Jak:** `.appmaker/hooks/bash-dispatcher.js` agregujący sub-checki; profile decydują które aktywne.
**Ostrzeżenie:** lekki wzór, niska kolizja; warto wdrożyć razem z A (gating).

### H. SessionStart memory injection z budżetem znaków  ⭐⭐⭐
**Wartość:** AppMaker MA już session-start hook i memory/wiki — ECC pokazuje *dyscyplinę*: top-N instynktów ≥0.7 confidence + ostatnie podsumowanie, twardy limit znaków, tryby startup/resume/clear/compact, opt-out env.
**Jak:** rozszerzyć istniejący session-start AppMakera o injekcję z `.appmaker/memory/` z `APPMAKER_SESSION_START_MAX_CHARS` i progiem confidence.
**Ostrzeżenie:** to bezpośrednio nakłada się na istniejący hook AppMakera — to rozszerzenie, nie nowy mechanizm. Pilnować budżetu kontekstu (memory z notatki użytkownika: długie sesje wybuchają "Prompt is too long").

### NIE adoptować wprost (wymaga runtime/daemona — sprzeczne z modelem AppMakera):
- **Session daemon (ecc2/daemon.rs)** — ciągła pętla heartbeat/auto-dispatch/auto-merge wymaga procesu w tle. W AppMakerze odtworzyć *fragmentarycznie i on-demand*: "resume crashed session", "merge ready worktrees", "prune worktrees" jako pojedyncze **SC** wywoływane przez użytkownika/CI, nie jako daemon. Cron można delegować do systemowego crona/CI, nie do własnego binarnego schedulera.
- **Worktree management (ecc2/worktree)** — wartościowy, ale 1500 linii git2. W AppMakerze: **SC** `/appmaker-worktree {create,status,merge-check,merge,prune}` jako cienkie wrappery na `git worktree` + `gh` przez Bash. NIE odtwarzać per-hunk staging w Rust — to przerost; Claude i tak operuje przez git CLI. Synergia: pairing z Graphify może mapować worktree→branch→zadania.
- **SQLite state store** — w AppMakerze trzymać stan jako JSON/JSONL w `.appmaker/` (jak ECC robi dla observations/costs), nie wprowadzać bazy wymagającej runtime. `governance_events` → `.appmaker/governance/events.jsonl`.
- **TUI dashboard (ratatui)** — AppMaker ma już studio GUI (server.mjs); to pokrywa potrzebę wizualizacji bez nowej binarki.
