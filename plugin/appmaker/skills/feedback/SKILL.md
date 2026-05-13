---
description: Quick QA/user feedback capture into AppMaker backlog. Use when user reports a bug, QA note, UX complaint, missing behavior, or small improvement that should become a durable backlog item.
disable-model-invocation: true
---

Feedback capture. Lightweight QA session -> backlog item. No full PRD unless scope grows.

## When to invoke

- Manual: `/appmaker:feedback "<description>"`
- Suggested by `diagnose`, `review`, or user QA reports
- AFK-safe: yes after user report; writes backlog item
- Required state: `appmaker/backlog/`
- Required input: feedback description

## Process

### 1. Capture user report

Ask at most 3 clarifying questions:
1. expected vs actual
2. steps to reproduce or where seen
3. severity / frequency

If clear enough, don't over-interview.

### 2. Classify

Labels:
- `bug`
- `feedback`
- `ux`
- `refactor`
- `documentation`
- `feature`

Execution class:
- `human_required` if identity/money/legal/security/design judgment
- `autonomous` if clear behavior fix
- `conditional` if needs runtime confirmation

### 3. Read context lightly

Read glossary + constitution. If brownfield area matters and packet exists, link it. If missing and high-risk, suggest `/appmaker:context "<topic>"`; don't block capture.

### 4. Write backlog item

Use next backlog ID. Save:
`appmaker/backlog/<NNN>-<slug>.md`

Frontmatter:

```yaml
---
id: 012
slug: login-error-message
status: open
labels: [bug, feedback]
execution_class: autonomous
blocked_by: []
traces_to: []
feature:
user_stories_covered: []
context_packets: []
touches:
  communities: []
  files: []
created: 2026-05-11
source: feedback
---
```

Body:

```markdown
# 012: Login Error Message

## Parent

Ad-hoc feedback.

## What happened

## Expected behavior

## Steps to reproduce

## Acceptance criteria

- [ ] [Behavioral criterion]

## Blocked by

None — can start immediately.
```

### 5. Output

```
✓ Feedback captured: appmaker/backlog/012-login-error-message.md
  Labels: bug, feedback
  execution_class: autonomous
  Suggested next: /appmaker:diagnose 012 OR /appmaker:tdd 012
```

## Guardrails

- **Keep feedback durable.** Behavior language, not implementation guesses.
- **Reproduction steps mandatory for bugs** unless user cannot provide them.
- **No file paths in title/what-to-build.** Paths can go under context/touches only.
- **Don't create full feature folder** unless feedback becomes a larger feature.
- **Don't publish to GitHub.** Local backlog default; `/appmaker:sync-github` future adapter.
- **Don't over-question.** Max 3 clarifying questions before capture.
