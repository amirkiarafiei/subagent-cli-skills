# Devin CLI — reference

> **Documented, not verified.** Written from Devin's published CLI docs on 2026-09-06 and **not** checked
> against an installed binary. `devin --help` is the only authority. On an unrecognized flag or rejected
> value, re-read `--help`, use what exists, and report that this skill needs updating.

Auth: `devin auth login` (`--force-manual-token-flow` available), `devin auth logout`,
`devin auth status`. Interactive equivalents `/login` and `/logout`. **No API-key environment variable is
documented** — credentials are stored by `devin auth login`.

## Models

Run **`devin models list --format json`** for the accepted strings. The docs reference `--model` and the
`DEVIN_MODEL` environment variable and show `--model opus` in an example, but **do not enumerate valid
IDs**. `/fast` is documented as switching to "SWE-1.6 Fast".

## Permission modes

| Mode | Behaviour |
|---|---|
| `normal` | Default. |
| `accept-edits` | Accepts edits without prompting. |
| `smart` | Auto-approves edits; a fast model judges the safety of other actions and falls back to prompting. |
| `dangerous` | Auto-approves **all** tool calls. |
| `autonomous` | **Requires `--sandbox`.** Everything **except file writes** is auto-approved; the OS sandbox enforces the boundary instead of prompts. Note the carve-out — this is not blanket autonomy. |

> ⚠️ **Naming conflict inside Devin's own docs.** The essential-commands page calls the bypass mode
> `bypass` (aliases `/yolo`, `/dangerous`); the command reference lists it as `dangerous`. This skill
> does not pick a winner — resolve it against `devin --help` and report which spelling was right.

Interactive mode equivalents: `/normal`, `/accept-edits`, `/smart`, `/bypass`, `/plan`, `/ask <question>`,
`/autonomous`. These are permission modes, **not** named subagents — no internal subagent selector is
documented.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print [PROMPT]` | Non-interactive output mode; exits after the response. |
| `--permission-mode <MODE>` | See the table above. Also settable via `DEVIN_PERMISSION_MODE`. |
| `--sandbox` | OS-level process sandbox; required by `autonomous`. |
| `--model <MODEL>` | Model for this run (also `DEVIN_MODEL`). |
| `--export <FILE>` | Export the run, e.g. `--export out.json`. |
| `--config <PATH>` | Configuration file location. No default path documented. |
| `--respect-workspace-trust [true\|false]` | Workspace trust validation. Defaults `true`. |
| `-c`, `--continue` | Resume the most recent session. |
| `-r`, `--resume [SESSION_ID]` | Resume by ID, or open an interactive picker when omitted. |
| `--` | Everything after it is treated as the prompt (`devin -- add a login page`). |

**Not documented:** a general wall-clock timeout (only `devin cloud drs run --timeout <SECONDS>`, default
600, which is a different command), a quiet/silent flag, an exit-code table, and any API-key env var.

Documented behaviour worth knowing: "If a command is still running after the default wait period, Devin
moves it to the background" — the wait period itself is not given.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `devin models list --format json` | List models. **The authority on `--model` values.** |
| `devin list` / `devin ls` | Session picker; `--format json` / `--format csv` available. |
| `devin skills list [--trigger user\|model]` | List discovered skills. |
| `devin rules list [--provider cursor\|windsurf]` | List rules. |
| `devin plugins install <source>` / `list` / `update [name]` | Plugin management. |
| `devin auth login\|logout\|status` | Authentication. |

## Agent Skills

Devin "automatically discovers them across all your connected repositories" — indexing skills for
already-connected repos before a session starts, and scanning repos cloned mid-session.

**There is no documented global/user-level skills directory.** Only repo-relative locations, checked in
this order:

| Path | Note |
|---|---|
| `.agents/skills/<skill-name>/SKILL.md` | **Recommended** — use this one |
| `.devin/skills/<skill-name>/SKILL.md` | |
| `.github/skills/<skill-name>/SKILL.md` | |
| `.claude/skills/<skill-name>/SKILL.md` | Devin natively reads Claude Code's project convention |
| `.cognition/skills/<skill-name>/SKILL.md` | |
| `.windsurf/skills/<skill-name>/SKILL.md` | |

Layout is `<skills-dir>/<skill-name>/SKILL.md`, one level deep, no documented recursion. Frontmatter
fields: `name` (optional; falls back to the directory name), `description` (recommended),
`allowed-tools` (optional), `argument-hint` (Devin-specific), `triggers` (Devin-specific, default
`["user", "model"]`). "Everything after the frontmatter is the skill body."

**Installer note:** because no global path is documented, install this repo's skills for Devin with the
installer's `Custom path…` option pointed at `.agents/skills` inside the target repository. Pi and Oh My
Pi also read a repo-level `.agents/skills`, so one install there covers more than Devin — note this is
the *repo-root* path, distinct from the global `~/.agents/skills/` that Codex and Grok read.

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
