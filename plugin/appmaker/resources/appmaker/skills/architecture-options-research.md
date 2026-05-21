# Architecture Options Research

Use before committing to high-impact technical choices. This applies to greenfield and brownfield; greenfield often needs it more because there is no existing codebase to constrain bad choices.

## When Required

Complete this research before PRD finalization or before TDD starts when the work introduces or changes:
- architecture boundaries, storage model, data model, auth, billing, security, background jobs, external services, AI/LLM integration, deployment model
- framework/library/vendor choice
- design system or reusable UI primitive taxonomy
- irreversible migration or expensive-to-reverse workflow
- new cross-cutting abstraction

Mark `not_applicable` only for narrow fixes where the existing owner and approach are already clear.

## Research Order

1. **Local context first** — memory wiki, glossary, constitution, current code, context packets, existing decisions.
2. **Ref documentation search** — use the Ref subscription via `ref_search_documentation` for official docs, framework/library guidance, and indexed private docs.
3. **Ref URL read** — use `ref_read_url` for exact URLs returned by search before citing details.
4. **GitHub indexed resources** — use Ref GitHub resources when repository examples or internal/private repos matter. Note that Ref indexes every file for small repos and documentation files for larger repos; synced repos update on a short cron.
5. **Targeted web/GitHub fallback** — use when Ref lacks coverage, preferring official docs, source repos, release notes, ADRs, and mature examples over blog posts.

## Evidence Standard

Record the exact query, source URL, and conclusion. Do not cite a tool name alone.

Minimum artifact:

```markdown
## Architecture Options Research

**Required:** yes | no
**Status:** pending | complete | not_applicable
**Trigger:** <library choice | storage model | design-system primitive | ...>

**Sources checked**
| Source | Query / URL | Why used | Key finding |
|---|---|---|---|
| local | `rg -n "..."` | existing owner | ... |
| Ref | `ref_search_documentation: "..."` | official docs / private docs | ... |
| Ref | `https://docs...` | exact cited page | ... |
| GitHub | `<repo/example>` | mature implementation | ... |

**Options matrix**
| Option | Evidence | Pros | Cons / risks | Fit |
|---|---|---|---|---|
| Reuse existing | ... | ... | ... | best / acceptable / reject |
| Library A | ... | ... | ... | ... |
| Custom build | ... | ... | ... | ... |

**Decision**
- Chosen:
- Why:
- Rejected options:
- Reversal cost:
- Follow-up validation:
```

## Decision Rules

- At least two credible options for architecture decisions unless there is a documented constraint that leaves only one viable path.
- Prefer official docs and source repos over generic advice.
- Prefer boring, well-supported choices over novel options unless the feature specifically needs novelty.
- Custom build requires a rationale against existing libraries/framework primitives.
- New abstraction requires a real second use case or clear removal of meaningful duplication.
- If evidence is weak or sources disagree, mark the slice `human_required` or run a spike.
