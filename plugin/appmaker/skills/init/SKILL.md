---
description: Bootstrap or upgrade AppMaker setup in current project. Materializes plugin resources, creates appmaker/config.yaml + .appmaker-version, seeds constitution, and configures optional integrations. Upgrade preserves user-owned files.
disable-model-invocation: true
---

Bootstrap or upgrade AppMaker setup. **Self-contained:** materializes resources from plugin into project tree (no manual copy required). Idempotent — re-running safe; differentiates fresh init from upgrade.

The bulk materialization runs in `plugin/appmaker/scripts/init-materialize.sh`. This skill owns user confirmation, upgrade-path decisions, and optional integrations. Tooling details live in `appmaker/skills/init/tooling-integrations.md`.

## When to invoke

- Manual: user types `/appmaker:init` (with optional `--upgrade` flag to force resource refresh)
- AFK-safe: NO — requires user confirmations for integrations + project mode
- Required state: any directory (need write access)
- Required input: user confirmations (greenfield/brownfield, backlog provider, optional integrations)

## Process

### 1. Detect current state

Check filesystem (parallel reads OK):

- `appmaker/` exists? → check `.appmaker-version` and `config.yaml`
  - Both present → **UPGRADE mode**
  - Missing → **FRESH INIT mode** (or partial — fill gaps)
- Git repo present? Note (some commands need it).
- Existing code? `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` etc. → the materialize script auto-detects test/lint commands.
- Existing `CLAUDE.md` at project root? Note (may merge Forest's CLAUDE.md).

### 2. FRESH INIT mode (no existing appmaker/)

**2a. Confirm with user** via AskUserQuestion:

1. Greenfield or brownfield?
2. Backlog provider: local markdown (default) or GitHub issues?
3. Pair with Graphify? [y/N]
   - Warn: pass-3 sends docs/PDFs to LLM API once at build (~$X).
4. Connect GitHub CLI (`gh`) now? [Y/n, highly recommended but optional] — enables GitHub issues/backlog and GitHub-backed research.
5. Connect Ref Tools MCP now? [Y/n, highly recommended but optional] — enables Architecture Options Research against current docs/private indexed docs.
6. Connect gstack browser runtime? [Y/n, optional, highly recommended for UI QA/design review] — enables fast browser evidence for `/appmaker:qa` and `/appmaker:design-review`.
7. Install Forest's CLAUDE.md baseline? [y/N]
8. Configure pre-commit hook?
9. Multi-project inheritance? (`~/Projects/CLAUDE.md`)

**Note:** the session-start hook is **default-on** as of v0.2.11 (prints a 1-line AppMaker status when sessions begin in an `appmaker/`-enabled folder). It is a silent read-only filesystem check, never blocks the session. To disable: delete `appmaker/hooks/session-start.sh` after init or remove the hook entry from `.claude/settings.json`.

**2b. Install Forest's CLAUDE.md baseline (if user chose `yes` in 2a).**

This step MUST run BEFORE the materialize script (2c). Reason: Forest's install uses `curl ... > CLAUDE.md`, which would overwrite the AppMaker pointer if the script already appended it. By running Forest first, the materialize script then appends the AppMaker pointer to Forest's content (idempotently — detects `^## AppMaker` header).

- No existing `CLAUDE.md`: `curl -sL https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md > CLAUDE.md`
- Existing `CLAUDE.md`: ask user via AskUserQuestion — merge (recommended) / overwrite-with-backup / skip.

If user did NOT choose Forest in 2a, skip this step entirely; the materialize script in 2c handles `CLAUDE.md` creation OR pointer append on its own.

**2c. Run materialize script.**

> ⚠ **IMPORTANT:** instructions for Claude, NOT auto-executed. Claude MUST call this via the `Bash` tool **after** completing user confirmations in 2a and Forest install in 2b. Pre-execution side effects (mkdir/cp before user confirms) violate guardrails.

The script does it all in one shot (idempotent):

- reads plugin version via `jq -r '.version'` from `plugin.json` (single source of truth, v0.2.11)
- creates `appmaker/` tree
- copies templates, supporting skill files (`tdd/`, `review/`, `status/`), memory wiki seeds
- writes `appmaker/config.yaml` from template + auto-detects test/lint/typecheck commands
- writes `appmaker/.appmaker-version` marker
- installs `session-start.sh` + `glossary-extract.sh` hooks (per config flags)
- wires `.claude/settings.json` SessionStart hook (jq merge if file exists; warns + asks user if jq absent)
- seeds memory headers (`architecture.md`, `decisions.md`, `lessons.md`) and glossary stub
- seeds `appmaker/constitution.md` from `resources/appmaker/constitution.md.seed` (10 default rules; user-owned thereafter)
- appends AppMaker pointer block to project-root `CLAUDE.md` (idempotent — detects `^## AppMaker` header)

Invocation:

```bash
bash "${CLAUDE_SKILL_DIR}/../../scripts/init-materialize.sh"
```

If `.claude/settings.json` exists without `jq` available, the script prints a guidance block; this skill must follow up with AskUserQuestion (skip / overwrite-with-backup / install jq + re-run).

**2d. Configure remaining optional integrations** (run AFTER 2c — none of these touch `CLAUDE.md`):

- **Graphify:** `pip install graphifyy && graphify install && graphify claude install`. Build graph (~12 min). Set `graphify_enabled: true` in config.
  - Before install/build, create `.graphifyignore` from plugin template if missing: `cp "${CLAUDE_SKILL_DIR}/../../resources/graphify/.graphifyignore.template" .graphifyignore`
  - Build graph after explicit user consent: `graphify .`
  - Graphify outputs are read-only input for AppMaker. AppMaker writes only small context packets to `appmaker/context/`.
- **GitHub CLI:** follow `appmaker/skills/init/tooling-integrations.md`: check `gh`, run/guide `gh auth login` only after user consent, verify `gh auth status --hostname github.com`, then set `github_cli_enabled: true`; never store tokens in project files.
- **Ref Tools MCP:** follow `appmaker/skills/init/tooling-integrations.md`: configure user-level MCP for the active client (Codex: `~/.codex/config.toml`), verify availability, then set `ref_tools_enabled: true`; never store Ref API keys in the project.
- **gstack browser runtime:** follow `appmaker/skills/init/tooling-integrations.md`: verify `bun`, install/guide gstack only after consent, verify `$B status`, then set `gstack_enabled: true` and `gstack_browse_bin: <path>`. Do not run gstack `--team` by default.
- **Pre-commit hook:** write `.git/hooks/pre-commit` (or `.husky/pre-commit`) with detected `lint_command` + `typecheck_command` from `appmaker/config.yaml`.
- **Multi-project:** instruct user about parent `~/Projects/CLAUDE.md`.

### 3. UPGRADE mode (existing appmaker/ with version marker)

Detect drift between current `appmaker/.appmaker-version` and plugin resource version.

Claude reads both versions using the Bash tool:

```bash
cat appmaker/.appmaker-version 2>/dev/null || echo unknown
jq -r '.version' "${CLAUDE_SKILL_DIR}/../../.claude-plugin/plugin.json"
```

If different (and current isn't `unknown`), proceed with upgrade flow (write operations require explicit confirmation per "Upgrade rules" below). If `unknown` or missing, treat as fresh init instead.

**Upgrade rules:**

- **NEVER overwrite user-owned files:**
  - `appmaker/constitution.md` (user-edited)
  - `appmaker/glossary.md` (project state — stubs auto-flagged by hook, definitions explicit)
  - `appmaker/memory/**` (project state, wiki, raw notes)
  - `appmaker/context/*.md` (context snapshots)
  - `appmaker/backlog/**`, `appmaker/features/**` (project state)
  - `appmaker/config.yaml` (user config — only diff-suggest new fields, never overwrite)
- **REFRESH plugin-owned files:**
  - `appmaker/templates/*` — compare with plugin resources; if user has overrides, ask via AskUserQuestion before overwriting.
  - `appmaker/skills/tdd/*`, `appmaker/skills/output-style.md`, `appmaker/skills/tdd/plan-format.md` — pure reference (1:1 with plugin); safe to overwrite if user didn't customize (check `git diff` or filesize heuristic).
  - missing seed files under `appmaker/memory/index.md`, `schema.md`, `log.md`, `raw/`, `wiki/` — create only if absent, never overwrite.
  - missing report dirs: `checklists/`, `diagnostics/`, `afk/`, `phase-plans/`, `reviews/`.
  - **session-start hook** (v0.2.11+) — install if missing: copy from `${CLAUDE_SKILL_DIR}/../../hooks/session-start.sh` to `appmaker/hooks/session-start.sh`, `chmod +x`, and merge `SessionStart` entry into `.claude/settings.json` (create file if missing, otherwise warn user to merge manually).
  - `.graphifyignore` — if created from AppMaker template, ask before refresh; user may customize heavily.
- **Update version marker:** `echo "$PLUGIN_VERSION" > appmaker/.appmaker-version`.
- **Diff new config fields:** read user's `config.yaml`, compare keys with `config.yaml.template`; for new keys, append to user's config with defaults + comment `# added by upgrade ${PLUGIN_VERSION}`.

**Show user a summary before applying:**

```
Upgrade: <previous> → <current>
Will refresh (with confirmation if user edits):
  - appmaker/templates/backlog-item-template.md
  - appmaker/skills/tdd/deep-modules.md
Will add new config fields:
  - memory_wiki_enabled: true
  - checklist_report_dir: appmaker/checklists
  - afk_report_dir: appmaker/afk
  - phase_plan_dir: appmaker/phase-plans
Will NOT touch (user-owned):
  - appmaker/constitution.md
  - appmaker/glossary.md (12 terms)
  - appmaker/memory/* (3 files)
  - appmaker/backlog/* (4 items)
Proceed? [Y/n]
```

### 4. Output summary

**Fresh init:**

```
✓ AppMaker initialized at appmaker/
✓ Resources materialized from plugin v<current>
✓ Constitution: default rules seeded (edit appmaker/constitution.md as needed)
✓ Config: appmaker/config.yaml (commands auto-detected for detected project type)
✓ Version marker: appmaker/.appmaker-version
✓ Memory: architecture, decisions, lessons + wiki seed
✓ Context packets: appmaker/context/ (created empty)
✓ Gates/reports: appmaker/checklists/, appmaker/diagnostics/, appmaker/afk/, appmaker/phase-plans/, appmaker/reviews/
✓ Backlog: local markdown
✓ Templates + supporting files (tdd/, review/, status/)
✓ Graphify: (installed or skipped per choice)
✓ GitHub CLI: (connected or skipped)
✓ Ref Tools MCP: (connected or skipped)
✓ gstack browser runtime: (connected or skipped)
✓ Forest's CLAUDE.md: (installed or skipped)

Next: /appmaker:start "<your first intent>"
```

**Upgrade:**

```
✓ AppMaker upgraded: <previous> → <current>
✓ Resources refreshed: template files, memory wiki seed files, supporting files
✓ Config fields added: memory wiki, checklist/diagnostics/review dirs, AFK controls
✓ User-owned files preserved: constitution.md, glossary.md (12 terms), memory/, backlog/ (4 items), features/

Next: continue your workflow or check changelog if curious about new features.
```

## Guardrails

- **Idempotent.** Re-running on existing setup must not overwrite user-owned files (constitution, glossary, memory, backlog, features, config).
- **Materialize from plugin.** Don't ask user to manually copy files. Resources packed in plugin, copied by the materialize script.
- **Detect fresh vs upgrade.** `appmaker/.appmaker-version` marker is the signal.
- **Confirm before destructive.** If `appmaker/` exists with custom content, ask before any modification.
- **No silent defaults.** User sees every choice and confirms.
- **Don't auto-pair Graphify.** Privacy implications require explicit user opt-in with cost note.
- **Don't auto-login external tools.** GitHub CLI, Ref Tools MCP, and gstack browser runtime require explicit opt-in; store only capability flags/paths in config, never tokens/API keys.
- **Don't treat Graphify as memory.** It is read-only code graph input. Persist only context packets derived from it.
- **Don't run other skills mid-init.** Init only sets up scaffold. User invokes `/appmaker:start` after.
- **Forest BEFORE materialize.** If installing Forest's `CLAUDE.md` baseline (`curl > CLAUDE.md`), it must run in step 2b — before the materialize script's pointer append in 2c — otherwise the AppMaker pointer is clobbered.
- **Keep seed bounded.** Default constitution seed has 10 rules in `resources/appmaker/constitution.md.seed`; do not expand casually or inline alternate seeds here.
- **Upgrade preserves user-owned state.** constitution.md, glossary.md, memory/, backlog/, features/ — never overwrite.
- **Upgrade refreshes plugin-owned files** (templates, supporting reference) — confirm if user customized.
- **Version marker mandatory.** Without `.appmaker-version`, future upgrades can't detect drift.
