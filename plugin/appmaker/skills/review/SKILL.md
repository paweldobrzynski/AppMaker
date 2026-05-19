---
description: Critic gate before promote/archive. Invokes Claude Code subagent (default code-reviewer, configurable) on specified scope (backlog item, feature, or current diff). Captures structured findings to review report. Pass/fail gate — user decides fix-or-override on fail. Use when implementation is complete and needs independent review.
disable-model-invocation: true
---

Critic gate. Invokes subagent for independent review. Generator (you) is not the only reviewer of your own artifact (Constitution rule 6 spirit, Spec Kit `/speckit.analyze` parallel).

Provider-agnostic — default `code-reviewer` subagent, configurable in `appmaker/config.yaml` (`review_subagent`).

**Output style:** Follow the **Compact report contract** in `appmaker/skills/output-style.md`. Review report = status line + bullet findings (1 line each). No prose, no multi-paragraph deep-dives, no separate "Constitution" / "Glossary" / "AC coverage" sub-sections when each has 0-1 finding — fold all findings into one table. Skip empty categories.

Detailed checklist + report template: `appmaker/skills/review/review-contract.md`.

## When to invoke

- Manual: `/appmaker:review <scope> [--mode=local|ultra]` where scope is:
  - `<backlog-id>` — review specific backlog item
  - `feature <NNN>` — review full feature
  - `diff` — review current uncommitted changes
  - omitted → review latest completed backlog item
- Mode flag (v0.2.12):
  - `--mode=local` (default) — invoke configured subagent (`code-reviewer`) locally; tokens-only cost
  - `--mode=ultra` — invoke Claude Code's `/ultra-review` (parallel reviewer fleet, bugs reproduced before reporting). AppMaker layers compliance checks (AC coverage, constitution, glossary, traceability) ON TOP of `/ultra-review` findings. **Best for critical features (payments, auth, migrations).** Cost: 3 free/month then $5-20 per run (Claude Code Pro/Max).
- Auto: by `tdd` (suggests post-completion), by `archive` (pre-archive gate)
- AFK-safe: yes — subagent runs autonomously, gates pass/fail
- Required state: scope target exists; for `--mode=ultra` requires Claude Code 2.1.86+ and Claude account (not API key alone)
- Required input: scope (auto-detected if obvious)

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

Before invoking subagent, read durable test patterns + known gotchas so the reviewer's checklist is grounded in project history, not generic CR heuristics.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in testing integration-gotchas; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

Pass these contents to the subagent as part of its context package (see step 2). The subagent's "Memory regression check" (item 10 in its checklist) MUST cite at least one wiki entry if any apply — silent passthrough on a relevant gotcha = review FAIL. Note: this supersedes prior "when relevant" wording; these pages are read on every review invocation.

### 1. Determine scope

Parse argument. Default to latest completed backlog item. Confirm via AskUserQuestion.

### 2. Gather context for subagent

Build context package:
- Backlog item: backlog file (`## Approved TDD Plan` + `## Execution Record`) + parent feature PRD + `context_packets` field values + diff
- Feature: PRD + decomposition + all backlog items + all referenced `context_packets` + cumulative diff
- Diff: current `git diff` output + relevant context packet if available

Plus always:
- `appmaker/glossary.md` — flag glossary violations
- `appmaker/constitution.md` — flag rule violations
- `appmaker/config.yaml` — graphify settings + review subagent
- `appmaker/memory/wiki/testing.md` + `integration-gotchas.md` — already read in step 0; passed to subagent as mandatory context, not "when relevant"

Context packet handling:
- Read each `appmaker/context/*.md` listed in backlog/decomposition `context_packets`.
- Pass them to reviewer as **Graph context packet(s)**.
- If changed files fall outside expected `touches.communities` / `touches.files`, ask reviewer to flag as `WARN` unless justified by AC.
- If no packets exist and Graphify is enabled, suggest `/appmaker:context "<scope topic>"` before review; don't block review.

### 3. Invoke reviewer

**Branch on `--mode` (v0.2.12):**

#### 3a. `--mode=local` (default)

Read `appmaker/config.yaml` for `review_subagent` (default `code-reviewer`). Invoke via `Agent` tool:

```
Agent(
  subagent_type: <configured>,
  description: "Review backlog item NNN-slug",
  prompt: <context package + Graph context packet(s) + review checklist>
)
```

Pass the checklist from `appmaker/skills/review/review-contract.md`. It includes code quality, constitution, glossary, AC coverage, Plan-vs-actual drift, test quality, surgical changes, security/performance, graph context, and memory regression.

#### 3b. `--mode=ultra` (v0.2.12 delegation to Claude Code built-in)

Delegate bug-finding to `/ultra-review`, then run AppMaker compliance locally (constitution, glossary, AC coverage, graph context, memory regression, plan-vs-actual drift). Combine both in one persisted review. PASS only if both pass. Fallback to local review only with explicit warning. See `appmaker/skills/review/review-contract.md`.

### 4. Capture findings — **MANDATORY persistence**

Subagent returns structured report. **Claude MUST persist via Bash tool** — DO NOT only print to chat. Past sessions showed 10 review invocations with 0 files persisted due to skipping this step.

Use the compact review template in `appmaker/skills/review/review-contract.md` for all scopes. Do not print review-only detail in chat without persisting it.

**Per scope — persistence command:**

```bash
# Backlog item review — append ## Review to backlog file.
# Item may live in appmaker/backlog/NNN-slug.md (active) OR appmaker/backlog/done/<YYYY-MM-DD>-NNN-slug.md
# (after tdd moves it). Resolve by ID, not hardcoded path. v0.2.15: per-slice review in /appmaker:next
# chain runs AFTER tdd, so target is almost always in done/.
BACKLOG_ID="NNN"  # e.g. "008" — passed as scope arg
BACKLOG_FILE=$(ls appmaker/backlog/${BACKLOG_ID}-*.md appmaker/backlog/done/*-${BACKLOG_ID}-*.md 2>/dev/null | head -1)
if [ -z "$BACKLOG_FILE" ] || [ ! -f "$BACKLOG_FILE" ]; then
  echo "✗ Backlog item ${BACKLOG_ID} not found (checked active + done/)" >&2
  exit 1
fi
cat >> "$BACKLOG_FILE" <<'REVIEW_EOF'
[compact template above]
REVIEW_EOF
test -f "$BACKLOG_FILE" && echo "✓ Review appended → $BACKLOG_FILE"

# Feature review — write to features/<NNN-slug>/review.md
mkdir -p "appmaker/features/<NNN-slug>"
cat > "appmaker/features/<NNN-slug>/review.md" <<'FEATURE_REVIEW_EOF'
# Feature Review: <NNN-slug>

[compact template above]
FEATURE_REVIEW_EOF
test -f "appmaker/features/<NNN-slug>/review.md" && echo "✓ Feature review saved"

# Diff review — save to reviews/<date>-diff-<slug>.md
mkdir -p appmaker/reviews
REVIEW_PATH="appmaker/reviews/$(date -u +%Y-%m-%d-%H%M)-diff-<slug>.md"
cat > "$REVIEW_PATH" <<'DIFF_REVIEW_EOF'
# Diff Review: <slug>

[compact template above]
DIFF_REVIEW_EOF
test -f "$REVIEW_PATH" && echo "✓ Diff review: $REVIEW_PATH"
```

**Verification before continuing:** after writing, `test -f "$path"` to confirm. If write failed, report to user — don't silently proceed to gate decision.

### 5. Gate decision

Classify findings:
- **PASS** — no critical issues; suggestions allowed
- **FAIL** — at least 1 critical issue

**On PASS:** suggest next action (`/appmaker:archive` if last slice, or next slice tdd).

**On FAIL:** surface critical issues. User decides via AskUserQuestion:
- **Fix:** address issues, re-run `/appmaker:review`
- **Override:** mark backlog item `status: done` with `review_status: failed_overridden` + reason

Never auto-mark `done` on FAIL without explicit override.

### 6. Chat reply (after persistence)

Short. Compact. The file has the detail — chat does not duplicate it.

```
✓ Review: 008-theme-context-setup → PASS (0 critical, 2 suggestions)
  Saved: appmaker/backlog/008-theme-context-setup.md
  Next:  /appmaker:tdd 009
```

If FAIL: surface the critical findings inline (1 line each) so user can decide fix-vs-override without opening the file.

## Guardrails

- **Independent reviewer mandatory.** You (generator) are NOT reviewer. Always invoke subagent via `Agent` tool.
- **Structured findings.** PASS/FAIL classification.
- **Never auto-mark `done` on FAIL.** User explicit override required.
- **Audit trail preserved.** `review_status: failed_overridden` + reason.
- **Configurable subagent.** Read `appmaker/config.yaml`.
- **Don't reinvent code review checklist.** Subagent has its own logic; provide AppMaker-specific check items.
- **Don't review own work without subagent.**
- **Don't auto-fix issues.** Surface to user.
- **Don't override silently.**
- **Don't skip AppMaker-specific checks** (constitution + glossary + AC coverage).
- **Don't skip graph context checks** when packets exist. Reviewer must compare changed files against expected touched communities/files.
- **Don't skip relevant memory wiki checks.** If a known gotcha exists, reviewer must confirm it wasn't repeated.
- **Don't bundle multiple scopes.**
- **Don't re-run review without addressing findings.**
