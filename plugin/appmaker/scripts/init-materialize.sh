#!/usr/bin/env bash
# Materializes appmaker/ project tree from plugin resources.
# Called by /appmaker:init AFTER user confirmations in skill step 2a.
# Idempotent: never overwrites user-owned files; safe to re-run.
#
# Single source of truth (v0.2.11): plugin.json holds canonical version.
# This script reads it via jq (preferred) or sed fallback.

set -u

# Resolve plugin paths from this script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESOURCES_DIR="$PLUGIN_ROOT/resources/appmaker"
GRAPHIFY_RESOURCES_DIR="$PLUGIN_ROOT/resources/graphify"
PLUGIN_MANIFEST="$PLUGIN_ROOT/.claude-plugin/plugin.json"
HOOKS_DIR="$PLUGIN_ROOT/hooks"

# Read plugin version (canonical: plugin.json).
if command -v jq >/dev/null 2>&1; then
  PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_MANIFEST")
else
  PLUGIN_VERSION=$(grep -m1 '"version"' "$PLUGIN_MANIFEST" | sed -E 's/.*"version"[^"]*"([^"]+)".*/\1/')
fi
[ -z "$PLUGIN_VERSION" ] && { echo "❌ Failed to read version from $PLUGIN_MANIFEST" >&2; exit 1; }
echo "ⓘ Plugin version: $PLUGIN_VERSION (source: plugin.json)"

# Directory tree.
mkdir -p appmaker/{templates,skills,memory/raw,memory/wiki,context,backlog/done,features/archive,reviews,checklists,diagnostics,decisions,security,afk,phase-plans,hooks}

# Templates (per-project overrides allowed; user edits freely).
cp -n "$RESOURCES_DIR/templates/"*.md appmaker/templates/ 2>/dev/null || true

# Supporting reference files (e.g., Matt Pocock tdd/, plan-format.md).
cp -rn "$RESOURCES_DIR/skills/"* appmaker/skills/ 2>/dev/null || true

# Memory wiki seeds (never overwrite user memory).
cp -rn "$RESOURCES_DIR/memory/"* appmaker/memory/ 2>/dev/null || true

# Config.yaml (only if absent — never overwrite user config). Substitute ${VERSION}.
if [ ! -f appmaker/config.yaml ]; then
  sed "s/\${VERSION}/$PLUGIN_VERSION/g" "$RESOURCES_DIR/config.yaml.template" > appmaker/config.yaml
fi

# Auto-detect project commands and patch appmaker/config.yaml.
patch_cmd() {
  local key="$1" value="$2"
  # Replace only when value is empty (don't overwrite user-set commands).
  grep -qE "^${key}:[[:space:]]*$" appmaker/config.yaml 2>/dev/null && \
    sed -i.bak -E "s|^${key}:[[:space:]]*\$|${key}: \"${value}\"|" appmaker/config.yaml && \
    rm -f appmaker/config.yaml.bak
}
if [ -f package.json ]; then
  patch_cmd test_command "npm test"
  patch_cmd lint_command "npm run lint"
  patch_cmd typecheck_command "tsc --noEmit"
elif [ -f pyproject.toml ]; then
  patch_cmd test_command "pytest"
  patch_cmd lint_command "ruff check"
  patch_cmd typecheck_command "mypy"
elif [ -f Cargo.toml ]; then
  patch_cmd test_command "cargo test"
  patch_cmd lint_command "cargo clippy"
elif [ -f go.mod ]; then
  patch_cmd test_command "go test ./..."
  patch_cmd lint_command "golangci-lint run"
fi

# Version marker.
echo "$PLUGIN_VERSION" > appmaker/.appmaker-version

# Read hook flags (default true on fresh init).
read_flag() {
  local key="$1" val
  val=$(grep -E "^${key}:" appmaker/config.yaml 2>/dev/null | awk '{print $2}' | head -1)
  [ -z "$val" ] && val="true"
  echo "$val"
}
SESSION_HOOK_ENABLED=$(read_flag session_hook_enabled)
GLOSSARY_HOOK_ENABLED=$(read_flag glossary_hook_enabled)

# Install hook scripts.
if [ "$SESSION_HOOK_ENABLED" = "true" ]; then
  cp "$HOOKS_DIR/session-start.sh" appmaker/hooks/session-start.sh
  chmod +x appmaker/hooks/session-start.sh
  echo "✓ session-start hook installed"
else
  echo "ⓘ session_hook_enabled=false → skipping session-start.sh install"
fi

if [ "$GLOSSARY_HOOK_ENABLED" = "true" ]; then
  cp "$HOOKS_DIR/glossary-extract.sh" appmaker/hooks/glossary-extract.sh
  chmod +x appmaker/hooks/glossary-extract.sh
  echo "✓ glossary-extract hook installed"
else
  echo "ⓘ glossary_hook_enabled=false → skipping glossary-extract.sh install"
fi

# Wire .claude/settings.json — guarded by session_hook_enabled.
# Three paths: no settings.json → write fresh. Exists + jq → merge idempotently.
# Exists, no jq → print guidance for skill to ask user (skill handles AskUserQuestion).
if [ "$SESSION_HOOK_ENABLED" = "true" ]; then
  mkdir -p .claude
  if [ ! -f .claude/settings.json ]; then
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
    echo "⚠ .claude/settings.json exists, but jq not installed — cannot auto-merge."
    echo "  Skill should ask user: skip / overwrite-with-backup / install jq + re-run."
    echo "  Manual merge target (add to .hooks.SessionStart array):"
    echo '    { "matcher": "", "hooks": [{ "type": "command", "command": "bash appmaker/hooks/session-start.sh" }] }'
  fi
else
  echo "ⓘ session_hook_enabled=false → skipping .claude/settings.json wire-up"
fi

# Memory seeds (header-only, never overwrite).
[ -f appmaker/memory/architecture.md ] || \
  printf '# Architecture Memory\n\nLazy-loaded notes. Updated by appmaker commands and user.\n' > appmaker/memory/architecture.md

[ -f appmaker/memory/decisions.md ] || cat > appmaker/memory/decisions.md <<'DECISIONS_EOF'
# Decisions Memory

Cross-feature hard-to-reverse decisions. Markdown, NIE numbered ADRs.

## When to log

Both criteria:
- Hard to reverse (migration, public API, schema, lib lock-in)
- Surprising without context (real trade-off; future reader asks "why?")

Skip interchangeable choices, defaults, style preferences.

## Format

    ### YYYY-MM-DD — <title>
    **Feature:** <NNN-slug> (or cross-cutting)
    **Decision:** <what picked>
    **Why:** <trade-off + alternatives rejected>
    **Consequences:** <downstream impacts>

Written by /appmaker:archive retro from interview-result.md "Architectural decisions surfaced" + retro answers.
DECISIONS_EOF

[ -f appmaker/memory/lessons.md ] || \
  printf '# Lessons Memory\n\nPost-retro lessons learned. Appended by /appmaker:archive when retro run.\n' > appmaker/memory/lessons.md

# Glossary seed (header-only — auto-populated by grill/interview/prd/decompose).
[ -f appmaker/glossary.md ] || cat > appmaker/glossary.md <<'GLOSSARY_EOF'
---
last_updated:
last_updated_by:
term_count: 0
---

# Project Ubiquitous Language

(Empty. Will be auto-populated by /appmaker:grill, /appmaker:interview, /appmaker:prd, /appmaker:decompose.)
GLOSSARY_EOF

# Constitution seed (only if absent — user-owned thereafter).
[ -f appmaker/constitution.md ] || cp "$RESOURCES_DIR/constitution.md.seed" appmaker/constitution.md

# AppMaker pointer in project-root CLAUDE.md (idempotent).
APPMAKER_POINTER='## AppMaker

- Domain language: `appmaker/glossary.md`
- Project rules: `appmaker/constitution.md`
- Active features: `appmaker/features/`
- Cross-feature decisions: `appmaker/memory/decisions.md`
'
if [ ! -f CLAUDE.md ]; then
  printf '%s' "$APPMAKER_POINTER" > CLAUDE.md
  echo "✓ CLAUDE.md created with AppMaker pointer"
elif ! grep -q '^## AppMaker' CLAUDE.md; then
  printf '\n%s' "$APPMAKER_POINTER" >> CLAUDE.md
  echo "✓ AppMaker pointer appended to existing CLAUDE.md"
else
  echo "ⓘ CLAUDE.md already has AppMaker pointer — skipping"
fi

echo "✓ Materialization complete (plugin v$PLUGIN_VERSION)"
