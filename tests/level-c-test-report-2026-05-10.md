# Level C Real Test — Plugin Validation

**Tester:** [your name]
**Project:** ClaimCompass (`/Users/pawel/Projects/ClaimCompass/`)
**AppMaker version:** 0.2.0 — 15/15 core skills + bounded `/appmaker:afk` (plugin format, post-refactor 2026-05-11)
**Test scenario:** Research workflow — "jak ClaimCompass radzi sobie z multi-tenant routing?"

## Architecture history (UPDATED 2026-05-11)

Two refactors done:
1. **Skills → slash commands** (2026-05-10): moved from `.claude/skills/` to `.claude/commands/appmaker/` per OpenSpec/Spec Kit convention
2. **Slash commands → plugin format** (2026-05-11): per official Claude Code docs, subdirs in `.claude/commands/` are organizational only — namespace prefix (`/appmaker:start`) requires plugin format. Final structure: `plugin/appmaker/skills/<name>/SKILL.md` loaded via `--plugin-dir` flag.

## Why this scenario

- **Safest entry test** — research-only, no code changes, no risk to production
- Tests **4 critical-path skills**: init, start, grill, glossary (auto-byproduct)
- Realistic dev use case — exploring own codebase
- Zero risk dla production code in ClaimCompass

After success here, optional next test = feature scenario (full lifecycle init → start → grill → interview → prd → decompose → tdd → review → archive).

## Pre-test verification

```bash
# Verify plugin source exists:
ls /Users/pawel/Projects/AppMaker/plugin/appmaker/.claude-plugin/plugin.json
ls /Users/pawel/Projects/AppMaker/plugin/appmaker/skills/   # Should show 18 dirs (15 core + afk + status v0.2.6 + token-audit v0.2.8)

# Verify plugin packaged resources:
ls /Users/pawel/Projects/AppMaker/plugin/appmaker/resources/appmaker/templates/   # 3 files
ls /Users/pawel/Projects/AppMaker/plugin/appmaker/resources/appmaker/skills/tdd/  # 5 files
ls /Users/pawel/Projects/AppMaker/plugin/appmaker/resources/appmaker/memory/wiki/ # 5 files
```

## Test steps

### Step 1: Open fresh Claude Code session with plugin loaded

```bash
cd /Users/pawel/Projects/ClaimCompass
claude --plugin-dir /Users/pawel/Projects/AppMaker/plugin/appmaker
```

**Critical first check:** w Claude Code session wpisz:
```
/help
```

Lista powinna pokazać `/appmaker:init`, `/appmaker:start`, `/appmaker:grill`, etc. **Jeśli nie ma — plugin nie załadował się** → debug:
- Czy ścieżka `--plugin-dir` poprawna?
- Czy plugin.json ma valid JSON?
- Run `/reload-plugins` w Claude Code

### Step 2: Initialize AppMaker

```
/appmaker:init
```

**Expected init flow** (from init/SKILL.md):
1. Detect: brownfield (Next.js + TypeScript + Supabase, 1200+ commits, 1931 tests)
2. Confirm via AskUserQuestion: brownfield, local backlog, NO Graphify (privacy concern), session hook YES, pre-commit YES, no multi-project
3. Optional: install Forest's CLAUDE.md? — recommended for universal agent baseline
4. Create `appmaker/` tree from plugin resources: templates, skills/tdd, memory/wiki, context, checklists, diagnostics, reviews, afk

**Capture in section "Init findings" below:**
- Did `/appmaker:init` autocomplete in `/`-menu? (validation Q1: plugin namespace works)
- Did init flow ask all 6-7 questions clearly via AskUserQuestion?
- Did `appmaker/` tree match expected structure?
- Did init materialize templates/skills/memory wiki without manual copy?
- Time taken: ____

### Step 3: Run start z research intent

```
/appmaker:start "research: jak ClaimCompass radzi sobie z multi-tenant routing?"
```

**Expected behavior** (from start/SKILL.md):
1. Detect intent → category RESEARCH
2. Read context: `appmaker/` exists, glossary empty, constitution loaded
3. Suggest skill chain: `/appmaker:grill` (single skill, no artifact)
4. Optionally invoke grill (after AskUserQuestion confirmation)

**Capture in section "Start findings" below:**
- Was classification natural? (RESEARCH category correct?)
- Did context detection work?
- Suggested chain sensible?
- Time taken: ____

### Step 4: Run grill on the research topic

If start auto-invoked grill, proceed. Otherwise:
```
/appmaker:grill "jak ClaimCompass radzi sobie z multi-tenant routing?"
```

**Expected behavior** (from grill/SKILL.md):
1. Read context: glossary, constitution
2. Map decision tree mentally (auth/URL/DB layers)
3. Walk one question at a time **with recommendations per question** (Matt Pocock signature)
4. Use AskUserQuestion tool per question
5. Explore codebase before asking facts
6. Detect closure when user satisfied
7. Auto-byproduct: invoke `/appmaker:glossary` to update `appmaker/glossary.md`

**Capture in section "Grill findings" below:**
- Were questions one-at-a-time?
- Were recommendations paired z każdym question?
- Did agent explore codebase before asking facts?
- Were questions sensible / surprising / shallow?
- Time to closure: ____ minutes
- How many questions: ____

### Step 5: Verify glossary auto-updated

```bash
cat /Users/pawel/Projects/ClaimCompass/appmaker/glossary.md
```

**Expected:** populated z domain terms identified during grilling.

**Capture in section "Glossary findings" below:**
- Were terms captured?
- Format match Matt Pocock template?
- Header has `last_updated_by: grill` and `term_count: N`?

## Findings

### Plugin loading verification (Q1 — critical)

[fill in: did /appmaker:init appear in /-menu?]

### Init findings

[fill in]

### Start findings

[fill in]

### Grill findings

[fill in]

### Glossary findings

[fill in]

## Issues encountered

[List any unexpected behavior, errors, or rough edges. Format: severity / what happened / what was expected / suggested fix.]

## What worked surprisingly well

[Things that went better than expected.]

## What needs fix before next test

[Blockers for moving to feature scenario test.]

## Decision after test

- [ ] Plugin loads correctly, critical path validated, ready for feature scenario test
- [ ] Plugin loads but skills have issues — fix before feature test
- [ ] Plugin doesn't load — debug `--plugin-dir` setup
- [ ] Major redesign needed before continuing

## Notes

[Free-form observations, surprises, ideas.]
