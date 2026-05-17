# Lessons Memory

Post-retro lessons learned. Appended by `/appmaker:archive` when retro run.

Format: `- [<feature-id>] <one-line lesson> (durable: <destination>)`

---

- [001] METHOD.md correction: PRD upstream source of intent, never rollup of slices (durable: decisions.md)
- [001] Dogfood location `dogfood/appmaker/` (not `appmaker/`) escapes plugin source `.gitignore` (durable: decisions.md)
- [001] Test extension > test creation when contract overlap exists in adjacent test (durable: wiki/testing.md)
- [001] Scoped regex pattern for docs drift — anchor to visual context, not content (durable: wiki/testing.md)
- [001] Test from failure mode, not AC paraphrase — zielony test ≠ AC enforcement (durable: wiki/testing.md)
- [001] Cross-slice review catches different errors than per-slice — both gates necessary (durable: wiki/integration-gotchas.md)
- [001] PRD addendum as honest correction, not failure — `source: decompose-addendum` preserves audit chain (durable: wiki/integration-gotchas.md)
- [002] Capture first, automate later — MVP design move for new audit/observability features (durable: decisions.md)
- [002] Self-applying meta-test for new contracts (n=2 validated) — introducing feature applies own contract (durable: wiki/integration-gotchas.md)
- [002] Line-number ordering checks in tests — structural anchor, not content match (durable: wiki/testing.md)
- [002] Drift class closure pattern works cycle 1 — v0.2.18 narrative coherence test caught v0.2.19 drift first usage (durable: wiki/integration-gotchas.md)
- [002] Bump checklist now 5 places — plugin.json + marketplace.json + test EXPECTED + README narrative + DESIGN narrative (durable: wiki/integration-gotchas.md)
