---
description: Security gate. Runs deterministic external scanners (secrets, dependency audit, SAST) over the project + .claude config, then optionally layers an LLM critic for injection/trust-boundary issues, and persists a PASS/FAIL/WARN report. Vendor-agnostic — you configure which scanners. Use before archiving auth/payments/security/migration work, or after touching .claude/ config.
disable-model-invocation: true
---

Safety/validator gate. Adapts the ECC AgentShield pattern (MIT) into AppMaker's "no vendor lock" shape: **deterministic facts first, LLM judgment second, never invent findings.** Closes two deferred future-scope items — *Backpressure & Safety/Quality Hooks* and partial *Validator* — without a runtime or a single hardcoded tool.

**Vendor-agnostic by design.** The *pattern* is "external deterministic scan + optional LLM overlay". The *tools* are your choice (`security_scan_commands` in config): `gitleaks`, `npm audit`, `pip-audit`, `semgrep`, `trivy`, or `npx ecc-agentshield scan` — any/all. The LLM overlay runs as the configured `security_subagent`. Nothing here depends on a specific vendor.

**Output style:** Compact report contract + Verdict vocabulary in `appmaker/skills/output-style.md`. Quality verdict is `PASS | FAIL | WARN` — never SHIP/NEEDS_WORK.

## When to invoke

- Manual: `/appmaker:security-scan [scope]` where scope is `diff` (default), `project`, `config` (.claude/ + settings + MCP), or a `<backlog-id>`.
- Suggested by `next`: before `archive` when `rigor_level: strict` (and `security_gate_on_strict: true`), or when the feature/slice labels include `security`/`auth`/`payments`/`migration`.
- Auto: never (side-effect skill).
- AFK-safe: yes for the deterministic pass (scanners are non-interactive); the LLM overlay + gate decision are reported, not auto-fixed.
- Required state: `appmaker/` initialized for persistence; scanners installed for the deterministic pass.
- Required input: scope (auto-detected; defaults to `diff`).

## Process

### 1. Resolve scanners (deterministic engine)

Read `security_scan_commands` from `appmaker/config.yaml`. If empty, auto-detect what's installed (run only those present — a missing tool is a `WARN`, not a `FAIL`):

```bash
CMDS=$(grep -A20 '^security_scan_commands:' appmaker/config.yaml 2>/dev/null)
# If the list is empty [], auto-detect available scanners:
DETECTED=()
command -v gitleaks  >/dev/null 2>&1 && DETECTED+=("gitleaks detect --no-banner --redact")
[ -f package.json ]  && command -v npm >/dev/null 2>&1 && DETECTED+=("npm audit --omit=dev")
{ [ -f requirements.txt ] || [ -f pyproject.toml ]; } && command -v pip-audit >/dev/null 2>&1 && DETECTED+=("pip-audit")
command -v semgrep   >/dev/null 2>&1 && DETECTED+=("semgrep --error --quiet --config auto")
command -v npx       >/dev/null 2>&1 && DETECTED+=("npx ecc-agentshield scan --format json")  # AgentShield: one valid backend
printf 'Scanners available: %s\n' "${DETECTED[*]:-NONE — record WARN, fall back to LLM overlay only}"
```

If neither configured nor detected scanners exist: record a `WARN` ("no deterministic scanner available"), do **not** silently PASS, and proceed to the overlay (step 3) so the gate still produces signal.

### 2. Run scanners, collect facts

Run each scanner. Capture exit code + findings verbatim. **These are facts — do not paraphrase severity or invent findings.** Normalize each into: `tool | severity | file:line | what`. For `config` scope, point scanners at `.claude/` (settings.json, CLAUDE.md, MCP configs, hooks, agent defs) — the injection/permission/secret surface.

### 3. LLM critic overlay (optional, separates facts from judgment)

If `security_subagent` is set (non-empty), invoke it via the `Agent` tool over the diff/config — to catch what pattern-scanners miss: prompt-injection surface, trust-boundary bugs, silent error suppression (`2>/dev/null`, `|| true`), broad permissions, unpinned `npx`, secrets in non-obvious places. Pass the deterministic findings as context so it doesn't re-report them.

```
Agent(subagent_type: <security_subagent>, description: "Security overlay: <scope>",
      prompt: <diff/config + scanner facts + checklist above + "flag only NEW issues; cite file:line; never invent">)
```

Provider-agnostic: read the type from config; never hardcode a vendor. Empty `security_subagent` = skip overlay (deterministic-only gate).

### 4. Classify + gate

| Verdict | Trigger |
|---|---|
| `FAIL` | ≥ 1 critical: hardcoded secret/token, `Bash(*)` / unscoped allow-list, command injection in a hook, shell-running MCP, known-exploited dependency. |
| `WARN` | Medium/high non-critical: missing deny-list, silent error suppression, unpinned `npx -y`, agent with unnecessary Bash, scanner unavailable. |
| `PASS` | No critical or unaccepted-high findings. |

Critical = block. Never auto-fix; surface to the user (constitution rule 1 — no silent fallbacks).

### 5. Persist — MANDATORY when `appmaker/` exists

Write to `security_report_dir` (default `appmaker/security/`). Persist via Bash; verify with `test -f`.

```bash
mkdir -p appmaker/security
SCAN_PATH="appmaker/security/$(date -u +%Y-%m-%d-%H%M)-<scope>.md"
cat > "$SCAN_PATH" <<'SEC_EOF'
---
scope: <diff | project | config | backlog NNN>
verdict: PASS | FAIL | WARN
created: 2026-06-02
provenance:
  author: appmaker:security-scan
  created: 2026-06-02
  source: <scanners run + overlay subagent | scanners only>
  confidence: file_verified
---

# Security Scan: <scope>

**N critical / M high / K medium**   |   **Verdict:** <PASS|FAIL|WARN>

## Findings  ← only if any
| Tool | Severity | Location | Issue | Fix |
|---|---|---|---|---|
| gitleaks | critical | src/db.ts:14 | hardcoded API key | move to env, rotate key |

## Scanners run
- gitleaks ✓ (exit 1, 1 finding) · npm audit ✓ (0 high) · semgrep — not installed (WARN)
SEC_EOF
test -f "$SCAN_PATH" && echo "✓ Security scan → $SCAN_PATH"
```

### 6. Chat reply (after persistence)

Compact. Verdict + critical findings inline + handoff.

```
✓ Security: diff → FAIL (1 critical, 2 medium)
  Saved: appmaker/security/2026-06-02-1410-diff.md
  Critical: src/db.ts:14 hardcoded API key → move to env + rotate.
  Fix then re-run /appmaker:security-scan diff
```

On PASS, suggest the next lifecycle step (`/appmaker:archive` if pre-archive gate). On FAIL the user decides fix-vs-override; never auto-mark anything done.

## Guardrails

- **Deterministic facts first.** Scanner output is the source of truth; the LLM overlay adds judgment, never overrides facts. Keep them separable in the report.
- **Never invent findings.** No scanner finding + no overlay finding = honest PASS (or WARN if no scanner ran). Don't manufacture severity.
- **No silent PASS without a scan.** Missing tools = WARN, not PASS (constitution rule 1).
- **Critical = block.** Never auto-fix; surface to user. Override is explicit + logged, same as `/appmaker:review`.
- **Vendor-agnostic.** Tools come from `security_scan_commands`; overlay from `security_subagent`. AgentShield is one option, not a dependency.
- **Config scope is real.** Scanning `.claude/` (permissions, hooks, MCP, agent defs) is a first-class scope — that's where injection/permission risk lives.
- **Don't duplicate `/appmaker:review`.** Review = correctness/quality/constitution. Security-scan = secrets/deps/injection/permissions. They compose; they don't replace each other.
- **Quality vocabulary only.** PASS/FAIL/WARN — never SHIP/NEEDS_WORK.
