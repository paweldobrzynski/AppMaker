# Context Packet Template

Small, citable context artifact produced by `/appmaker:context`.

Context packet is NOT memory and NOT source of truth. It is a snapshot of codebase context used for one feature, slice, review, or investigation.

## Template

```markdown
---
id: 2026-05-11-claim-scoring
topic: claim scoring pipeline
source: graphify                  # graphify | standard
generated: 2026-05-11T10:00:00Z
graphify_out_dir: graphify-out
queries:
  - graphify query "claim scoring pipeline"
  - graphify path "ClaimSignal" "PolicyThreshold"
related_feature:
related_backlog_item:
---

# Context Packet: Claim Scoring Pipeline

## Summary

[3-6 bullets. What matters for current task.]

## Relevant Communities

| Community | Why it matters | Confidence |
|---|---|---|
| claim-scoring | Owns score calculation and BPS output | high |
| policy-thresholds | Downstream threshold decisions | medium |

## Key Files

| File | Why relevant | Read? |
|---|---|---|
| `src/scoring/rules.ts` | Rule evaluator | yes |
| `src/signals/claim-signals.ts` | Signal extraction | yes |

## Architecture Options Research

| Source | Query / URL | Why used | Key finding |
|---|---|---|---|
| local | `rg -n "..."` | existing project context | ... |
| Ref | `ref_search_documentation: "..."` | official docs / indexed resources | ... |
| GitHub | `<repo/example>` | mature implementation | ... |

## Canonical Values / Hardcoded Contracts

| Value or contract | Search evidence | Consumers / mirrors | Confidence |
|---|---|---|---|
| `PolicyThreshold` | `rg -n "PolicyThreshold|policy threshold" src tests` | scoring, admin UI, docs | medium |

## Dependency Surfaces

| Surface | Reads | Writes | Side effects | Notes |
|---|---|---|---|---|
| domain / API / UI / jobs / tests / docs | ... | ... | ... | ... |

## Reuse / Refactor-First Candidates

| Existing code | Why candidate | Reuse / extend / extract / replace / add-new? | Confidence |
|---|---|---|---|
| `src/scoring/rules.ts` | owns adjacent scoring behavior | extend | medium |

## Visual System / CSS Reuse

| Visual primitive | Existing CSS/component | Hardcoded visuals found | Confidence |
|---|---|---|---|
| button / card / row / modal / badge | `.app-btn`, `.app-card`, etc. | `style=`, `cssText`, inline colors/sizes | medium |

## Design Standards Compliance

| Element | Existing standard / pattern | States to verify | Gap |
|---|---|---|---|
| button / card / row / modal / badge | tokens, component inventory, UI pattern docs | hover/focus/disabled/loading/error/responsive | none / describe |

## Graph Relationships

| Relationship | Evidence | Confidence |
|---|---|---|
| `ClaimSignal` -> `PolicyThreshold` | `graphify path` | medium |

## Risks / Constraints

- [Risk or constraint derived from graph context.]

## Open Questions

- [Question for human or future `/appmaker:grill-brownfield`.]

## Source Notes

- Graphify data is read-only context. Treat inferred/ambiguous edges as hypotheses until code/docs confirm.
- Do not copy `graph.json` here. Keep packet small.
```

## Field Semantics

| Field | Required | Notes |
|---|---|---|
| `id` | yes | Date + topic slug. Unique enough for `appmaker/context/`. |
| `topic` | yes | User query or derived feature/slice topic. |
| `source` | yes | `graphify` if graph data used; `standard` if fallback file discovery. |
| `generated` | yes | ISO timestamp. |
| `queries` | yes | Exact Graphify/file-search operations used. |
| `related_feature` | optional | Feature folder slug if known. |
| `related_backlog_item` | optional | Backlog ID if known. |

## Rules

- Keep under ~120 lines.
- Cite exact Graphify queries and key files.
- Preserve confidence. Never upgrade `inferred`/`ambiguous` relationships to fact without code/doc evidence.
- Use packet paths in PRD/decomposition/backlog/review instead of re-deriving same context.
