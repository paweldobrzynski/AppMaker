---
description: Brownfield questioning skill for stress-testing a plan against existing code, Graphify context packets, glossary, constitution, and memory wiki before PRD/decomposition. Use when user wants to change an existing project or says the current codebase matters.
disable-model-invocation: false
---

Brownfield grill. Matt Pocock `grill-with-docs` adapted to AppMaker: ask one hard question at a time, but first read project reality.

## When to invoke

- Manual: `/appmaker:grill-brownfield "<topic>"`
- Suggested by `start` for brownfield feature/refactor/research work
- AFK-safe: NO — interactive questioning
- Required state: existing codebase; works best after `/appmaker:init`
- Required input: topic/change intent

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

Brownfield depends most on prior knowledge — read **all wiki pages**, not lazy subset. Cite as `per wiki/<page>.md: ...`. If wiki and code diverge, raise the conflict in your output instead of trusting either silently.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in architecture domain-model feature-index integration-gotchas testing; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

If wiki is empty (first brownfield call), proceed but flag: "no prior wiki context — first session will seed the wiki from this grilling." Subsequent calls should find the seeded content.

### 1. Read project reality

Read in parallel:
- `appmaker/config.yaml`
- `appmaker/constitution.md`
- `appmaker/glossary.md`
- `appmaker/memory/index.md`
- relevant `appmaker/memory/wiki/*.md`
- latest related `appmaker/context/*.md`

If no packet exists and codebase context matters, suggest:

```
/appmaker:context "<topic>"
```

Do not block; fallback to targeted file reads if user wants to continue.

### 2. Find contradictions

Compare user plan against:
- glossary terms
- domain invariants
- architecture notes
- Graphify communities/touched files
- existing PRDs/decompositions if similar feature exists

Surface contradictions immediately:

```
Your glossary defines "Policy Threshold" as insurer-owned config, but this plan lets claim handlers edit it. Which is true?
Recommendation: keep thresholds insurer-owned; add handler override as separate audited concept.
```

### 3. Ask one question at a time

Pattern:

```
Q: [specific decision point grounded in current system]
Recommendation: [proposed answer + why]
Evidence: [glossary/memory/context packet/file path]
```

Wait for answer. Update mental model. Continue.

### 4. Capture byproducts

When resolved:
- glossary term changes -> update `appmaker/glossary.md`
- durable architectural insight -> append candidate note to `appmaker/memory/wiki/architecture.md`
- domain model insight -> append candidate note to `appmaker/memory/wiki/domain-model.md`
- open risk -> note for PRD `Existing System Context`

Do not create PRD here. Suggest `/appmaker:interview` or `/appmaker:prd` when ready.

## Output

Conversation only, plus optional small updates to glossary/memory wiki when a term or durable lesson is resolved.

```
Brownfield grill summary:
- Resolved: tenant routing uses subdomain, not user profile.
- Risk: billing community touches auth callback.
- Context packet: appmaker/context/2026-05-11-tenant-routing.md
- Suggested next: /appmaker:prd appmaker/features/003-tenant-routing
```

## Guardrails

- **Explore before asking.** Don't ask user for facts code/docs can answer.
- **One question per turn.** No batches.
- **Recommendation mandatory.** Every question includes proposed answer.
- **Evidence mandatory.** Brownfield questions cite docs, memory, context packet, or file path.
- **Don't over-write memory.** Append candidate notes; avoid rewriting wiki pages during live grill unless user confirms.
- **Don't turn graph neighbors into scope.** Graphify informs risk; PRD/AC decides scope.
- **Don't create PRD/backlog here.** This skill sharpens understanding only.
