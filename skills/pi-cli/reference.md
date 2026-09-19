# Pi CLI — reference

> **Checked against the official Pi documentation on 2026-09-19. Not run against an installed binary —
> confirm with `pi --help` and `pi --list-models` before trusting a flag.**

## Authentication

`ANTHROPIC_API_KEY` (example shown in the docs) or `--api-key <key>` to override the environment.
Interactive `/login` and `/logout` manage OAuth or API-key credentials. Stored at
`~/.pi/agent/auth.json`.

## Models

Run **`pi --list-models [search]`**. Select with `--model <provider/id>`, optionally suffixed
`:<thinking>`, alongside `--provider <name>` (e.g. `anthropic`, `openai`, `google`). Concrete IDs are
not pinned beyond that pattern — ask the binary. `--thinking <level>` accepts `off`, `minimal`, `low`,
`medium`, `high`, `xhigh`, `max`. `--models <patterns>` (comma-separated) is for interactive cycling
only.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Print response and exit. The prompt is positional, not an argument to this flag. |
| `--mode <mode>` | `json` (JSON-lines events) or `rpc` (stdin/stdout RPC). |
| `--provider <name>` | Provider selection. |
| `--model <provider/id[:thinking]>` | Model selection. |
| `--thinking <level>` | `off\|minimal\|low\|medium\|high\|xhigh\|max`. |
| `--list-models [search]` | List available models. |
| `-a`, `--approve` | Trust project-local files for this run — project trust, *not* tool approval. |
| `-na`, `--no-approve` | Ignore project-local files for this run. |
| `--tools <list>` | Allowlist of tools. |
| `--exclude-tools <list>` | Denylist of tools. |
| `-nbt`, `--no-builtin-tools` | Disable built-in tools only. |
| `--no-tools` | Disable all tools. |
| `-c`, `--continue` | Resume the most recent session. |
| `-r`, `--resume` | Browse and select a session. |
| `--session <path\|id>` | Use a specific session file or UUID. |
| `--fork <path\|id>` | Fork into a new session. |
| `--no-session` | Ephemeral, unsaved run. |
| `-e`, `--extension <source>` | Load an extension (path, npm, git). Repeatable. |
| `--skill <path>` | Load a skill explicitly. Repeatable; additive even with `--no-skills`. |
| `--no-skills` | Disable skill discovery. |
| `--api-key <key>` | Override credentials from the environment. |
| `@file` | Attach a file to the message (`pi @README.md "prompt"`). |

Not documented: any timeout/limit flag, an exit-code table, and — importantly — any approve-all /
`--yolo` equivalent.

## Approvals and permissions

**Verified: Pi has no per-tool-call permission system.** Its security docs state Pi "is a local coding
agent. It runs with the permissions of the user account that starts it," "does not include a built-in
sandbox," and built-in tools "can read files, write files, edit files, and run shell commands with the
permissions of the pi process." There is no allow/deny/ask policy for `bash`, `write`, or `edit`.

The only gate is **project trust**, which decides whether project-local settings, resources, extensions,
and skills are *loaded* — not whether a tool call is allowed:

- Global setting `defaultProjectTrust`: `ask` (default), `always`, or `never`.
- Saved decisions in `~/.pi/agent/trust.json`; `/trust` sets them interactively.
- Trusting a project allows Pi to load `.pi/settings.json` and `.pi` resources, install missing project
  packages, and execute project extensions.
- Headless, verbatim: **"Non-interactive modes (`-p`, `--mode json`, and `--mode rpc`) do not show a
  trust prompt."** Without an applicable saved decision they fall back to `defaultProjectTrust`; `ask`
  and `never` ignore those project resources, `always` trusts them.

Tool-call confirmation is possible only via a custom extension using the `tool_call` event and
`ctx.ui.confirm(...)`; `ctx.hasUI` is "true in TUI and RPC modes, false in print mode (`-p`) and JSON
mode" — behavior of a confirm call when `hasUI` is false is not documented. For untrusted work, Pi's
docs recommend "a container, VM, micro-VM, remote sandbox, or policy-controlled sandbox."

## Subcommands

Pi is invoked as flags on the base `pi` binary rather than through named subcommands in the sources
used here (e.g. no separate `pi models` or `pi skills` subcommand beyond the flags above).

## Agent Skills

Pi loads skills from `SKILL.md` files under designated skill paths. Frontmatter and descriptions load at
startup; the full body is retrieved when the skill becomes relevant.

| Scope | Path |
|---|---|
| Global (user) | `~/.pi/agent/skills/` |
| Shared cross-agent | `~/.agents/skills/` |
| Project | `.pi/skills/` and `.agents/skills/`, resolved from the working directory up to the git repo root, once the project is trusted |

Layout is `<skills-dir>/<skill-name>/SKILL.md` with optional `scripts/`, `references/`, `assets/`.
Directories containing `SKILL.md` are discovered recursively. The two global roots differ: in
`~/.pi/agent/skills/` (and project `.pi/skills/`) root-level `.md` files also count as skills, whereas
`~/.agents/skills/` expects nested grouping folders rather than bare root `.md` files.

Frontmatter: `name` required (max 64 chars, lowercase `a-z`, `0-9`, hyphens) and `description` required
(max 1024 chars). Optional: `license`, `compatibility`, `metadata`, `allowed-tools`,
`disable-model-invocation`.

Pi can read other agents' skills, opt-in via settings — add their directories under a `skills` array in
`settings.json` / `.pi/settings.json`, e.g. `~/.claude/skills` and `~/.codex/skills` (or
`../.claude/skills` for a project-level Claude Code skills folder).

## Configuration and paths

| Component | Path |
|---|---|
| Global skills | `~/.pi/agent/skills/` |
| Global context / system prompt | `~/.pi/agent/AGENTS.md`, `~/.pi/agent/SYSTEM.md` |
| Sessions | `~/.pi/agent/sessions/` |
| Auth | `~/.pi/agent/auth.json` |
| Trust decisions | `~/.pi/agent/trust.json` |
| Project settings / system prompt | `.pi/settings.json`, `.pi/SYSTEM.md` |
| Project context files | `AGENTS.md`, `AGENTS.override.md`, or `CLAUDE.md` (walked up the tree) |

## Documentation

- Vendor documentation: <https://pi.dev/docs/latest/usage>, <https://pi.dev/docs/latest/settings>,
  <https://pi.dev/docs/latest/skills>
- **Checked against the official documentation on 2026-09-19. Not run against an installed binary —
  confirm with `pi --help` before trusting a flag.**

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
