# Cline CLI — reference

> **Verified against `cline` 3.0.62 on 2026-09-21 by running the binary** (`--help`, `auth --help`,
> `skill --help`). Flags below came from that build, not from documentation. A full delegation was
> not run, because that needs provider credentials. `cline --help` is the only authority. On an
> unrecognized flag, re-read `--help`, use what exists, and report that this file needs updating.

## Authentication

`cline auth [provider]` authenticates a provider and chooses the model. Options:
`-p`/`--provider <id>`, `-k`/`--apikey <key>`, `-m`/`--modelid <id>`, `-b`/`--baseurl <url>`,
`--azure-api-version <version>`. The provider may also be given positionally.

`cline config` shows the current configuration. `cline doctor` diagnoses and fixes configuration
problems. A per-run key override is `-k`/`--key <api-key>`.

## Models

The default provider id is `cline`. Per run, select with `-P`/`--provider <id>` and
`-m`/`--model <model-id>`.

**This build ships no command that prints a list of model identifiers.** Use `cline auth` to set the
provider and model, and `cline config` to read back what is configured. Never hard-code a model
identifier into a delegation — take it from the user, or leave the configured default alone.

## Essential Flags

`cline [options] [command] [prompt]` — the prompt is positional.

| Flag | Meaning |
|---|---|
| *(positional)* | The prompt. Starts in act mode with auto-approve enabled |
| `-p`, `--plan` | **Plan mode — never use for delegation** |
| `-P`, `--provider <id>` | Provider id for this run (default `cline`) |
| `-m`, `--model <model-id>` | Model for this run with the selected provider |
| `-k`, `--key <api-key>` | API key override for this run |
| `--json` | NDJSON event stream on stdout, one object per line; errors on stderr |
| `--auto-approve <boolean>` | Tool auto-approval for all tools; **default `true`** |
| `-c`, `--cwd <path>` | Working directory |
| `-t`, `--timeout <seconds>` | Timeout; **default `0`, meaning no timeout** |
| `--retries [value]` | Consecutive mistakes before exiting; default `6` |
| `--thinking <level>` | `none\|low\|medium\|high\|xhigh`; bare `--thinking` means medium |
| `--compaction <mode>` | Context compaction: `agentic\|basic\|off` (default `agentic`) |
| `-i`, `--tui` | Opens the interactive interface — do not use from a script |
| `--id <session-id>` | Resume an existing session |
| `-s`, `--system <prompt>` | Override the default system prompt |
| `-z`, `--zen` | Run in the background hub |
| `--acp` | Agent Client Protocol mode for editor integration |
| `--config <path>` | Configuration directory (default `~/.cline`) |
| `--data-dir <path>` | Isolated local state (default `~/.cline/data`) |
| `--hooks-dir <path>` | Extra runtime hooks |
| `--worktree` | Auto-create a detached git worktree under `~/.cline/worktrees/` |
| `-v`, `--verbose` | Verbose output |

**`-p` collides across commands.** At the top level `-p` is `--plan`; inside `cline auth` it is
`--provider`. It is never the prompt.

`-y`/`--yolo` and `--team-name` parse but are hidden from `--help` in 3.0.62. `--yolo` is not needed,
because auto-approve is already the default.

Command-level restriction is environment-based, not a flag:
`CLINE_COMMAND_PERMISSIONS='{"allow":["npm *"],"deny":["rm -rf *"],"allowRedirects":false}'`, where
deny wins over allow.

Exit codes are NOT DOCUMENTED in `--help`. Observed: `1` on argument errors. Treat empty stdout as
failure and read stderr.

## Approvals and permissions

`--auto-approve` defaults to `true`, and the positional prompt runs "in act mode with auto-approve
enabled". No extra flag is needed for unattended work.

Plan mode (`-p`/`--plan`) is the failure case: the other agent produces a plan for itself and waits,
so the delegation returns nothing usable. For a read-only run keep act mode and state
"report only, no edits" in the handoff.

## Subcommands

| Command | Purpose |
|---|---|
| `cline auth [provider]` | Authenticate a provider, set the model |
| `cline config` | Show current configuration |
| `cline skill [args...]` | Manage skills via the open skills CLI |
| `cline plugin` | Manage Cline plugins |
| `cline mcp` | Manage MCP servers |
| `cline doctor` | Diagnose and fix configuration issues |
| `cline history` (`h`) | List session history, manage saved sessions |
| `cline schedule` | Manage scheduled tasks |
| `cline connect [channel]` | Connect to an external channel |
| `cline hook` | Handle a hook payload from stdin |

## Agent Skills

Cline loads Agent Skills and delegates management to the open `skills` CLI:
`cline skill [args...]` forwards to `npx skills`, defaulting to `--agent cline`.

| Command | Purpose |
|---|---|
| `cline skill add <owner/repo>` | Add a skill (alias `install`) |
| `cline skill list` | List installed skills |
| `cline skill remove` | Remove a skill (alias `uninstall`) |

Directories, from the vendor's skills documentation:

| Scope | Path |
|---|---|
| Global | `~/.cline/skills/` (Windows: `C:\Users\USERNAME\.cline\skills\`) |
| Project | `.cline/skills/` (recommended), `.clinerules/skills/`, `.claude/skills/` |

`~/.cline/skills/` is the documented global directory — install there. The source also aggregates
`~/.agents/skills/`, but it appears as `LEGACY_AGENT_SKILLS_CONFIG_DIR` and the vendor documentation
never mentions it, so treat it as compatibility only rather than the target. Cline is detected by the
presence of `~/.cline`.

## Configuration and paths

| Path | Contents |
|---|---|
| `~/.cline` | Configuration directory (`--config` overrides) |
| `~/.cline/data` | Local state (`--data-dir` overrides) |
| `~/.cline/hooks` | Runtime hooks (`--hooks-dir` overrides) |
| `~/.cline/worktrees/` | Worktrees created by `--worktree` |
| `~/.cline/skills/` | Global skills |

## Documentation

- Vendor documentation: <https://docs.cline.bot/>
- Repository: <https://github.com/cline/cline>
- Package: `cline` on npm. A separate `@cline/cli` package exists, is marked experimental, and
  installs a different binary (`clite`) — it is not this CLI.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch, as absolute paths.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
