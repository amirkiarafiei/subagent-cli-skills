# Hermes Agent CLI — reference

> **Checked against the official Nous Research documentation on 2026-09-19. Not run against an installed
> binary — confirm with `hermes --help` before trusting a flag.**

## Authentication

`hermes setup` (interactive wizard with sections: model, tts, terminal, gateway, tools, agent; flags
`--quick`, `--non-interactive`, `--reset`), or `hermes setup --portal` (one-shot Nous Portal OAuth + Tool
Gateway setup). `hermes model` configures provider + model and is also where new providers/API keys/OAuth
are added.

## Models

Models are specified as `provider/model-name`. Run **`hermes model`** for the interactive provider+model
picker. A documented `--refresh` flag to re-fetch a provider's live model list was **not confirmed** in
the pages checked. `hermes config show` and `hermes status [--all] [--deep]` show current configuration
(exact output formatting not confirmed).

Documented provider keys: `openai-api`, `gemini`, `zai` (not `zhipuai`), `deepseek`, `kimi-coding` /
`kimi-coding-cn`, `minimax` / `minimax-cn`, `nous`, `openrouter`, `xai`, `ollama-cloud`, plus others
(`novita`, `bedrock`, `azure-foundry`, `alibaba`, etc.). `mistral` and `groq` were not found as
first-class provider IDs. Model availability depends on which providers the user has authenticated —
check [Artificial Analysis](https://artificialanalysis.ai/) for pricing/benchmarks, then confirm the
exact ID via `hermes model` rather than guessing.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `chat -q "prompt"` / `--query` | Seed a session with a prompt (first turn). |
| `-z "prompt"` | Minimal one-shot: prints only the final text to stdout; exit codes `0`/`2`/`130`. |
| `-Q`, `--quiet` | Suppress banner, spinner, tool previews — use for programmatic delegation. |
| `-m`, `--model "provider/model"` | Specify model. |
| `--provider name` | Force a specific provider. |
| `-t`, `--toolsets "list"` | Enable tool bundles (e.g. `file,terminal,web,skills`). |
| `-s`, `--skills name` | Preload a skill. Repeatable or comma-separable. |
| `-w`, `--worktree` | Start in an isolated git worktree (auto-cleanup). |
| `-c`, `--continue [name]` | Resume the most recent session. |
| `-r`, `--resume <session>` | Resume a specific session by ID/title, or `latest`. |
| `-v`, `--verbose` | Enable debug/verbose output. |
| `--max-turns N` | Cap tool-calling iterations. One official source states a default of 500 — treat any other number as unverified. |
| `--checkpoints` | Snapshot files before destructive operations (`/rollback` restores). |
| `--ignore-user-config` | Bypass `~/.hermes/config.yaml` (isolated CI-like run). |
| `--ignore-rules` | Skip `AGENTS.md`, `SOUL.md`, `.cursorrules`, memory, and preloaded skills. |
| `--safe-mode` | Combines `--ignore-user-config` and `--ignore-rules`; isolates config/rules/plugins/MCP. |
| `--source tool` | Tag the session as third-party (default `cli`), keeping it out of the user's session list. |
| `--accept-hooks` | Auto-approve shell hooks without a TTY prompt (persists to an allowlist; scoped to hooks only). |

## Approvals and permissions

`--yolo` bypasses dangerous-command approval but not a hardline blocklist of catastrophic commands.
`HERMES_YOLO_MODE` is the env var `--yolo` sets internally; its exact accepted value string is not
documented. `--accept-hooks` is scoped to shell hooks only (persisted to
`~/.hermes/shell-hooks-allowlist.json`), not general tool approval. No per-tool allow-rule flag exists —
scoping is only via `--toolsets`.

The primary gate is **`approvals.mode`** in `~/.hermes/config.yaml` (`smart` default = auxiliary-LLM
risk assessment, `manual` = always prompt, `off` = disabled), plus three headless-specific keys that each
**default to `deny`**: `single_query_mode` (`-q`/one-shot), `cron_mode` (scheduled jobs), and
`unattended_mode` (webhook/API sessions). With the default `deny`, a dangerous command is blocked and the
tool call returns an error to the agent (instructed not to blindly retry) — it does not stall and does
not silently succeed. Set the relevant key to `approve` to auto-approve in that context. Unapproved shell
hooks are "skipped rather than silently approved."

## Subcommands

| Subcommand | Purpose |
|---|---|
| `hermes setup [--quick\|--non-interactive\|--reset]` / `hermes setup --portal` | Initial auth/config. |
| `hermes model` | Interactive provider+model picker; add providers/keys/OAuth. |
| `hermes config show` | Show current configuration. |
| `hermes status [--all] [--deep]` | Inspect session/config state. |
| `hermes tools` / `hermes tools list` | Curses UI / list enabled toolsets. |
| `hermes chat -q "prompt"` | Seeded single-query session. |
| `hermes -z "prompt"` | Minimal one-shot scripting mode. |

## Agent Skills

Hermes loads `SKILL.md`-style skills from `~/.hermes/skills/`, organized in category subdirectories
(e.g. `~/.hermes/skills/devops/<skill>/SKILL.md`) to keep the list manageable. Preload with `-s`/
`--skills name` (repeatable or comma-separable). Whether skills also surface as slash commands was not
confirmed in the pages checked.

## Configuration and paths

| Component | Path |
|---|---|
| Main config | `~/.hermes/config.yaml` |
| Session storage | `~/.hermes/state.db` (SQLite) |
| Shell-hooks allowlist | `~/.hermes/shell-hooks-allowlist.json` |
| Skills | `~/.hermes/skills/<category>/<skill>/SKILL.md` |
| Plan-skill output directory | claimed `<workspace>/.hermes/plans/` — not confirmed in the pages checked |

## Toolsets and built-in tools

Documented toolsets: `browser`, `clarify`, `code_execution`, `connections`, `coding` (composite),
`cronjob`, `debugging` (composite), `delegation`, `discord`, `discord_admin`, `feishu_doc`,
`feishu_drive`, `file`, `homeassistant`, `computer_use`, `context_engine`, `image_gen`, `video_gen`,
`kanban`, `memory`, `desktop_ui`, `project`, `safe`, `search`, `session_search`, `skills`, `spotify`,
`terminal`, `todo`, `tts`, `vision`, `video`, `web`, `x_search`, `yuanbao`, plus platform toolsets
(`hermes-cli`, `hermes-telegram`, etc). Disabled by default: `computer_use`, `context_engine`,
`video_gen`, `video`, `x_search`. Run `hermes tools list` to see what's enabled for the install.

Built-in tools include `read_file`, `write_file`, `patch`, `search_files`, `terminal`, `process`
(background process management), `web_search`, `web_extract`, `delegate_task`, `memory`,
`execute_code`, `vision_analyze`, `skill_view`/`skill_manage`/`skills_list`, `session_search`, among
roughly 86 tools total across all toolsets (many platform- or toolset-gated).

## Documentation

- <https://hermes-agent.nousresearch.com/docs/>
- <https://hermes-agent.nousresearch.com/docs/reference/cli-commands>
- <https://hermes-agent.nousresearch.com/docs/user-guide/cli>
- <https://hermes-agent.nousresearch.com/docs/user-guide/security>
- <https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks>
- <https://hermes-agent.nousresearch.com/docs/reference/toolsets-reference>
- <https://hermes-agent.nousresearch.com/docs/reference/tools-reference/>
- <https://hermes-agent.nousresearch.com/docs/integrations/providers>
- <https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models>
- <https://hermes-agent.nousresearch.com/docs/user-guide/features/skills>
- <https://hermes-agent.nousresearch.com/docs/guides/work-with-skills>

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
