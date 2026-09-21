# Kilo Code CLI — reference

> **Verified against `kilo` 7.7.6 on 2026-09-21 by running the binary** (`--help`, `run --help`,
> `models --help`). Flags below came from that build, not from documentation. A full delegation was
> not run, because that needs provider credentials. `kilo help` is the only authority. On an
> unrecognized flag, re-read `--help`, use what exists, and report that this file needs updating.

> **Kilo Code is built on OpenCode.** Its own startup log line reports `opencode`, and the command
> surface matches. That means OpenCode's traps apply here too — most importantly `-p` being
> `--password`. Do not assume the reverse: take every flag from `kilo`, not from the OpenCode skill.

## Authentication

`kilo auth` (alias `kilo providers`) manages AI providers and credentials. `kilo profile` shows the
Kilo account profile. Basic auth against an attached server uses `-u`/`--username` (default from
`KILO_SERVER_USERNAME`, else `kilo`) and `-p`/`--password` (default from `KILO_SERVER_PASSWORD`).

## Models

`kilo models` lists every available model. `kilo models <provider>` filters by provider id.

Select per run with `-m`/`--model <provider/model>`. Reasoning effort is `--variant <value>`, which is
provider-specific. `kilo roll-call <filter>` batch-tests matching text models for connectivity and
latency. Never hard-code a model identifier — ask the binary.

## Essential Flags

`kilo run [message..]` — the message is a variadic positional argument.

| Flag | Meaning |
|---|---|
| *(positional)* | The message to send |
| `--auto` | Auto-approve permissions not explicitly denied; **default `false`** |
| `--format <fmt>` | `default` (formatted) or `json` (raw JSON events) |
| `--print-logs` | Print logs to stderr |
| `--log-level <lvl>` | `DEBUG\|INFO\|WARN\|ERROR` |
| `-m`, `--model <p/m>` | Model as `provider/model` |
| `--agent <name>` | Which configured agent runs the task |
| `-f`, `--file <path>` | Attach file(s) to the message |
| `--dir <path>` | Directory to run in |
| `-c`, `--continue` | Continue the last session |
| `-s`, `--session <id>` | Session id to continue |
| `--fork` | Fork the session when continuing |
| `--title <text>` | Session title |
| `--variant <value>` | Provider-specific reasoning effort |
| `--thinking` | Show thinking blocks |
| `-i`, `--interactive` | Interactive split-footer mode — do not use from a script |
| `--pure` | Run without external plugins |
| `--share` | Share the session |
| `--attach <url>` | Attach to a running kilo server |
| `-p`, `--password` | **Basic auth password — NOT the prompt** |
| `-u`, `--username` | Basic auth username |
| `--port <n>` | Port for the local server |

Exit codes, from the vendor's CLI page:

| Code | Meaning |
|---|---|
| `0` | Success — task completed |
| `1` | Error: initialization, execution, or request failure — **including an auto-rejected permission when `--auto` was omitted** |
| `124` | Timeout — task exceeded its time limit |

No `--timeout` flag exists on `kilo run` and no default limit is documented, so wrap long calls in an
external `timeout`. There is no `--quiet` on `kilo run` either.

## Approvals and permissions

`--auto` is documented as "auto-approve permissions that are not explicitly denied (dangerous!)" and
defaults to `false`. Always pass it for unattended delegation; without it the run can stop on a
permission that headless mode cannot answer. Explicit deny rules still apply.

`--agent` selects the agent. A planning agent writes a plan for itself and waits for approval, which
never arrives headless — keep the default agent and put "report only, no edits" in the handoff when
you want no file changes.

## Subcommands

| Command | Purpose |
|---|---|
| `kilo run [message..]` | Run kilo with a message (**use this**) |
| `kilo models [provider]` | List all available models |
| `kilo auth` | Manage providers and credentials (alias `providers`) |
| `kilo agent` | Manage agents |
| `kilo session` | Manage sessions |
| `kilo config` | Configuration tools |
| `kilo serve` | Start a headless kilo server |
| `kilo attach <url>` | Attach to a running kilo server |
| `kilo export [sessionID]` | Export session data as JSON |
| `kilo stats` | Token usage and cost statistics |
| `kilo mcp` | Manage MCP servers |
| `kilo worktree` | Manage git worktrees |
| `kilo debug` | Debugging and troubleshooting tools |
| `kilo help [command]` | Full CLI reference |

## Agent Skills

Kilo Code loads Agent Skills. There is no top-level `skills` command, but `kilo debug skill` lists
every skill the agent can see, which is the way to confirm an install worked.

| Scope | Paths |
|---|---|
| Global, native | `~/.kilo/skills/` |
| Global, compatibility | `~/.claude/skills/`, `~/.agents/skills/` |
| Project, native | `<project>/.kilo/skills/` |
| Project, compatibility | `<project>/.claude/skills/`, `<project>/.agents/skills/` |
| Extra | `skills.paths` and `skills.urls` in `kilo.jsonc` |

All of the global directories load by default — verified on a clean configuration, with no migration
flag required. An existing `~/.claude/skills/` tree is therefore already visible to Kilo Code. The
compatibility directories can be switched off with `KILO_DISABLE_EXTERNAL_SKILLS=true`, so if a skill
is not being picked up, check that variable first.

Frontmatter: `name` is required, max 64 characters, lowercase letters, numbers and hyphens only, not
starting or ending with a hyphen, and **it must match the parent directory name**. `description` is
required, max 1024 characters. `license`, `compatibility` and `metadata` are optional. Skills are
loaded when a new session starts or when `kilo run` starts, so headless runs do get them.

One safety note: embedded `` !`command` `` placeholders execute only in trusted global directories.
Project skills and skills fetched from remote URLs never execute commands. `KILO_DISABLE_SKILL_SHELL`
turns the behaviour off entirely.

## Configuration and paths

| Path | Contents |
|---|---|
| `~/.kilo/` | State directory used for detection |
| `~/.kilocode/` | Alternative state directory used for detection |
| `~/.kilo/skills/` | Global skills |
| `~/.config/kilo/kilo.jsonc` | Global configuration |
| `~/.local/share/kilo/auth.json` | Credentials |

`KILO_SERVER_USERNAME` and `KILO_SERVER_PASSWORD` supply basic-auth defaults for `--attach`.

## Documentation

- Vendor documentation: <https://kilo.ai/docs/code-with-ai/platforms/cli>
- Repository: <https://github.com/Kilo-Org/kilocode>
- Package: `@kilocode/cli` on npm; it installs both `kilo` and `kilocode`, pointing at the same file.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch, as absolute paths.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
