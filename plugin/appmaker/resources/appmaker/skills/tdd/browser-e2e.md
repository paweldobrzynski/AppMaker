# Browser E2E — scan-first grounding

Supporting ref for `/appmaker:tdd`. Use when a slice has UI/browser surface AND an AC needs an end-to-end browser flow (not just unit/integration).

## Core rule (the whole point)

**NEVER write E2E selectors from imagination.** LLM has knowledge cutoff and never saw your live DOM. Blind E2E hallucinates locators -> brittle, fake-green tests you spend hours unbreaking.

Scan live app FIRST -> real accessibility tree / DOM snapshot in context -> generate E2E from THAT. Selector must trace to a snapshot line, not a guess.

This mirrors the Playwright-MCP pattern: drive the real browser, pull the page snapshot into the conversation, then emit code grounded in it.

## When to invoke

- Slice touches UI/browser AND has an AC describing a user-visible flow (search, login, cart, nav, form submit).
- Skip for pure logic/API/domain slices — those stay normal `/appmaker:tdd` integration tests.
- No browser runtime available -> mark the E2E AC `human-review:` or blocked. Do NOT fabricate a passing E2E.

## Step 1 — App map (write once, reuse)

Build a small surface map so E2E generation has a head start and burns fewer tokens. Equivalent of the `setup.md` + `testplan.md` pattern.

Write `appmaker/features/<NNN>/app-map.md`:

```markdown
# App map: <feature>

**Scanned:** <ISO date> | **Base URL:** <url>

## Pages / routes
| Route | Purpose | Key roles/labels (from snapshot) |
|---|---|---|
| /search | product search | searchbox "Search", button "Search" |

## API routes (for API E2E)
| Method | Path | Returns |
|---|---|---|
| GET | /api/products | product list JSON |

## Flows to cover (from AC)
- pcrit-NNN: search "liquid" -> 1 result -> open PDP
```

Reuse the existing map if fresh. Refresh when routes/DOM changed (treat like a context packet snapshot).

## Step 2 — Scan the live flow

Prefer the gstack adapter when `gstack_enabled: true` (see qa/SKILL.md for `$B` resolution):

```bash
$B status
$B goto <url>
$B snapshot -i        # accessibility tree -> into context; THIS is the grounding
```

Capture role/label/text from the snapshot for every element the flow touches. Playwright MCP (`browser_navigate` + `browser_snapshot`) is the equivalent when configured instead of gstack.

## Step 3 — Generate E2E grounded in the snapshot

- Locators come from captured roles/labels/text — prefer `getByRole`/`getByLabel`/`getByText` over CSS/XPath.
- Every locator must map to a snapshot line. If you can't point to it, you guessed it — rescan.
- One E2E spec per flow; AC comment on top (`// pcrit-NNN: <flow>`), like the video's test-plan-as-comment trick — keeps the LLM on track.
- Respect `edit_scope`; put specs where the project's E2E live.

## Step 4 — Run + bounded repair loop

Agentic loop, mirrors "run the test, if it fails, fix it":

1. Run the E2E.
2. Fail -> read the actual error + fresh snapshot, fix locator/wait/assert, rerun.
3. Max 3 repair attempts. Still red -> stop, report blocker, do NOT comment out asserts to force green.

After green, run the **test-validity** check (`appmaker/skills/tdd/test-validity.md`): confirm the E2E actually asserts the AC outcome, not just that the page loaded. A green E2E that asserts nothing is a placebo.

## Guardrails

- **Scan before generate.** No snapshot in context = no E2E.
- **No invented selectors / test-ids.** Trace every locator to a snapshot line.
- **No fabricated pass.** No browser -> blocked/human-review, never fake.
- **Repair is bounded.** 3 attempts, then escalate; never weaken asserts to pass.
- **Grounding evidence in the slice.** Note the app-map path + scan date in the QA / Smoke Plan.
