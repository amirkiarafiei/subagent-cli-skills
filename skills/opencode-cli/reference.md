# OpenCode CLI — reference

> **Checked against the official OpenCode documentation on 2026-09-19. Not run against an installed
> binary — confirm with `opencode run --help` before trusting a flag.**

## Authentication

`opencode providers login` (aliased `opencode auth login`), or `/connect` inside the TUI.
`OPENCODE_API_KEY` is also honored. Credentials are stored at `~/.local/share/opencode/auth.json`;
inspect with `opencode providers list`.

## Models

Run **`opencode models`** to list the IDs actually available for the authenticated providers — this is
authoritative and beats guessing. IDs take the form `provider/model`, where the provider is the gateway
authenticated against. Select with `-m`/`--model <provider/model>`; omit to use the configured default.
No fixed catalog is reproduced here since names and tiers change — consult
[Artificial Analysis](https://artificialanalysis.ai/) for current pricing/performance comparisons.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `run [message..]` | Execute prompt and exit (non-interactive). Prompt is **positional** — variadic. |
| `--auto` | Auto-approve permission requests that are not explicitly denied. **The real flag — `--dangerously-skip-permissions` does not exist and does not appear in the docs.** |
| `-m`, `--model` | Specify the model to use (format: `provider/model`). |
| `--agent` | Agent to run as. Leave unset (`build`) for delegation; never `plan`. |
| `--print-logs` | Print logs to stderr, instead of the default timestamped files under `~/.local/state/opencode/logs/`. |
| `--log-level` | `DEBUG`/`INFO`/`WARN`/`ERROR`, paired with `--print-logs` for the full stderr stream. |
| `--variant` | Provider-specific reasoning effort. |
| `--format` | Output format: `default` or `json` (raw JSON events — parse this for programmatic use). |
| `-f`, `--file` | Attach file(s) to the message. Repeatable. |
| `-c`, `--continue` | Continue the last session. |
| `-s`, `--session <id>` | Continue a specific session by ID. |
| `--fork` | Fork the session instead of appending (with `--continue`/`--session`). |
| `--share` | Share the session. |
| `--dir` | Directory to run in. |
| `--title` | Session title (defaults to a truncated prompt). |
| `--thinking` | Show thinking blocks. |
| `--attach` | Connect to a running server (e.g. `http://localhost:4096`). |
| `-p`, `--password` | Basic-auth password for `--attach`. **Not the prompt — see Approvals below.** |
| `-u`, `--username` | Basic-auth username for `--attach`. |
| `--port` | Local server port (random if unspecified). |
| `--command` | Specifies the command to run. |

## Approvals and permissions

Permissions take one of three values: `"allow"` (executes without approval), `"ask"` (prompts), or
`"deny"` (blocked — enforced regardless of mode). `--auto` turns every `ask` into an allow while still
honoring explicit `deny` rules. There is no `--dangerously-skip-permissions` equivalent; it is absent
from the official docs entirely.

**The verified trap:** `-p`/`--password` is basic-auth for `--attach`, not the prompt. Passing a prompt
to `-p` (a habit from `claude -p` / `copilot -p` / `qwen -p`) leaves the actual message empty, and an
empty message makes the process wait on stdin forever — no session, no output, no exit.

What happens to an `ask` permission during a non-interactive `opencode run` with no `--auto` and no TTY
to answer it is **not explicitly documented** by the vendor. Treat it as an undefined stall risk and
always pass `--auto` for unattended delegation rather than relying on default behavior. Deny rules are
enforced no matter what.

## Subcommands

| Command | Purpose |
|---------|---------|
| `opencode run [message..]` | Execute prompt and exit. |
| `opencode models [provider]` | List available model IDs (authoritative). |
| `opencode agent list` / `agent create` | Inspect or create agents. |
| `opencode providers list\|login\|logout` (alias `auth`) | Manage credentials. |
| `opencode github install\|run` | Install and run the GitHub agent in CI. |
| `opencode stats` | Token usage and cost statistics. |
| `opencode export [sessionID]` | Export session data as JSON. |
| `opencode serve` | Headless server (pair with `run --attach`). |

## Agent Skills

Not documented as a feature of this CLI — no evidence in official docs that `opencode` itself loads
`SKILL.md` files for its own agents (note: oh-my-pi's `opencode` skill *provider* reads
`~/.config/opencode/skills/` and `.opencode/skills/`, but that is oh-my-pi reading OpenCode's
convention, not a documented OpenCode-native skill loader — do not present it as one here).

## Configuration and paths

| Component | Path |
|---|---|
| Auth/credentials | `~/.local/share/opencode/auth.json` |
| Default logs (without `--print-logs`) | `~/.local/state/opencode/logs/` |

## Documentation

- Vendor documentation: <https://opencode.ai/docs/cli/>, <https://opencode.ai/docs/permissions/>,
  <https://opencode.ai/docs/troubleshooting/>
- **Checked against the official documentation on 2026-09-19. Not run against an installed binary —
  confirm with `opencode run --help` before trusting a flag.**

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
