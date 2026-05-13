# Memory Schema

Memory wiki captures durable project knowledge. It is not a transcript store.

## Page Header

Each `wiki/*.md` page should use:

```markdown
---
last_updated:
last_updated_by:
source_artifacts: []
confidence: medium
---
```

## Entry Format

```markdown
## <Topic>

What changed / what we learned.

Evidence:
- `appmaker/features/archive/.../retro.md`
- `appmaker/context/...md`

Confidence: high | medium | low
```

## Confidence

- `high` — confirmed by code/tests/docs
- `medium` — inferred from multiple artifacts
- `low` — plausible, needs future confirmation

## Rules

- Do not paste raw `graph.json`, logs, or large transcripts.
- Do not store secrets.
- Do not turn one-off implementation details into durable truth.
- Prefer small sections over long essays.
- When stale, mark stale instead of deleting unless obviously wrong.
