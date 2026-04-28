# Kimi Code CLI — reference

Concise reference for agents. Auth: `KIMI_API_KEY` or `kimi login`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Recommended Model | Description |
|-------------------|-------------|
| `kimi-latest`     | Flagship model. |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--prompt`, `-p` | Execute prompt and exit (Non-interactive). |
| `--print` | Run in print mode (non-interactive), implicitly enables `--yolo`. |
| `--yolo`, `-y` | Auto-approve all operations. |
| `--model`, `-m` | Specify the model to use. |
| `--plan` | Start in plan mode (read-only). |
| `--max-ralph-iterations`| Number of iterations for Ralph loop mode. |
| `--output-format` | `text` (default) or `stream-json`. |
| `--final-message-only` | Only output the final assistant message. |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
