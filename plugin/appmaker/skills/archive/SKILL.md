---
description: Close out completed feature. Verifies all backlog items done + review passed, moves backlog items to backlog/done/, moves feature folder to features/archive/<date>-<NNN-slug>/, optionally invokes retro to capture lessons. Adopts OpenSpec /opsx:archive flow. Use when all slices in feature are complete.
disable-model-invocation: true
---

Close out completed feature. Final step in feature lifecycle. Adopts OpenSpec `/opsx:archive` flow plus AppMaker extensions (review gate, optional retro).

**Output style:** Follow the **Compact report contract** in `appmaker/skills/output-style.md`. Retro = one Q&A table + lessons-extracted bullets. Lessons appended to `memory/lessons.md` as 1-line bullets. No prose retrospectives, no "What worked / What broke / What to change" 3-section split when a single 3-column table covers it.

## When to invoke

- Manual: `/appmaker:archive <NNN-slug>` or `/appmaker:archive` (latest completed feature). Use `--force` flag to override pre-archive verification failures.
- Auto: by `start` when feature workflow shows all slices done
- AFK-safe: yes (verification + file moves; retro is opt-in user prompt) — but writes/moves files (side effect)
- Required state: feature folder + all linked backlog items `status: done`
- Required input: feature ID (auto-detected if obvious)

## Process

### 1. Locate feature

If invoked without arg, find latest `appmaker/features/<NNN-slug>/` not in `archive/` with all linked backlog items `status: done`.

Confirm via AskUserQuestion: "Archive feature `003-add-dark-mode`? (4 backlog items done)"

### 2. Pre-archive verification

Refuse to archive if ANY:
- Linked backlog items have `status` other than `done` (list which)
- Feature folder missing required artifacts (`prd.md`, `decomposition.md`)
- No backlog items linked (suggests feature was abandoned)

User can:
- Fix (complete pending slices)
- Override (`/appmaker:archive --force <NNN>` — captures `archive_status: forced` + reason)

### 3. Optional pre-archive review

If feature has no `appmaker/features/<NNN>/review.md` AND user did not run `/appmaker:review feature <NNN>` recently, suggest via AskUserQuestion:

```
No feature-level review found. Run /appmaker:review feature 003 first? [Y/n]
```

If Y → invoke `/appmaker:review feature <NNN>`. Refuse archive if review FAIL (unless `--force`).

### 4. Move artifacts

**Backlog items:**
For each linked item:
- Move `appmaker/backlog/NNN-slug.md` → `appmaker/backlog/done/<YYYY-MM-DD>-NNN-slug.md`
- Date prefix = original `completed` date (or today)

**Feature folder:**
- Move `appmaker/features/<NNN-slug>/` → `appmaker/features/archive/<YYYY-MM-DD>-<NNN-slug>/`
- Date prefix = today

### 5. Optional retro

Ask via AskUserQuestion:

```
Run retro on this feature to capture lessons? [y/N]
```

If y → invoke retro flow:
1. Read archived feature artifacts: `prd.md`, `decomposition.md`, linked backlog items, listed `context_packets`.
2. Ask user 4 questions (skip any user already volunteered):
   - What surprised you during this feature?
   - What would you do differently next time?
   - What patterns should AppMaker reuse?
   - Any commands that didn't fit?
3. Write `retro.md` using **compact retro template**:

```markdown
---
feature: 003-add-dark-mode
created: 2026-05-11
lessons_extracted: 3
---

# Retro: 003-add-dark-mode

## Q&A

| Question | Answer (1-3 lines) | Lesson |
|---|---|---|
| Surprises? | Graphify mis-classified `theme/` as unrelated community | graph confidence ≠ certainty — verify before scope |
| Differently? | Would write context packet before decompose | packet-first reduces backlog re-edits |
| Reuse? | RED-GREEN with AC checkbox tracking | proven discipline — keep in TDD skill |
| Misfits? | `/appmaker:diagnose` not used for theme-flicker bug | promote diagnose UX in v0.2.6 |

## Context packets referenced
- `appmaker/context/2026-05-09-theme-system.md` (graphify)
```

   - No "What worked / What broke" prose sections. The Q&A table is the retro.
   - Skip the "Context packets referenced" section if none exist.

4. Append extracted lessons to `appmaker/memory/lessons.md` as 1-line bullets (one per lesson, prefix with feature ID for traceability):
   ```
   - [003] graph confidence ≠ certainty — verify before scope inclusion
   - [003] packet-first reduces backlog re-edits
   ```
5. Update memory wiki **only when** the lesson is durable and reusable:
   - architecture insight → `appmaker/memory/wiki/architecture.md`
   - domain invariant → `appmaker/memory/wiki/domain-model.md`
   - test seam/loop → `appmaker/memory/wiki/testing.md`
   - integration gotcha → `appmaker/memory/wiki/integration-gotchas.md`
   - shipped feature 1-liner → `appmaker/memory/wiki/feature-index.md`
   - append 1-line entry to `appmaker/memory/log.md`

   Wiki updates = bullet additions, NOT full rewrites. Don't paste prose.

### 6. Chat summary — compact

```
✓ Archived: 003-add-dark-mode (4 slices, review PASS, +2 lessons)
  → appmaker/features/archive/2026-05-11-003-add-dark-mode/

Next: /appmaker:start "<intent>"
```

One line per fact, no checkmark wall.

## Archive structure

```
appmaker/
├── backlog/
│   ├── done/
│   │   ├── 2026-05-09-008-theme-context-setup.md
│   │   └── ...
│   └── (active items remain)
└── features/
    ├── archive/
    │   └── 2026-05-11-003-add-dark-mode/
    │       ├── interview-result.md
    │       ├── prd.md
    │       ├── decomposition.md
    │       ├── slices/
    │       ├── review.md
    │       └── retro.md  (if retro run)
    └── (active features remain)
```

Archive is **read-only by convention**. Lessons go forward to `memory/lessons.md` and durable synthesis goes to `memory/wiki/`.

Context packets remain in `appmaker/context/` as snapshots. Archive may reference them in retro, but memory gets only durable synthesis.

## Optional retro questions (default 4)

1. **What surprised you during this feature?**
2. **What would you do differently next time?**
3. **What patterns should AppMaker reuse?**
4. **Any commands that didn't fit?**

Skip per question if user already volunteered answer.

## Guardrails

- **Pre-archive verification mandatory.** Don't archive incomplete without `--force`.
- **Suggest pre-archive review** if missing. Don't force.
- **Suggest retro** but don't force.
- **Date-prefix archived items.**
- **Audit trail.** `archive_status: forced` + reason if `--force`.
- **Archive is read-only.** Lessons go to `memory/`.
- **Memory wiki is synthesis only.** Update durable pages and `memory/log.md`; don't paste raw transcripts/logs.
- **Graphify data stays external.** Archive may reference context packets; don't copy `graph.json` or packet dumps into memory.
- **Don't auto-clean backlog/.** Items stay in `done/`.
- **Don't archive incomplete silently.**
- **Don't modify archived artifacts.**
- **Don't bundle archives.** One feature at a time.
