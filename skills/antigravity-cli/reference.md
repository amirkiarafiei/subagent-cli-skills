# Antigravity CLI — reference

> **Verified against `agy` v1.1.12 on 2026-08-12 by running the binary.** Flags change between builds,
> and this vendor's changelog has announced flags the shipped binary rejects. `agy --help` and
> `agy models` are the only authorities. On `flags provided but not defined`, re-read `--help`, use
> what exists, and report that this file needs updating.

## Authentication

Silent keyring sign-in (local), Google Sign-In via an SSH URL (remote), or `/logout`. Headless mode
reuses cached credentials — authenticate once interactively first, or an unauthenticated run exits
with an authentication error.

## Models

Run **`agy models`** for the identifiers this build accepts. No fixed list is reproduced here: names
and tiers change, and a list written into this file goes stale.

Identifiers carry a reasoning tier. Pass either a full tiered identifier, or a family name together
with `--effort low|medium|high` — a family name **alone is rejected** with
`requires --effort (available: low, medium, high)`. Headless mode does **not** fall back on an unknown
model: it exits non-zero with `status: "ERROR"` and lists what is available in the `error` field.

Note that `agy models` does **not** accept `--output-format` on this build, despite the changelog
announcing it.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print`, `--prompt` | Run a single prompt non-interactively and print the response. **Required for delegation.** |
| `--output-format` | `text` (default), `json`, `stream-json`. |
| `--model` | Model identifier for this run (see `agy models`). |
| `--effort` | Reasoning effort: `low`, `medium`, `high`. |
| `--mode` | `accept-edits` or `plan`. Do not use `plan` for delegation. |
| `--add-dir` | Add a directory to the workspace (repeatable). **Absolute paths only.** |
| `--print-timeout` | Maximum wait for a response; default `5m`. |
| `--json-schema` | Schema string or file path to enforce structured output. |
| `--dangerously-skip-permissions` | Auto-approve every tool. Blunt — prefer `--add-dir` and allow-rules. |
| `--agent` | Select an agent for the run (see `agy agents`). |
| `--sandbox` | Run with terminal sandbox restrictions enabled. |
| `--disable-slash-commands` | Disable slash command and skill expansion in print mode. |
| `-c`, `--continue` | Continue the most recent conversation. |
| `--conversation <id>` | Resume a conversation by ID. |
| `--log-file` | Override the CLI log file path. |
| `--project`, `--new-project` | Workspace and project scoping. |

**Not flags on this build** (all rejected, though older docs or sibling skills name them): `--bare`,
`-o`, `--yolo`/`-y`, `-m`, `--worktree`/`-w`, `--resume`/`-r`. Use `--print`, `--output-format`,
`--dangerously-skip-permissions`, `--model`, and `--continue`/`--conversation` instead.

## Approvals and permissions

Headless mode cannot prompt, so a tool requiring approval is **soft-denied**: the run continues,
**exits 0**, `status` is `SUCCESS`, `response` is **empty**, and a notice naming the tool goes to
**stderr**. Under `--output-format text` this looks like silent success with no output — always check
for empty output rather than trusting the exit code.

Grant the narrowest access that works:

1. **`--add-dir /abs/path`** — file reads are *not* granted by the shell's working directory, and a
   relative path such as `.` does not resolve to your cwd. Absolute paths only.
2. **Allow-rules** under `permissions.allow` in `~/.gemini/antigravity-cli/settings.json`, matching
   `action(target)`:
   ```json
   { "permissions": { "allow": ["command(git)", "command(npm run (build|lint|test))", "write_file(src/)"] } }
   ```
   `trustedWorkspaces` is a *trust* setting and does **not** grant tool permissions.
3. **`--dangerously-skip-permissions`** — last resort; approves writes and command execution too.

Inspect the rules actually in effect with `agy -p "/permissions"` — read-only slash commands answer in
print mode without starting an agent turn, spending quota, or leaving a conversation behind.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `agy models` | List available model identifiers. **The authority on `--model` values.** |
| `agy agents` | List available agents. **Returns empty when none are configured** — do not assume named specialists exist. |
| `agy changelog` | Release notes; useful for explaining a behaviour that changed under you. |
| `agy plugin` / `plugins` | Install, uninstall, list, enable, disable plugins. |
| `agy install` | Configure environment paths and shell settings. |
| `agy update` | Update the CLI. |

The supported way to pick a specialist is **`--agent <name>`**, discovered with `agy agents`. An
`@name` prefix inside the prompt is **not** a dispatch mechanism — if no such agent exists the text is
simply read as part of the prompt.

## Agent Skills

| Scope | Path |
|---|---|
| **Global (user)** | `~/.gemini/antigravity-cli/skills/` |
| **Workspace** | `<workspace-root>/.agents/skills/` |

## Configuration and paths

| Component | Path |
|---|---|
| Configuration and permissions | `~/.gemini/antigravity-cli/settings.json` |
| CLI logs | `~/.gemini/antigravity-cli/log/`, `~/.gemini/antigravity-cli/cli.log` |
| Conversations | `~/.gemini/antigravity-cli/conversations/` |
| MCP configuration | `~/.gemini/antigravity-cli/mcp_config.json` |
| Global rules | `~/.gemini/GEMINI.md` |
| Workspace rules | `<workspace-root>/.agents/rules/` |

## Documentation

- Vendor documentation: <https://antigravity.google/docs/cli/headless>, <https://antigravity.google/docs/cli/reference>
- **Verified against `agy` v1.1.12 on 2026-08-12 by running the binary** — the only file in this
  catalog with binary-level verification rather than a documentation check.

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
