---
description: Diff-aware QA pass for AppMaker work. Reads the slice QA / Smoke Plan, inspects git diff, runs targeted manual/browser checks, records evidence, and writes a compact QA report.
disable-model-invocation: true
---

Diff-aware QA. Inspired by gstack `/qa`, but AppMaker defaults to report-first unless the user explicitly asks to fix findings.

## When to invoke

- Manual: `/appmaker:qa [backlog <NNN>|feature <NNN>|diff|<url>]`
- Suggested after `/appmaker:review` PASS, before archive, or when UI/API behavior needs live smoke.
- AFK-safe: report-only yes; fixes require explicit user approval.
- Output artifact: `appmaker/qa/<YYYY-MM-DD>-<scope>.md`

## Process

### 1. Determine scope

Default to `diff`. If a backlog item is named, read its `## QA / Smoke Plan`, `## Approved TDD Plan`, and `## Execution Record`.

### 2. Build diff map

Use git first:

```bash
git status --short
git diff --name-only
git diff --stat
```

Classify touched surfaces: UI/browser, API, domain logic, data/schema, docs, build/deploy. For UI/browser work, QA must include browser execution and screenshot evidence unless impossible; if impossible, write the blocker.

### 2a. gstack browser adapter

If `appmaker/config.yaml` has `gstack_enabled: true`, use `gstack_browse_bin` as `$B`.

```bash
B="$(grep '^gstack_browse_bin:' appmaker/config.yaml | sed 's/^gstack_browse_bin:[[:space:]]*//')"
[ -z "$B" ] && B="$HOME/.claude/skills/gstack/browse/dist/browse"
$B status
```

For UI/browser QA, prefer:
- `$B goto <url>`
- `$B snapshot -i`
- `$B screenshot --full-page --path appmaker/qa/<scope>.png`
- `$B responsive <url>`
- `$B console --errors`
- `$B network`

If `gstack_required_for_ui_qa: true` and `$B status` fails, mark QA BLOCKED rather than falling back silently.

### 3. Run checks

- Execute the project's configured test/lint commands when relevant.
- For UI: open the app or provided URL, exercise the changed flow, capture screenshot evidence for default/hover/focus/active/disabled/error/responsive states touched by the diff. Use gstack when enabled.
- For API/domain: run the narrowest command proving changed behavior plus one backward-compat check.
- For docs-only: verify links/commands/examples that changed.

Do not silently widen scope. If QA finds a bug outside the diff, record it under "Adjacent finding" and suggest `/appmaker:feedback`.

### 4. Persist report

```bash
mkdir -p appmaker/qa
QA_PATH="appmaker/qa/$(date -u +%Y-%m-%d)-<scope>.md"
cat > "$QA_PATH" <<'QA_EOF'
# QA: <scope>

**Status:** PASS | FAIL | BLOCKED

| Surface | Check | Evidence | Result |
|---|---|---|---|
| UI | notes edit modal smoke | screenshot: appmaker/qa/...png | PASS |

## Findings
- ...
QA_EOF
test -f "$QA_PATH" && echo "QA report: $QA_PATH"
```

## Guardrails

- Evidence before claims: tests/browser output/screenshots first, then PASS/FAIL.
- Report-first by default. Fix only when the user asked for QA+fix.
- Every FAIL needs a reproduction step.
- Every fixed QA finding needs a regression test or explicit manual check in the report.
