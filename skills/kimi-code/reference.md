# Kimi Code CLI — reference

Concise reference for agents. Auth: `KIMI_API_KEY` or `kimi login`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Recommended Model | Description |
|-------------------|-------------|
| `kimi-k2.7-code` | Coding flagship — long-context, precise instruction following. Default choice for delegation. |
| `kimi-k2.7-code-highspeed` | Same generation, faster/cheaper — simple edits and tight loops. |
| `kimi-k3` | Newest general-purpose frontier model. |
| `kimi-k2-thinking` | Extended-reasoning variant (also `-turbo`) for complex logic. |
| `kimi-k2.6` / `kimi-k2.5` | Previous generations, still selectable. |

`kimi-latest` is a moving alias rather than a pinned model — prefer an explicit `kimi-k2.7-code`
or `kimi-k3` for reproducible delegations.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--prompt`, `-p` | Execute prompt and exit (Non-interactive). |
| `--print` | Run in print mode (non-interactive); implicitly enables **`--afk`** (away-from-keyboard: tools auto-approved, interactive questions auto-dismissed). Not `--yolo`. |
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
