# Claude Code CLI — reference

Concise reference for agents. Auth: `CLAUDE_API_KEY` or `claude login`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Model Alias | Description |
|-------------|-------------|
| `sonnet`    | Latest Claude Sonnet model. |
| `opus`      | Latest Claude Opus model. |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--print`, `-p` | Execute prompt and exit (Non-interactive). |
| `--bare` | Skip auto-discovery of hooks/skills for faster startup. |
| `--permission-mode auto` | Enable autonomous execution with safety classifier. |
| `--dangerously-skip-permissions` | Bypass all confirmation prompts (YOLO). |
| `--permission-mode plan` | Read-only planning mode. |
| `--model` | Specify the model to use. |
| `--output-format` | `text` (default), `json`, or `stream-json`. |
| `--max-turns` | Limit the number of agentic turns. |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
