# OpenHands CLI — reference

Concise reference for agents. Auth: Configured via environment variables.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

OpenHands relies on environment variables (e.g., `LLM_MODEL`, `LLM_API_KEY`) for model configuration in headless mode.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--headless` | Run without UI for scripting and automation. |
| `-t`, `--task` | Provide a task description directly. |
| `-f`, `--file` | Load task description from a file. |
| `--json` | Enable structured JSONL output streaming events. |
| `--resume` | Resume a previous conversation. |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
