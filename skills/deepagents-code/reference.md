# Deep Agents Code (`dcode`) — reference

> **Verified against `deepagents-code` 0.1.72 on 2026-09-21 by running the binary** (`--help`,
> `config --help`, `config path`, `skills --help`, `skills list`, and a real `-n` run) and by reading
> the installed package source. **The official documentation disagrees with this build in several
> places** — `config show`/`config list`, the `--allow-fs-tools execute` example, and the role of
> `--yolo` in headless mode — each noted inline; the binary wins. A model turn was never completed
> (no credentials), so exit codes `0` and `124` are documented rather than observed. Version 0.1.72
> shipped on 2026-09-21; re-check before trusting this later.

## Installation

```bash
curl -LsSf https://langch.in/dcode | bash
```

The binary is `dcode`. Deep Agents Code is the `deepagents-code` package in
`langchain-ai/deepagents` (`libs/code`).

> **Do not install anything called `dcode` from npm or PyPI.** Several unrelated packages use that
> name — a Material Design UI library, a URL-sharing tool, and others. None is this CLI. The npm
> `deepagents-cli` package and the PyPI `deepagents-cli` package are deploy tooling, not this agent;
> the PyPI one is deprecated in favour of `managed-deepagents` (`mda`), which is also a different
> thing. Use the vendor script above.

## Authentication

Credentials are stored per provider and resolved at run time.

| Command | Purpose |
|---|---|
| `dcode auth list` | List known providers and where each credential resolves from |
| `dcode auth status <provider>` | Credential source for one provider |
| `dcode auth set <provider>` | Store a credential from stdin or `--from-env` |
| `dcode auth remove <provider>` | Remove a stored credential |
| `dcode auth path` | Show the credential store path |

`dcode auth set` refuses to run in an interactive terminal unless the key is piped via stdin or
`--from-env` is used, so the key never lands in shell history.

## Models

Select with `-M`/`--model <MODEL>`. Provider-prefixed (`<provider>:<model-id>`) works, and a bare
model name works when the provider is unambiguous. **No shell command lists models** — the picker is
interactive only; the provider catalogue is a documentation page.

`--rubric-model <MODEL>` sets the model used by the rubric grader and defaults to the main agent
model. `--default-model [MODEL]` shows or sets the persistent default.

`dcode config` prints every option's effective value and its source; add `-v`/`--verbose` for each
option's description and how to set it. **The vendor documentation lists `dcode config show` and
`dcode config list`; this build has neither** — only `dcode config`, `dcode config get <key|section>`
and `dcode config path`. Never hard-code a model identifier.

## Essential Flags

`dcode` launches an interactive session. For delegation, always pass `-n` or pipe stdin.

| Flag | Meaning |
|---|---|
| `-n`, `--non-interactive <TEXT>` | Run a single task non-interactively and exit |
| `--stdin` | Read input from stdin explicitly instead of auto-detection |
| `-q`, `--quiet` | Clean output for piping — only the agent's response on stdout |
| `--no-stream` | Buffer the full response and write it at once |
| `--max-turns <N>` | Cap agentic turns |
| `--timeout <SECONDS>` | Hard wall-clock limit |
| `--allow-fs-tools <list>` | Which filesystem tools exist (see below) |
| `-S`, `--shell-allow-list <list>` | Which shell commands may run through `execute` |
| `-M`, `--model <MODEL>` | Primary model (**`-m` is `--message`, not the model**) |
| `-a`, `--agent <NAME>` | Agent to use |
| `-m`, `--message <TEXT>` | Initial prompt to auto-submit on start |
| `--skill <name>` | Invoke a skill immediately on launch |
| `--rubric <TEXT\|@PATH>` | Acceptance criteria for rubric grading |
| `--show-reasoning` | Provider-visible reasoning; goes to stderr when non-interactive |
| `--startup-cmd <CMD>` | Shell command run before the first prompt (60 s cap when non-interactive) |
| `-y`, `--auto-approve` | Classifier-backed Auto mode (TUI or ACP) — **ignored with a warning in headless mode** |
| `--yolo` | Gated actions without review (TUI or ACP) — **ignored with a warning in headless mode**; it has **no** short form |
| `--no-mcp`, `--mcp-config`, `--trust-project-mcp` | MCP control; place before a subcommand |

`-q`, `--no-stream`, `--max-turns`, `--timeout` and the rubric flags all require `-n` or piped stdin.

When stdin is piped the run goes non-interactive automatically. Combining a pipe with `-n` puts the
piped content first, then the flag text. Maximum piped input is **10 MiB**.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | Success, or an intentional hook stop |
| `1` | Runtime failure (observed: missing credentials) |
| `2` | Argument/usage error, including an `--allow-fs-tools` list without `read_file` |
| `124` | `--max-turns` or `--timeout` budget exceeded, matching GNU `timeout` |
| `130` | Keyboard interrupt |

Read from the installed source, whose docstring states "0 for success or an intentional hook stop, 1
for error, 124 when the `--max-turns` budget was exceeded (matching GNU `timeout`), 130 for keyboard
interrupt". The `--help` text mentions 124 only under `--timeout`, which is incomplete rather than
contradictory — both budgets use it.

## Approvals and permissions

Approval modes are Manual (default), Auto and YOLO, and read-only tools such as `ls`, `read_file`,
`glob` and `grep` always run without prompting. **None of that applies to a headless run.**

`-y`/`--auto-approve` and `--yolo` are both marked "(TUI or ACP); **ignored with a warning in headless
mode**". Passing either changes nothing and prints a warning to stderr. They do not stall and they do
not grant anything.

In non-interactive mode the only lever is the shell allowlist:

| Flag | Role |
|---|---|
| `-S`, `--shell-allow-list <CMDS>` | **Enables shell.** Comma-separated commands, `recommended`, or `all` |
| `--allow-fs-tools <LIST>` | *Restricts* filesystem tools. All are exposed by default; unrelated to shell |

Without `-S` the agent answers but executes nothing. `--allow-fs-tools` is only for narrowing: its
valid names are `ls`, `read_file`, `write_file`, `edit_file`, `delete`, `glob`, `grep`, `execute`, or
the single word `all`, and an explicit list must contain `read_file` or the run exits `2`.

`recommended` resolves to readers and formatters only — `ls, dir, cat, head, tail, grep, wc, strings,
cut, tr, diff, md5sum, sha256sum, pwd, which, uname, hostname, whoami, id, groups, uptime, nproc,
lscpu, lsmem, ps` — read from the installed package. It excludes `git`, `python`, `pytest`, `npm` and
`make`, so it cannot run a build or a test. Name the commands you need, or use `all`.

`DEEPAGENTS_CODE_SHELL_ALLOW_LIST` sets the same thing from the environment.

In non-interactive mode the agent is instructed to make reasonable assumptions and proceed
autonomously rather than ask clarifying questions, and to prefer non-interactive command variants.

## Subcommands

| Command | Purpose |
|---|---|
| `dcode tools list [--json]` | Tools available to the configured agent |
| `dcode agents list` | List agents (alias `ls`) |
| `dcode agents reset --agent NAME` | Clear agent memory; supports `--dry-run` |
| `dcode skills list\|create\|info\|delete\|trust [--project]` | Manage skills |
| `dcode threads list\|delete` | Manage sessions |
| `dcode config` / `config get` / `config path` | Inspect configuration |
| `dcode auth ...` | Manage credentials |
| `dcode mcp login\|config` | MCP servers |
| `dcode doctor` | Diagnostics without launching a session |
| `dcode update` | Check for and install updates |

All management subcommands support `--json`. Destructive commands support `--dry-run`.

## Agent Skills

At startup Deep Agents Code reads the `name` and `description` from each `SKILL.md` frontmatter. When
a task matches a description, it reads the file and follows the instructions. Discovery re-runs on
`/reload`.

Locations read:

| Scope | Path |
|---|---|
| Built-in | bundled with the package |
| User | `~/.deepagents/<agent_name>/skills/` |
| User, shared | `~/.agents/skills/` |
| Project | `<project>/.deepagents/skills/` |
| Project, shared | `<project>/.agents/skills/` |
| User, compatibility | `~/.claude/skills/` |
| Project, compatibility | `<project>/.claude/skills/` |

All directories are merged into one list; a higher-precedence entry only replaces a skill with the
**same name**, it does not hide the rest of a directory. The `~/.claude/skills` tree is labelled experimental
in the docs, but this build reads it without any feature gate — so an existing Claude Code skills
directory is already visible to `dcode`.

Note that `dcode skills list` under-reports: skills the agent loads may not appear in that listing, so
do not use it as the only proof an install worked.

`dcode skills --agent <name>` defaults to `agent`, so global installs land in
`~/.deepagents/agent/skills/`. Verified: `dcode skills list` also reads `~/.agents/skills/`. For
a custom-named agent, install per project or symlink into `~/.deepagents/<your-agent>/skills/`.
Project roots are identified by a containing `.git` folder.

`dcode skills create NAME [--project]` writes a template `SKILL.md`, and `--skill <name>` invokes one
on launch.

## Configuration and paths

| Path | Contents |
|---|---|
| `~/.deepagents/config.toml` | Configuration, including `[startup] mode` |
| `~/.deepagents/<agent_name>/memories/` | Agent memory as markdown |
| `~/.deepagents/<agent_name>/AGENTS.md` | Global instructions |
| `.deepagents/AGENTS.md` | Project instructions |
| `~/.deepagents/<agent_name>/skills/` | User skills |
| `.deepagents/skills/` | Project skills |

`dcode config path` prints the config file locations and whether each exists.

## Documentation

- CLI reference: <https://docs.langchain.com/oss/deepagents/code/cli-reference>
- Overview: <https://docs.langchain.com/oss/deepagents/code/overview>
- Quickstart: <https://docs.langchain.com/oss/deepagents/code/quickstart>
- Approval modes: <https://docs.langchain.com/oss/deepagents/code/approval-modes>
- Memory and skills: <https://docs.langchain.com/oss/deepagents/code/memory-and-skills>
- Repository: <https://github.com/langchain-ai/deepagents>

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch, as absolute paths.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
