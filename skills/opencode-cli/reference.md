# OpenCode CLI — reference

Concise reference for agents. Auth: `OPENCODE_API_KEY` (via `/connect` or env).

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Recommended Model | Provider |
|-------------------|----------|
| `gpt-5.2`         | OpenAI   |
| `claude-sonnet-4.5`| Anthropic|
| `gemini-3-pro`    | Google   |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `run` | Execute prompt and exit (Non-interactive). |
| `--dangerously-skip-permissions` | Auto-approve all actions (YOLO). |
| `-m`, `--model` | Specify the model to use (format: `provider/model`). |
| `--format` | Output format: `default` or `json`. |
| `agent create` | Create a custom agent with specific instructions. |
| `github run` | Run a task in a GitHub Actions environment. |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
