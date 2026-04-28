# Cursor CLI — reference

Concise reference for agents. Auth: `CURSOR_API_KEY` or `agent login`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Use `agent models` to list all available models.

## Essential Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--print` | `-p` | Print responses to console (Non-interactive). |
| `--yolo` | `-f` | Alias for `--force`. Auto-approve all commands. |
| `--model` | | Specify the model to use. |
| `--mode` | | Set agent mode: `agent` (default), `plan`, or `ask`. |
| `--plan` | | Shorthand for `--mode=plan`. |
| `--workspace`| | Workspace directory to use. |
| `--output-format`| | `text` (default), `json`, or `stream-json`. |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
