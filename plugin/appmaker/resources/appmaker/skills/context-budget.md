# Context Budget / MCP Audit

Use before large planning, review, AFK, or agent-heavy work. The goal is to prevent context rot and unnecessary per-turn MCP schema cost.

## When Required

- Work will spawn subagents, run AFK, or perform large review/planning.
- The session already read many large files or tool outputs.
- Heavy MCP servers are enabled, especially browser/playwright, OS helpers, database admin tools, or project-stale servers.
- Ref, GitHub, Graphify, or web research will be used repeatedly.

## Pre-flight MCP audit

Record:
- MCP servers enabled in this client/session.
- Which servers are needed for the current slice.
- Servers to disable or avoid until needed.
- Whether Ref is needed for Architecture Options Research.

MCP schema cost is paid every turn when the server is enabled in the runtime, even if the tool is not called. Prefer enabling only the servers needed for the current phase.

## Context degradation

| Tier | Signal | Behavior |
|---|---|---|
| OK | Fresh or focused session | Normal reads; still prefer context packets |
| Heavy | Many broad reads or large tool results | Read summaries/frontmatter, delegate side work, avoid pasting full artifacts |
| Poor | Vague reasoning, skipped protocol steps, repeated broad search | checkpoint, write artifact, stop adding context |

## AppMaker Rules

- Use `appmaker/context/*.md` packets instead of repeatedly rediscovering the same codebase context.
- Prefer `rg` summaries and targeted file reads over dumping large files.
- Before enabling browser/playwright or OS MCPs, confirm the slice actually needs them.
- For Ref, prefer precise `ref_search_documentation` queries and `ref_read_url` on selected results, not broad repeated searches.
