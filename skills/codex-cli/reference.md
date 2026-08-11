# OpenAI Codex CLI — reference

Concise reference for agents. Auth: `OPENAI_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing and reasoning capabilities.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data. GPT-4o and the o1/o3 series are legacy.

The GPT-5.6 family is three tiers, not a single model:

| Model | Tier | Use |
|-------|------|-----|
| `gpt-5.6-sol` | Flagship | Complex reasoning, architecture. **CLI default** (medium reasoning). |
| `gpt-5.6-terra` | Balanced | Everyday implementation workhorse. |
| `gpt-5.6-luna` | Fast / cheap | High-volume, responsive tasks. |
| `gpt-5.5` | Previous frontier | Fallback if 5.6 is unavailable. |
| `gpt-5.3-codex-spark` | Research preview | Text-only, ChatGPT Pro only. |

> **Retiring `gpt-5.4` and `gpt-5.4-mini` retire from Codex on August 31, 2026.** Replace with
> `gpt-5.6-terra` and `gpt-5.6-luna` respectively. `gpt-5.2` and `gpt-5.3-codex` are already
> deprecated for ChatGPT sign-in. There is no `gpt-5.4-thinking` — reasoning is a separate
> setting, not a model suffix.

**Reasoning effort** is configured independently of the model: Low, Medium (default), High,
Extra High, Max. Set via `-c model_reasoning_effort="high"`. "Ultra" mode fans out to subagents
for parallel work on complex tasks.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `exec` | Primary subcommand for non-interactive execution. |
| `--full-auto`, `-a full-auto` | Fully autonomous mode; auto-approves all actions. |
| `--approval-mode auto-edit` | Auto-patches files but asks before shell commands. |
| `--model`, `-m` | Specify the model to use. |
| `--ephemeral` | Run without saving rollout files (cleaner CI/CD). |
| `--search` | Enable live web browsing/search. |
| `--profile`, `-p` | Load a specific configuration profile. |

## Execution Patterns

- **Direct Prompt**: `codex exec "prompt"`
- **Stdin Handoff**: `cat instruction.txt | codex exec -`
- **Context Injection**: `cat context.json | codex exec "process this"`

## Configuration

- `~/.codex/config.toml`: Global settings.
- `AGENTS.md`: Instruction pipeline (can be overridden with `--system-prompt`).

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
