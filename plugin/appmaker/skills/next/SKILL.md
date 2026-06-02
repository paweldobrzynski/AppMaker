---
description: AppMaker lifecycle dispatcher. Detects current feature state, determines next phase deterministically, and emits the exact slash command for the user to run. Side-effect skills keep disable-model-invocation:true and MUST NOT be called through the Skill tool.
disable-model-invocation: true
---

Lifecycle dispatcher. User explicit entry point; read-only state detection + exact next command. Preserves audit-safe property: side-effect skills stay `disable-model-invocation: true`, so `/appmaker:next` MUST NOT use the Skill tool to call them.

**Output style:** Compact tables per `appmaker/skills/output-style.md`. One-line state + one AskUserQuestion + one slash-command handoff.

## When to invoke

- Manual: `/appmaker:next`
  - confirms the proposed phase via AskUserQuestion
  - emits the exact slash command the user should run next
- Suggested by hook output OR after any phase completes when user wants to keep moving
- AFK-safe: NO — this dispatcher does not execute work; use `/appmaker:afk` for autonomous loops
- Required state: `appmaker/` initialized, ≥ 1 feature folder OR explicit user intent to start new feature
- Required input: none (state-driven)

## Process

### 1. Detect current state (read-only filesystem)

Reuse logic from `/appmaker:status` step 2:

```bash
# Active feature (highest-numbered non-archived)
FEATURE=""
for d in $(ls -1d appmaker/features/*/ 2>/dev/null | sort -r); do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  [ "$name" = "archive" ] && continue
  FEATURE="$name"
  break
done

# Phase artifacts present
INTERVIEW_OK=""; PRD_OK=""; DECOMP_OK=""; REVIEW_OK=""
if [ -n "$FEATURE" ]; then
  [ -f "appmaker/features/$FEATURE/interview-result.md" ] && INTERVIEW_OK="yes"
  [ -f "appmaker/features/$FEATURE/prd.md" ] && PRD_OK="yes"
  [ -f "appmaker/features/$FEATURE/decomposition.md" ] && DECOMP_OK="yes"
  [ -f "appmaker/features/$FEATURE/review.md" ] && REVIEW_OK="yes"
fi

# Slice counts (active backlog + done/)
TOTAL=0; DONE_COUNT=0; FIRST_OPEN=""
if [ -n "$FEATURE" ]; then
  for f in appmaker/backlog/*.md appmaker/backlog/done/*.md; do
    [ -f "$f" ] || continue
    if grep -q "^feature: $FEATURE" "$f" 2>/dev/null; then
      TOTAL=$((TOTAL + 1))
      if grep -q "^status: done" "$f" 2>/dev/null; then
        DONE_COUNT=$((DONE_COUNT + 1))
      elif [ -z "$FIRST_OPEN" ]; then
        FIRST_OPEN=$(basename "$f" .md | grep -oE '^[0-9]+')
      fi
    fi
  done
fi

# Latest checklist status
CHECK_STATUS=""
if [ -n "$FEATURE" ]; then
  LATEST_CHECK=$(ls -t appmaker/checklists/*"$FEATURE"*.md 2>/dev/null | head -1)
  [ -n "$LATEST_CHECK" ] && CHECK_STATUS=$(grep -m1 '^status:' "$LATEST_CHECK" 2>/dev/null | awk '{print $2}')
fi

# Oldest done backlog item for this feature with no per-slice review yet (v0.2.15)
# done items live in appmaker/backlog/done/<YYYY-MM-DD>-NNN.md (date prefix → ls -1 sorts oldest-first)
# An item is "reviewed" when its file has a `## Review` heading appended OR a `review_status:` YAML field
# (latter covers `failed_overridden` explicit override flow).
UNREVIEWED_DONE=""
if [ -n "$FEATURE" ]; then
  for f in $(ls -1 appmaker/backlog/done/*.md 2>/dev/null); do
    [ -f "$f" ] || continue
    grep -q "^feature: $FEATURE" "$f" 2>/dev/null || continue
    if ! grep -q "^## Review" "$f" 2>/dev/null && \
       ! grep -q "^review_status:" "$f" 2>/dev/null; then
      UNREVIEWED_DONE=$(grep -m1 '^id:' "$f" 2>/dev/null | awk '{print $2}')
      break
    fi
  done
fi

# --- v0.2.27 advisory gates: council (pre-decompose) + security-scan (pre-archive) ---
COUNCIL_ENABLED=$(grep '^council_enabled:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
SECURITY_ENABLED=$(grep '^security_scan_enabled:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
SECURITY_GATE_STRICT=$(grep '^security_gate_on_strict:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
RIGOR=$(grep '^rigor_level:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')

# Strategic fork unresolved (advisory council trigger): PRD present, no decomposition yet,
# PRD has a pending Architecture Options Research OR an unresolved/human_required gray area,
# AND no council decision already recorded for this feature.
STRATEGIC_FORK=""
if [ -n "$FEATURE" ] && [ -n "$PRD_OK" ] && [ -z "$DECOMP_OK" ] && [ "$COUNCIL_ENABLED" != "false" ]; then
  PRD="appmaker/features/$FEATURE/prd.md"
  if grep -qiE '^\**Status:\**[[:space:]]*pending' "$PRD" 2>/dev/null || \
     grep -qiE 'human_required|Unresolved gray area' "$PRD" 2>/dev/null; then
    grep -lq "$FEATURE" appmaker/decisions/*.md 2>/dev/null || STRATEGIC_FORK="yes"
  fi
fi

# Security gate (pre-archive): strict rigor (when enabled) OR a sensitive slice label, and no scan yet.
SECURITY_DUE=""
if [ -n "$FEATURE" ] && [ "$SECURITY_ENABLED" != "false" ]; then
  SENSITIVE=""
  grep -rqiE '^labels:.*(security|auth|payments|migration)' appmaker/backlog/done/*.md appmaker/backlog/*.md 2>/dev/null && SENSITIVE="yes"
  if { [ "$RIGOR" = "strict" ] && [ "$SECURITY_GATE_STRICT" != "false" ]; } || [ -n "$SENSITIVE" ]; then
    ls appmaker/security/*.md >/dev/null 2>&1 || SECURITY_DUE="yes"
  fi
fi
```

### 2. Determine next phase (deterministic state machine)

| Current state | Next phase | Skill to invoke | Args |
|---|---|---|---|
| No `appmaker/` at all | initialize | `/appmaker:init` | (none) |
| No active feature | start new | `/appmaker:start` | ask user for intent string |
| Active feature, no interview-result.md (greenfield) | interview | `/appmaker:interview` | feature folder |
| Active feature, no PRD | PRD synthesis | `/appmaker:prd` | feature folder |
| PRD exists, no decomposition, **unresolved strategic fork** (`$STRATEGIC_FORK`, council_enabled) | go/no-go council (advisory) | `/appmaker:council` | `"<decision question>"` |
| PRD exists, no decomposition | decompose | `/appmaker:decompose` | feature folder |
| Decomposition exists, no checklist or checklist FAIL | checklist | `/appmaker:checklist` | `feature <NNN-slug>` |
| **Done slice without per-slice review** (`$UNREVIEWED_DONE` non-empty) | per-slice review | `/appmaker:review` | `$UNREVIEWED_DONE` |
| Checklist PASS/WARN, slices open, no unreviewed done | TDD next slice | `/appmaker:tdd` | `$FIRST_OPEN` |
| All slices done + all reviewed, no feature review.md | feature review | `/appmaker:review` | `feature <NNN-slug>` |
| Feature review PASS, **security gate due** (`$SECURITY_DUE`, strict/sensitive, no scan yet) | security gate (advisory) | `/appmaker:security-scan` | `project` |
| Feature review PASS, not archived | archive | `/appmaker:archive` | `<NNN-slug>` |
| Active feature is in archive/ AND all slices done | nothing — lifecycle complete | (output: "Feature lifecycle complete. Use /appmaker:start for next feature.") | — |

**Per-slice review takes priority** over "next TDD slice" (v0.2.15). Rationale: catching constitution / glossary / AC-coverage / memory-regression issues immediately after a slice is cheaper than discovering them at end-of-feature review when 6 dependent slices have already inherited the flaw. Same critic gate as feature-level review, scoped to one backlog item — `/appmaker:review <id>` (see `review/SKILL.md` step 2: backlog-item scope reads backlog file + parent PRD + `context_packets` + diff). Override flow unchanged: review FAIL → user fix or `review_status: failed_overridden` + reason → orchestrator un-blocks.

**Council and security gates are advisory, not hard blocks (v0.2.27).** Both rows fire only on a heuristic (`$STRATEGIC_FORK` / `$SECURITY_DUE`) and the user may always skip straight to `decompose` / `archive`. When `next` proposes one, the AskUserQuestion options must include **Skip this gate → proceed to <decompose|archive>** so the gate never traps the lifecycle. `council` writes a decision artifact + `SHIP|NEEDS_WORK|BLOCKED` verdict; `security-scan` writes a `PASS|FAIL|WARN` report. A council `BLOCKED`/`NEEDS_WORK` or security `FAIL` becomes the next remediation handoff, same as a review FAIL.

If state is ambiguous (e.g., review FAIL not resolved), surface via AskUserQuestion with options: address findings / override / skip phase.

### 3. Confirm with user (default mode)

Show compact state + proposed action:

```markdown
## AppMaker Next

**Active feature:** 001-bps-risk-compute
**State:** 5/7 slices done, checklist PASS, no feature review yet
**Proposed next:** `/appmaker:review feature 001-bps-risk-compute`

Proceed?
```

AskUserQuestion options:
- **Yes** → step 4
- **No, show alternatives** → list other valid phases (e.g., "tdd next open slice", "manual checklist run") + AskUserQuestion
- **Stop** → exit, no action

### 4. Hand off target slash command

Always emit the exact slash command, for example:

```text
Next command: /appmaker:tdd 008
```

Then stop. Do not simulate the target skill inline. If the user wants to proceed, they type the command. If a previous command failed, surface the failed artifact and suggest `/appmaker:review`, `/appmaker:checklist`, or a fix command as appropriate.

### 5. Report

Compact summary per cycle:

```
[1/?] interview    → ✓ done
[2/?] prd          → ✓ done
[3/?] decompose    → ✓ done
[4/?] checklist    → ✓ PASS
[5/?] next         → handoff `/appmaker:tdd 001`

Run: /appmaker:tdd 001
```

## Guardrails

- **User-explicit single entry.** `disable-model-invocation: true` — Claude never auto-invokes this; user types `/appmaker:next` explicitly.
- **Manual handoff.** Side-effect skills are manual slash-command handoffs; do not call them with Skill tool.
- **Stop on FAIL.** No silent failure passthrough. Review FAIL or checklist FAIL changes the next handoff to remediation.
- **Idempotent.** Re-running `/appmaker:next` is safe — detects current state, picks up where last cycle stopped.
- **No state mutation by `next` itself.** All writes happen inside the slash command the user runs next. `/appmaker:next` only reads + dispatches.
- **Honest about ambiguity.** When state is unclear (e.g., force-archived feature with open slices, or multiple non-archived features), surface via AskUserQuestion rather than picking silently.
- **Don't skip checklist.** Checklist must run before TDD and review must run before archive.
