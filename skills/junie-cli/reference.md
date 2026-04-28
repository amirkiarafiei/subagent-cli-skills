# Junie CLI — reference

Concise reference for agents. Auth: `JUNIE_API_KEY` (via `--auth` or env).

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Model ID | Provider | Description |
|----------|----------|-------------|
| `sonnet` | Anthropic| Latest Claude Sonnet model. |
| `opus`   | Anthropic| Latest Claude Opus model. |
| `gpt`    | OpenAI   | Latest GPT model. |
| `gemini-pro`| Google| Latest Gemini Pro model. |
| `grok`   | xAI      | Latest Grok model. |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--auth` | Provide Junie API token. |
| `--model` | Specify the model to use. |
| `--review` | Start a code review task. |
| `--merge` | Resolve merge conflicts with specified branch/commit. |
| `--rebase` | Resolve rebase conflicts. |
| `--output-format`| `text` (default) or `json`. |
| `--project`, `-p`| Specify path to project directory. |
| `--session-id` | Resume a previous session. |

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
