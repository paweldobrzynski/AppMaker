---
description: AppMaker lifecycle orchestrator. Detects current feature state, determines next phase deterministically, and (with explicit user confirmation per phase) invokes the appropriate side-effect skill via the Skill tool. Solves the "side-effect skills are disable-model-invocation:true so agent can't chain them" friction without reverting the v0.2.9 audit fix. Single user trigger; chained phased execution with checkpoint gates.
disable-model-invocation: true
---

Lifecycle orchestrator. User explicit entry point; chained execution. Preserves audit-safe property (side-effect skills stay `disable-model-invocation: true`) by being the SINGLE explicit trigger that owns the chain.

**Output style:** Compact tables per `appmaker/skills/output-style.md`. One-line state + one AskUserQuestion + one Skill-tool invocation per cycle.

## When to invoke

- Manual: `/appmaker:next [--auto]`
  - default: confirm each phase via AskUserQuestion before invoking next skill
  - `--auto`: invoke next phase without confirmation; STILL stops on FAIL gate (review/checklist FAIL)
- Suggested by hook output OR after any phase completes when user wants to keep moving
- AFK-safe: only with `--auto` AND `afk_enabled: true` in config (same constraint as `/appmaker:afk`)
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
```

### 2. Determine next phase (deterministic state machine)

| Current state | Next phase | Skill to invoke | Args |
|---|---|---|---|
| No `appmaker/` at all | initialize | `/appmaker:init` | (none) |
| No active feature | start new | `/appmaker:start` | ask user for intent string |
| Active feature, no interview-result.md (greenfield) | interview | `/appmaker:interview` | feature folder |
| Active feature, no PRD | PRD synthesis | `/appmaker:prd` | feature folder |
| PRD exists, no decomposition | decompose | `/appmaker:decompose` | feature folder |
| Decomposition exists, no checklist or checklist FAIL | checklist | `/appmaker:checklist` | `feature <NNN-slug>` |
| Checklist PASS/WARN, slices open | TDD next slice | `/appmaker:tdd` | `$FIRST_OPEN` |
| All slices done, no feature review.md | review | `/appmaker:review` | `feature <NNN-slug>` |
| Review PASS, not archived | archive | `/appmaker:archive` | `<NNN-slug>` |
| Active feature is in archive/ AND all slices done | nothing — lifecycle complete | (output: "Feature lifecycle complete. Use /appmaker:start for next feature.") | — |

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
- **Yes, then continue chain** → step 4 + loop back to step 1 after target completes
- **No, show alternatives** → list other valid phases (e.g., "tdd next open slice", "manual checklist run") + AskUserQuestion
- **Stop** → exit, no action

With `--auto` flag: skip AskUserQuestion, go directly to step 4 + loop. **Still stops on FAIL.**

### 4. Invoke target skill via Skill tool

```
Skill(skill: "<target-name>", args: "<computed args>")
```

Wait for completion. Read target's output/exit signal.

**On target FAIL** (review FAIL, checklist FAIL, tdd test failure):
- Stop chain regardless of mode (`--auto` or default).
- Surface findings to user via AskUserQuestion: fix / override / abandon.
- Do NOT invoke next phase silently.

**On target PASS:**
- If user chose "Yes, then continue chain" or `--auto`: re-enter step 1.
- Else: stop, show "✓ <phase> complete. Run /appmaker:next when ready for next phase."

### 5. Report

Compact summary per cycle:

```
[1/?] interview  → ✓ done
[2/?] prd        → ✓ done
[3/?] decompose  → ✓ done
[4/?] checklist  → ✓ PASS
[5/?] tdd 001    → ✓ done
[6/?] tdd 002    → ⏸ stopped at user request

Resume: /appmaker:next
```

## Guardrails

- **User-explicit single entry.** `disable-model-invocation: true` — Claude never auto-invokes this; user types `/appmaker:next` explicitly.
- **Per-phase confirmation by default.** `--auto` is opt-in and only valid when `afk_enabled: true` in config.
- **Stop on FAIL.** No silent failure passthrough. Review FAIL or checklist FAIL ends the chain immediately.
- **Idempotent.** Re-running `/appmaker:next` is safe — detects current state, picks up where last cycle stopped.
- **No state mutation by `next` itself.** All writes happen INSIDE invoked target skills. `/appmaker:next` only reads + orchestrates.
- **Honest about ambiguity.** When state is unclear (e.g., force-archived feature with open slices, or multiple non-archived features), surface via AskUserQuestion rather than picking silently.
- **Respects existing config.** `afk_enabled`, `afk_max_iterations`, `afk_cost_cap_usd` apply to `--auto` mode.
- **Don't skip checklist.** Even in `--auto`, checklist must run before each tdd and review must run before each archive.
