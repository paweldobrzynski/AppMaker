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

### 2b. Build Brownfield Impact Audit seed

Before asking implementation-shaping questions, assemble the first-pass dependency map. This prevents the common brownfield failure mode: changing the obvious file and missing hardcoded dependents elsewhere.

Cover these angles and cite evidence:
- **Reuse / refactor-first candidates:** existing owners/helpers/components that could be reused, extended, extracted, or replaced before adding new code.
- **Canonical values / hardcoded contracts:** exact strings, aliases, enum-ish lists, column names, route/action names, CSS classes, ScriptProperties.
- **Read/write/derive/display paths:** readers, writers, validators, migrations, caches, UI renderers.
- **Mirrors and duplicate logic:** client-side mirrors, Apps Script HTML inline JS, tests, docs examples, agent/tool schemas.
- **Side-effect order:** guards before writes, Drive/DB/Sheets/Calendar/email/audit/cache effects, idempotency/lock behavior.
- **Rollout/backward compatibility:** existing data, legacy aliases, old deployments, browser/App Script cache, manual smoke surfaces.

Use `rg` searches when the project is locally available. If Graphify/context packet evidence is inference-only, label it as a hypothesis until code confirms it.

Carry the seed into `interview-result.md` and later backlog items. It does not need to be complete during grilling, but it must be specific enough that `/appmaker:tdd` can finish the audit without rediscovering the whole project.

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

### 5. Write feature folder + interview-result.md (v0.2.14, MANDATORY when proceeding to PRD)

**Closes design gap surfaced in caseman session:** `prd` requires `interview-result.md` as primary input. Before v0.2.14, brownfield path went `grill-brownfield → prd` without producing this artifact — agent had to synthesize one on the fly. v0.2.14 makes the artifact part of the canonical contract.

When user wants to proceed to PRD (or `/appmaker:next` detects state ready):

1. **Allocate feature folder.** Same logic as `/appmaker:interview` step 2: list `appmaker/features/`, find highest existing NNN, allocate next. Confirm slug via AskUserQuestion.

2. **Write `appmaker/features/<NNN-slug>/interview-result.md`** via Bash heredoc with **grill-brownfield-specific shape** — same fields as interview output, plus brownfield-specific sections:

```bash
mkdir -p "appmaker/features/<NNN-slug>"
cat > "appmaker/features/<NNN-slug>/interview-result.md" <<'EOF'
---
feature: <NNN-slug>
created: <ISO date>
source: grill-brownfield
readiness: ready_with_override
override_reason: brownfield grilling covered all dimensions interview would; no formal interview phase
---

# Feature: <NNN-slug>

## Problem statement
[1-3 sentence problem rooted in brownfield context]

## Existing System Context (brownfield-specific)
- Code regions touched: [from grill conversation + context packets]
- Brownfield impact audit seed: [reuse/refactor-first candidates, canonical values, hardcoded contracts, mirrors, side-effect surfaces, first grep queries]
- Glossary terms resolved during grill: [list]
- Architectural decisions surfaced: [list with wiki/architecture.md candidate notes]
- Open risks: [from step 4]

## Target users + use case
[from grill conversation]

## Constraints discovered
[constraints found during grilling — code, data, integration, business]

## Success indicators
[what proves this works — not yet PRD-grade SCs, but directional]

## Out of scope (intentional)
[boundaries explicitly drawn during grill]

## Context packet
[path to appmaker/context/<date>-<topic>.md if /appmaker:context was invoked]
EOF
test -f "appmaker/features/<NNN-slug>/interview-result.md" && echo "✓ interview-result.md written (source: grill-brownfield)"
```

**Verification:** `test -f` before continuing. Without this artifact, downstream `/appmaker:prd` will refuse (readiness gate).

3. **Update glossary deterministic** (v0.2.11 pattern):
```bash
bash appmaker/hooks/glossary-extract.sh "appmaker/features/<NNN-slug>/interview-result.md"
```

Do NOT create PRD here. The artifact unlocks `/appmaker:prd` as the next phase. Suggest via output.

## Output

Conversation + feature folder + `interview-result.md` (v0.2.14) + optional glossary/memory wiki updates.

```
Brownfield grill summary:
- Feature folder: appmaker/features/003-tenant-routing/
- Artifact: appmaker/features/003-tenant-routing/interview-result.md (source: grill-brownfield, readiness: ready_with_override)
- Resolved: tenant routing uses subdomain, not user profile.
- Risk: billing community touches auth callback.
- Context packet: appmaker/context/2026-05-11-tenant-routing.md
- Suggested next: /appmaker:prd
```

## Guardrails

- **Explore before asking.** Don't ask user for facts code/docs can answer.
- **One question per turn.** No batches.
- **Recommendation mandatory.** Every question includes proposed answer.
- **Evidence mandatory.** Brownfield questions cite docs, memory, context packet, or file path.
- **Don't over-write memory.** Append candidate notes; avoid rewriting wiki pages during live grill unless user confirms.
- **Don't turn graph neighbors into scope.** Graphify informs risk; PRD/AC decides scope.
- **Don't create PRD/backlog here.** This skill sharpens understanding only.
