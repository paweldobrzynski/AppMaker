---
description: Compact context retrieval for codebase questions. Uses Graphify data when available, falls back to standard file discovery, and writes small context packets to appmaker/context/ for PRD/decompose/TDD/review reuse. Invoked by other commands when they need codebase awareness. User can invoke manually for ad-hoc queries.
disable-model-invocation: true
---

Codebase context retrieval. Graphify = read-only intelligence layer. AppMaker persists only small context packets, never raw graph state.

## When to invoke

- Workflow: invoked or suggested by `grill`, `interview`, `prd`, `decompose`, `diagnose`, `tdd`, `review` when they need codebase context
- Manual: `/appmaker:context "<topic>"` for ad-hoc queries
- Optional flags: `--no-save` (print only), `--feature <NNN-slug>`, `--backlog <NNN>`
- AFK-safe: yes (read-only codebase access, writes context packet unless `--no-save`)
- Required state: project filesystem accessible
- Required input: topic string
- Output artifact: `appmaker/context/<YYYY-MM-DD>-<topic-slug>.md` unless `--no-save`

## Process

### 1. Detect context mode

Read:
- `appmaker/config.yaml` for `graphify_enabled`, `graphify_out_dir`, `graphify_context_packet_dir`
- `<graphify_out_dir>/GRAPH_REPORT.md`
- `<graphify_out_dir>/graph.json`

Check Graphify CLI availability with a small command discovery (`graphify --help` or equivalent).

If config enables Graphify + report exists + graph exists + CLI exists → **Graphify mode**. Else → **standard mode**.

### 2a. Graphify mode

Use Graphify's public surface. Do not reimplement graph traversal.

1. Read `<graphify_out_dir>/GRAPH_REPORT.md` first: communities, god nodes, surprising connections.
2. Run `graphify query "<topic>"`.
3. If two named concepts matter, run `graphify path "<A>" "<B>"`.
4. If one module/concept is central, run `graphify explain "<concept>"`.
5. Read source files only for highest-relevance nodes (normally 3-5 files).
6. Mark confidence/provenance. Treat inferred/ambiguous relationships as hypotheses until code/docs confirm.
7. Write context packet using `appmaker/templates/context-packet-template.md`.
8. Return packet path + key files + short summaries + graph communities.

Token budget: aim for <2k tokens.

### 2b. Standard mode

1. Read `README.md`, `package.json` (or equivalent) for project shape.
2. Use Glob for likely file patterns based on topic keywords.
3. Use Grep for keyword search (skip node_modules, vendor, .git).
4. Read top 3-5 highest-relevance files.
5. Write context packet with `source: standard`.
6. Return packet path + key files + short summaries.

Token budget: aim for <5k tokens.

### 3. Context packet — **MANDATORY persistence**

Default packet dir: `appmaker/context/` unless config overrides `graphify_context_packet_dir`.

**Claude MUST persist via Bash tool** — DO NOT only print packet content to chat. Past sessions showed 9 context invocations with 0 packets persisted due to skipping this step.

Persist via Bash tool (use heredoc):
```bash
mkdir -p appmaker/context
PACKET_PATH="appmaker/context/$(date -u +%Y-%m-%d)-<topic-slug>.md"
cat > "$PACKET_PATH" <<'PACKET_EOF'
---
id: <date>-<topic-slug>
topic: <topic>
source: graphify  # or "standard"
generated: <ISO timestamp>
graphify_out_dir: graphify-out
queries:
  - graphify query "<topic>"
  - graphify path "A" "B"  # if used
related_feature: <NNN-slug or empty>
related_backlog_item: <NNN or empty>
---

# Context Packet: <topic>

## Summary
[3-6 bullets — what matters for current task]

## Relevant Communities
| Community | Why it matters | Confidence |
|---|---|---|
| ... | ... | high/medium/low |

## Key Files
| File | Why relevant | Read? |
|---|---|---|
| `path/to/file.ts` | ... | yes/no |

## Canonical Values / Hardcoded Contracts
| Value or contract | Search evidence | Consumers / mirrors | Confidence |
|---|---|---|---|
| ... | `rg -n "..." ...` | ... | high/medium/low |

## Dependency Surfaces
| Surface | Reads | Writes | Side effects | Notes |
|---|---|---|---|---|
| domain / API / UI / jobs / tests / docs | ... | ... | ... | ... |

## Reuse / Refactor-First Candidates
| Existing code | Why candidate | Reuse / extend / extract / replace / add-new? | Confidence |
|---|---|---|---|
| ... | ... | ... | high/medium/low |

## Graph Relationships (Graphify mode only)
| Relationship | Evidence | Confidence |
|---|---|---|
| `A` → `B` | `graphify path` | medium |

## Risks / Constraints
- ...

## Open Questions
- ...

## Source Notes
- Graphify data is read-only context. Treat inferred/ambiguous edges as hypotheses.
PACKET_EOF

echo "✓ Context packet: $PACKET_PATH"
```

**Verification before returning:** `test -f "$PACKET_PATH"` to confirm. Return packet path to caller (other skill or user). Without persistence, downstream commands can't reference packet via `context_packets` field.

Packet captures:
- exact topic/query
- source mode (`graphify` or `standard`)
- Graphify commands or file-search operations used
- relevant communities
- key files
- canonical values / hardcoded contracts when the topic touches brownfield behavior
- dependency surfaces across domain/API/UI/jobs/tests/docs
- reuse / refactor-first candidates so new code is justified instead of automatic
- graph relationships
- risks/constraints
- open questions

Downstream commands consume packet path instead of re-querying broad context.

### 4. Cache hint

If standard mode was used and topic is broad or repeated, suggest:

```
Graphify not available. Consider enabling:
  graphify .
  graphify claude install
Then re-run /appmaker:context "<topic>"
```

Never auto-install.

## Output format

```markdown
## Context: <topic>

**Source:** Graphify graph (4041 nodes, 185 communities)  -- OR --
**Source:** Standard file discovery (no Graphify)
**Packet:** appmaker/context/2026-05-11-auth-tenancy.md

### Relevant files
- `src/auth/middleware.ts` — extracts tenant from subdomain
- `src/auth/jwt.ts` — JWT augmentation with tenant claim
- `lib/db/rls.sql` — Supabase RLS policies on tenant_id

### Community context (Graphify mode only)
- **Auth & tenancy** community: 12 files, central concepts: tenant, JWT, RLS

### Risks / constraints
- Auth changes may affect Supabase RLS assumptions.

### Token cost
~1.2k tokens (Graphify mode)
```

## Guardrails

- **Graphify is read-only input.** AppMaker does not own or mutate graph data.
- **Use Graphify CLI/report first.** Don't hand-parse `graph.json` unless implementing checklist-level validation.
- **Persist small packets.** Save useful context to `appmaker/context/`; don't save raw Graphify output.
- **Don't dump full files.** Return paths + summaries. Caller decides what to read.
- **Don't query Graphify if not installed.** Fall back gracefully.
- **Don't pretend Graphify accuracy in standard mode.** Mark `Source: Standard`.
- **Don't treat inferred graph edges as facts.** Mark confidence and confirm in code/docs before decisions.
- **Respect token budget.** If query too broad, return "topic too broad — narrow to: X, Y, Z?"
- **Don't auto-install Graphify.** Hint, never auto-install (privacy + cost).
- **Don't read entire file trees.** Pre-filter.
- **Don't return raw grep output.** Summarize per file.
- **Don't recursively call other commands.**
- **Don't cache raw results across sessions.** Context packets are snapshots; refresh when stale.
