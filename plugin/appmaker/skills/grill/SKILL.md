---
description: General-purpose relentless interview tool. Sharpen any idea (feature, blog post, technical decision, business question) by walking decision tree one question at a time. For each question, provide recommended answer. Output enriches conversation context, NO specific artifact written. Use when user wants to stress-test plan, clarify thinking, or mentions "grill me".
disable-model-invocation: false
---

Adopted from Matt Pocock `productivity/grill-me` skill (MIT). Fundamental thinking aid — works on anything user wants to sharpen.

## When to invoke

- Manual: user types `/appmaker:grill "<topic>"` or `/appmaker:grill` then describes
- Auto: invoked by `interview` skill (greenfield) and `grill-brownfield` (brownfield variant)
- AFK-safe: NO — interactive interview requires human responses
- Required state: any (works without `appmaker/` setup; richer with glossary/constitution present)
- Required input: topic (verbal or written)

## Core instructions

Interview user relentlessly about every aspect of the plan/idea until shared understanding reached. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one.

**For each question, provide your recommended answer.** Don't just ask — propose. User confirms, rejects, or refines.

**Ask questions one at a time.** No batched lists. Wait for answer before next question.

**If question can be answered by exploring codebase, explore first.** Don't ask user for facts agent can read directly.

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

Before grilling, surface durable project knowledge so questions don't re-litigate settled context. Cite as `per wiki/<page>.md: ...` when content drives a question. If wiki contradicts user's framing, raise the conflict — don't silently agree.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"  # auto|always|never; auto currently behaves like always until context-aware signal exists
if [ "$WIKI_MODE" != "never" ]; then
  for page in architecture domain-model; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

Greenfield projects often have empty wiki — that's OK, proceed with defaults. Brownfield with empty wiki = soft signal to suggest `/appmaker:grill-brownfield` instead.

### 1. Receive topic

If user invoked without arg, ask via AskUserQuestion: "What topic do you want to grill?"

### 2. Read context (parallel)

- `appmaker/glossary.md` if exists → use canonical terms, don't invent synonyms.
- `appmaker/constitution.md` if exists → respect project rules in recommendations.
- If Graphify available, query relevant neighborhood for the topic — saves tokens vs grep/glob.

### 3. Map decision tree

Identify branches: what decisions are independent vs dependent? Order by dependency (resolve roots first, leaves last). Don't tell user the tree — just navigate it.

### 4. Walk tree, one question at a time

Pattern per question:
```
Q: [specific decision point]
Recommendation: [proposed answer + 1-line why]
```

Use AskUserQuestion tool per question. Update mental model. Move to next question.

### 5. Detect closure

Stop when:
- All branches resolved.
- User explicit "satisfied" / "done grilling" / "enough".
- Diminishing returns (last 2 questions had user say "doesn't matter").

### 6. Glossary update (two-tier, v0.2.11)

After grilling closes:

**Tier 1 — Deterministic** (if grilling produced a written artifact, e.g. session notes):
```bash
# When grill produces no artifact (pure conversation), skip Tier 1 — go directly to Tier 2.
bash appmaker/hooks/glossary-extract.sh "<artifact-path-if-any>"
```

**Tier 2 — Semantic review** (primary path for `grill` since conversations rarely write artifacts):
Suggest `/appmaker:glossary` with conversation context. New domain terms surface as resolved entries only when the user invokes it (best-effort, depends on conversation richness). NOT deterministic — user confirms ambiguous cases.

```
Glossary: +N terms (X, Y, Z), M ambiguities flagged.
```

## Output

NO specific artifact written. Output = enriched conversation context (questions + answers collocated). Other commands (`interview`, `prd`, `decompose`) consume this when invoked next.

If user wants persistent capture: suggest `/appmaker:interview` (structured feature output) or save manually.

## Difference from `/appmaker:interview`

| | grill | interview |
|---|---|---|
| Purpose | Sharpen any idea | Define feature |
| Output | Conversation only | `interview-result.md` artifact |
| Folder allocation | No | Yes (`features/<NNN-slug>/`) |
| Greenfield/brownfield branch | No | Yes (calls grill or grill-brownfield) |
| Readiness gate | No | Yes (4-state enum) |

## Guardrails

- **Recommendations mandatory.** Every question paired with proposed answer + 1-line why.
- **One question per turn.** Batched questions reduce response quality + lose dependency ordering.
- **Explore over ask.** Read code, glossary, constitution before asking facts agent can verify.
- **Reference glossary terms.** If glossary has "materialize", don't invent synonyms.
- **Stop when done.** Don't pad with low-value questions.
- **Don't write artifacts here.** Grill is conversation enrichment.
- **Don't classify topic.** Grill works on anything. Classification is `start` skill's job.
