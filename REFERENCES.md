# References

External projects, articles, and concepts that influenced AppMaker's design (P-Hybrid). Not exhaustive — only entries with concrete value for future decisions.

Last updated: 2026-05-10.

---

## Core inspirations (directly adopted)

### Matt Pocock Skills

- **Canonical repo:** https://github.com/mattpocock/skills (official, "Skills for Real Engineers")
- **Mirror/fork:** https://github.com/patjfree/Matt_Pocock_Skills (older snapshot)
- **Local clone (older):** `/Users/pawel/Projects/Matt_Pocock_Skills/`
- **License:** MIT, Copyright (c) 2026 Matt Pocock
- **Pinned commit (older snapshot):** `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8`
- **What:** Single-purpose markdown SKILL.md files for Claude Code, organized in folders (engineering/productivity/misc/personal/in-progress/deprecated)
- **Active skills as of May 2026:**
  - `engineering/`: diagnose, grill-with-docs, improve-codebase-architecture, setup-matt-pocock-skills, tdd, to-issues, to-prd, triage, zoom-out, prototype
  - `productivity/`: caveman, grill-me, write-a-skill
  - `misc/`: git-guardrails-claude-code, migrate-to-shoehorn, scaffold-exercises, setup-pre-commit
  - `in-progress/` (new): handoff, writing-beats, writing-fragments, writing-shape
  - `deprecated/` ("Skills I no longer use"): design-an-interface, qa, request-refactor-plan, **ubiquitous-language**
- **Why for AppMaker:** Form factor + philosophy template. Each AppMaker skill modeled after Pocock pattern.
- **Key insight:** "Inspiracja > runtime dependency" — copy-paste skill markdown, modify, no framework.

### Matt Pocock — `deprecated/ubiquitous-language` (adopt format)

- **Path (older clone):** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/deprecated/ubiquitous-language/SKILL.md`
- **Status:** Matt deprecated standalone version. **BUT** in his real-world workflow video, he actively maintains `UBIQUITOUS_LANGUAGE.md` as **byproduct** of grill-me/PRD skills (not standalone invocation).
- **Why for AppMaker:** Adopt the **format** (tables: Term | Definition | Aliases to avoid; example dialogue; flagged ambiguities) for `appmaker/glossary.md`. Adopt the **process** (auto-maintenance as byproduct) into `interview`/`prd`/`decompose` skills.
- **Caveat:** Matt deprecated for unstated reason. Possible: stale-glossary maintenance overhead. Mitigation: auto-update on every skill execution, track `last_updated_by` field.

### Matt Pocock — `engineering/improve-codebase-architecture/LANGUAGE.md` (per-skill vocabulary pattern)

- **Path:** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/engineering/improve-codebase-architecture/LANGUAGE.md`
- **What:** Skill-local vocabulary file defining "Module", "Interface", "Implementation", "Depth", "Seam", "Adapter", "Leverage", "Locality" — terms specific to that skill's domain.
- **Why for AppMaker:** Optional pattern for AppMaker skills with unique vocabulary. Each skill MAY have local "Skill-specific terms" section that supplements (not replaces) `appmaker/glossary.md`. Use sparingly — only when skill-domain has truly local terms.

### Matt Pocock — `productivity/caveman` (style guide for AppMaker skills)

- **Path:** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/productivity/caveman/SKILL.md`
- **What:** Ultra-compressed communication style — drop articles/filler/pleasantries, fragments OK, abbreviations (DB/auth/config), pattern `[thing] [action] [reason]. [next step].`, ~75% token reduction.
- **Why for AppMaker:** Adopt as **mandatory style guide** for writing AppMaker skill markdown. Per DESIGN.md decision: all AppMaker skills written in caveman style. Exception: security warnings, destructive op confirmations, multi-step sequences, error messages quoted exact.

### OpenSpec

- **Repo:** https://github.com/Fission-AI/OpenSpec
- **NPM:** `@fission-ai/openspec` (~41k★, v1.3.1)
- **Local:** `/opt/homebrew/lib/node_modules/@fission-ai/openspec/`, `/Users/pawel/Projects/ClaimCompass/openspec/`
- **License:** MIT
- **What:** Spec-driven dev framework, 4 core slash commands (`/opsx:propose`, `/apply`, `/archive`, `/explore`) + 7 expanded
- **Why for AppMaker:** Per-change folder pattern (`changes/<name>/proposal.md + specs/ + design.md + tasks.md`), archive flow, "fluid not rigid" philosophy
- **Key insight:** No phase gates ≠ no structure. Convention without coercion.

### Spec Kit

- **Repo:** https://github.com/github/spec-kit
- **Maintainer:** GitHub, ~93.9k★, v0.8.7 (May 2026)
- **What:** 5-phase spec-driven workflow (constitution → specify → plan → tasks → implement) with optional deepening commands (clarify/analyze/checklist)
- **Why for AppMaker:** Constitution layer concept (project-level principles), opt-in deepening commands pattern
- **Slash commands:** `/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`, `/speckit.clarify`, `/speckit.analyze`, `/speckit.checklist`

### Graphify

- **Repo:** https://github.com/safishamsi/graphify
- **Site:** https://graphify.net/
- **PyPI:** `graphifyy` (double-y) — v0.7.13 (May 9, 2026), 45.8k★ in ~5 weeks
- **License:** MIT, single maintainer (Safi Shamsi)
- **What:** Knowledge graph builder for AI coding assistants. 3-pass architecture: code (tree-sitter, local) + audio/video (faster-whisper, local) + docs/PDFs (Claude API, runs once).
- **Output:** `graphify-out/graph.html`, `GRAPH_REPORT.md`, `graph.json`
- **Claude Code integration:** PreToolUse hook intercepts before file-search calls, surfaces graph context first
- **Supports:** 29 code languages, 16+ AI assistants (Claude Code, Codex, OpenCode, Cursor, Gemini CLI, etc.)
- **Why for AppMaker:** Optional Layer 3 pair. AppMaker = workflow orchestration, Graphify = passive context layer.
- **Origin:** Built ~48h after Karpathy's "LLM Knowledge Bases" workflow post (April 1, 2026); released April 3, 2026
- **Caveats:** Pre-1.0 (breaking changes possible), single maintainer (bus factor), 71.5x token claim is naive-baseline cherry-pick (real saves ~7-8% per query plus quality improvement)

---

## Tools considered (alternatives or potential future integrations)

### Code-Review-Graph

- **Repo:** https://github.com/tirth8205/code-review-graph
- **What:** Alternative to Graphify, uses MCP (Model Context Protocol) instead of hooks
- **Claims:** 8.2x avg / 49x monorepo token reduction; <2s incremental updates; 28 MCP tools
- **Why noted:** Cleaner MCP-based architecture; consider if Graphify becomes unmaintained
- **License:** Likely MIT (verify)

### Aider

- **Repo:** https://github.com/Aider-AI/aider
- **Repo-map docs:** https://aider.chat/docs/repomap.html
- **What:** Open-source AI pair programming tool with sophisticated repo-map (tree-sitter + PageRank, 1k token budget default)
- **Why noted:** Repo-map algorithm is the seminal pattern that Graphify and others follow. If we ever build custom context compression, Aider's algorithm is the reference.

### Claude Code Memory Setup (Obsidian + Graphify combo)

- **Repo:** https://github.com/lucasrosati/claude-code-memory-setup
- **What:** Combines Obsidian (knowledge management) + Graphify (codebase graph) for persistent memory
- **Why noted:** Pre-built integration pattern if user already uses Obsidian for notes
- **Includes:** PT-BR docs

### Anthropic Skills repo

- **Repo:** https://github.com/anthropics/skills (official)
- **What:** SKILL.md format spec, skill-creator skill, mcp-builder
- **Why noted:** Authoritative format reference for skill markdown structure

### VoltAgent — awesome-claude-code-subagents

- **What:** 100+ curated Claude Code subagents
- **Why noted:** Reference catalog for subagent role design (NOT bulk install — pick selectively for AppMaker subagent invocations like critic in `/appmaker:review`)

### Other glossary / DDD skills considered (not adopted)

- **`mcpmarket.com/ubiquitous-language-glossary`** — Slack-based extractor. NOT applicable (Claude Code doesn't have Slack history access).
- **`mcpmarket.com/ubiquitous-language-extractor-2`** — Same Slack-centric approach.
- **`skills.rest/sdd-glossary`** — Generates DDD glossary; full content gated (403 fetch). Worth revisiting if Matt's deprecated format proves insufficient.
- **`mcpmarket.com/ddd-strategic-design`** — Comprehensive DDD skill (Bounded Contexts, Context Maps, stakeholder interviews). Heavy. Reference if AppMaker ever extends to multi-bounded-context projects.
- **`github.com/ruvnet/agentic-flow`** — `v3-ddd-architecture` skill in `agentic-flow/.claude/skills/v3-ddd-architecture/SKILL.md`. Reference for DDD architecture patterns.
- **`github.com/ruvnet/ruflo`** wiki — `CLAUDE-MD-DDD` page documents CLAUDE.md patterns for DDD projects.

**Why not adopted now:** Matt's deprecated `ubiquitous-language` SKILL.md format is sufficient for AppMaker's scope and aligns with our minimalist philosophy. Heavier DDD tools (Bounded Contexts, Context Maps) would over-engineer for typical solo-dev / small-team use case.

---

## Memory tools mentioned (Agentic OS context)

| Tool | What it does | Status |
|---|---|---|
| `claude-mem` | Semantic search over Claude conversation memory | Considered |
| `mem-search` | Similar semantic memory tool | Considered |
| `mem palace` | Verbatim recall (word-for-word) | Likely overkill |

These are referenced in the "Agentic OS" video (Memory Levels 3-4). Our P-Hybrid uses simpler `appmaker/memory/*.md` lazy retrieval — these tools may be relevant if scaling beyond solo developer use case.

---

## Patterns / articles (background reading)

- **Karpathy's LLM Knowledge Bases workflow** — original X post inspiring Graphify and similar tools (April 1, 2026): https://x.com/socialwithaayan/status/2041192946369007924
- **Analytics Vidhya: From Karpathy's LLM Wiki to Graphify** (April 2026): https://www.analyticsvidhya.com/blog/2026/04/graphify-guide/
- **emelia.io: Knowledge Graphs for Codebases — Complete Guide to Graphify**: https://emelia.io/hub/knowledge-graph-graphify-guide
- **Matt Pocock Top 5 Skills article** — referenced in Pocock's real-world workflow video (need URL — find via Pocock's blog/YouTube)
- **Agentic OS video** — content marketing for "Agentic Academy" community; useful for: session start hooks, multi-client folder inheritance, output consolidation patterns. Bias: sales pitch for paid template.

---

## Concepts (no specific repo)

- **Domain-Driven Design — Ubiquitous Language** (Eric Evans book): the pattern Matt Pocock adopts for `glossary.md` auto-maintained by skills. Bridges human-domain-expert ↔ LLM-developer language gap.
- **Day shift / Night shift** (Matt Pocock + @jamonholmgren on Twitter): mental model for AppMaker UX. Day = human grilling/QA, night = AFK Ralph loop execution.
- **Tracer bullet** (Pragmatic Programmer): vertical slice principle. Each slice demoable on its own. Adopted in `/appmaker:decompose`.
- **Anthropic agentic patterns** — 5 patterns: Prompt Chaining, Routing, Parallelization, Orchestrator-Workers, Evaluator-Optimizer. AppMaker uses Prompt Chaining (skill-to-skill) + Evaluator-Optimizer (review subagent).
- **Progressive disclosure** (Anthropic skills best practice): name+description always loaded, full SKILL.md only when invoked, examples loaded on demand. Keep skills <200 lines for reliable recall.
- **MAKER paper voting algorithm** — referenced via AppsMaker-2025 (negative reference); high-stakes decision via k-candidate voting. Not adopted in P-Hybrid.

---

## Negative reference (lessons in what NOT to do)

### AppsMaker-2025

- **Local:** `/Users/pawel/Projects/AppsMaker-2025/`
- **Status:** Stalled at 75% complete since 2025-11-24, never shipped
- **What it did:** Implemented MAKER paper voting algorithm
- **Why stalled:** Over-scoped, never integrated with Claude Code skills/agents, ClaimCompass-specific, ambitious without minimal first cut
- **Lesson:** Don't over-scope v1. Ship working minimal first. The cautionary tale that justifies P-Hybrid's "each layer opt-in" design.

### Earlier AppMaker iteration (now in `history/`)

- **Local:** `/Users/pawel/Projects/AppMaker/history/`
- **What:** 5 ADRs (process kernel, interview, schemas, PRD, decomposition), 18 constitutional rules, 3 JSON Schemas, 23 lessons, 7 work_units, propagation chains, JSONL streams
- **Why archived:** Heavyweight self-bootstrap. ~80% of artifacts had low practical value for end users; mostly served meta-consistency. Caught by user instinct ("musimy się tu zatrzymać i zdefiniować"). See `DESIGN.md` for what survived.
- **Lesson:** Without concrete user, comprehensive design naturally expands to cover all hypothetical edge cases. Stop-points must come from human ("does this concretely help anyone today?").

---

## How to update this file

- Add new entries when discovering tools/repos that may influence AppMaker design.
- Note version, license, and a one-line "why for AppMaker" — not an exhaustive review.
- If a referenced project becomes unmaintained or fundamentally changes, mark it explicitly.
- Don't list every link encountered — only entries with **concrete future utility** (adopted, considered, alternative, negative reference, or significant pattern source).
