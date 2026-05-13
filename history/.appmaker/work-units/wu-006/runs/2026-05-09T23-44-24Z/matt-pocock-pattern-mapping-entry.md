### Entry 3: `to-prd` → AppMaker PRD Synthesis

| Field | Value |
|---|---|
| `source_skill` | `Matt_Pocock_Skills/skills/engineering/to-prd/SKILL.md` |
| `source_commit` | `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30) |
| `license` | MIT |
| `adr_reference` | ADR-004 |
| `appmaker_pattern` | PRD Synthesis |
| `surface` | lifecycle |
| `output_artifact` | `.appmaker/prd.md` (single project-level, kernel-managed; per ADR-004 §D2) |
| `notes` | Adapted from Matt Pocock's `/to-prd`. AppMaker adds: Understanding section with 7 mandatory subsections (users/buyers/operators, domain invariants, identity model, trust boundaries, non-delegable human judgments, verifiable success criteria, failure modes / unacceptable outcomes) per WU-005 lesson human_understanding; verifiable success criteria with auto-check OR human-review-with-criteria treatment per WU-005 lesson verifiability_bias; field-by-field consumption rule for `interview-result.yaml` per ADR-004 §D5 (no silent omission); PRD-required-before-decomposition gate per ADR-004 §D4; ready_with_override propagation from Interview per ADR-004 §D6 (PRD status `ACCEPTED_WITH_INHERITED_OVERRIDE`, UPPERCASE per work-unit-v1 status enum convention). AppMaker does NOT adopt Matt's "publish to issue tracker" step — no built-in issue tracker dependency in v1; PRD lives in `.appmaker/`-managed location. |
