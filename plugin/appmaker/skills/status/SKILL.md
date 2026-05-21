---
description: Compact snapshot of AppMaker state for current project. Reads filesystem only (no LLM calls for data gathering). Shows version, active feature, phase progress, checklist status, optional token usage from session logs, suggested next action (deterministic + optional LLM-grounded refinement).
disable-model-invocation: true
---

Status snapshot. Read-only filesystem inspection. Companion to the session-start hook (which prints a 1-liner); this skill prints the full report on demand.

**Data sources:**
- AppMaker filesystem (`appmaker/`) — primary, always-on
- Claude Code session logs (`~/.claude/projects/<dashes-path>/*.jsonl`) — optional, for token usage telemetry; requires `jq`; format is internal to Claude Code and may change without notice (degrade gracefully on parse error)
- Git log + recent file mtimes — optional, for LLM-grounded next-action refinement

**Output style:** Follow the **Compact report contract** in `appmaker/skills/output-style.md`. Status output = single phase table + 1-line "Next" suggestion. No prose, no nested headings, no version banner.

Optional telemetry/refinement details: `appmaker/skills/status/telemetry-refinement.md`.

## When to invoke

- Manual: `/appmaker:status`
- Suggested after `/clear` or session restart when user wants more detail than the 1-line hook output
- AFK-safe: yes (read-only)
- Required state: `appmaker/` exists
- Required input: none

## Process

### 1. Refuse if no AppMaker project

```bash
[ -d appmaker ] || { echo "AppMaker not initialized in this directory. Run /appmaker:init."; exit 0; }
```

### 2. Gather state via Bash (no LLM analysis needed)

```bash
VERSION="$(cat appmaker/.appmaker-version 2>/dev/null || echo '?')"

# Active feature = highest-numbered non-archived feature folder.
# Names are zero-padded NNN-slug, so reverse alphabetic == reverse numeric.
FEATURE=""
for d in $(ls -1d appmaker/features/*/ 2>/dev/null | sort -r); do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  [ "$name" = "archive" ] && continue
  FEATURE="$name"
  break
done

# Slice counts for active feature — check BOTH active backlog AND backlog/done/.
# tdd moves completed items into done/; ignoring it shows 0/N after TDD.
TOTAL=0; DONE_COUNT=0; OPEN_LIST=""
if [ -n "$FEATURE" ]; then
  for f in appmaker/backlog/*.md appmaker/backlog/done/*.md; do
    [ -f "$f" ] || continue
    if grep -q "^feature: $FEATURE" "$f" 2>/dev/null; then
      TOTAL=$((TOTAL + 1))
      if grep -q "^status: done" "$f" 2>/dev/null; then
        DONE_COUNT=$((DONE_COUNT + 1))
      else
        slice_id=$(basename "$f" .md | grep -oE '^[0-9]+')
        OPEN_LIST="$OPEN_LIST $slice_id"
      fi
    fi
  done
fi

# Latest checklist for feature
CHECK_FILE=""; CHECK_STATUS=""
if [ -n "$FEATURE" ]; then
  CHECK_FILE=$(ls -t appmaker/checklists/*"$FEATURE"*.md 2>/dev/null | head -1)
  if [ -n "$CHECK_FILE" ]; then
    CHECK_STATUS=$(grep -m1 '^status:' "$CHECK_FILE" 2>/dev/null | awk '{print $2}')
  fi
fi

# Latest review for feature
REVIEW_STATUS=""
if [ -n "$FEATURE" ] && [ -f "appmaker/features/$FEATURE/review.md" ]; then
  REVIEW_STATUS=$(grep -m1 '^\*\*Status:\*\*' "appmaker/features/$FEATURE/review.md" 2>/dev/null | awk '{print $2}')
fi

# PRD / decomposition presence
PRD_OK="—"; DECOMP_OK="—"
if [ -n "$FEATURE" ]; then
  [ -f "appmaker/features/$FEATURE/prd.md" ] && PRD_OK="✓"
  [ -f "appmaker/features/$FEATURE/decomposition.md" ] && DECOMP_OK="✓"
fi
```

### 2.5. Token usage telemetry (best-effort, optional)

May compute project token volume from Claude Code jsonl logs if `jq` and logs are present. Omit the row on any failure; token usage is volume, not cost. See `appmaker/skills/status/telemetry-refinement.md`.

### 3. Print compact report

**No active feature case:**

```markdown
## AppMaker Status

**Version:** 0.2.11
**Active feature:** none
**Token usage (project):** 2.7M across 12 sessions  ← omit row if telemetry unavailable

**Next:** `/appmaker:start "<your intent>"` to begin a new feature OR `/appmaker:archive` if you have a force-archived feature pending closeout
```

**Active feature case:**

```markdown
## AppMaker Status

**Version:** 0.2.11
**Active feature:** 001-bps-risk-compute
**Token usage (project):** 2.7M across 12 sessions  ← omit row if telemetry unavailable

| Phase | State |
|---|---|
| PRD | ✓ |
| Decomposition | ✓ |
| TDD | 5/7 done (open: 006, 007) |
| Checklist | WARN (latest: 2026-05-11-feature-001-...post-archive.md) |
| Review | feature-level: PASS |
| Review Readiness Dashboard | Architecture Research / Brownfield Audit / TDD Plan Check / QA / Smoke Plan / Design Review / Documentation staleness / Archive |
| Archive | not archived |

**Next:** `/appmaker:tdd 006`
**Multi-session view:** `cloud agents`  ← omit row if Claude Code <2.1.86 (Agent View unavailable)
```

### 3.5. Agent View hint (v0.2.12)

If multiple Claude Code session logs were active in the last 24h, MAY show `cloud agents`. Omit if only one session. Details in `appmaker/skills/status/telemetry-refinement.md`.

### 4. Suggest next action

Heuristic, in priority order:

| Condition | Suggested next |
|---|---|
| No PRD | `/appmaker:prd` (or `/appmaker:grill` first if greenfield) |
| PRD but no decomposition | `/appmaker:decompose` |
| Decomposition but no slices done | `/appmaker:checklist` then `/appmaker:tdd <first-open-slice>` |
| Slices partially done | `/appmaker:tdd <lowest-open-slice-id>` |
| All slices done, no review | `/appmaker:review feature <NNN>` |
| Review PASS but QA / Smoke Plan or Design Review missing for touched UI | `/appmaker:qa` or `/appmaker:design-review diff` |
| Review PASS, not archived | `/appmaker:archive <NNN-slug>` |
| Active feature is force-archived with open slices | `/appmaker:tdd <open-slice>` (finish work) OR move slice to `done/` if completed externally |

Only print 1 suggestion — the highest-priority next step. Don't list all options unless user asks "what now?" with multi-state input.

### 5. Refined suggestion (LLM-grounded, optional)

Filesystem-derived `Next` is canonical. Optional refinement may add one line only when recent commits, modified backlog, unresolved critical review findings, or dirty git state contradict it. Agreement = no refinement section. Details in `appmaker/skills/status/telemetry-refinement.md`.

## Output format (canonical)

Compact contract — no frontmatter (this is chat-only output, not a persisted file). Phase table + Next line + nothing else.

## Guardrails

- **Read-only.** No file writes. No state mutations.
- **State from filesystem first.** LLM reasoning only refines the deterministic baseline; never replaces it. If filesystem says "X is done", LLM cannot claim "X is open".
- **Silent on missing dirs.** If `appmaker/checklists/` doesn't exist yet, don't error — show `—` in the cell.
- **Silent on optional telemetry failure.** No `jq`, no session log dir, parse error → omit the row, never surface the error to user.
- **Token usage = volume, NOT cost.** Caveat the number with the formula; don't imply dollar amount.
- **Single suggestion.** Don't dump all possible next actions.
- **No version banner.** Hook already shows the 1-liner; status command shows the detail.
- **No prose summaries.** Phase table is the report.
- **Don't re-run other skills.** Status reads — doesn't invoke checklist/review/etc.
- **Refinement is silent by default.** Emit refined suggestion only when it diverges from deterministic. Agreement = no refinement section.
