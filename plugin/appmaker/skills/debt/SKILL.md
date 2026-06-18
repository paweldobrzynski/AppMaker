---
description: Harvest every `appmaker:debt` shortcut marker in the codebase into one ledger, so deliberate shortcuts get tracked instead of rotting into "later means never". Deterministic Tier-1 grep via debt-json.sh. One-shot report — collects, never fixes. Use when the user says "debt", "/appmaker:debt", "list the shortcuts", "what did we defer", or "debt ledger".
disable-model-invocation: true
---

Debt ledger. Every deliberate shortcut leaves an `appmaker:debt` marker naming its **ceiling** and **upgrade path**; this collects them into one place. Sibling of the anti-placebo test-validity gate — Tier-1 (grep), not judgment. Collects, never fixes.

**Output style:** Follow the **Compact report contract** in `appmaker/skills/output-style.md`. Ledger = one markdown table + (optional) hygiene WARN bullets. No prose.

## Marker convention

In any code comment:

```
appmaker:debt <ceiling> -> upgrade: <path>      (the arrow → also accepted)
```

- **ceiling** — what this shortcut tops out at (`global lock`, `O(n²) scan`, `naive heuristic`).
- **upgrade path** — what to do when the ceiling bites (`per-account locks if throughput matters`).

Written by `tdd` (or by hand) at the moment a deliberate shortcut is taken. See `appmaker/skills/yagni-ladder.md`.

## When to invoke

- Manual: `/appmaker:debt`
- AFK-safe: yes — read-only scan; writes one ledger report
- Required state: `appmaker/` (for the report dir)
- Output artifact: `appmaker/debt/<YYYY-MM-DD>-ledger.md`

## Process

### 1. Harvest (deterministic)

```bash
bash "${CLAUDE_PLUGIN_ROOT:-plugin/appmaker}/scripts/debt-json.sh" --project-dir .
```

Emits JSON `{"debts":[{file,line,ceiling,upgrade,has_ceiling,has_upgrade,raw}]}`. Scans source only — excludes `.git/`, `node_modules/`, `appmaker/`. No markers → `{"debts":[]}` (report "no tracked debt", stop).

### 2. Classify hygiene

- **OK** — has both ceiling and upgrade path.
- **WARN** — bare marker: `has_ceiling:false` or `has_upgrade:false`. A shortcut with no named ceiling/upgrade is the "later means never" failure.

### 3. Write ledger

Save to `appmaker/debt/<YYYY-MM-DD>-ledger.md`:

```markdown
---
scope: debt-ledger
created: 2026-06-18
total: 2
needs_hygiene: 1
---

# Debt Ledger

**2 markers / 1 needs hygiene**

| File:Line | Ceiling | Upgrade path | Hygiene |
|---|---|---|---|
| `src/lock.js:14` | global lock | per-account locks if throughput matters | OK |
| `src/scan.py:30` | naive O(n²) scan | — | WARN: no upgrade path |
```

Persist via Bash heredoc; `test -f` to confirm. Don't only print to chat.

### 4. Chat reply

Compact:

```
✓ Debt ledger: appmaker/debt/2026-06-18-ledger.md
  2 markers, 1 needs a named upgrade path (src/scan.py:30).
```

## Guardrails

- **Deterministic only.** The harvest is grep; do not editorialize or invent debt.
- **Collect, never fix.** Surface markers; user decides. No auto-refactor.
- **Bare marker = WARN, not FAIL.** Tracking is the win; hygiene is a nudge.
- **Source only.** Never scan `appmaker/` artifacts or the ledger itself.
- **No new dependency.** Pure bash + the shared script.
