# AppMaker Design History (pre-v0.2.5 decisions 1-29)

Archived from `DESIGN.md` in v0.2.10 to reduce active document size. These decisions established AppMaker's foundational architecture and are now stable — they're preserved here as the design rationale record.

For current decisions (30+) and active architecture, see [DESIGN.md](DESIGN.md).

---

## Foundational decisions (1-29)

1. **Forma** = Claude Code plugin (`plugin/appmaker/skills/<name>/SKILL.md`). Loaded via `--plugin-dir`.
2. **Filozofia** = Matt Pocock minimalism. Markdown only, no framework code.
3. **Cel** = "produkt który wszystko zepnie" — end-to-end orchestrator.
4. **Pair** = Graphify (optional Layer 3, separate tool, no hard dependency).
5. **Critic role** = Claude Code subagent via `Agent` tool. Provider-agnostic.
6. **Pozycjonowanie** = P-Hybrid (3 layers each opt-in) + Layer 4 AFK runner opt-in.
7. **Skill count** = 15 core + 4 opt-in TODO + 1 Layer 4 implemented + 1 Layer 4 adapter TODO.
8. **Project state** = `appmaker/` directory in user project (constitution + memory + features + backlog + skills + templates).
9. **Memory strategy** = lazy retrieval, NIE always-on dump.
10. **Per-feature folder** = OpenSpec-style `appmaker/features/<NNN-slug>/` z structured artifacts.
11. **Self-learning loop** = `appmaker/memory/lessons.md` + retro in archive skill.
12. **Output consolidation** = predictable per project per skill.
13. **Session start hook** = optional, wymusza load active context.
14. **Multi-project inheritance** = opt-in, leverages Claude Code parent CLAUDE.md.
15. **Layer 4 AFK runner** = implemented as conservative opt-in skill. Runs only explicit `execution_class: autonomous` items after checklist/review gates.
16. **Backlog persistence** = local markdown default. GitHub issues jako opcjonalny adapter (`/appmaker:sync-github`).
17. **`/appmaker:feedback`** = CORE. Quick capture skill → backlog item.
18. **`/appmaker:glossary`** = CORE, "invisible by default". Auto-maintained przez `interview`/`prd`/`decompose`/`grill`.
19. **`/appmaker:checklist`** = CORE (per Spec Kit `/speckit.analyze` pattern).
20. **Clarifications section pattern** w PRD (per Spec Kit). PRD ma `## Clarifications` block auto-populated przez `/appmaker:clarify`.
21. **Numbered feature folders** = `appmaker/features/001-add-dark-mode/`. Liczba = kolejność (auto-incremented).
22. **Templates jako separate files** w `appmaker/templates/`. Override per-project.
23. **Multi-file SKILL pattern** = default single `SKILL.md`, BUT skill MAY reference supporting files w project tree `appmaker/skills/<name>/`. Example: `/appmaker:tdd` references `appmaker/skills/tdd/{deep-modules,interface-design,mocking,refactoring,tests}.md`.
24. **`/appmaker:spike` adopts Matt's `prototype` 1:1**. Supporting: `appmaker/skills/spike/{LOGIC.md, UI.md}` (TODO).
25. **`/appmaker:grill` jako separate CORE** (adopts Matt's `productivity/grill-me` 1:1). General-purpose.
26. **`/appmaker:grill-brownfield` jako separate CORE** (adopts Matt's `engineering/grill-with-docs` 1:1).
27. **Forest's CLAUDE.md = optional integration in `/appmaker:init`** (NOT bundled). Curl from upstream.
28. **Format refactor (skills → slash commands, 2026-05-10)** — initial design used `.claude/skills/<name>/SKILL.md` (Matt Pocock skill format with auto-invocation). Moved to `.claude/commands/appmaker/<name>.md` (slash command format) per OpenSpec/Spec Kit convention.
29. **Plugin refactor (slash commands → plugin, 2026-05-11)** — per official Claude Code docs (`/en/plugins`), subdirs in `.claude/commands/` are organizational only — `/appmaker:start` namespace prefix requires plugin format. Final structure: `plugin/appmaker/skills/<name>/SKILL.md`. Loaded via `claude --plugin-dir /path/to/AppMaker/plugin/appmaker`. Invocation: `/appmaker:<name>` (colon namespace, OpenSpec style). Per-skill `disable-model-invocation: true` for side-effect skills (init, interview, prd, decompose, tdd, context, archive), `false` for read-only / informational (start, grill, review, glossary). Validated via `claude plugin validate` (passes).

---

**Archival date:** 2026-05-11 (v0.2.10 token-diet patch)

**Why archived:** these 29 decisions are stable foundational architecture — moved out of `DESIGN.md` so the active document focuses on current-era patches (30+). Foundational rationale is preserved here for future audits and onboarding.
