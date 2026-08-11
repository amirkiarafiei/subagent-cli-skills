# Mistral Vibe CLI — reference

Concise reference for agents. Auth: `MISTRAL_API_KEY` or `vibe --setup`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Recommended Model | Description |
|-------------------|-------------|
| `devstral-latest` | Alias for the current flagship Devstral coding model (Devstral 2, 123B, 256K context). Vibe's default. |
| `devstral-2512`   | Pinned snapshot of the flagship — use for reproducible delegations. |
| `devstral-medium-latest` | Mid-tier coding model. |
| `devstral-small-2507` | Small/fast tier (Devstral Small 2, 24B) — locally deployable. |
| `labs-devstral-small-2512` | Newest small-tier snapshot (labs channel). |
| `mistral-medium-latest` | General (non-coding) model; `mistral-medium-2604` is the current snapshot. |

> **Naming trap:** "Devstral 2" and "Devstral Small 2" are *marketing* names, not API IDs.
> `devstral-2` and `devstral-small-2` are **not** valid model IDs — use the `-latest` aliases or a
> dated snapshot (`YYMM`, e.g. `2512` = Dec 2025).

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
