# Raw Memory Inputs

User-owned drop folder for source material that should land in pre-flight context BEFORE being synthesized into wiki.

Per Karpathy/Cole compiler analogy: this is source code. Wiki pages (`memory/wiki/*.md`) are the compiled executable. `/appmaker:archive` retro + manual edits do the compile.

## What to drop here

- short incident notes ("postgres pool exhaustion 2026-04-12")
- review excerpts worth keeping verbatim
- user-provided decisions (paste from Slack / email)
- relevant logs with secrets removed
- transcripts / paper excerpts when researching a feature
- snippets you want pre-flight skills to surface ("read this before deciding X")

## Lifecycle

- **You drop**: any markdown file. Use date-prefix for ordering: `2026-05-14-postgres-pool.md`.
- **Compile (manual or via archive retro)**: extract durable synthesis into `memory/wiki/<area>.md`. Drop raw file or leave for audit trail.
- **Audit (via `/appmaker:checklist memory`)**: warns if raw entries grow stale without promotion.

## Not allowed

- secrets / credentials / tokens
- raw `graph.json` (use `appmaker/context/` packets instead)
- full chat dumps by default (pull the high-signal snippets)
- generated build output / lint logs
