# Mistral Vibe CLI — reference

> **Checked against the official documentation on 2026-11-05; not run against an installed binary.**
> Latest release on PyPI: `mistral-vibe` 3.1.0. Confirm with `vibe --help` before trusting a flag.

## Install

`curl -LsSf https://mistral.ai/vibe/install.sh | bash`, or `uv tool install mistral-vibe`, or
`pip install mistral-vibe` (official repo README: <https://github.com/mistralai/mistral-vibe>).

## Authentication

`MISTRAL_API_KEY` env var, or `vibe --setup` (re-runs the setup wizard: browser sign-in with a Mistral
account, or paste an API key). First run auto-launches this wizard and stores credentials in the Vibe
home directory. `OPENROUTER_API_KEY` is also supported for third-party provider auth.

## Models

No `vibe models` subcommand or `--list-models` flag is documented. Selection is `--model [model_name]`.
Model IDs can be a `-latest` alias for a tier (e.g. a "medium" or "small" coding tier) or a pinned
dated/version snapshot made by replacing `-latest` with a date/version suffix — prefer a pinned snapshot
for reproducible delegations. An interactive `/model` slash command selects the active model; whether it
lists the full catalog or only opens a picker is unconfirmed. Check
[Artificial Analysis](https://artificialanalysis.ai/) and Mistral's own docs for current names/pricing.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--prompt "prompt"` | Non-interactive programmatic mode; disables interactive tools like `ask_user_question`. |
| `--model` | Specify the model. |
| `--output` | `text` (default), `json`, or `streaming`. |
| `--max-turns` | Limit the maximum number of assistant turns. |
| `--max-price` | Indicative (soft) cost cap in dollars — not a hard guarantee. |
| `--max-tokens <N>` | Cap total prompt and completion tokens. |
| `--time-limit <seconds>` | Stop the run at the deadline; the session can be resumed. `SIGTERM` stops it the same way. |
| `--prompt-file <path>` | Read the prompt from a file. |
| `--system-prompt-file <path>` | Replace Vibe's built-in instructions; project context and `AGENTS.md` still apply. |
| `--output-dir <dir>` | Write `export.json` (config, token usage, cost, stop reason, outcome) and a session copy. |
| `--disabled-tools <list>` | Disable tools after `--enabled-tools` filtering. Repeatable. |
| `--worktree [name]` | Run in a git worktree under `~/.vibe/worktrees/`. |
| `--enabled-tools <list>` | Enable only the named tools (exact name, glob, or `re:` regex); disables all others. |
| `--agent <name>` | Built-in agent: `ask`, `accept-edits` (default), `smart-approve`, `auto-approve` (`lean` is Lean 4 only). |
| `--auto-approve`, `--yolo` | Approve every tool call. Ignored if an admin sets `enable_auto_approve = false`. |
| `--trust` | Grant temporary folder trust for this invocation only (non-persistent). |
| `--continue`/`-c` | Resume the most recent session. |
| `--resume <SESSION_ID>` | Resume a specific session. |
| `--setup` | Run/re-run the credential setup wizard. |
| `--version` | Print version. |

`--auto-approve` and `--yolo` are documented flags. This card prefers `--agent auto-approve`, which
names the agent explicitly.

## Approvals and permissions

`--agent` selects a built-in agent: `ask`, `accept-edits` (the default), `smart-approve`, or
`auto-approve` (approves everything, sandbox use only). `lean` exists for Lean 4 only. Vibe has no
built-in `plan` agent; `default_agent = "plan"` warns and starts `ask`. **A programmatic run
(`--prompt`) does not auto-approve.** It uses the default agent, and Vibe denies every tool call that
needs approval. Pass `--agent auto-approve` for a run that must act. There is a real multi-tier permission system
underneath this (per-tool `"always"/"ask"` settings, bash allow/deny lists, `--trust` for folder trust) —
it is not the case that "no permission system exists".

**Exit codes (vendor docs):** `0` the agent finished; `1` the run could not start (invalid flag or
config); `2` model API or runtime failure; `3` the agent stopped before finishing (limit reached, run
stopped, or the model declined). Denial, not a stall, is the documented outcome for a call that needs
approval. A community report of a stall on an internal plan-confirmation step came from an older
release and is **unverified for the current one**. Keep an external timeout around every run.

## Subcommands

No traditional subcommand verbs beyond flags on the root `vibe` binary. A separate binary, **`vibe-acp`**,
ships alongside it as an Agent Client Protocol server for editor integrations.

## Configuration and paths

| Component | Path |
|---|---|
| Project config | `./.vibe/config.toml` (takes precedence) |
| User config | `~/.vibe/config.toml` |
| Relocate home | `VIBE_HOME` env var (relocates config, `.env`, agents, prompts, skills, tools, logs) |

`config.toml` supports a `default_agent = "..."` setting and `[[providers]]`/`[[models]]` blocks for
custom or offline model providers, plus `disabled_tools` (config-only blacklist) and per-tool
`[tools.<name>]` permission blocks.

## Documentation

- <https://docs.mistral.ai/vibe/code/cli/work-with-cli>
- <https://docs.mistral.ai/vibe/code/cli/configuration>
- <https://docs.mistral.ai/vibe/code/cli/install-setup>
- <https://docs.mistral.ai/vibe/code/cli/commands-shortcuts>
- <https://docs.mistral.ai/vibe/code/safety-approvals-permissions>
- <https://docs.mistral.ai/getting-started/quickstarts/vibe-code/install-cli>
- <https://docs.mistral.ai/vibe/code/cli/agents>
- Official OSS repo (corroborating evidence only): <https://github.com/mistralai/mistral-vibe>

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
