---
description: Disciplined bug and performance diagnosis loop for existing failures. Builds a repro signal, ranks hypotheses, instruments one variable at a time, fixes with regression coverage, and records diagnostic findings.
disable-model-invocation: true
---

Bug diagnosis. Adapted from Matt Pocock `diagnose`: feedback loop first, fix second.

## When to invoke

- Manual: `/appmaker:diagnose "<bug report>"`
- Suggested by `start` for bug/refactor/performance reports
- AFK-safe: conditional — read/diagnosis yes; code changes require blocker checks + user confirmation if `human_required`
- Required state: codebase + bug description
- Required input: symptom or failing command
- Output artifact: `appmaker/diagnostics/<YYYY-MM-DD>-<slug>.md`

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

Bug diagnosis benefits enormously from knowing past gotchas + architectural assumptions. Read BEFORE generating hypotheses.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in integration-gotchas architecture testing; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

Cite as `per wiki/integration-gotchas.md: <known issue>` if the symptom matches a documented gotcha. If it does match → diagnosis is fast (cite the lesson, propose the recorded fix). If symptom matches NOTHING in wiki → diagnosis must surface this: "no prior record of this failure mode — durable lesson if confirmed."

### 1. Capture symptom

Write diagnosis artifact with:
- user-reported symptom
- expected behavior
- actual behavior
- environment
- suspected feature/backlog link if any

### 2. Build feedback loop

Find fastest reliable pass/fail signal:
1. failing test
2. CLI/curl script
3. browser automation
4. captured trace replay
5. throwaway harness
6. repeated flake loop

If no loop possible, stop. Ask for logs/HAR/repro access. Do not guess-fix.

### 3. Reproduce

Run loop. Capture exact output. Confirm it matches user symptom.

For non-deterministic bugs: raise reproduction rate. Loop 100x, stress, seed, freeze time, isolate network.

### 4. Rank hypotheses

Create 3-5 falsifiable hypotheses:

```
H1: If cache key ignores tenant, then running same claim under two tenants reproduces score bleed.
Prediction: adding tenant to key makes repro pass.
```

Show list. Proceed with top hypothesis if user is AFK.

### 5. Instrument narrowly

Probe one hypothesis at a time.
- Prefer debugger/REPL if available.
- Else targeted logs with unique tag `[DEBUG-appmaker-<id>]`.
- Never "log everything".

Perf branch: measure baseline first, then change.

### 6. Fix + regression

If correct seam exists:
1. turn repro into failing test
2. watch fail
3. implement minimal fix
4. watch pass
5. rerun original loop

If no correct seam exists, document architecture gap and create backlog item via `/appmaker:feedback`.

### 7. Cleanup + memory

- Remove `[DEBUG-appmaker-*]`
- Delete throwaway harness or move under clearly named debug artifact
- Append result to diagnosis artifact
- If durable lesson: update `appmaker/memory/wiki/integration-gotchas.md` or `testing.md`
- If fix complete: suggest `/appmaker:review diff`

## Output format

```markdown
# Diagnosis: tenant cache bleed

## Symptom
## Feedback loop
## Reproduction
## Hypotheses
## Instrumentation
## Fix
## Regression coverage
## Cleanup
## Lessons for memory wiki
```

## Guardrails

- **Feedback loop before fix.** No loop, no diagnosis.
- **Falsifiable hypotheses only.** No vague theories.
- **One variable at a time.**
- **Regression test before fix** when correct seam exists.
- **Remove debug instrumentation.**
- **Don't mark done without rerunning original repro.**
- **Don't skip memory lesson** when bug exposed durable architectural/testing knowledge.
