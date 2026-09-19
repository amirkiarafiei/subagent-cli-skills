# Mistral Vibe CLI — reference

> **Checked against the official Mistral AI documentation on 2026-09-19. Not run against an installed
> binary — confirm with `vibe --help` before trusting a flag.**

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
| `--enabled-tools <list>` | Enable only the named tools (exact name, glob, or `re:` regex); disables all others. |
| `--agent <mode>` | Approval mode: `default`, `plan`, `accept-edits`, `auto-approve`. |
| `--trust` | Grant temporary folder trust for this invocation only (non-persistent). |
| `--continue`/`-c` | Resume the most recent session. |
| `--resume <SESSION_ID>` | Resume a specific session. |
| `--setup` | Run/re-run the credential setup wizard. |
| `--version` | Print version. |

There is no bare `--yolo` or `--auto-approve` boolean flag — passing one is rejected as an unrecognized
argument; use `--agent auto-approve` instead (or rely on the programmatic-mode fallback below).

## Approvals and permissions

`--agent` selects one of four modes: `default` (ask before every tool), `plan` (read-only — auto-approves
safe reads, blocks edits/commands), `accept-edits` (auto-approves file edits, still asks for
shell/sensitive tools), `auto-approve` (approves everything). **In programmatic mode (`--prompt`), Vibe
falls back to `auto-approve` when `--agent` is omitted** — this is the documented default, so no extra
flag is required to get full auto-approval headlessly. There is a real multi-tier permission system
underneath this (per-tool `"always"/"ask"` settings, bash allow/deny lists, `--trust` for folder trust) —
it is not the case that "no permission system exists"; it's simply defaulted to `auto-approve` for
`--prompt` runs unless overridden.

**Unanswered-approval / stall behavior is not documented.** No exit-code or hang contract is stated for
a blocked tool call in headless mode. A community bug report (a specific released version) found that
even with `auto-approve` active, a complex prompt could trigger an internal plan-confirmation step that
the run then stalls on, waiting for input headless mode cannot supply. Treat this as a known,
version-dependent edge case rather than confirmed universal behavior — always wrap a `vibe --prompt` run
in an external timeout.

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
