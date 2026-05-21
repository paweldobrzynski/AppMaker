---
description: Deterministic cross-artifact gate for AppMaker projects. Checks PRD, decomposition, backlog, glossary, context packets, review, memory wiki, Graphify freshness, and archive readiness with PASS/FAIL/WARN output.
disable-model-invocation: true
---

Checklist gate. Spec Kit `/analyze` spirit, AppMaker invariants. Deterministic first, judgment second.

**Output style:** Follow the **Compact report contract** in `appmaker/skills/output-style.md`. Checklist report is ONE markdown table + (optional) compact Warnings/Blockers bullet sections. No prose deep-dives, no Suggested Next section, no count fields in frontmatter, no companion paragraphs. Evidence cells ≤ 80 chars. Skip empty sections.

## When to invoke

- Manual: `/appmaker:checklist [feature <NNN-slug> | backlog <NNN> | project | archive <NNN-slug> | memory]`
- Suggested by `decompose` before `tdd`, by `archive` before closeout, by `afk` before loops
- AFK-safe: yes for read-only checks; writes report
- Required state: `appmaker/`
- Output artifact: `appmaker/checklists/<YYYY-MM-DD>-<scope>.md`

## Process

### 1. Determine scope

Default order:
1. current feature if one active
2. latest feature with `prd.md`
3. project scope

Read `appmaker/config.yaml`, constitution, glossary, memory index, relevant feature/backlog/context packets. Capture `rigor_level` (`light|standard|strict`, default `standard`) before classifying gates:
- `light` may skip feature-level PRD/decomposition checks for ad-hoc bug/feedback backlog items; traceability inside the backlog item still applies.
- `standard` uses the Required checks table as written.
- `strict` escalates unexplained Execution Record drift from WARN to FAIL for auth/payments/security/migrations/data-loss slices.

### 2. Run deterministic checks

Classify each check:
- **FAIL** = invariant broken; should block promote/archive/AFK
- **WARN** = risk or stale context; user may proceed
- **PASS** = OK

Only invariant breakage should be FAIL. Style preferences, extra polish, and
"nice to have" completeness checks stay WARN unless they break traceability,
reviewability, or archive safety.

Required checks:

| Check | Scope | Fail condition |
|---|---|---|
| Required files | feature | missing `prd.md` or `decomposition.md` after phase claims ready |
| PRD criteria IDs | feature | duplicate or malformed `pcrit-*` IDs |
| Trace coverage | feature | any PRD `pcrit-*` absent from backlog `traces_to` |
| Orphan traces | feature/backlog | backlog references nonexistent `pcrit-*` |
| Backlog blockers | project/feature | `blocked_by` references missing item |
| Blocker cycles | project/feature | cycle in `blocked_by` graph |
| Status validity | backlog | status not `open|in_progress|done|blocked` |
| Execution class | backlog | missing or not `human_required|autonomous|conditional` |
| AC test mapping | backlog | AC missing both `test:` and `human-review:` annotation |
| AC checkbox coverage | backlog | item `done` with unchecked AC |
| Implementation gray areas | backlog | unresolved gray areas without a decision, explicit deferral/risk, or `human_required` |
| Architecture Options Research | feature/backlog | high-impact architecture/library/vendor/storage/auth/design-system item missing complete `## Architecture Options Research`, source evidence, options matrix, or decision rationale |
| Package legitimacy | feature/backlog | new package/service dependency missing legitimacy evidence, or failed install substituted with a near-name package without human approval |
| Context budget / MCP audit | feature/backlog | large, agent-heavy, or MCP-heavy work missing context budget / Pre-flight MCP audit notes |
| Brownfield Impact Audit | brownfield/backlog | `in_progress`/`done` brownfield item missing `## Brownfield Impact Audit`, missing `Audit status: complete`, missing reuse/refactor-first decision, missing visual system/CSS reuse decision, missing design standards compliance check, or complete audit with no search evidence |
| Approved TDD plan | backlog | done item missing non-empty `## Approved TDD Plan` = WARN |
| TDD Plan Check | backlog | done item missing non-FAIL `## TDD Plan Check` result |
| QA / Smoke Plan | backlog/review | operator-visible, API, or integration item missing `## QA / Smoke Plan` evidence or explicit deferral |
| Design Review | UI/backlog | UI/CSS item missing design-review evidence or hardcoded visual exception |
| gstack browser evidence | UI/backlog | `gstack_required_for_ui_qa: true` but UI QA/design review lacks `$B status`, screenshot, or responsive evidence |
| Documentation staleness | feature/review | code changes affect documented commands/workflows/APIs/UI but docs were not updated or marked not_applicable |
| Edit scope | backlog/review | actual changed files violate `edit_scope.allow` / `edit_scope.forbid` without drift notes or user approval |
| Adversarial review | strict/review | high-risk diff lacks adversarial/ultra review or explicit deferral |
| Execution Record base | backlog | missing `Base ref` = FAIL |
| Execution Record tests | backlog | missing `Tests run` = FAIL |
| Execution Record drift | backlog | planned-vs-actual differs and `Drift notes` is empty = WARN |
| Review gate | archive | feature archive requested without review PASS or explicit force |
| Context packet links | brownfield | referenced `context_packets` missing |
| Touch map drift | review/archive | changed files outside expected `touches.files` without note |
| Graphify freshness | project | graph enabled but output missing or older than threshold = WARN |
| Glossary drift | feature | PRD/backlog uses known aliases-to-avoid = WARN/FAIL depending severity |
| Memory wiki health | project/memory | missing `memory/index.md`, `memory/schema.md`, or core wiki pages = WARN |
| Memory broken links | project/memory | `[[name]]` in wiki/* that doesn't resolve to existing memory file = FAIL |
| Memory stale pages | project/memory | `memory/wiki/*.md` mtime > 30 days since last touch = WARN |
| Memory raw orphans | project/memory | `memory/raw/*.md` not referenced in `memory/log.md` and mtime > 30 days = WARN |

### 3. Use shell where useful

Prefer concrete commands:
- `test -f <path>` for required files
- `rg -no 'pcrit-[0-9]+|SC[0-9]+|ID[0-9]+'` for criteria/traces (project may use any stable ID format — `pcrit-*` is suggested, NOT required)
- `rg -n 'status:|execution_class:|blocked_by:|traces_to:' appmaker/backlog`
- `rg -n '^## Implementation Decisions / Gray Areas|Unresolved gray area|human_required' appmaker/backlog`
- `rg -n '^## Architecture Options Research|Options matrix|Sources checked|ref_search_documentation|ref_read_url|Decision' appmaker/features appmaker/backlog appmaker/context`
- `rg -n 'Package / dependency legitimacy|slopsquatting|failed install|Context budget / MCP audit|Pre-flight MCP audit|## TDD Plan Check|exists / substantive / wired / functional' appmaker/features appmaker/backlog appmaker/context appmaker/reviews`
- `rg -n '^## Brownfield Impact Audit|Audit status:|rg -n|Search evidence|Dependency surface map|Reuse / refactor-first|Visual system / CSS reuse|Design standards compliance' appmaker/backlog`
- `rg -n '^## QA / Smoke Plan|Documentation staleness|edit_scope|Design Review|Adversarial review|gstack browser evidence|\\$B status|screenshot|responsive' appmaker/backlog appmaker/features appmaker/reviews appmaker/checklists appmaker/qa`
- `find appmaker/context -type f`
- `git status --short` and `git log -1 --format=%ct -- graphify-out/GRAPH_REPORT.md` if git repo
- Memory checks (scope=memory or project):
  - broken `[[links]]`: `rg -no '\[\[[^]]+\]\]' appmaker/memory/` then for each match `test -f appmaker/memory/wiki/<name>.md || test -f appmaker/memory/<name>.md`
  - stale wiki: `find appmaker/memory/wiki -name '*.md' -mtime +30`
  - raw orphans: `find appmaker/memory/raw -name '*.md' ! -name 'README.md' -mtime +30` then `rg -l "<stem>" appmaker/memory/log.md`

Do not rely on vibes when a file/regex check is possible.

### Shell safety (Bash tool on macOS often runs via zsh)

⚠ macOS default `$SHELL=/bin/zsh`. Claude Code's Bash tool may invoke zsh subprocess. Several variable names are **read-only in zsh** and will fail assignment:

- `status` (zsh built-in — last command's exit code)
- `path` (zsh built-in — $PATH as array)
- `argv`, `argc`
- `pipestatus`

**Use safe names instead:** `check_state`, `result`, `outcome`, `file_path`, `n_args`.

Example — DO:
```bash
check_state="PASS"
result=$(rg -c 'pcrit-' appmaker/features/*/prd.md || echo 0)
```

Example — DON'T:
```bash
status="PASS"          # zsh: read-only variable
path="/some/dir"       # zsh: read-only variable
```

If zsh rejection happens, retry the same logic with safe variable names — do NOT switch to subshell hacks.

### PRD criterion ID format

Canonical: `pcrit-NNN` (e.g. `pcrit-001`). **BUT projects may use other stable ID schemes** (e.g. `SC1`/`ID1`, `R1`/`AC1`). Don't FAIL on format alone — check that:
- IDs are unique within PRD
- traces_to references resolve to existing IDs in PRD
- format is consistent within the project (mixed `pcrit-001` + `SC1` in same PRD → WARN)

### 4. Human judgment checks

After deterministic checks:
- Are PRD success criteria verifiable?
- Are `human_required` slices justified?
- Did Graphify context become accidental scope creep?
- Does memory wiki contain durable synthesis, not raw dumps?

Mark as WARN unless clear contradiction.

### 5. Write report — **compact contract**

Save to `appmaker/checklists/<YYYY-MM-DD>-<scope>.md` using this **exact skeleton** (skip empty sections, no counts in frontmatter, no Suggested Next, no prose deep-dives):

```markdown
---
scope: feature 003-add-dark-mode
status: FAIL
created: 2026-05-11
---

# Checklist: feature 003-add-dark-mode

**14 PASS / 1 FAIL / 2 WARN**

## Checks

| ID | Status | Check | Evidence | Fix |
|---|---|---|---|---|
| trace-coverage | FAIL | PRD IDs traced | `pcrit-004` missing from backlog | add slice or defer explicitly |
| ac-checkbox-coverage | WARN | Done items: all ACs ticked | slice 007: 4/9 ticked, 5 stray `[ ]` lines | tick or convert to `-` |
| graphify-freshness | WARN | Graph at HEAD | 6 commits ahead, mtime 8h stale | `graphify update .` |

## Blockers
- **trace-coverage**: `pcrit-004` orphan (no slice covers it). Fix: add slice or note deferral in `decomposition.md`.

## Warnings
- **ac-checkbox-coverage**: slice 007 has 5 stray `[ ]` inside description, not real ACs. Fix: replace with `-` bullets.
- **graphify-freshness**: graph 6 commits behind HEAD. Fix: `graphify update .` (AST-only, no API cost).
```

**Forbidden:**
- `## Summary` heading with prose explanation (replace with single bold count line)
- `## Suggested Next` section (next-action belongs in chat reply, not the file)
- `fail_count` / `warn_count` / `pass_count` in frontmatter
- Multi-paragraph Warnings with "What:/Why:/Fix:" sub-blocks
- Empty `## Blockers — None.` filler — omit the heading entirely
- Evidence cells longer than 80 chars — compress or move to Warnings bullet

Persist via Bash heredoc:
```bash
mkdir -p appmaker/checklists
REPORT_PATH="appmaker/checklists/$(date -u +%Y-%m-%d)-<scope-slug>.md"
cat > "$REPORT_PATH" <<'REPORT_EOF'
[compact skeleton above, filled in]
REPORT_EOF
test -f "$REPORT_PATH" && echo "✓ Checklist: $REPORT_PATH"
```

### 6. Gate output

- Any FAIL -> final status FAIL
- No FAIL, any WARN -> WARN
- No FAIL/WARN -> PASS

## Guardrails

- **PASS/FAIL/WARN mandatory.** No essay-only output.
- **Evidence mandatory.** Every FAIL/WARN cites file/path/line or explicit missing artifact.
- **No auto-fix.** Report first; user chooses fix.
- **Don't block on Graphify freshness alone.** Stale graph is WARN unless user requested graph-dependent archive.
- **Don't treat graph neighbors as requirements.** Only PRD/AC create scope.
- **Don't skip blocker cycle check.**
- **Don't archive/promote on FAIL** unless explicit override flow exists.
