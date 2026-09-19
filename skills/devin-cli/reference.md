> **Documented, not run against a binary.** Checked against `docs.devin.ai` on 2026-09-19. `devin --help` is the only authority. On an unrecognized flag or rejected value, re-read `--help`, use what exists, and report that this skill needs updating.

## Authentication

`devin auth login` (`--force-manual-token-flow` available), `devin auth logout`, `devin auth
status`. Interactive equivalents `/login` and `/logout`. No API-key environment variable is
documented — credentials are stored by `devin auth login`.

## Models

Run **`devin models list`** — "list available models, organized by model family." Select for a run
with `--model <MODEL>` (or the `DEVIN_MODEL` environment variable). A documented `/fast` interactive
command switches to a faster model tier. Use the web / [Artificial Analysis](https://artificialanalysis.ai/)
only for pricing and benchmark comparisons — always confirm the accepted ID strings against
`devin models list` first.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print [PROMPT]` | Print response and exit (non-interactive mode). Prompt is this flag's value. |
| `--prompt-file <path>` | Load the initial prompt from a file. |
| `--permission-mode <MODE>` | See Approvals below. Also settable via `DEVIN_PERMISSION_MODE`. |
| `--sandbox` | OS-level process sandbox; required by `autonomous` mode (also `DEVIN_SANDBOX`). |
| `--model <MODEL>` | Model for this run (also `DEVIN_MODEL`). |
| `--export <FILE>` | Export the conversation after each turn, e.g. `--export out.json`. |
| `--config <PATH>` | Configuration file location. No default path documented. |
| `--respect-workspace-trust [true\|false]` | Workspace trust validation. Defaults `true`. |
| `-c`, `--continue` | Resume the most recent session in the current directory. |
| `-r`, `--resume [SESSION_ID]` | Resume by ID, or open an interactive picker when omitted. |
| `--` | Everything after it is treated as the prompt, e.g. `devin -- add a login page`. |

**Not documented:** a general wall-clock timeout (only `devin cloud drs run --timeout <SECONDS>`,
default 600, a different command), a quiet/silent flag, and a full exit-code table. Documented
behavior worth knowing: "if a command is still running after the default wait period, Devin moves it
to the background" — the wait period itself is not given.

## Approvals and permissions

Set with `--permission-mode <MODE>` (or `DEVIN_PERMISSION_MODE`):

| Mode | Behavior |
|---|---|
| `normal` (alias `auto`) | Default. Read-only tools auto-run; writes/shell/fetch prompt. |
| `accept-edits` | Auto-approves file edits in the workspace; still prompts for shell/fetch. |
| `smart` | Auto-approves edits; a fast model judges fetch/shell safety and falls back to prompting. |
| `dangerous` (aliases `bypass`, `yolo`) | Auto-approves **all** tool calls, including shell. |
| `autonomous` | **Requires `--sandbox`.** Shell commands and fetches auto-approve inside the OS sandbox. Direct file edits via the `edit`/`write` tools still prompt, because those tools run in the CLI process rather than inside the sandbox. A `Write(...)` scope granted mid-session dynamically expands the sandbox for subsequent commands; mid-session `Read(...)` approvals affect only the agent's own tools. |

**Resolved naming conflict:** earlier docs disagreed on whether the bypass mode's flag value is
`dangerous` or `bypass`. The current reference page gives `dangerous` as the canonical value with
`bypass` and `yolo` as documented aliases — pass whichever your installed binary's `--help` accepts.

Interactive-only equivalents: `/normal`, `/accept-edits`, `/smart`, `/bypass`, `/plan`,
`/ask <question>`, `/autonomous`. These are permission modes, not named subagents — no internal
subagent selector is documented.

**Unanswered approval, documented behavior:** `--print`/`-p` "cannot show the workspace trust
prompt, so it fails in an untrusted directory" — a hard failure, not a stall, for that specific case.
The general fallback for an unanswered tool-approval prompt in `normal`/`accept-edits`/`smart` mode
beyond workspace trust is **not documented** — avoid the situation by running `dangerous` (or
`autonomous` with `--sandbox`) for headless delegation.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `devin models list` | List models, organized by family. **The authority on `--model` values.** |
| `devin list` / `devin ls` | Session picker; `--format json` / `--format csv` available. |
| `devin skills list [--trigger user\|model]` | List discovered skills. |
| `devin skills show <name>` | Show details for a specific skill. |
| `devin skills paths` | Show skill directory locations. |
| `devin rules list [--provider cursor\|windsurf]` | List rules. |
| `devin plugins install <source>` / `list` / `update [name]` | Plugin management. |
| `devin auth login\|logout\|status` | Authentication. |

## Agent Skills

Devin "automatically discovers them across all your connected repositories" — indexing skills for
already-connected repos before a session starts, and scanning repos cloned mid-session.

**No documented global/user-level skills directory.** Only repo-relative locations, checked in this
order:

| Path | Note |
|---|---|
| `.agents/skills/<skill-name>/SKILL.md` | **Recommended** — use this one |
| `.devin/skills/<skill-name>/SKILL.md` | |
| `.github/skills/<skill-name>/SKILL.md` | |
| `.claude/skills/<skill-name>/SKILL.md` | Devin natively reads Claude Code's project convention |
| `.cognition/skills/<skill-name>/SKILL.md` | |
| `.windsurf/skills/<skill-name>/SKILL.md` | |

Layout is `<skills-dir>/<skill-name>/SKILL.md`, one level deep, no documented recursion.
Frontmatter fields: `name` (optional; falls back to the directory name), `description`
(recommended), `allowed-tools` (optional), `argument-hint` (Devin-specific), `triggers`
(Devin-specific, default `["user", "model"]`). Everything after the frontmatter is the skill body.

**Installer note:** because no global path is documented, install this repo's skills for Devin with
the installer's `Custom path…` option pointed at `.agents/skills` inside the target repository. Pi
and Oh My Pi also read a repo-level `.agents/skills`, so one install there covers more than Devin —
note this is the *repo-root* path, distinct from the global `~/.agents/skills/` that Codex and Grok
read.

## Configuration and paths

- `--config <PATH>` — no default path is documented; pass it explicitly if you rely on one.
- `devin skills paths` prints the resolved skill directories for the current repo.

## Documentation

- Official docs: <https://docs.devin.ai/cli/reference/commands>,
  <https://docs.devin.ai/cli/reference/permissions>, <https://docs.devin.ai/cli/essential-commands>
- Vendor card in this skill: [SKILL.md](SKILL.md)

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
