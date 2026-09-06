# Grok CLI — reference

> **Documented, not verified.** Written from xAI's published CLI docs on 2026-09-06 and **not** checked
> against an installed binary. `grok --help` and `grok models` are the only authorities. On
> `unrecognized flag` (or similar), re-read `--help`, use what exists, and report that this skill needs
> updating.

Auth: `XAI_API_KEY`, or `grok login` (`--device-auth` for headless/remote machines). `grok logout` ends
the session.

## Models

Model IDs are **NOT DOCUMENTED** as a fixed list. Run **`grok models`** ("List available models") for the
strings this install accepts. Consult [Artificial Analysis](https://artificialanalysis.ai/) for pricing
and benchmarks only — it returns marketing names, not CLI identifiers.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--single <PROMPT>` | Send one prompt and exit. **The prompt is a flag argument, not positional.** |
| `--output-format <fmt>` | `plain` (default), `json` (one object on completion), `streaming-json` (newline-delimited events). |
| `--always-approve` / `--yolo` | Auto-approve tool executions. Blunt — prefer `--allow`/`--sandbox` when the run can be scoped. |
| `--allow <RULE>` / `--deny <RULE>` | Permission rules, narrower than blanket approval. |
| `--sandbox <PROFILE>` | Run under a sandbox profile. |
| `-m`, `--model <MODEL>` | Model ID for this run (see `grok models`). |
| `--effort <LEVEL>` | Reasoning effort. Accepted levels NOT DOCUMENTED — check `--help`. |
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

**No quiet/silent flag** and **no exit-code table** are documented. Judge success by output, not status.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `grok models` | List available models. **The authority on valid `--model` strings.** |
| `grok login [--device-auth]` / `grok logout` | Authenticate; `--device-auth` suits headless machines. |
| `grok sessions <list\|search\|delete>` | Manage stored sessions. |
| `grok export <session-id> [output]` | Export a session. |
| `grok inspect [--json]` | Inspect configuration/state. |
| `grok agent stdio` | Run Grok as an ACP (Agent Client Protocol) agent over stdin/stdout JSON-RPC. A protocol server mode, **not** a named-subagent selector. |

## Agent Skills

Grok loads `SKILL.md` skills — "reusable folders containing markdown instructions, script files, and
resources for agents."

| Scope | Path |
|---|---|
| **Global (user)** | `~/.grok/skills/` |
| **Shared cross-agent** | `~/.agents/skills/` |
| **Project** | `./.grok/skills/` — walked up to the repo root |
| **Plugin-provided** | any enabled plugin's `skills/` directory |
| **Configured extras** | additional paths listed under `[skills] paths` in `~/.grok/config.toml` |

Layout is `<skills-dir>/<skill-name>/SKILL.md`. Documented frontmatter fields: `name`, `description`,
`when-to-use` (alias `when_to_use`), `paths`, `allowed-tools`, `argument-hint`, `user-invocable`,
`disable-model-invocation`, `metadata`. Nothing this repo ships is forbidden.

Grok is documented as **"fully compatible with Claude Code with zero configuration needed"**, reading
Claude Code marketplaces, plugins, skills, MCPs, agents, hooks and instruction files alongside its own.
Skills are managed from the TUI via `/skills` (and `/plugins`, `/hooks`, `/mcps`), and invoked as
`/<skill-name>`. No `--skills`/`--no-skills` CLI flags are documented.

## Essential Paths

| Component | Path |
|---|---|
| Config | `~/.grok/config.toml` (e.g. `auto_update = false` under `[cli]`) |
| Sessions | `~/.grok/sessions` |
| Global skills | `~/.grok/skills/` |
| Marketplaces | `~/.grok/plugins/known_marketplaces.json` |

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
