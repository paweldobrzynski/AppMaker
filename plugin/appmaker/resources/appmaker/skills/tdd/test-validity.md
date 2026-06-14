# Test validity — anti-placebo gate

Supporting ref for `/appmaker:tdd`, `/appmaker:review`, `/appmaker:checklist`. Determinism first (Tier 1 grep), judgment second (Tier 2).

## Why

AI-generated tests "try to please." When told "make it pass," an LLM will skip the test, weaken the assert, comment out the check, or write a tautology — green bar, zero coverage. A placebo test guarding an AC is worse than no test: it claims the AC is verified when it is not.

## Tier 1 — deterministic sweep (run first)

Scan changed test files for placebo markers. Adjust globs to the project's test dir/extension.

```bash
# changed test files only
FILES=$(git diff --name-only --diff-filter=d | rg -i 'test|spec' || true)
[ -z "$FILES" ] && echo "no changed test files" && exit 0

# skipped / focused tests (silently disable or narrow coverage)
echo "$FILES" | xargs rg -n '\.skip\(|\.only\(|\bxit\(|\bxdescribe\(|\bfit\(|\bfdescribe\(|test\.todo|@(unittest\.)?skip|@pytest\.mark\.skip' 2>/dev/null

# tautology asserts (always pass, prove nothing)
echo "$FILES" | xargs rg -n 'expect\(true\)\.|expect\(1\)\.toBe\(1\)|assert\(true\)|assertTrue\(True\)|assertEqual\(1, *1\)|expect\(.+\)\.toBeDefined\(\)\s*$' 2>/dev/null

# commented-out / disabled assertions
echo "$FILES" | xargs rg -n '^\s*(//|#)\s*(expect|assert|self\.assert)' 2>/dev/null

# bodyless test that asserts nothing (heuristic — verify by eye)
echo "$FILES" | xargs rg -n 'it\(.+\}\s*\)\s*;?\s*$|test\(.+\}\s*\)\s*;?\s*$' 2>/dev/null | rg -v 'expect|assert' 2>/dev/null
```

Any hit = inspect. A marker is a flag, not an automatic verdict (a legit `.skip` with a written reason + tracking item is fine).

## Tier 2 — judgment per test

For each test that maps to an AC:

- **Asserts the AC outcome?** Test checks the behavior the AC promises, not just "page loaded" / "no throw" / value is defined.
- **Would it catch a regression?** If the impl were reverted/broken, would this test go red? If no, it's a placebo.
- **Public interface, not internals.** (Already in `tests.md` — placebo often hides behind over-mocked internals.)
- **For E2E:** asserts the visible result of the flow (result count, text, URL), not merely that navigation happened.

## Verdict

- **FAIL** — a placebo (skipped/tautology/commented/no-assert) guards an AC, or an AC's only test would not go red on regression.
- **WARN** — skip/only/todo present with a written reason + tracking, or a weak-but-not-empty assert.
- **PASS** — every AC test asserts its outcome and would catch a regression.

Record hits as `file:line — marker — verdict` in the QA / review / checklist report. Never silence a marker by deleting the test; fix the assert or justify the skip.
