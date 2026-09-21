# Goose CLI — reference

> **Verified against `goose` 1.51.0 on 2026-09-21 by running the binary** (`--help`, `run --help`,
> `skills --help`, `skills list`, `info`), cross-checked against the official docs in
> `aaif-goose/goose`. `GOOSE_MODE`, its four values and its `auto` default are documentation-sourced,
> not visible in `--help`. The vendor moved: docs now live at `goose-docs.ai` and the repository org
> was renamed from `block` to `aaif-goose`.
> A full delegation was not run, because that needs provider credentials. `goose run --help` is the
> only authority. On an unrecognized flag, re-read `--help`, use what exists, and report that this
> file needs updating.

## Authentication

Credentials and provider choice are configured with `goose configure`, which is interactive. Values
resolve from `~/.config/goose/config.yaml` and from environment variables.

`goose info` prints the resolved paths and configuration. `goose doctor` checks that the setup works.

## Models

Provider and model come from `GOOSE_PROVIDER` and `GOOSE_MODEL`, and both can be overridden per run:

| Flag | Meaning |
|---|---|
| `--provider <PROVIDER>` | Override `GOOSE_PROVIDER` for this run |
| `--model <MODEL>` | Override `GOOSE_MODEL`; must be supported by the provider |

Other documented environment variables include `GOOSE_TEMPERATURE` (0.0–1.0), `GOOSE_MAX_TOKENS`, and
`GOOSE_CACHE_TTL` (`5m` or `1h`). Note that **headless runs — `goose run`, subagents and scheduled
recipes — always use a `5m` cache TTL** regardless of the setting.

`goose local-models` (alias `lm`) manages local inference models. Never hard-code a model identifier.

## Essential Flags

`goose run [OPTIONS]` — "Execute commands from an instruction file or stdin". The prompt is a flag.

| Flag | Meaning |
|---|---|
| `-t`, `--text <TEXT>` | Input text containing commands for goose |
| `-i`, `--instructions <FILE>` | Path to an instruction file; `-` reads stdin |
| `-q`, `--quiet` | Suppress non-response output; only the model response on stdout |
| `--output-format <FMT>` | `text` (default), `json`, `stream-json` |
| `--no-session` | Run without a session file — "Useful for automated runs" |
| `--max-turns <N>` | Cap iterations without user input; default 1000 (`GOOSE_MAX_TURNS`) |
| `--max-tool-repetitions <N>` | Cap identical consecutive tool calls; prevents infinite loops |
| `--system <TEXT>` | Extra system instructions |
| `--provider <P>` / `--model <M>` | Per-run overrides |
| `-n`, `--name <NAME>` | **Session name — not "non-interactive"** |
| `--session-id <ID>` | Session id to resume; requires `--resume` |
| `-r`, `--resume` | Continue from a previous run |
| `-s`, `--interactive` | Stay interactive after the initial input — do not use from a script |
| `--stats` | Print generation statistics after the run |
| `--debug` | Full tool responses and paths, untruncated |
| `--recipe <NAME\|PATH>` | Run a recipe; `--params KEY=VALUE`, `--sub-recipe`, `--explain` |
| `--with-builtin <NAME>` | Add bundled extensions, comma-separated |
| `--with-extension <CMD>` | Add a stdio extension from a command |
| `--no-profile` | Skip default extensions; use only CLI-specified ones |
| `--container <ID>` | Run extensions inside a container |

Exit codes are NOT DOCUMENTED — the vendor publishes no table. Observed: `0` success, `1` runtime
error, `2` usage error. Treat non-zero as failure rather than branching on a specific code, and note
that some startup errors print to stdout rather than stderr.

## Approvals and permissions

There is **no approval flag on `goose run`**. The behaviour is set by the `GOOSE_MODE` environment
variable:

| Value | Meaning |
|---|---|
| `auto` | **Default.** Runs tools without asking |
| `approve` | Asks before tool execution |
| `smart_approve` | Asks selectively |
| `chat` | No tool calls at all — never use for delegation |

`GOOSE_MODE` is absent from `--help` and from the vendor's permissions page; it is documented on the
configuration and headless pages. Environment beats `config.yaml`, so set it explicitly for your own
call rather than editing their configuration:

```bash
GOOSE_MODE=auto goose run -t "[prompt]" --no-session
```

`GOOSE_MODE` is the lever for a headless call, but it is not the only approval surface in Goose. The
mode can also be persisted in `~/.config/goose/config.yaml`; per-tool rules live in
`~/.config/goose/permission.yaml` ("Always allow" / "Ask before" / "Never allow") and are edited with
`goose configure`; `GOOSE_ALLOWLIST` filters extensions; and an interactive session can switch with
`/mode`. For delegation, set `GOOSE_MODE` inline and leave the user's files alone.

Governance note: Goose moved from Block to the Agentic AI Foundation, which is why the repository org
is now `aaif-goose` and the docs live at `goose-docs.ai`.

## Subcommands

| Command | Purpose |
|---|---|
| `goose run` | Execute commands from an instruction file or stdin (**use this**) |
| `goose session` (`s`) | Start or resume interactive chat sessions |
| `goose skills list` | List all skills available to the agent |
| `goose configure` | Configure settings |
| `goose info` | Show version, config dir, config yaml, sessions DB, logs dir |
| `goose doctor` | Check that the setup works |
| `goose recipe` | Recipe validation and deeplinking |
| `goose schedule` (`sched`) | Manage scheduled jobs |
| `goose review` | Review the current diff |
| `goose mcp` | Run a bundled MCP server |
| `goose acp` / `goose serve` | ACP agent server on stdio / over HTTP and WebSocket |
| `goose plugin` | Manage plugins |
| `goose local-models` (`lm`) | Manage local inference models |
| `goose update` | Update the CLI |

## Agent Skills

Goose loads Agent Skills. `goose skills list` prints every skill with its name, description, token
counts and location, which is the quickest way to confirm an install worked.

Documented locations, in order:

| Scope | Path |
|---|---|
| Global | `~/.agents/skills/` |
| Project | `.agents/skills/` |
| Plugins | `~/.agents/plugins/<plugin-name>/` |

The docs note that other directories are also read, including `.claude/skills/`, `~/.claude/skills/`
and platform-specific config directories; the open `skills` CLI registry records
`~/.config/goose/skills` as Goose's config-home location. Placing a skill in `~/.agents/skills/`
reaches Goose and several other agents at once.

A `SKILL.md` requires YAML frontmatter with **`name` and `description`**, followed by the skill
content. Each skill lives in its own directory, e.g. `~/.agents/skills/code-review/SKILL.md`.
Supporting files (scripts, templates) may sit alongside it.

## Configuration and paths

| Path | Contents |
|---|---|
| `~/.config/goose` | Config directory |
| `~/.config/goose/config.yaml` | Configuration |
| `~/.local/share/goose/sessions/sessions.db` | Sessions (SQLite) |
| `~/.local/state/goose/logs` | Logs |
| `~/.agents/skills/` | Global skills |

Install with the vendor script; `GOOSE_BIN_DIR` chooses the install directory (default
`~/.local/bin`) and `CONFIGURE=false` skips the interactive configure step.

## Documentation

- Vendor documentation: <https://goose-docs.ai/docs/>
- Repository: <https://github.com/aaif-goose/goose>
- Skills guide: `documentation/docs/guides/context-engineering/using-skills.md` in the repository
- Environment variables: `documentation/docs/guides/environment-variables.md`

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch, as absolute paths.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
