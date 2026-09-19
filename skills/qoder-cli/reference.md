# Qoder CLI — reference

> **Checked against the official Qoder documentation on 2026-09-19. Not run against an installed
> binary — confirm with `qodercli --help` before trusting a flag.**

## Authentication

`qodercli login` or browser-based OAuth.

## Models

Use `qodercli --list-models` to see the models available to your account. Consult
[the model docs](https://docs.qoder.com/en/cli/model) and
[Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing —
names and credit costs change frequently and are not reproduced here.

### Tiered Models

| Tier | Flag | Use Case |
|------|------|----------|
| Auto (Smart Routing) | `--model auto` | Most daily development work (recommended default) |
| Ultimate | `--model ultimate` | Complex system design, deep reasoning |
| Performance | `--model performance` | Core features, architecture, refactoring |
| Efficient | `--model efficient` | Basic code gen, tests, daily Q&A |
| Lite | `--model lite` | Quick validation, basic logic (free for Team users) |

### Frontier models

`--model` also accepts a specific vendor-hosted frontier model identifier directly (not a tier name).
Run `--list-models` for the current set and their credit rates — do not hardcode a name here since it
will go stale.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` (also `--prompt`) | Execute prompt and exit (non-interactive). |
| `-o`, `--output-format` | Output format: `text` (default), `json`, `stream-json`. |
| `--list-models` | Print available models without opening the TUI. |
| `-m`, `--model` | Specify model tier or a frontier model name. |
| `--reasoning-effort` | Thinking depth: `low`, `medium`, `high`, `xhigh`, `max`. |
| `--context-window` | Max context in tokens. |
| `--yolo` | Skip permission checks — shorthand for `--permission-mode bypass_permissions`. |
| `--dangerously-skip-permissions` | Same as `--yolo`. |
| `--permission-mode` | `default`, `plan`, `auto`, `bypass_permissions`, `accept_edits`, `dont_ask` (case-insensitive; `bypassPermissions` etc. also accepted). |
| `-w` | Specify workspace directory. |
| `--worktree [name]` | Start in a separate Git worktree, with auto-merge. |
| `--tools` | Restrict to specific built-in tools (`""` disables all, `default` allows all). |
| `--allowed-tools` | Allow only specified tools (e.g. `Read,Grep,Bash`). |
| `--disallowed-tools` | Disallow specified tools. |
| `--max-turns` | Limit maximum dialog turns. |

## Approvals and permissions

`--permission-mode <mode>`:

| Mode | Behavior |
|------|----------|
| `default` | Auto-runs safe reads/internal operations; sensitive actions require confirmation |
| `accept_edits` | Auto-approves in-workspace file edits; shell/external operations still gated |
| `auto` | The agent decides authorization per action without prompting; a circuit breaker asks for confirmation after too many consecutive blocked actions |
| `bypass_permissions` (`--yolo` / `--dangerously-skip-permissions`) | Skips approval prompts, but destructive operations against the working directory, home directory, filesystem root, or top-level directories still require confirmation |
| `dont_ask` | Built for non-interactive workflows: anything needing approval is **denied** instead of asked |
| `plan` | Legacy compatibility mode: `default` plus a read-only work state (disableable via config) — do not use for delegation |

**Headless default, stated explicitly by the vendor:** "Headless (`-p`/`--prompt`): Auto-deny. No
interaction available; `ask` becomes `deny`." A plain `-p` run with no `--permission-mode` set will
therefore silently refuse anything gated under `default` — pass `--yolo` /
`--dangerously-skip-permissions` for delegation that must act, or `dont_ask` for the same deny-everything
behavior made explicit. Non-default modes only take effect in trusted directories; in an untrusted
directory, Qoder falls back to `default`.

## Subcommands

| Command | Purpose |
|---------|---------|
| `mcp` | MCP server management. |
| `plugins` | Plugin management. |
| `skills` | Skill management. |
| `hooks` | Hook management. |
| `agents` | Subagent management. |
| `login` | Authenticate. |
| `commit` | Commit helper. |
| `rollback` | Rollback helper. |
| `update` | Self-update. |
| `remote-control` | Remote control. |
| `status` | Status info. |
| `feedback` | Send feedback. |
| `wiki` | Wiki helper. |

## Agent Skills

Qoder CLI loads Agent Skills; a `Skills` field on Subagent frontmatter can restrict which Skills a given
subagent may use. Directory locations (from configuration docs):

| Scope | Path |
|---|---|
| User-level | `~/.qoder/skills/` |
| Project-level | `<project>/.qoder/skills/` |

Exact frontmatter requirements and the precise `skills` subcommand syntax are not fully detailed in the
pages consulted — confirm with `qodercli skills --help`.

## Configuration and paths

- `~/.qoder/settings.json`: User global settings.
- `<project>/.qoder/settings.json`: Project-level settings.
- `<project>/.qoder/settings.local.json`: Machine-local settings (add to `.gitignore`).
- `<project>/AGENTS.md` or `<project>/.qoder/AGENTS.md`: Project memory.
- `~/.qoder/skills/`: User-level skills directory.
- `<project>/.qoder/skills/`: Project-level skills directory.

## Documentation

- Vendor documentation: <https://docs.qoder.com/cli/cli-reference>,
  <https://docs.qoder.com/en/cli/permissions>, <https://docs.qoder.com/en/cli/model>,
  <https://docs.qoder.com/cli/subagent>
- **Checked against the official documentation on 2026-09-19. Not run against an installed binary —
  confirm with `qodercli --help` before trusting a flag.**

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
