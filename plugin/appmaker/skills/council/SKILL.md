---
description: Go/no-go decision gate for ambiguous strategic forks. Convenes a four-voice council (in-context Architect + Skeptic/Pragmatist/Critic as fresh subagents) over one explicit decision, then persists a verdict (SHIP/NEEDS_WORK/BLOCKED) to appmaker/decisions/. Use between PRD and decompose when multiple credible paths exist and no obvious winner. Not code review, not implementation planning.
disable-model-invocation: true
---

Decision gate for **ambiguity**, not correctness. Adapted from ECC `council` (MIT), reshaped as an AppMaker governance gate: it writes a durable decision artifact and a SHIP/NEEDS_WORK/BLOCKED verdict, and feeds material decisions into `memory/decisions.md`.

Fills the structural gap between discovery (`grill`/`interview`/`prd`) and planning (`decompose`): before slicing a PRD whose approach has unresolved strategic forks, force the disagreement to be legible. The value is not unanimity — it is surfacing dissent before commitment.

**Provider-agnostic.** The three external voices run as fresh subagents of the configured type (`council_subagent`, default `general-purpose`). Anti-anchoring = they get only the question + compact context, never the conversation transcript.

**Output style:** Follow the **Compact report contract** and **Verdict vocabulary** in `appmaker/skills/output-style.md`. Decision verdict is `SHIP | NEEDS_WORK | BLOCKED` — never PASS/FAIL.

## When to invoke

- Manual: `/appmaker:council "<decision question>"` or `/appmaker:council` then describe.
- Suggested by `next`: when a PRD exists, no decomposition yet, and an unresolved strategic fork is present (Architecture Options Research `pending` on a strategic trigger, or an unresolved `human_required` gray area). Advisory, not a hard block — user may skip straight to `decompose`.
- Auto: never (side-effect skill, `disable-model-invocation: true`).
- AFK-safe: NO — convening + synthesis is a human-facing judgment gate.
- Required state: any; richer with `appmaker/` present. Persists artifact only if `appmaker/` exists.
- Required input: one decision question (verbal or written).

## When NOT to use

| Instead of council | Use |
|---|---|
| Is this implementation correct / does it have bugs | `/appmaker:review` |
| Break a PRD into slices | `/appmaker:decompose` |
| Sharpen a vague idea one question at a time | `/appmaker:grill` |
| A straight factual question | answer it directly |
| An obvious choice with a conventional default | just pick it |

## Process

### 0. Pre-flight: read memory wiki (advisory)

Surface durable decisions so the council doesn't relitigate settled context.

```bash
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in architecture domain-model; do
    f="appmaker/memory/wiki/${page}.md"
    [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ] && { echo "─── $f ───"; cat "$f"; }
  done
  [ -f appmaker/memory/decisions.md ] && cat appmaker/memory/decisions.md
fi
```

### 1. Extract the real question

Reduce to one explicit prompt: what are we deciding? what constraints bind? what counts as success? If vague, ask **one** clarifying question (AskUserQuestion) before convening.

### 2. Gather only necessary context

Compact. For codebase-specific decisions: the relevant files/snippets/metrics + `appmaker/constitution.md` + any linked context packet. For strategic decisions: skip repo dumps unless they change the answer. Read `appmaker/glossary.md` so voices use canonical terms.

### 3. Form the Architect position first

Before launching voices, write your own initial position: 3 strongest reasons + the main risk in your preferred path. Do this first so synthesis doesn't just mirror the subagents.

### 4. Launch three independent voices in parallel

Read `council_subagent` from `appmaker/config.yaml` (default `general-purpose`). Launch all three in one batch via the `Agent` tool — each gets ONLY the question + compact context + its role, never the transcript:

```
Agent(subagent_type: <council_subagent>, description: "Council: <Skeptic|Pragmatist|Critic>", prompt: <below>)
```

```text
You are the [ROLE] on a four-voice decision council.

Question: [decision question]
Constraints: [what binds]   Success = [what counts]
Context: [only the relevant snippets/constraints]

Respond with:
1. Position — 1-2 sentences
2. Reasoning — 3 concise bullets
3. Risk — biggest risk in your recommendation
4. Surprise — one thing the other voices may miss
Be direct. No hedging. Under 300 words.
```

Role emphasis:
- **Skeptic** — challenge the framing, question assumptions, propose the simplest credible alternative.
- **Pragmatist** — shipping speed, user impact, operational reality.
- **Critic** — downside risk, edge cases, failure modes.

### 5. Synthesize with bias guardrails

- Don't dismiss an external view without saying why.
- If an external voice changed your recommendation, say so explicitly.
- Always include the strongest dissent, even if you reject it.
- Two voices aligning against your initial position = real signal; weight it.
- Keep raw positions visible before the verdict.

### 6. Decide verdict + confidence

- `SHIP` — proceed with the recommended path. **Requires** provenance `confidence` ≥ `council_min_confidence` (config, default `file_verified`). A SHIP resting only on `model_assertion` is downgraded to `NEEDS_WORK`.
- `NEEDS_WORK` — named gaps must close first (more grill/research/prd). List them.
- `BLOCKED` — cannot proceed: external dependency, missing input, or non-delegable human judgment (constitution rule 6).

### 7. Persist — MANDATORY when `appmaker/` exists

Write to `council_report_dir` (default `appmaker/decisions/`). **Persist via Bash, don't only print.**

```bash
mkdir -p appmaker/decisions
SLUG="monorepo-vs-polyrepo"   # kebab, derived from decision title
DEC_PATH="appmaker/decisions/$(date -u +%Y-%m-%d)-${SLUG}.md"
cat > "$DEC_PATH" <<'COUNCIL_EOF'
---
scope: <feature 003-foo | project>
verdict: SHIP | NEEDS_WORK | BLOCKED
created: 2026-06-02
provenance:
  author: appmaker:council
  created: 2026-06-02
  source: <prd.md path | conversation>
  confidence: file_verified
---

# Council: <short decision title>

**Decision:** <one-line question>   |   **Verdict:** <SHIP|NEEDS_WORK|BLOCKED>

**Architect:** <1-2 sentence position> — <1 line why>
**Skeptic:** <position> — <why>
**Pragmatist:** <position> — <why>
**Critic:** <position> — <why>

## Verdict
- **Consensus:** <where they align>
- **Strongest dissent:** <most important disagreement>
- **Premise check:** <did the Skeptic challenge the question itself?>
- **Recommendation:** <synthesized path>
- **Gaps (if NEEDS_WORK) / Blocker (if BLOCKED):** <named items or (none)>
COUNCIL_EOF
test -f "$DEC_PATH" && echo "✓ Council decision → $DEC_PATH"
```

If the decision is hard-to-reverse AND surprising-without-context (Matt's filter), also append a 4-line entry to `appmaker/memory/decisions.md` in that file's documented format. Otherwise don't — not every council is a durable decision.

### 8. Chat reply (after persistence)

Compact. Verdict + recommendation + handoff.

```
✓ Council: monorepo-vs-polyrepo → SHIP (confidence: file_verified)
  Saved: appmaker/decisions/2026-06-02-monorepo-vs-polyrepo.md
  Strongest dissent: Critic — shared CI blast radius.
  Next:  /appmaker:decompose
```

On `NEEDS_WORK`/`BLOCKED`: surface the gaps/blocker inline (1 line each) so the user can act without opening the file.

## Guardrails

- **Anti-anchoring mandatory.** External voices get the question + compact context only — NEVER the conversation transcript.
- **Architect position first.** Write your own stance before reading subagent output.
- **Surface dissent.** Strongest disagreement always visible; hiding it defeats the gate.
- **Decision vocabulary only.** `SHIP`/`NEEDS_WORK`/`BLOCKED` — never PASS/FAIL (that's quality gates).
- **SHIP needs evidence.** Honor `council_min_confidence`; downgrade unverified SHIP to NEEDS_WORK.
- **Provider-agnostic.** Read `council_subagent`; never hardcode a vendor.
- **Persist only real artifacts.** Write the decision file in a project; append to `memory/decisions.md` ONLY for hard-to-reverse + surprising decisions.
- **One decision per invocation.** Don't bundle multiple forks.
- **Don't use council for code review, implementation planning, or obvious choices.**
- **Default one round.** A second round keeps the Skeptic clean to preserve anti-anchoring value.
