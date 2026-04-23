# Gemini CLI — reference

Concise reference for agents. Auth: `GEMINI_API_KEY` or interactive OAuth.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.**

- **Default (Simple Tasks)**: `flash` (Alias for `gemini-3.1-flash-preview`)
- **Heavy Tasks**: `pro` (Alias for `gemini-3.1-pro-preview`)

## Subagents

Specialists run in isolated context. Force with **`@name`** at the start of the prompt.

| Name | Role |
|------|------|
| `codebase_investigator` | Deep codebase analysis, dependencies, “how does X work?” |
| `generalist` | Broad/heavy subtasks (multi-file edits, large output) with tool access. |
| `gemini-cli-security` | Security-focused audits (injection, XSS, auth). |
| `code-review` | Code-review / PR-style analysis. |

## Essential Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--yolo` | `-y` | Auto-approve tool calls. |
| `--output-format` | `-o` | `text`, `json`. Use `text` for clean scripting output. |
| `--model` | `-m` | Specify the model to use. |
| `--worktree` | `-w` | Run in a Git worktree (experimental). |
| `--resume` | `-r` | Resume a session (e.g., `-r latest`). |

## JSON Output (`-o json`)

Parse top-level `response` and `stats` (model tokens, tool usage).

## Delegation Checklist

1. **Full Goal**: Clearly state what needs to be achieved.
2. **Prior Decisions**: Stack, style, and API choices already made.
3. **Scope**: Define `@paths` or out-of-scope areas.
4. **Constraints**: Performance, a11y, or compatibility requirements.
5. **Desired Shape**: "Summarize results," "Apply diffs," etc.
