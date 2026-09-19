> **Checked against the official Google/Gemini CLI documentation on 2026-09-19. Not run against an installed binary — confirm with `gemini --help` before trusting a flag.**

> [!WARNING]
> **DEPRECATED**: Gemini CLI has been deprecated in favor of **Antigravity CLI** (`agy`). We
> strongly recommend migrating to `/antigravity-cli` for up-to-date features and performance.

## Authentication

`GEMINI_API_KEY`, or interactive OAuth. Config root is `$GEMINI_CLI_HOME` (falling back to the OS
home directory), with everything under `<root>/.gemini`.

## Models

No CLI subcommand to list models is documented. Select with `--model`, `-m <alias-or-name>` — the
default is an automatic-routing alias. **`--model` (and the interactive `/model` command) does not
override the model used by sub-agents** — a model-usage report can show other models in use even
after you set `--model`. Search the web / [Artificial Analysis](https://artificialanalysis.ai/) for
current identifiers and pricing.

## Essential Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--prompt <text>` | `-p` | Prompt text; forces non-interactive mode. Use this to guarantee headless execution rather than relying on the bare positional form. |
| `--prompt-interactive <text>` | `-i` | Execute a prompt, then continue in interactive mode. |
| `--model <alias-or-name>` | `-m` | Model to use (default: automatic routing). |
| `--approval-mode <mode>` | | See Approvals below. |
| `--sandbox` | `-s` | Run in a sandboxed environment. |
| `--skip-trust` | | Trust the current workspace for this session, skipping the folder-trust check. |
| `--worktree [name]` | `-w` | Start in a new Git worktree; requires `experimental.worktrees: true` in settings. |
| `--allowed-mcp-server-names` | | Allowed MCP server names (comma-separated or repeatable). |
| `--debug` | `-d` | Verbose logging. |

Piped stdin (non-TTY) is prepended to the `--prompt`/positional query, joined by a blank line; an
8MB input limit applies.

## Approvals and permissions

- **`--approval-mode <default\|auto_edit\|yolo\|plan>`** is the current control:
  - `default` — prompts for approval on each tool call.
  - `auto_edit` — auto-approves edit tools (`replace`, `write_file`) only.
  - `yolo` — auto-approves all tool calls.
  - `plan` — read-only; the docs themselves flag it as "currently under development and not yet
    fully functional." Do not use it for delegation.
- **`-y`, `--yolo` is deprecated** — use `--approval-mode=yolo` instead; the two flags cannot be
  combined.
- **`--allowed-tools` is deprecated** in favor of the Policy Engine.
- **Unanswered approval, documented behavior:** in non-interactive mode, a tool call needing
  confirmation under `default` (or under `auto_edit`, for tools it doesn't cover) is **treated as a
  denial** — the policy engine maps `ask_user` to `deny`, and the scheduler marks the call as errored
  with `CONFIRMATION_REQUIRED`. The run continues; that specific call simply fails. Pass
  `--approval-mode=yolo` before running headless if the task needs those calls to succeed.
- In Plan Mode specifically, the policy engine auto-approves the `enter_plan_mode`/`exit_plan_mode`
  transition tools, and exiting plan mode to implement automatically switches to `yolo` rather than
  `default`, so the implementation phase does not hang on confirmations.

## Subcommands

Primarily invoked as `gemini -p "..."` with flags. `/agents list` / `reload` / `enable` / `disable`
/ `config` manage local and remote subagents interactively (agent directories:
`~/.gemini/agents` and `.gemini/agents`).

## Configuration and paths

- `<root>/.gemini` (root is `$GEMINI_CLI_HOME` or the OS home directory) — `google_accounts.json`,
  `trustedFolders.json`, and other CLI state.
- `~/.gemini/agents` and `.gemini/agents` — subagent directories.

## Documentation

- Official docs: <https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/cli-reference.md>,
  <https://geminicli.com/docs/cli/headless/>,
  <https://github.com/google-gemini/gemini-cli/blob/main/docs/reference/policy-engine.md>
- Vendor card in this skill: [SKILL.md](SKILL.md)

## Delegation Checklist

1. **Full Goal**: Clearly state what needs to be achieved.
2. **Prior Decisions**: Stack, style, and API choices already made.
3. **Scope**: Define `@paths` or out-of-scope areas.
4. **Constraints**: Performance, a11y, or compatibility requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Summarize results," "Apply diffs," etc.
