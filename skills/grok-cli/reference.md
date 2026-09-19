# Grok CLI — reference

> **Checked against the official xAI documentation on 2026-09-19. Not run against an installed binary —
> confirm with `grok --help` before trusting a flag.**

## Authentication

`XAI_API_KEY` env var, or `grok login` (`--device-auth` for headless/remote machines). `grok logout`
ends the session.

## Models

Model IDs are not documented as a fixed list. Run **`grok models`** to list the strings this install
accepts. Selection is `-m`, `--model <MODEL>`. `--effort <LEVEL>` sets reasoning effort; the accepted
level values are not documented in the pages this reference was checked against — confirm with `grok
--help`. Consult [Artificial Analysis](https://artificialanalysis.ai/) for pricing and benchmarks only —
it uses marketing names, not CLI identifiers.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--single <PROMPT>` | Send one prompt and exit. The prompt is a flag value, not positional. |
| `--output-format <fmt>` | `plain`, `json` (one object on completion), `streaming-json` (newline-delimited events). |
| `-m`, `--model <MODEL>` | Model ID for this run (see `grok models`). |
| `--effort <LEVEL>` | Reasoning effort. Accepted levels not documented — check `--help`. |
| `--max-turns <N>` | Maximum number of agent turns. |
| `--no-alt-screen` | Run inline instead of taking over the terminal with a fullscreen TUI. |
| `--no-auto-update` | Skip background update checks. Recommended for automated environments. |
| `-c`, `--continue` | Resume the most recent session in the current directory. |
| `-r`, `--resume [<ID>]` | Resume by ID, or the most recent if omitted. |
| `-s`, `--session-id <UUID>` | Create or resume a specific session by ID. |
| `--fork-session` | Fork rather than append when resuming. |
| `--no-subagents` | Disable Grok's own internal subagent spawning for the session. |
| `--no-plan`, `--no-memory`, `--disable-web-search` | Feature toggles for the session. |
| `--rules`, `--system-prompt-override`, `--cwd` | Rules file, system-prompt override, working directory. |

No quiet/silent flag beyond `--output-format` is documented, and no general exit-code table is
documented — judge success by output, not status alone.

## Approvals and permissions

`--always-approve` skips ordinary permission prompts; documented deny rules, hooks, and some shell `ask`
rules still apply on top of it. `--yolo` is **not** a current CLI flag — it survives only as a legacy
`yolo = true` key in `config.toml`, superseded by `permission_mode` / `--always-approve`. Narrower
options: `--allow <RULE>` / `--deny <RULE>` (both interactive and headless), `--sandbox <PROFILE>`
(flag exists; profile values undocumented).

**Unanswered approval in headless mode:** a blocked tool call fails immediately and the failure is
reported back to the model in-band (e.g. "Auto mode blocked this action…") — it does not stall and does
not exit 0 with silent empty output. A `dontAsk` permission mode denies silently the same way, without
ever surfacing a prompt, for any call lacking an explicit allow rule. A recent update lets non-interactive
sessions auto-resolve requests for user input or plan approval instead of failing on them; genuine
tool-permission blocks still fail-and-report as above.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `grok models` | List available models. The authority on valid `--model` strings. |
| `grok login [--device-auth]` / `grok logout` | Authenticate; `--device-auth` suits headless machines. |
| `grok sessions <list\|search\|delete>` | Manage stored sessions. |
| `grok export <session-id> [output]` | Export a session (Markdown). |
| `grok inspect [--json]` | Inspect configuration/state. |
| `grok agent stdio` | Run Grok as an ACP (Agent Client Protocol) agent over stdin/stdout JSON-RPC. |
| `grok mcp <list\|add\|remove\|doctor>` | Manage MCP servers. |
| `grok plugin <list\|install\|uninstall\|update\|enable\|disable\|details\|validate>` | Manage plugins. |
| `grok plugin marketplace <list\|add\|remove\|update>` | Manage plugin marketplaces. |
| `grok import [targets...]` | Import configuration from Claude Code. |
| `grok memory clear [--workspace\|--global\|--all]` | Clear stored memory. |
| `grok worktree <list\|show\|rm\|gc>` | Manage git worktrees Grok created. |
| `grok dashboard` | Open the usage/session dashboard. |
| `grok wrap <command...>` | Wrap an arbitrary command. |
| `grok update [--check\|--version\|--alpha\|--stable]` | Self-update. |
| `grok version` / `grok completions <shell>` / `grok setup` | Version info, shell completions, setup wizard. |

## Agent Skills

Grok loads `SKILL.md` skills from:

| Scope | Path |
|---|---|
| Project | `./.grok/skills/` — walked up to the repo root |
| Global (user) | `~/.grok/skills/` |
| Plugin-provided | any enabled plugin's `skills/` directory |
| Configured extras | additional paths under `[skills] paths` in `~/.grok/config.toml` |

Frontmatter: `name`, `description`, `user-invocable` (default `true` — controls slash-command
visibility), `allowed-tools`, `paths` (gitignore-style patterns). Extra keys such as `model`, `effort`,
`license`, `compatibility` are accepted but not applied. User-invocable skills become slash commands
(`/<skill-name>`). The format is explicitly documented as portable/compatible with Claude Code, Codex,
and other agents.

## Configuration and paths

| Component | Path |
|---|---|
| User config | `~/.grok/config.toml` (Windows: `%USERPROFILE%\.grok\config.toml`) |
| Project config | `.grok/config.toml` |
| Managed config | `~/.grok/managed_config.toml`, `/etc/grok/managed_config.toml` |
| Requirements config | `~/.grok/requirements.toml`, `/etc/grok/requirements.toml` |
| Relocate home | `$GROK_HOME` env var |
| Global skills | `~/.grok/skills/` |
| Marketplaces | `~/.grok/plugins/known_marketplaces.json` |
| Sessions | not documented — no page states an explicit session-storage directory |

## Documentation

- <https://docs.x.ai/build/overview>
- <https://docs.x.ai/build/cli/reference>
- <https://docs.x.ai/build/cli/headless-scripting>
- <https://docs.x.ai/build/settings>
- <https://docs.x.ai/build/modes-and-commands>
- <https://docs.x.ai/build/features/permissions>
- <https://docs.x.ai/build/features/skills-plugins-marketplaces>
- <https://docs.x.ai/build/enterprise>

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
