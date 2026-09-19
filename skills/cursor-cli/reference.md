> **Checked against the official Cursor documentation on 2026-09-19. Not run against an installed binary — confirm with `agent --help` before trusting a flag.**

## Authentication

`CURSOR_API_KEY` environment variable (recommended for CI/CD), or `--api-key <key>` for a single
invocation, or interactive `agent login`.

## Models

Run **`agent models`** or pass **`--list-models`** to list the models this install accepts. Select
with `--model <model>`. New installs default to automatic model routing. Search the web /
[Artificial Analysis](https://artificialanalysis.ai/) for current identifiers and pricing.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Print responses to console for non-interactive use. Prompt is a separate positional string, not this flag's value. |
| `--output-format <text\|json\|stream-json>` | Default `text`. |
| `--stream-partial-output` | Stream partial output as individual text deltas. |
| `--resume [chatId]` | Resume a chat session. |
| `--continue` | Continue the previous session (alias for `--resume=-1`). |
| `--model <model>` | Model to use. |
| `--mode <plan\|ask>` | Set agent mode. The unnamed default is the normal agent mode. |
| `--plan` | Shorthand for `--mode=plan`. |
| `--workspace <path>` | Workspace directory to use. |
| `--sandbox <enabled\|disabled>` | Sandbox mode. |
| `-w`, `--worktree [name]` | Run in a new Git worktree under `~/.cursor/worktrees/<reponame>/<name>`. |
| `--api-key <key>` | Authenticate for this invocation. |
| `-H`, `--header <header>` | Add a custom header to agent requests. |

## Approvals and permissions

| Flag | Effect |
|---|---|
| `-f`, `--force` (alias `--yolo`) | Force-allow commands unless explicitly denied. |
| `--approve-mcps` | Automatically approve all MCP servers. |
| `--trust` | Trust the workspace without prompting (headless mode only). |

**Unanswered approval, documented behavior:** confirmed from the official headless docs — **without
`--force`/`--yolo`, changes are only proposed, not applied.** This is not a stall and not an error:
the agent still prints its response in `-p` mode, but file edits and other confirmation-gated
actions are silently skipped rather than made. For a delegation that must change files,
`--force`/`--yolo` is required; a report-only run can simply omit it.

## Subcommands

`agent` (default), `login`, `logout`, `status` / `whoami`, `about`, `models`, `mcp`, `sandbox`,
`worker`, `acp`, `update`, `ls`, `resume`, `create-chat`, `generate-rule` / `rule`,
`install-shell-integration` / `uninstall-shell-integration`.

## Configuration and paths

- `mcp.json` — auto-detected; the CLI respects the same MCP servers/tools configured for the editor.
- `~/.cursor/worktrees/<reponame>/<name>` — default worktree location for `-w`/`--worktree`.
- `cli-config.json` — CLI configuration file (see the Cursor configuration reference).

## Documentation

- Official docs: <https://cursor.com/docs/cli/headless>,
  <https://cursor.com/docs/cli/reference/parameters>,
  <https://cursor.com/docs/cli/reference/authentication>
- Vendor card in this skill: [SKILL.md](SKILL.md)

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
