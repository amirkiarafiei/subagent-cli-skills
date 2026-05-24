# Antigravity CLI — reference

Concise reference for agents. Auth: Silent keyring sign-in (local), Google Sign-In via SSH URL (remote), or `/logout`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

- **Default (Simple Tasks)**: `gemini-3.5-flash`
- **Heavy Tasks**: `pro` or `gemini-3.1-pro`

## Subagents

Specialists run in isolated contexts. Force with **`@name`** at the start of the prompt.
Manage active child tasks using the `/agents` panel inside the Terminal User Interface (TUI).

| Name | Role |
|------|------|
| `codebase_investigator` | Deep codebase analysis, dependencies, “how does X work?” |
| `generalist` | Broad/heavy subtasks (multi-file edits, large output) with tool access. |
| `gemini-cli-security` | Security-focused audits (injection, XSS, auth). |
| `code-review` | Code-review / PR-style analysis. |

### TUI Subagent Management
- **View child logs**: Type `/agents` to open the subagents dashboard.
- **Fast Path Approval**: Press `ctrl+k` to approve the pending subagent tool request instantly from the main conversation.
- **Teleport Focus**: Press `ctrl+j` to instantly switch focus from the main thread directly to the detailed view of the next subagent waiting for approval.

## Essential Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--dangerously-skip-permissions` | `-y` / `--yolo` | Auto-approve tool calls. |
| `--output-format` | `-o` | `text`, `json`. Use `text` for clean scripting output. |
| `--model` | `-m` | Specify the model to use. |
| `--bare` | | Disable TUI and run as bare CLI execution. |
| `--worktree` | `-w` | Run in a Git worktree. |
| `--sandbox` | | Force command execution to run within the isolation sandbox. |
| `--resume` | `-r` | Resume a session (e.g., `-r latest`). |

## Essential Paths

| Scope | Component | File Path |
|-------|-----------|-----------|
| **Global** | Configuration Settings | `~/.gemini/antigravity-cli/settings.json` |
| **Global** | Custom Keybindings | `~/.gemini/antigravity-cli/keybindings.json` |
| **Global** | MCP Configuration | `~/.gemini/antigravity/mcp_config.json` |
| **Global** | Global Skills | `~/.gemini/antigravity-cli/skills/` |
| **Global** | Global Rules | `~/.gemini/GEMINI.md` |
| **Workspace**| Workspace Skills | `<workspace-root>/.agents/skills/` |
| **Workspace**| Workspace Rules | `<workspace-root>/.agents/rules/` |
| **Workspace**| Workspace Plugins | `<workspace-root>/.agents/plugins/` |

## Terminal Sandbox Configuration
Configure your security parameters in `~/.gemini/antigravity-cli/settings.json`:
```json
{
  "enableTerminalSandbox": true
}
```

## Delegation Checklist

1. **Full Goal**: Clearly state what needs to be achieved.
2. **Prior Decisions**: Stack, style, and API choices already made.
3. **Scope**: Define `@paths` or out-of-scope areas.
4. **Constraints**: Performance, a11y, or compatibility requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Summarize results," "Apply diffs," etc.
