# YAGNI Ladder

Cross-cutting reference for `decompose`, `tdd`, and `review`. Adapted from
[ponytail](https://github.com/DietrichGebert/ponytail) (MIT) — the lazy-senior-dev skill.
AppMaker frames it as a **scope discipline**, not a persistent mode.

The shortest path to done that stays correct is the right path. The best code is the code never
written. But laziness is efficiency, never carelessness — the carve-outs below are hard limits.

## The ladder

When scoping a slice or writing code, stop at the first rung that holds:

1. **Does this need to exist at all?** Speculative need = skip it, say so in one line. (YAGNI)
2. **Does the standard library do it?** Use it.
3. **Does a native platform feature cover it?** `<input type="date">` over a picker lib, CSS over
   JS, a DB constraint over app code.
4. **Does an already-installed dependency solve it?** Use it. Never add a new dep for what a few
   lines do. (This is AppMaker's existing reuse/refactor-first rule, made a reflex.)
5. **Can it be one line?** One line.
6. **Only then:** the minimum code that works.

Two rungs work → take the higher one and move on. The ladder is a reflex, not a research project.

## Over-engineering smells (flag in review)

- Interface with one implementation; factory for one product; config for a value that never changes.
- Boilerplate/scaffolding "for later" — later can scaffold for itself.
- Reinvented stdlib; a new dependency for a few lines; dead flexibility no AC asked for.
- Abstraction added before the second caller exists.

One line per finding: **location → what to cut → what replaces it.**

## `build_intensity` (config dial)

`appmaker/config.yaml` `build_intensity` (orthogonal to `rigor_level`):

| Level | Effect |
|-------|--------|
| **lite** | Build what's asked; name the lazier alternative in one line, user picks. |
| **standard** | Ladder applied; stdlib/native/reuse first; shortest working diff. Default. |
| **ultra** | YAGNI extremist; deletion before addition; ship the minimal version and challenge the rest of the requirement in the same breath. |

## When NOT to be lazy (hard limits)

Never simplify away:

- Input validation at trust boundaries.
- Error handling that prevents data loss.
- Security measures and accessibility basics.
- Anything explicitly requested — user insists on the full version → build it, no re-arguing.
- Correctness on edge cases — laziness means writing less code, not picking the flimsier algorithm.

These align with the constitution and the PRD's Non-delegable judgments / Failure modes. The
ladder governs **how much** you build, never whether you keep the safety net.

## Deliberate shortcut → mark it

A shortcut with a known ceiling is fine **if it is tracked**. Leave an
[`appmaker:debt`](../../skills/debt/SKILL.md) marker naming the ceiling and the upgrade path:

```
# appmaker:debt global lock -> upgrade: per-account locks if throughput matters
```

`/appmaker:debt` harvests these into a ledger; `review`/`checklist` warn on a bare marker (no
named ceiling or upgrade path). Untracked shortcut = the "later means never" failure the ladder
is supposed to prevent.
