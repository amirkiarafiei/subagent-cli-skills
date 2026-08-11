# Claude Code CLI — reference

Concise reference for agents. Auth: `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`,
`CLAUDE_CODE_OAUTH_TOKEN`, or `claude login`. There is no `CLAUDE_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Prefer the **aliases** — they track the current generation, so a pinned skill does not go stale.
Use a full ID only when you need to pin an exact snapshot.

| Alias | Resolves to (current) | Use |
|-------|----------------------|-----|
| `haiku`  | `claude-haiku-4-5`  | Fast/cheap — simple edits, high-volume delegations. |
| `sonnet` | `claude-sonnet-5`   | Balanced workhorse, 1M context. Default for most delegation. |
| `opus`   | `claude-opus-5`     | Flagship — hardest long-horizon agentic work. |

Anthropic IDs are **dash-separated** (`claude-sonnet-5`, `claude-opus-5`, `claude-haiku-4-5`), not
dotted. Previous generations (`claude-sonnet-4-6`, `claude-opus-4-8`) remain available.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--print`, `-p` | Execute prompt and exit (Non-interactive). |
| `--bare` | Minimal mode: skips hooks, LSP, plugin sync, auto-memory, keychain reads, and **CLAUDE.md auto-discovery**. **Auth caveat:** Anthropic auth becomes strictly `ANTHROPIC_API_KEY` or `apiKeyHelper` via `--settings` — OAuth and keychain are never read, so a subscription-authenticated delegation fails. (Bedrock/Vertex/Foundry use their own credentials and are unaffected.) Since CLAUDE.md is not loaded, pass context explicitly via `--add-dir`, `--system-prompt`, `--settings`, `--agents`. |
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
