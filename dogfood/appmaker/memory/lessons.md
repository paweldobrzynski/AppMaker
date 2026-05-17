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
