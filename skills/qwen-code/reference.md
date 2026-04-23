# Qwen-Code CLI — reference

Concise reference for agents. Auth: `DASHSCOPE_API_KEY` or `OPENAI_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.**

- **Default (Simple Tasks)**: `qwen-coder-plus`
- **Heavy Tasks**: `qwen-coder-max`

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
5. **Desired Shape**: "Summarize results," "Apply diffs," etc.
