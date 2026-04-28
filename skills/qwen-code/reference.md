# Qwen-Code CLI — reference

Concise reference for agents. Auth: `DASHSCOPE_API_KEY` or `OPENAI_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

- **Agentic Coding**: `qwen3-coder-plus` (Optimized for tool use and implementation)
- **High Reasoning**: `qwen3.6-max-preview` (Includes "Thinking" mode for complex logic)
- **Latest Balanced**: `qwen3.6-plus` (April 2026 flagship)

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
