# OpenCode CLI — reference

Concise reference for agents. Auth: `opencode providers login` (aliased `opencode auth login`),
or `/connect` inside the TUI. `OPENCODE_API_KEY` is also honored. Credentials are stored at
`~/.local/share/opencode/auth.json`; inspect with `opencode providers list`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Run **`opencode models`** to list the IDs actually available for the authenticated providers —
this is authoritative and beats guessing. IDs take the form `provider/model`, where the provider
is the gateway you authenticated against (e.g. `opencode/…` for OpenCode Zen).

Note the ID style: version suffixes are **dash-separated for Anthropic** (`claude-sonnet-4-5`,
not `claude-sonnet-4.5`) and **dot-separated for OpenAI/Google** (`gpt-5.4`, `gemini-3.5-flash`).

| Example Model ID | Tier |
|-------------------|------|
| `opencode/gpt-5.4-nano` / `opencode/gemini-3.5-flash-lite` | Fast / cheap delegations |
| `opencode/gpt-5.4` / `opencode/claude-sonnet-4-6` | General implementation work |
| `opencode/claude-sonnet-5` / `opencode/gpt-5.5` / `opencode/gemini-3.1-pro` | Heavy reasoning / architecture |
| `opencode/gpt-5.3-codex` / `opencode/gpt-5.1-codex-max` | Codex-tuned coding runs |

## Agents

`--agent NAME` selects the agent. `opencode agent list` shows the live set; defaults are:

| Agent | Kind | Use |
|-------|------|-----|
| `build` | primary | Default. Full edit + tool access. |
| `plan` | primary | Read-only analysis — the correct choice for "report only, no edits". |
| `explore` | subagent | Codebase search / discovery. |
| `general` | subagent | General-purpose delegated subtask. |

`opencode agent create` scaffolds a custom agent with its own instructions and permissions.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `run` | Execute prompt and exit (non-interactive). |
| `--auto` | Auto-approve permissions not explicitly denied (YOLO). **The real flag — `--dangerously-skip-permissions` does not exist and is silently ignored.** |
| `-m`, `--model` | Specify the model to use (format: `provider/model`). |
| `--agent` | Agent to run as (`build`, `plan`, …). Use `plan` for read-only passes. |
| `--variant` | Provider-specific reasoning effort (e.g. `high`, `max`, `minimal`). |
| `--format` | Output format: `default` or `json` (raw JSON events — parse this for programmatic use). |
| `-f`, `--file` | Attach file(s) to the message. Repeatable. |
| `-c`, `--continue` | Continue the last session. |
| `-s`, `--session <id>` | Continue a specific session by ID. |
| `--fork` | Fork the session instead of appending (with `--continue`/`--session`). |
| `--dir` | Directory to run in. |
| `--title` | Session title (defaults to a truncated prompt). |
| `--thinking` | Show thinking blocks. |
| `--print-logs` / `--log-level` | Diagnostics to stderr (`DEBUG`/`INFO`/`WARN`/`ERROR`). |

Unknown flags are **silently accepted** by the CLI parser rather than rejected, so a typo'd
flag produces a run that looks successful while doing nothing. Verify flags against
`opencode run --help` rather than assuming an error will surface the mistake.

## Other commands

| Command | Purpose |
|---------|---------|
| `opencode models [provider]` | List available model IDs (authoritative). |
| `opencode agent list` / `agent create` | Inspect or create agents. |
| `opencode providers list\|login\|logout` | Manage credentials (alias: `auth`). |
| `opencode github install\|run` | Install and run the GitHub agent in CI. |
| `opencode stats` | Token usage and cost statistics. |
| `opencode export [sessionID]` | Export session data as JSON. |
| `opencode serve` | Headless server (pair with `run --attach`). |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
