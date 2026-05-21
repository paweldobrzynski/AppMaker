# Init Tooling Integrations

Use during `/appmaker:init` after the materialize script. These integrations are optional but highly recommended: without them AppMaker can still run, but GitHub workflow automation, Architecture Options Research, and browser-backed QA/design review are weaker. These are user-level tool connections, not project secrets. Never store GitHub tokens or Ref API keys in `appmaker/`, `CLAUDE.md`, or git-tracked files.

## GitHub CLI

Purpose: GitHub-backed backlog, issue lookup, PR/review automation, and source research.

1. Check install: `command -v gh`.
2. Check login: `gh auth status --hostname github.com`.
3. If missing or unauthenticated, ask before guiding the user to install `gh` or run `gh auth login`.
4. If successful, set `github_cli_enabled: true` in `appmaker/config.yaml`.
5. If the project remote is GitHub, infer `github_repo` from `git remote get-url origin`; ask before switching `backlog_provider: github`.

## Ref Tools MCP

Purpose: Architecture Options Research with current official docs, private indexed docs, and GitHub resources.

Current Ref docs:
- General install/auth: `https://docs.ref.tools/context/install/index`
- Codex config: `https://docs.ref.tools/context/install/codex`

Ref auth options:
- HTTP MCP endpoint: `https://api.ref.tools/mcp`
- API key query param: `https://api.ref.tools/mcp?apiKey=<your-api-key>`
- API key location: `https://ref.tools/keys`
- OAuth: omit the API key and let the MCP client start sign-in when supported.

For Codex CLI, user-level config is typically `~/.codex/config.toml`:

```toml
[mcp_servers.ref]
url = "https://api.ref.tools/mcp?apiKey=<your-api-key>"
```

Legacy stdio fallback:

```toml
[mcp_servers.ref]
command = "npx"
args = ["-y", "ref-tools-mcp@latest"]
env = { "REF_API_KEY" = "<your-api-key>" }
```

Verify with `codex mcp list` when Codex is the active client, or the equivalent MCP server list command for the user's client. If Ref is available, set `ref_tools_enabled: true` and keep `ref_tools_mcp_server: ref`.

## gstack Browser Runtime

Purpose: optional gstack browser runtime for `/appmaker:qa` and `/appmaker:design-review` screenshot/browser evidence.

Default install path:

```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

Verification:

```bash
B="$HOME/.claude/skills/gstack/browse/dist/browse"
$B status
```

If successful, set:

```yaml
gstack_enabled: true
gstack_browse_bin: ~/.claude/skills/gstack/browse/dist/browse
```

Do not run --team by default. Team mode changes repo/session behavior; only enable it after explicit user decision. Do not vendor gstack into AppMaker or project repos.
