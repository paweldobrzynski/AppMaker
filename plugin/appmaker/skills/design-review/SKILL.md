---
description: Visual/design compliance review for UI changes. Checks reusable CSS/component primitives, existing design standards, visual noise, interaction states, responsive behavior, and screenshot evidence.
disable-model-invocation: true
---

Design review for AppMaker UI work. Inspired by gstack `/design-review`, scoped to governance: find drift, verify screenshots, and persist a compact report.

## When to invoke

- Manual: `/appmaker:design-review [diff|backlog <NNN>|feature <NNN>|<url>]`
- Suggested whenever a slice touches UI, CSS, design-system tokens, components, or screenshots.
- AFK-safe: report-only yes; visual fixes require explicit user approval unless already requested.
- Output artifact: `appmaker/reviews/<YYYY-MM-DD>-design-<scope>.md`

## Process

### 1. Gather design context

Read:
- `appmaker/constitution.md`
- `appmaker/memory/wiki/ui-patterns.md` if present
- relevant `context_packets`
- `git diff --name-only` and UI/CSS diffs

### 2. Audit visual system

Check every touched visual element:
- reusable CSS/component primitive exists or is added deliberately
- no hardcoded inline visual styling (`style=`, `cssText`, one-off colors, spacing, radius, shadow)
- follows existing tokens, radius, spacing, typography, button/list/card/modal patterns
- default, hover, focus, active/selected, disabled, loading, error, empty, responsive/mobile states are covered
- visual noise is reduced, not increased: accent color restraint, consistent radius, limited shadows, no unnecessary motion

Hardcoded visuals without rationale are FAIL. New visual variants must be defined in CSS and documented.

### 3. Verify with screenshots

For browser UI, require screenshot evidence before/after or current-state screenshots at representative desktop/mobile widths. If no browser is available, mark BLOCKED or require human-review criteria.

If `appmaker/config.yaml` has `gstack_enabled: true`, use `gstack_browse_bin` as `$B`:

```bash
B="$(grep '^gstack_browse_bin:' appmaker/config.yaml | sed 's/^gstack_browse_bin:[[:space:]]*//')"
[ -z "$B" ] && B="$HOME/.claude/skills/gstack/browse/dist/browse"
$B status
$B screenshot --full-page --path appmaker/reviews/design-<scope>.png
$B responsive <url>
$B inspect <selector>
$B hover <selector>
```

If `gstack_required_for_ui_qa: true` and `$B status` fails, mark design review BLOCKED rather than accepting unevidenced visual claims.

### 4. Persist report

```bash
mkdir -p appmaker/reviews
REPORT_PATH="appmaker/reviews/$(date -u +%Y-%m-%d)-design-<scope>.md"
cat > "$REPORT_PATH" <<'REPORT_EOF'
# Design Review: <scope>

**Status:** PASS | FAIL | BLOCKED

| Element | Standard | Evidence | Result |
|---|---|---|---|
| Button | reusable CSS `.primary-cta` | screenshot: ... | PASS |

## Findings
- ...
REPORT_EOF
test -f "$REPORT_PATH" && echo "Design review: $REPORT_PATH"
```

## Guardrails

- Do not invent a new visual family before checking existing standards.
- Prefer reuse/extend/extract over add-new.
- Screenshot evidence is required for operator-visible UI claims.
- Design review reports problems; fixes happen only by explicit user request or follow-up backlog item.
