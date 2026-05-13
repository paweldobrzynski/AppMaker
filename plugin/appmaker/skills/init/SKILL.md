---
description: Bootstrap or upgrade AppMaker setup in current project. Materializes plugin resources (templates, supporting files) into appmaker/ project tree, creates appmaker/config.yaml + .appmaker-version, seeds 7-rule constitution. Detects fresh-init vs upgrade; upgrade preserves user-owned files. Optional integrations (Graphify, Forest's CLAUDE.md, hooks). Use when starting new project, migrating existing project, or upgrading plugin resources.
disable-model-invocation: true
---

Bootstrap or upgrade AppMaker setup. **Self-contained:** materializes resources from plugin into project tree (no manual copy required). Idempotent — re-running safe; differentiates fresh init from upgrade.

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
- Existing code? `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` etc. → infer project type + test/lint commands.
- Existing `CLAUDE.md` at project root? Note (may merge Forest's CLAUDE.md).

### 2. FRESH INIT mode (no existing appmaker/)

**2a. Confirm with user** via AskUserQuestion:
1. Greenfield or brownfield?
2. Backlog provider: local markdown (default) or GitHub issues?
3. Pair with Graphify? [y/N]
   - Warn: pass-3 sends docs/PDFs to LLM API once at build (~$X).
4. Install Forest's CLAUDE.md baseline? [y/N]
5. Configure pre-commit hook?
6. Multi-project inheritance? (`~/Projects/CLAUDE.md`)

**Note:** session-start hook is **default-on** as of v0.2.11 (prints 1-line AppMaker status when sessions begin in an `appmaker/`-enabled folder). It is a silent read-only filesystem check, never blocks the session. To disable, delete `appmaker/hooks/session-start.sh` after init or remove the hook entry from `.claude/settings.json`.

**2b. Materialize project tree from plugin resources**

> ⚠ **IMPORTANT:** the block below is **instructions for Claude, NOT auto-executed**. Claude MUST call this via the `Bash` tool **after** completing user confirmations in step 2a. Pre-execution side effects (mkdir/cp/echo before user confirms) violate guardrails.

Run via Bash tool after step 2a confirms:

```bash
# Source path uses ${CLAUDE_SKILL_DIR} (skill dir = .../plugin/appmaker/skills/init/)
RESOURCES_DIR="${CLAUDE_SKILL_DIR}/../../resources/appmaker"
GRAPHIFY_RESOURCES_DIR="${CLAUDE_SKILL_DIR}/../../resources/graphify"
PLUGIN_MANIFEST="${CLAUDE_SKILL_DIR}/../../.claude-plugin/plugin.json"

# Version single source of truth (v0.2.11): read from plugin.json at runtime.
# Previously hardcoded here AND in config.yaml.template AND in marketplace.json.
# Now: plugin.json is canonical; init substitutes ${VERSION} placeholder where needed.
if command -v jq >/dev/null 2>&1; then
  PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_MANIFEST")
else
  PLUGIN_VERSION=$(grep -m1 '"version"' "$PLUGIN_MANIFEST" | sed -E 's/.*"version"[^"]*"([^"]+)".*/\1/')
fi
[ -z "$PLUGIN_VERSION" ] && { echo "❌ Failed to read version from $PLUGIN_MANIFEST" >&2; exit 1; }
echo "ⓘ Plugin version: $PLUGIN_VERSION (source: plugin.json)"

mkdir -p appmaker/{templates,skills,memory/raw,memory/wiki,context,backlog/done,features/archive,reviews,checklists,diagnostics,afk}

# Copy templates (per-project overrides allowed; user edits freely)
cp -n "$RESOURCES_DIR/templates/"*.md appmaker/templates/ 2>/dev/null

# Copy supporting reference files (e.g., Matt Pocock tdd/)
cp -rn "$RESOURCES_DIR/skills/"* appmaker/skills/ 2>/dev/null

# Copy memory wiki seed files (never overwrite user memory)
cp -rn "$RESOURCES_DIR/memory/"* appmaker/memory/ 2>/dev/null

# Copy config template (only if not exists — never overwrite user config)
if [ ! -f appmaker/config.yaml ]; then
  # Substitute ${VERSION} placeholder from template (v0.2.11 SoT)
  sed "s/\${VERSION}/$PLUGIN_VERSION/g" "$RESOURCES_DIR/config.yaml.template" > appmaker/config.yaml
fi

# Write version marker (read from plugin.json, not hardcoded)
echo "$PLUGIN_VERSION" > appmaker/.appmaker-version

# Install hook scripts (v0.2.11) — respects config flags:
#   - session_hook_enabled: true  → install session-start.sh + wire .claude/settings.json
#   - glossary_hook_enabled: true → install glossary-extract.sh (used by parent skills as post-step)
# Read flags from config (default true for fresh init; upgrade preserves user choice)
HOOKS_DIR="${CLAUDE_SKILL_DIR}/../../hooks"
mkdir -p appmaker/hooks

# Helper: read a yaml boolean flag, defaulting to true
read_flag() {
  local key="$1"
  local val
  val=$(grep -E "^${key}:" appmaker/config.yaml 2>/dev/null | awk '{print $2}' | head -1)
  [ -z "$val" ] && val="true"
  echo "$val"
}

SESSION_HOOK_ENABLED=$(read_flag session_hook_enabled)
GLOSSARY_HOOK_ENABLED=$(read_flag glossary_hook_enabled)

if [ "$SESSION_HOOK_ENABLED" = "true" ]; then
  cp "$HOOKS_DIR/session-start.sh" appmaker/hooks/session-start.sh
  chmod +x appmaker/hooks/session-start.sh
  echo "✓ session-start hook installed"
else
  echo "ⓘ session_hook_enabled=false in config → skipping session-start.sh install"
fi

if [ "$GLOSSARY_HOOK_ENABLED" = "true" ]; then
  cp "$HOOKS_DIR/glossary-extract.sh" appmaker/hooks/glossary-extract.sh
  chmod +x appmaker/hooks/glossary-extract.sh
  echo "✓ glossary-extract hook installed"
else
  echo "ⓘ glossary_hook_enabled=false in config → skipping glossary-extract.sh install"
fi

# Wire .claude/settings.json — guarded by session_hook_enabled (v0.2.11)
# Three paths: no settings.json yet → write fresh. settings.json exists + jq available → merge.
# settings.json exists, no jq → AskUserQuestion (merge-manual / skip / overwrite-with-backup).
if [ "$SESSION_HOOK_ENABLED" = "true" ]; then
  mkdir -p .claude
  HOOK_ENTRY='{"type":"command","command":"bash appmaker/hooks/session-start.sh"}'

  if [ ! -f .claude/settings.json ]; then
    # Fresh write
    cat > .claude/settings.json <<'SETTINGS_EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash appmaker/hooks/session-start.sh" }
        ]
      }
    ]
  }
}
SETTINGS_EOF
    echo "✓ .claude/settings.json created with SessionStart hook"
  elif command -v jq >/dev/null 2>&1; then
    # Merge: preserve existing settings, add/update SessionStart entry idempotently.
    # Check if our hook command already present — skip duplicate.
    ALREADY=$(jq --arg cmd "bash appmaker/hooks/session-start.sh" \
      '.hooks.SessionStart // [] | map(.hooks[]?.command) | flatten | index($cmd)' \
      .claude/settings.json 2>/dev/null)
    if [ "$ALREADY" != "null" ] && [ -n "$ALREADY" ]; then
      echo "ⓘ .claude/settings.json: AppMaker SessionStart hook already wired — skipping"
    else
      cp .claude/settings.json .claude/settings.json.bak
      jq '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"matcher":"","hooks":[{"type":"command","command":"bash appmaker/hooks/session-start.sh"}]}])' \
        .claude/settings.json.bak > .claude/settings.json
      echo "✓ .claude/settings.json: SessionStart hook merged (backup at .bak)"
    fi
  else
    # jq missing — ask user via AskUserQuestion (Claude prompts) what to do
    echo "⚠ .claude/settings.json exists, but jq not installed — cannot auto-merge."
    echo "  Options for Claude to ask user:"
    echo "    1. Skip (user merges manually later) — recommended"
    echo "    2. Overwrite settings.json (backup created at .bak) — DANGEROUS if file has other settings"
    echo "    3. Install jq (\`brew install jq\` on macOS) and re-run /appmaker:init"
    echo ""
    echo "  Manual merge target (add to .hooks.SessionStart array):"
    echo '    { "matcher": "", "hooks": [{ "type": "command", "command": "bash appmaker/hooks/session-start.sh" }] }'
  fi
else
  echo "ⓘ session_hook_enabled=false → skipping .claude/settings.json wire-up"
fi

# Seed memory files (header-only)
[ -f appmaker/memory/architecture.md ] || printf '# Architecture Memory\n\nLazy-loaded notes. Updated by appmaker commands and user.\n' > appmaker/memory/architecture.md
[ -f appmaker/memory/decisions.md ] || printf '# Decisions Memory\n\nMarkdown notes on key project decisions. NIE numbered ADRs.\n' > appmaker/memory/decisions.md
[ -f appmaker/memory/lessons.md ] || printf '# Lessons Memory\n\nPost-retro lessons learned. Appended by /appmaker:archive when retro run.\n' > appmaker/memory/lessons.md

# Seed glossary (header-only — auto-populated by grill/interview/prd/decompose)
[ -f appmaker/glossary.md ] || cat > appmaker/glossary.md <<'GLOSSARY_EOF'
---
last_updated:
last_updated_by:
term_count: 0
---

# Project Ubiquitous Language

(Empty. Will be auto-populated by /appmaker:grill, /appmaker:interview, /appmaker:prd, /appmaker:decompose.)
GLOSSARY_EOF
```

**2c. Seed `appmaker/constitution.md`** (7 default rules, user edits freely):

```markdown
# Project Constitution

1. **No silent fallbacks.** Errors surface to caller.
2. **Verifiable success criteria.** Every requirement: auto-check OR human-review-with-criteria.
3. **Real boundaries in integration tests.** No mocking DB/file/API in integration tests.
4. **One thing well per slice.** Vertical slices demoable on their own.
5. **Glossary terms canonical.** Use ubiquitous language from appmaker/glossary.md.
6. **Non-delegable judgments explicit.** Identity/trust/money/irreversible decisions = `human_required`.
7. **Promote requires green.** No merge with failing tests, type errors, or lint violations.
```

**2d. Auto-detect project commands** for `appmaker/config.yaml`:
- `package.json` exists → `test_command: "npm test"`, `lint_command: "npm run lint"`, `typecheck_command: "tsc --noEmit"`
- `pyproject.toml` → `test_command: "pytest"`, `lint_command: "ruff check"`, `typecheck_command: "mypy"`
- `Cargo.toml` → `test_command: "cargo test"`, `lint_command: "cargo clippy"`
- `go.mod` → `test_command: "go test ./..."`, `lint_command: "golangci-lint run"`
- Otherwise: leave blank, user fills manually.

Plus set `project_mode: brownfield` or `greenfield` per user confirmation in 2a.

**2e. Configure optional integrations (per user choices)**

- **Graphify:** `pip install graphifyy && graphify install && graphify claude install`. Build graph (~12 min). Set `graphify_enabled: true` in config.
  - Before install/build, create `.graphifyignore` from plugin template if missing: `GRAPHIFY_RESOURCES_DIR="${CLAUDE_SKILL_DIR}/../../resources/graphify"; cp "$GRAPHIFY_RESOURCES_DIR/.graphifyignore.template" .graphifyignore`
  - Build graph after explicit user consent: `graphify .`
  - Graphify outputs are read-only input for AppMaker. AppMaker writes only small context packets to `appmaker/context/`.
- **Forest's CLAUDE.md:** `curl -sL https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md > CLAUDE.md` (or merge if existing — ask user).
- **Session-start hook:** installed automatically in step 2b (default-on as of v0.2.11). Hook script lives at `appmaker/hooks/session-start.sh`; `.claude/settings.json` wires the `SessionStart` event. Prints a 1-line status (version, active feature, slice progress, checklist state). Silent exit when no `appmaker/` folder present.
- **Pre-commit hook:** write `.git/hooks/pre-commit` (or `.husky/pre-commit`) with detected `lint_command` + `typecheck_command`.
- **Multi-project:** instruct user about parent `~/Projects/CLAUDE.md`.

### 3. UPGRADE mode (existing appmaker/ with version marker)

Detect drift between current `appmaker/.appmaker-version` and plugin resource version.

Claude reads the version using the Bash tool:
```bash
cat appmaker/.appmaker-version 2>/dev/null || echo "unknown"
```

Plugin version is read from `plugin.json` at runtime (v0.2.11 single-source-of-truth — no longer hardcoded here).

Compare the two. If different (and current isn't "unknown"), proceed with upgrade flow (write operations require explicit confirmation per "Upgrade rules" below). If "unknown" or missing, treat as fresh init instead.

**Upgrade rules:**

- **NEVER overwrite user-owned files:**
  - `appmaker/constitution.md` (user-edited)
  - `appmaker/glossary.md` (project state — stubs auto-flagged by hook, definitions explicit)
  - `appmaker/memory/*.md` (project state)
  - `appmaker/memory/wiki/*.md` (compiled knowledge)
  - `appmaker/memory/raw/*` (source notes)
  - `appmaker/context/*.md` (context snapshots)
  - `appmaker/backlog/*` (project state)
  - `appmaker/features/*` (project state)
  - `appmaker/config.yaml` (user config — only diff-suggest new fields, never overwrite)

- **REFRESH plugin-owned files:**
  - `appmaker/templates/*` — compare with plugin resources; if user has overrides, ask via AskUserQuestion before overwriting
  - `appmaker/skills/tdd/*` — these are pure reference (Matt Pocock 1:1); safe to overwrite if user didn't customize (check git diff or filesize heuristic)
  - missing seed files under `appmaker/memory/index.md`, `schema.md`, `log.md`, `raw/`, `wiki/` — create only if absent, never overwrite
  - missing report dirs: `checklists/`, `diagnostics/`, `afk/`, `reviews/`
  - **session-start hook** (v0.2.11+) — install if missing: copy `${CLAUDE_SKILL_DIR}/../../hooks/session-start.sh` to `appmaker/hooks/session-start.sh`, `chmod +x`, and merge SessionStart entry into `.claude/settings.json` (create file if missing, otherwise warn user to merge manually)
  - `.graphifyignore` — if created from AppMaker template, ask before refresh; user may customize heavily

- **Update version marker:** `echo "$PLUGIN_VERSION" > appmaker/.appmaker-version`

- **Diff new config fields:** read user's `config.yaml`, compare keys with `config.yaml.template`; for new keys, append to user's config with defaults + comment "# added by upgrade $PLUGIN_VERSION".

**Show user a summary before applying:**
```
Upgrade: 0.1.1 → 0.2.11
Will refresh (with confirmation if user edits):
  - appmaker/templates/backlog-item-template.md
  - appmaker/skills/tdd/deep-modules.md
Will add new config fields:
  - memory_wiki_enabled: true
  - checklist_report_dir: appmaker/checklists
  - afk_report_dir: appmaker/afk
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
✓ Resources materialized from plugin v0.2.11
✓ Constitution: 7 default rules (edit appmaker/constitution.md as needed)
✓ Config: appmaker/config.yaml (commands auto-detected for node project)
✓ Version marker: appmaker/.appmaker-version → 0.2.11
✓ Memory: 3 areas (architecture, decisions, lessons)
✓ Memory wiki: appmaker/memory/wiki/ + index/schema/log
✓ Context packets: appmaker/context/ (created empty)
✓ Gates/reports: appmaker/checklists/, appmaker/diagnostics/, appmaker/afk/, appmaker/reviews/
✓ Backlog: local markdown
✓ Templates: 3 files (backlog-item, decomposition, context-packet)
✓ Supporting files: appmaker/skills/tdd/ (5 Matt Pocock files)
✓ Graphify: (installed or skipped per choice)
✓ Forest's CLAUDE.md: (installed or skipped)

Next: /appmaker:start "<your first intent>"
```

**Upgrade:**
```
✓ AppMaker upgraded: 0.1.1 → 0.2.11
✓ Resources refreshed: 3 template files, memory wiki seed files, 5 supporting files
✓ Config fields added: memory wiki, checklist/diagnostics/review dirs, AFK controls
✓ User-owned files preserved: constitution.md, glossary.md (12 terms), memory/, backlog/ (4 items), features/

Next: continue your workflow or check changelog if curious about new features.
```

## Guardrails

- **Idempotent.** Re-running on existing setup must not overwrite user-owned files (constitution, glossary, memory, backlog, features, config).
- **Materialize from plugin.** Don't ask user to manually copy files. Resources packed in plugin, copied by init.
- **Detect fresh vs upgrade.** `appmaker/.appmaker-version` marker is the signal.
- **Confirm before destructive.** If `appmaker/` exists with custom content, ask before any modification.
- **No silent defaults.** User sees every choice and confirms.
- **Don't auto-pair Graphify.** Privacy implications require explicit user opt-in with cost note.
- **Don't treat Graphify as memory.** It is read-only code graph input. Persist only context packets derived from it.
- **Don't run other skills mid-init.** Init only sets up scaffold. User invokes `/appmaker:start` after.
- **Don't write 18 constitutional rules.** 7 max in seed.
- **Upgrade preserves user-owned state.** constitution.md, glossary.md, memory/, backlog/, features/ — never overwrite.
- **Upgrade refreshes plugin-owned files** (templates, supporting reference) — confirm if user customized.
- **Version marker mandatory.** Without `.appmaker-version`, future upgrades can't detect drift.
