# Mistral Vibe CLI — reference

Concise reference for agents. Auth: `MISTRAL_API_KEY` or `vibe --setup`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Recommended Model | Description |
|-------------------|-------------|
| `devstral-2`      | Flagship coding model. |
| `devstral-small-2`| Fast and efficient coding model. |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--prompt` | Execute prompt and exit (Non-interactive). |
| `--model` | Specify the model to use. |
| `--output` | Output format: `text` (default), `json`, or `streaming`. |
| `--max-turns` | Limit the maximum number of assistant turns. |
| `--max-price` | Set a maximum cost limit in dollars. |
| `--enabled-tools` | Enable specific tools (disables all others). |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
