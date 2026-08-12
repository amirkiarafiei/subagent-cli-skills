# Antigravity CLI — reference

Concise reference for agents. Auth: silent keyring sign-in (local), Google Sign-In via SSH URL (remote), or `/logout`. Headless mode reuses cached credentials—authenticate once interactively first, or an unauthenticated run exits with an authentication error.

> **Verify before trusting this file.** Flags change between builds, and the vendor changelog has described flags that the installed binary rejects. `agy --help` and `agy models` are the only authorities. On `flags provided but not defined`, re-read `--help` and report that this skill needs updating.
>
> *Verified against `agy` v1.1.12 on 2026-08-12.*

## Models (Discovery Required)

Run **`agy models`** for the slugs this build accepts. Consult [Artificial Analysis](https://artificialanalysis.ai/) for benchmarks and pricing.

Every Gemini slug carries a reasoning tier. Pass a **full slug** or a **family plus `--effort`**; a bare family name is rejected with `requires --effort (available: low, medium, high)`.

| Family / slug | Tiers | Notes |
|---|---|---|
| `gemini-3.6-flash` | `-high`, `-medium`, `-low` | Default choice: speed, research, formatting. |
| `gemini-3.5-flash` | `-high`, `-medium`, `-low` | Previous Flash generation. |
| `gemini-3.1-pro` | `-high`, `-low` | Heavy reasoning, large refactors. |
| `claude-sonnet-4-6` | — | Thinking variant, no effort suffix. |
| `claude-opus-4-6-thinking` | — | Frontier tier. |
| `gpt-oss-120b-medium` | — | Open-weights option. |

> **Pro-line caveat:** the Gemini **Pro** line is frozen at `gemini-3.1-pro`. There is no `gemini-3.5-pro` or `gemini-3.6-pro`—do not guess one. Only the Flash line advanced to `gemini-3.6-flash`.

Headless mode does **not** fall back on an unknown model: it exits non-zero with `status: "ERROR"` and lists the available models in the `error` field.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print`, `--prompt` | Run a single prompt non-interactively and print the response. **Required for delegation.** |
| `--output-format` | `text` (default), `json`, `stream-json`. |
| `--model` | Model slug for this run (see `agy models`). |
| `--effort` | Reasoning effort: `low`, `medium`, `high`. |
| `--mode` | `plan` (read-only by construction) or `accept-edits`. |
| `--add-dir` | Add a directory to the workspace (repeatable). **Absolute paths only.** |
| `--print-timeout` | Max wait for a response; default `5m`. |
| `--json-schema` | Schema string or file path to enforce structured output. |
| `--dangerously-skip-permissions` | Auto-approve every tool. Blunt—prefer `--add-dir` and allow-rules. |
| `--agent` | Select an agent for the run (see `agy agents`). |
| `--sandbox` | Run with terminal sandbox restrictions enabled. |
| `--disable-slash-commands` | Disable slash command and skill expansion in print mode. |
| `-c`, `--continue` | Continue the most recent conversation. |
| `--conversation <id>` | Resume a conversation by ID (from a previous run's `conversation_id`). |
| `--log-file` | Override the CLI log file path—useful for diagnosing a run. |
| `--add-dir`, `--project`, `--new-project` | Workspace and project scoping. |

**Not flags on this build** (documented elsewhere or in older skills, all rejected): `--bare`, `-o`, `--yolo`/`-y`, `-m`, `--worktree`/`-w`, `--resume`/`-r`. Use `--print`, `--output-format`, `--dangerously-skip-permissions`, `--model`, and `--continue`/`--conversation` respectively. `--output-format` is also **not** accepted by the `models` and `agents` subcommands here, despite the changelog claiming it was added.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `agy models` | List available model slugs. |
| `agy agents` | List available agents. **Returns empty when none are configured**—do not assume named specialists exist. |
| `agy changelog` | Release notes; useful for explaining a behaviour that changed under you. |
| `agy plugin` / `plugins` | Install, uninstall, list, enable, disable plugins. |
| `agy install` | Configure environment paths and shell settings. |
| `agy update` | Update the CLI. |

### Agents / specialists

The supported mechanism is **`--agent <name>`**, discovered with `agy agents`. An `@name` prefix inside the prompt is **not** a documented dispatch mechanism—if no agent by that name exists, the text is simply read as part of the prompt and the run proceeds on the default agent. Check `agy agents` before promising a specialist.

## Permissions (headless)

Headless mode cannot prompt, so a tool requiring approval is **soft-denied**: the run continues, **exits 0**, `status` is `SUCCESS`, `response` is **empty**, and a notice naming the tool goes to **stderr**. Under `--output-format text` this looks like silent success with no output—always check for empty output.

Grant the narrowest access that works:

1. **`--add-dir /abs/path`** — file reads are *not* granted by the shell's working directory, and a relative path like `.` does not resolve to your cwd. Absolute paths only.
2. **Allow-rules** under `permissions.allow` in `~/.gemini/antigravity-cli/settings.json`, matching `action(target)`:
   ```json
   { "permissions": { "allow": ["command(git)", "command(npm run (build|lint|test))", "write_file(src/)"] } }
   ```
   Note that `trustedWorkspaces` is a *trust* setting and does **not** grant tool permissions.
3. **`--dangerously-skip-permissions`** — last resort; approves writes and command execution too.

Inspect the rules actually in effect with `agy -p "/permissions"`. Read-only slash commands answer in print mode without starting an agent turn, spending quota, or leaving a conversation behind.

## JSON envelope (`--output-format json`)

Fields: `conversation_id`, `status`, `response`, `error` (failures only), `duration_seconds`, `num_turns`, `structured_output` + `json_schema` (with `--json-schema`), and `usage` (`input_tokens`, `output_tokens`, `thinking_tokens`, `cache_read_tokens`, `total_tokens`).

`status` values: `SUCCESS`, `ERROR`, `CANCELED`, `INTERRUPTED`, `INVALID`, `WAITING`, `RUNNING`.

`stream-json` emits NDJSON: one `init` event, any number of `step_update` events (with `text_delta`, `tool_info`, `subagent_info`), and exactly one terminal `result` event with the same shape as the `json` envelope.

## Essential Paths

| Scope | Component | File Path |
|-------|-----------|-----------|
| **Global** | Configuration & permissions | `~/.gemini/antigravity-cli/settings.json` |
| **Global** | CLI logs | `~/.gemini/antigravity-cli/log/`, `~/.gemini/antigravity-cli/cli.log` |
| **Global** | Conversations | `~/.gemini/antigravity-cli/conversations/` |
| **Global** | MCP Configuration | `~/.gemini/antigravity-cli/mcp_config.json` |
| **Global** | Global Skills | `~/.gemini/antigravity-cli/skills/` |
| **Global** | Global Rules | `~/.gemini/GEMINI.md` |
| **Workspace**| Workspace Skills | `<workspace-root>/.agents/skills/` |
| **Workspace**| Workspace Rules | `<workspace-root>/.agents/rules/` |

## Delegation Checklist

1. **Full Goal**: Clearly state what needs to be achieved.
2. **Prior Decisions**: Stack, style, and API choices already made.
3. **Scope**: Define paths (and `--add-dir` them) or out-of-scope areas.
4. **Constraints**: Performance, a11y, or compatibility requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Summarize results," "Apply diffs," etc.
