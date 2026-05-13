---
description: Token usage diagnostic. Parses Claude Code session logs to identify where tokens are spent — per-session totals, tool breakdown, per-skill cost (when /appmaker commands detected), top largest tool results, file-read hotspots. Read-only, requires jq. Use BEFORE making token-reduction patches so optimization targets are grounded in real data.
disable-model-invocation: true
---

Token usage diagnostic. Best-effort parser of Claude Code internal session log format. Output is a profile — not a billing source — for identifying optimization targets.

**Output style:** Compact tables per `appmaker/skills/output-style.md`. No prose summaries. Token numbers formatted compactly (`X.Yk`, `X.YM`).

**Caveats up front:**
- Reads `~/.claude/projects/<dashes-path>/*.jsonl` — Claude Code internal format, not public-stable.
- **Volume ≠ cost.** Cache reads cost ~10% of input. Output tokens ~5× input. Numbers reported are gross volume.
- Per-skill attribution: implemented (v0.2.11) via jsonl walk with skill-window tracking. Heuristic — only catches USER-typed `/appmaker:*` slash commands. Sub-skills invoked via Skill tool from within another skill count toward the originating user invocation (skill chains bleed by design).

## When to invoke

- Manual: `/appmaker:token-audit [--top N] [--session SESSION_ID]`
- AFK-safe: yes (read-only)
- Required state: `jq` installed; `~/.claude/projects/<dashes-path>/` exists
- Required input: none

## Process

### 0. Refuse if prereqs missing

```bash
command -v jq >/dev/null || { echo "❌ jq not installed. Install via: brew install jq"; exit 0; }

PROJ_LOG_DIR="$HOME/.claude/projects/$(pwd | sed 's|/|-|g')"
[ -d "$PROJ_LOG_DIR" ] || { echo "❌ No session logs at $PROJ_LOG_DIR. Has this project been used in Claude Code?"; exit 0; }
```

### 1. Aggregate session totals

```bash
TOTAL_TOKENS=0
SESSION_COUNT=0
declare -a SESSION_LINES

for j in "$PROJ_LOG_DIR"/*.jsonl; do
  [ -f "$j" ] || continue
  sid=$(basename "$j" .jsonl)
  short_sid="${sid:0:8}"

  first_ts=$(head -1 "$j" 2>/dev/null | jq -r '.timestamp // empty' 2>/dev/null | head -c 19)

  total=$(jq -r '.message.usage | select(.) | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0) + (.output_tokens // 0))' "$j" 2>/dev/null | awk '{s+=$1} END {print s+0}')

  turns=$(jq -r 'select(.message.role == "assistant")' "$j" 2>/dev/null | grep -c '^{')

  avg=0
  [ "$turns" -gt 0 ] && avg=$((total / turns))

  TOTAL_TOKENS=$((TOTAL_TOKENS + total))
  SESSION_COUNT=$((SESSION_COUNT + 1))
  SESSION_LINES+=("$short_sid|${first_ts:-?}|$total|$turns|$avg")
done
```

### 2. Tool call breakdown (across all sessions)

```bash
TOOL_BREAKDOWN=$(cat "$PROJ_LOG_DIR"/*.jsonl 2>/dev/null \
  | jq -r '.message.content[]? | select(.type == "tool_use") | .name' 2>/dev/null \
  | sort | uniq -c | sort -rn)
```

### 3. Per-skill attribution (v0.2.11 — real implementation)

Walks each jsonl in order: detects `/appmaker:<name>` in user-role text, opens a "skill window", sums assistant `usage` tokens until next user message (or file end). Bucket `__none__` captures tokens during non-AppMaker work.

**Caveats:**
- Skill chains bleed: if `/appmaker:prd` chains into glossary update via Skill tool, tokens for the inner call count toward `prd` (the originating user invocation), not `glossary`.
- Tool_result user-messages count as "user message boundary" — this means a long Bash output mid-skill-execution will NOT split the window. Correct behavior.
- Detects only USER-typed `/appmaker:*` patterns. Skills invoked via Skill tool internally are NOT detected (Pawel-typed slash commands only).

```bash
# Per-skill attribution: walk jsonl, track current skill window, sum usage
PER_SKILL=$(for j in "$PROJ_LOG_DIR"/*.jsonl; do
  jq -r '
    if .message.role == "user" then
      (
        if (.message.content | type) == "string" then .message.content
        else (.message.content[]? | select(.type == "text" or .type == null) | (.text // "")) // ""
        end
      ) | "USER\t\((. | scan("/appmaker:[a-z-]+") // ["__none__"])[0])"
    elif .message.role == "assistant" and .message.usage then
      "USAGE\t\((.message.usage.input_tokens // 0) + (.message.usage.cache_creation_input_tokens // 0) + (.message.usage.cache_read_input_tokens // 0) + (.message.usage.output_tokens // 0))"
    else empty end
  ' "$j" 2>/dev/null
done | awk '
BEGIN { current = "__none__"; FS="\t" }
$1 == "USER" { current = ($2 == "__none__" ? "__none__" : $2); next }
$1 == "USAGE" { totals[current] += $2; invocations[current] += 1 }
END {
  for (k in totals) printf "%s\t%d\t%d\n", k, invocations[k], totals[k]
}' | sort -t$'\t' -k3 -rn)
```

Output rows: `<skill>  <turns-attributed>  <total-tokens>`.

If only `__none__` bucket present, surface honestly: "no /appmaker:* invocations detected — this project hasn't been used through AppMaker workflow yet, or all skill calls were via Skill tool not slash commands."

### 4. Top largest tool results (where bytes go)

```bash
TOP_RESULTS=$(cat "$PROJ_LOG_DIR"/*.jsonl 2>/dev/null \
  | jq -r '.message.content[]? | select(.type == "tool_result") | (if (.content | type) == "string" then .content else (.content[0].text // "") end) | [length, .[0:80]] | @tsv' 2>/dev/null \
  | sort -t$'\t' -k1 -rn | head -10)
```

Each row = bytes + first 80 chars of result (gives hint what tool returned).

### 5. File-read hotspots (Read tool inputs)

```bash
READ_HOTSPOTS=$(cat "$PROJ_LOG_DIR"/*.jsonl 2>/dev/null \
  | jq -r '.message.content[]? | select(.type == "tool_use" and .name == "Read") | .input.file_path' 2>/dev/null \
  | sort | uniq -c | sort -rn | head -10)
```

Same file Read multiple times across sessions = caching opportunity OR pre-flight bloat indicator.

### 6. Bash command frequency (high-cost commands)

```bash
BASH_COMMANDS=$(cat "$PROJ_LOG_DIR"/*.jsonl 2>/dev/null \
  | jq -r '.message.content[]? | select(.type == "tool_use" and .name == "Bash") | .input.command' 2>/dev/null \
  | awk '{print $1}' | sort | uniq -c | sort -rn | head -10)
```

First-word of command = command name. Reveals e.g. lots of `cat`, `grep`, `find` — each returning stdout to context.

### 7. Format compact output

```markdown
## Token Audit: <project path>

**Total:** <X.YM> tokens across <N> sessions
**Caveat:** gross volume; cache reads ~10% input cost; output tokens ~5× input.

### Per-session
| Session | Started | Tokens | Turns | Avg/turn |
|---|---|---|---|---|
| abc12345 | 2026-05-10T07:50 | 1.2M | 21 | 57k |
| 872aab0f | (no ts)          | 1.5M | 20 | 73k |

### Tool call breakdown
| Tool | Calls |
|---|---|
| Read | 16 |
| Bash | 9 |
| Skill | 1 |

### Per-skill cost (if /appmaker:* invocations detected)
| Skill | Invocations | Total tokens | Avg/invocation |
|---|---|---|---|
| (omit section entirely when no invocations) |

### Top 10 largest tool results
| Bytes | Tool hint (first 80 chars) |
|---|---|
| 24.9k | `1\tThis is a long PRD output...` |
| 22.2k | `# Compact report contract...` |

### File-read hotspots (top 10)
| Reads | File |
|---|---|
| 4 | `appmaker/features/001/prd.md` |
| 3 | `DESIGN.md` |

### Bash command frequency (top 10)
| Calls | First-word |
|---|---|
| 12 | `grep` |
| 8 | `cat` |

### Optimization signals
- (only show if applicable; max 3 bullets)
- Same file `<path>` read N× → candidate for context packet caching
- Top tool result is `<X>k` from `<tool>` → consider truncation or summarization
- Bash command `<cmd>` runs N× returning large stdout → consider redirect to file + lazy read
```

### 8. Print only sections with data

- No `/appmaker:*` invocations → omit per-skill section
- No file-read hotspots > 1× → omit hotspots section
- Single session → drop Avg/turn column

## Guardrails

- **Read-only.** No writes. No state mutations.
- **Silent degradation.** Missing `jq`, missing log dir, malformed lines → report what's missing, never error-stop downstream sections.
- **Truncate previews.** Tool result hints capped at 80 chars; file paths shortened if > 60 chars.
- **No billing claims.** Numbers are volume. State this explicitly in output.
- **No optimization auto-fix.** Surface findings; user decides what to patch.
- **No prose interpretation.** Tables + max 3 optimization-signal bullets. No "what to do" essays.
- **Don't dump raw session content.** Only aggregates + truncated previews.
- **Don't try to merge sessions across projects.** Scope = current cwd's mapped log dir.
