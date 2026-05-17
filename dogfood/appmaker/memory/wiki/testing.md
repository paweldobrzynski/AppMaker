# Testing Memory Wiki

Durable testing patterns for AppMaker. Seeded 2026-05-17 from feature 001 retro.

## Test extension > test creation

When a contract is already covered by an existing test, **EXTEND that test rather than create a new file**. Avoid test-file proliferation.

**Example (slice 006 / 2026-05-17):** Release version bump needed assertion that `plugin.json` equals release target. `tests/smoke/test-version-sot.sh` already covered manifest consistency (`plugin.json == marketplace.json` equality). Extension added `EXPECTED_RELEASE_VERSION="0.2.18"` constant + assertion. Codex explicitly endorsed extension over new file: minimal contract, no proliferation, single point of update for release-target.

**When extension is wrong:** if existing test asserts a DIFFERENT contract class. E.g., `test-glossary-extract.sh` tests bash hook behavior — adding a doc-drift assertion there would be off-topic. Each test file should have a coherent contract scope.

**Heuristic:** Look at existing test names. If your new assertion fits semantically (same contract, same file), extend. If you'd need to rename the test file to capture both contracts, create a new test.

## Scoped regex pattern for documentation drift tests

Documentation drift tests must distinguish:
- **Drift form:** specific layout / example pattern (e.g., `← X dirs` arrow form in markdown layout block)
- **Historical/narrative form:** same content in different context (e.g., changelog `"X dirs" → "Y dirs"` referencing past changes)

A naive global regex (e.g., `grep "X dirs"`) catches both, creating false failures on legitimate historical mentions. Codex correction (slices 003 + 004, 2026-05-17): scope regex to layout/example-specific anchors.

**Anchor library:**

| Drift form | Regex anchor | Why it works |
|---|---|---|
| Markdown ASCII tree layout | `← X dirs` (left arrow before count) | Changelog narrative uses right arrow `→ X` or quoted `"X dirs"`; doesn't match `←` |
| `.appmaker-version` file-marker example | `(current: "X.Y.Z")` (parens + literal prefix) | Historical labels say `v0.2.11:` (colon-suffix), never wrapped in `(current:` |
| Version literal at end-of-line | `→ X.Y.Z$` (EOL anchor) | Prose mentions inline have trailing punctuation/text |
| Hardcoded "Upgrade: X.Y.Z → A.B.C" | Full pattern including arrow | Decision history uses `v` prefix or paren-context |
| Backtick command-route (slice 005) | `` `spike` `` (backtick form) | Trigger-keyword column uses `"spike"` (quotes), suggestion column uses backticks |
| Release narrative version | `^**Status:** v$EXPECTED_RELEASE_VERSION` (line-anchored prefix) | Status line is unique start-of-line marker |

**Rule of thumb:** Identify where drift visually lives in the file (layout block, example output, table cell, status line). Anchor regex to that visual context, not to the content alone. Historical narrative will reference same content but in a textually distinct form.

## Test from failure mode, not from AC paraphrase

When AC says "X must do Y", don't translate verbatim to regex. Ask: **"what could PASS my test while VIOLATING AC?"** — find that failure mode, anchor test against it.

**Example (slice 001 / 2026-05-17):** AC said "PRD has `## Criticisms` with at least 1 `pcrit-NNN` item". Verbatim regex: `pcrit-[0-9N]+`. Failure mode caught by Codex review: someone could write `## Criticisms` with only prose ("we'll track via pcrit-NNN naming") and no real list item — regex passes despite contract violation. Codex-strengthened regex: `^- \*\*pcrit-[0-9]{3}:\*\*` — requires markdown list bullet + bold + canonical 3-digit ID. Anchors against the failure mode, not the AC literal.

**Process:**
1. Read AC.
2. Write naive test from AC literal.
3. Ask: what's the simplest violation that would pass this test?
4. If violation case is plausible → strengthen regex against it.
5. Iterate until violation cases are eliminated or implausible.

**Why this matters:** Test gates trust. If test passes false-positive, the gate is fictional. Codex framing: "zielony test ≠ AC enforcement". Test is enforcement only when written from failure mode, not from AC paraphrase.

## Line-number ordering checks (structural, not content)

When a test must assert a section's POSITION (e.g., "Execution Record between Acceptance criteria and Blocked by") use `grep -nE` to get line numbers + integer comparison, NOT content-based matching.

**Pattern:**

```bash
AC_LINE=$(grep -nE '^## Acceptance criteria$' "$FILE" | head -1 | cut -d: -f1)
EXEC_LINE=$(grep -nE '^## Execution Record$' "$FILE" | head -1 | cut -d: -f1)
BLOCKED_LINE=$(grep -nE '^## Blocked by$' "$FILE" | head -1 | cut -d: -f1)

if [ "$AC_LINE" -lt "$EXEC_LINE" ] && [ "$EXEC_LINE" -lt "$BLOCKED_LINE" ]; then
  ORDER_OK="yes"
else
  ORDER_OK="no"
fi
assert_eq "Execution Record sits between AC and Blocked by" "yes" "$ORDER_OK"
```

**Why this over content matching:** content-based assertion (e.g., "section X appears AFTER section Y") would need brittle string search or false-positive on prose mentions. Line numbers are structural — survive rephrasing within sections, fail honestly on reordering.

**Real examples (v0.2.19):**
- `test-backlog-execution-record.sh` asserts Execution Record sits between Acceptance criteria and Blocked by.
- `test-tdd-execution-record.sh` extends pattern: asserts step `3b` between step `3` and step `4`; step `9a` between step `9` and `Move file:`.

**Trade-off:** test locks in section heading wording. If operator renames `## Execution Record` to `## Slice Execution`, test fails. Acceptable — heading wording is part of the contract being asserted.

Pairs with: scoped regex (above), test-from-failure-mode (above).
