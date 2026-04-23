# OpenAI Codex CLI — reference

Concise reference for agents. Auth: `OPENAI_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing and reasoning capabilities.** GPT-4o is legacy.

- **Thinking Reasoning**: `gpt-5.4-thinking` (PhD-level logic, successors to o1/o3)
- **Unified Multimodal**: `gpt-5.4` (Standard flagship, incorporates GPT-5.3-Codex)
- **High-Speed Reasoning**: `gpt-5.4-mini` (Successor to 4o-mini/o1-mini)

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
5. **Desired Shape**: "Apply changes," "Return JSON report," etc.
