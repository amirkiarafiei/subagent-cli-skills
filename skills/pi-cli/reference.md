# Pi CLI — reference

> **Documented, not verified.** Written from Pi's published docs (pi.dev) on 2026-09-06 and **not**
> checked against an installed binary. `pi --help` and `pi --list-models` are the only authorities. On an
> unrecognized flag, re-read `--help`, use what exists, and report that this skill needs updating.

Auth: `ANTHROPIC_API_KEY` (example shown in the docs) or `--api-key <key>` to override the environment.
Interactive `/login` and `/logout` manage OAuth or API-key credentials. Stored at
`~/.pi/agent/auth.json`.

## Models

Run **`pi --list-models [search]`**. Models are selected as `--model <provider/id>` with an optional
`:<thinking>` suffix, plus `--provider <name>` (e.g. `anthropic`, `openai`, `google`). Concrete IDs are
**NOT DOCUMENTED** beyond that pattern. `--thinking` accepts `off`, `minimal`, `low`, `medium`, `high`,
`xhigh`, `max`. `--models <patterns>` (comma-separated) is for interactive cycling only.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Print response and exit. **The prompt is positional**, not an argument to this flag. |
| `--mode <mode>` | `json` (JSON-lines events) or `rpc` (stdin/stdout RPC). |
| `--provider <name>` | Provider selection. |
| `--model <provider/id[:thinking]>` | Model selection. |
| `--thinking <level>` | `off\|minimal\|low\|medium\|high\|xhigh\|max`. |
| `--list-models [search]` | List available models. |
| `-a`, `--approve` | **"Trust project-local files for this run"** — project trust, *not* tool approval. |
| `-na`, `--no-approve` | **"Ignore project-local files for this run."** |
| `--tools <list>` / `-t` | Allowlist of tools. |
| `--exclude-tools <list>` / `-xt` | Denylist of tools. |
| `--no-builtin-tools` / `-nbt`, `--no-tools` / `-nt` | Disable built-in tools / all tools. |
| `-c`, `--continue` | Resume the most recent session. |
| `-r`, `--resume` | Browse and select a session. |
| `--session <path\|id>` | Use a specific session file or UUID. |
| `--fork <path\|id>` | Fork into a new session. |
| `--no-session` | Ephemeral, unsaved run. |
| `-n`, `--name <name>` | Set the session display name. |
| `--skill <path>` | Load a skill explicitly. Repeatable; additive even with `--no-skills`. |
| `--no-skills` | Disable skill discovery. |
| `-e`, `--extension <source>` | Load an extension. Repeatable. `--no-extensions` disables. |
| `-nc`, `--no-context-files` | Disable `AGENTS.md` / `CLAUDE.md` loading. |
| `--api-key <key>` | Override credentials from the environment. |
| `@file` | Attach a file to the message (`pi @README.md "prompt"`). |

**Not documented:** any timeout/limit flag, an exit-code table, and — importantly — any approve-all /
`--yolo` equivalent.

## Permissions and trust — read this before delegating

Pi has **no per-tool-call permission system**. From its security docs: Pi "is a local coding agent. It
runs with the permissions of the user account that starts it," it "does not include a built-in sandbox,"
and built-in tools "can read files, write files, edit files, and run shell commands with the permissions
of the pi process." There is no allow/deny/ask policy for `bash`, `write` or `edit`.

The only gate is **project trust**, which decides whether project-local settings, resources, extensions
and skills are *loaded*:

- Global setting `defaultProjectTrust`: `ask` (default), `always`, or `never`.
- Saved decisions in `~/.pi/agent/trust.json`; `/trust` sets them interactively.
- "Trusting a project allows pi to load `.pi/settings.json` and `.pi` resources, install missing project
  packages, and execute project extensions."
- Headless, verbatim: **"Non-interactive modes (`-p`, `--mode json`, and `--mode rpc`) do not show a
  trust prompt."** Without an applicable saved decision they fall back to `defaultProjectTrust`; `ask`
  and `never` ignore those project resources, `always` trusts them.

Tool-call confirmation is possible only via a custom extension using the `tool_call` event and
`ctx.ui.confirm(...)`. Note `ctx.hasUI` is "true in TUI and RPC modes. false in print mode (`-p`) and
JSON mode" — behaviour of a confirm call when `hasUI` is false is **NOT DOCUMENTED**. For untrusted work
Pi's docs recommend "a container, VM, micro-VM, remote sandbox, or policy-controlled sandbox."

## JSON event stream (`--mode json`)

Each line is a JSON object. The first is a session header:
`{"type":"session","version":3,"id":"uuid","timestamp":"...","cwd":"/path"}`.

Event types: `agent_start`, `turn_start`, `message_start`, `message_update`, `message_end`, `turn_end`,
`agent_end`, `tool_execution_start`, `tool_execution_update`, `tool_execution_end`, `queue_update`,
`compaction_start`, `compaction_end`.

`message_update` records are **delta-only** — they carry `usage`, `assistantMessageEvent`, `contentIndex`
and `delta`, not a cumulative snapshot. Accumulate deltas rather than expecting full text per event.

## Agent Skills

"Pi loads skills from `SKILL.md` files located in directories within designated skill paths." Frontmatter
and descriptions load at startup; the full body is retrieved when the skill becomes relevant.

| Scope | Path |
|---|---|
| **Global (user)** | `~/.pi/agent/skills/` |
| **Shared cross-agent** | `~/.agents/skills/` |
| **Project** | `.pi/skills/` and `.agents/skills/`, resolved from the working directory up to the git repo root |

Layout is `<skills-dir>/<skill-name>/SKILL.md` with optional `scripts/`, `references/`, `assets/`.
Directories containing `SKILL.md` are discovered recursively. The two global roots differ: in
`~/.pi/agent/skills/` (and project `.pi/skills/`) root-level `.md` files also count as skills, whereas
`~/.agents/skills/` expects nested grouping folders rather than bare root `.md` files.

Frontmatter: `name` **required** (max 64 chars, lowercase `a-z`, `0-9`, hyphens) and `description`
**required** (max 1024 chars). Optional: `license`, `compatibility`, `metadata`, `allowed-tools`,
`disable-model-invocation`. Nothing this repo ships is forbidden.

Pi can read other agents' skills, but **opt-in via settings**: "To use skills from Claude Code or OpenAI
Codex, add their directories to settings" — e.g. `~/.claude/skills` and `~/.codex/skills`.

## Essential Paths

| Component | Path |
|---|---|
| Global skills | `~/.pi/agent/skills/` |
| Global context / system prompt | `~/.pi/agent/AGENTS.md`, `~/.pi/agent/SYSTEM.md` |
| Sessions | `~/.pi/agent/sessions/` |
| Auth | `~/.pi/agent/auth.json` |
| Trust decisions | `~/.pi/agent/trust.json` |
| Project settings / system prompt | `.pi/settings.json`, `.pi/SYSTEM.md` |
| Project context files | `AGENTS.md`, `AGENTS.override.md`, or `CLAUDE.md` (walked up the tree) |

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
