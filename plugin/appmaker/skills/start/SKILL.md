---
description: Entry point for AppMaker workflow. Classifies user intent as macro action (feature, bug, prototype, refactor, research, review). Detects project context (appmaker/ setup, Graphify, backlog). Suggests command chain and optionally invokes first. Use when starting any new task — feature, bug, refactor, research, prototype, review.
disable-model-invocation: false
---

Entry point. User describes intent, AppMaker routes to appropriate workflow. Macro action paradigm — user delegates work, AppMaker orchestrates commands.

## When to invoke

- Manual: user types `/appmaker:start "<intent>"`
- Auto: Claude can suggest when user describes new task and `appmaker/` exists
- AFK-safe: NO — entry point requires human intent classification + workflow confirmation
- Required state: any (works on greenfield AppMaker setup or fully populated project)
- Required input: user intent (prompted via AskUserQuestion if not provided inline)

## Process

### 1. Receive intent

If no intent provided, ask via AskUserQuestion:
> "What macro action chcesz delegate? (feature / bug / refactor / research / prototype / review)"

### 2. Detect project context (parallel reads OK)

- `appmaker/` directory exists? If not → suggest `/appmaker:init` first.
- `appmaker/constitution.md` present? Read 5-7 rules for downstream context.
- `appmaker/glossary.md` present? Read terms — use as anchors when classifying intent.
- `appmaker/backlog/` has open items? Note count.
- `appmaker/features/` has in-progress feature? Note newest.
- `graphify-out/graph.json` exists? → Graphify available. Suggest `/appmaker:context`.
- Git status: clean / dirty / no repo.

### 3. Classify macro action

| Category | Triggers | Suggested chain |
|---|---|---|
| **feature** | "add", "build", "implement", "new" | `grill-brownfield` or `grill` → `interview` → `prd` → `decompose` → `checklist` → (`tdd` → `review`) per slice → feature `review` → `archive` |
| **bug** | "fix", "broken", "doesn't work", "error", "crash" | `diagnose` → `feedback` if backlog item needed → `tdd` → `review` → `archive` |
| **prototype** | "try", "explore design", "validate idea", "spike" | `grill` — prototype flow (`spike`) TODO/not yet implemented, use grill for exploration |
| **refactor** | "refactor", "clean up", "restructure" | `grill-brownfield` → `prd` → `decompose` → `checklist` → `tdd` |
| **research** | "investigate", "explore", "understand", "what is" | `grill` (general questioning), NO artifact unless wanted |
| **review** | "review", "audit", "check", "verify quality" | `review` (invokes code-reviewer subagent) |
| **qa/feedback** | "QA", "feedback", "user reported", "complaint" | `feedback` → `diagnose` or `tdd` |
| **continue** | "continue", "next", "what's left" | List open backlog items, suggest top-priority |
| **unclear** | none match | `grill` (sharpen idea), reclassify after |

### 4. Suggest workflow + optionally invoke

Output:

```
Detected: [CATEGORY]
Project context: [setup OK / missing X / brownfield / greenfield]
Graphify: [available / not available]

Suggested chain:
  1. /appmaker:<first> — [purpose]
  2. /appmaker:<second> — [purpose]
  3. ...

Auto-invoke /appmaker:<first> now? [Y/n]
```

Use AskUserQuestion tool for confirmation.

### 5. Note parallel opportunities (Layer 4)

If macro action decomposes into multiple `autonomous` slices:
> Note: 3 slices marked autonomous → Layer 4 AFK runner can execute after `/appmaker:checklist` PASS/WARN and explicit approval. Run `/appmaker:afk --dry-run` first.

## Output format example

```
You: /appmaker:start "users report login fails sometimes"

AppMaker.start:
  Detected: BUG
  Project context: appmaker/ OK, glossary has 23 terms (auth/session/token referenced)
  Graphify: available — querying auth neighborhood...
  Backlog: 0 open items related to auth.
  Git: clean.
  
  Suggested chain:
    1. /appmaker:diagnose — investigate, isolate root cause
    2. /appmaker:feedback — capture durable backlog item if needed
    3. /appmaker:tdd per slice — implement test-first
    4. /appmaker:review — critic pass
    5. /appmaker:archive — close out
  
  Auto-invoke /appmaker:diagnose now? [Y/n]
```

## Guardrails

- **Don't pretend to be done.** Output suggested chain + ask to invoke. Don't auto-execute full chain.
- **Surface context loudly.** User must see what AppMaker detected. No silent assumptions.
- **Suggest only, don't enforce.** User can override.
- **Reference glossary terms in classification.**
- **Acknowledge missing setup.** If `appmaker/` doesn't exist, offer init.
- **Don't classify silently.** Always show category + reasoning.
- **Don't invent macro action categories.** Stick to 8 listed. Unclear → `grill`.
- **Don't bypass `/appmaker:init`.** If `appmaker/` missing, offer init.
