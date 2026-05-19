# Status Telemetry + Refinement

Optional, best-effort additions for `/appmaker:status`. Fail silently when unavailable.

## Token usage telemetry

Reads Claude Code internal logs at `~/.claude/projects/<dashes-path>/*.jsonl`. Format is not public-stable; omit the row on parse errors or missing `jq`.

Formula per assistant message:

```text
input_tokens + cache_creation_input_tokens + cache_read_input_tokens + output_tokens
```

This is token volume, not dollar cost. Cache reads are cheaper than fresh input.

## Agent View hint

If multiple session logs were modified in the last 24h, show:

```markdown
**Multi-session view:** `cloud agents`
```

Omit when only one recent session exists.

## Refined next suggestion

Deterministic filesystem state always wins. LLM-grounded refinement only adds a note when there is real divergence:

- latest review has open `critical` finding → suggest fixing review first
- recent commit mentions a different slice ID → mention divergence
- most recently modified backlog item differs → mention divergence
- git status has unstaged changes touching a slice → suggest `/appmaker:review diff`

If deterministic and signals agree, emit no refinement section.
