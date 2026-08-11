# Qwen-Code CLI — reference

Concise reference for agents. Auth: `DASHSCOPE_API_KEY` or `OPENAI_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

| Model | Use |
|-------|-----|
| `qwen3-coder-plus` | Agentic coding — optimized for tool use and implementation |
| `qwen3-coder-flash` | Fast/cheap coding tier for simple delegations |
| `qwen3.8-max` | Highest reasoning — complex architecture and long-horizon logic |
| `qwen3.7-plus` | Latest balanced flagship |
| `qwen3.6-flash` | General fast tier |

Older `qwen3.6-max-preview` and `qwen3.6-plus` still resolve but are superseded by the 3.7/3.8
line. Prefer the `-coder-` variants for implementation work and the `max` line for reasoning.

## Essential Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--prompt` | `-p` | Execute prompt and exit (Non-interactive). |
| `--output-format` | `-o` | `text`, `json`, `stream-json`. Use `text` for clean scripting output. |
| `--model` | | Specify the model to use. |
| `--continue` | | Resume the most recent session. |
| `--resume <id>` | | Resume a specific session by ID. |
| `--system-prompt` | | Override the default system instruction. |
| `--verbose` | | Enable detailed logging for debugging scripts. |

## Context Handling

- **Piping**: `cat file.ts | qwen -p "summarize"`
- **Exclusions**: Uses `.gitignore` and `.qwenignore`.

## JSON Output (`-o json`)

Parse the JSON emitted at the end of the session for statistics and machine-readable responses.

## Delegation Checklist

1. **Full Goal**: Clearly state what needs to be achieved.
2. **Prior Decisions**: Stack, style, and API choices already made.
3. **Scope**: Define files or directories to work in.
4. **Constraints**: Performance, a11y, or compatibility requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Summarize results," "Apply diffs," etc.
