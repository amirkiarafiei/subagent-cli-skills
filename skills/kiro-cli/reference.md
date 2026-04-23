# Kiro CLI — reference

Concise reference for agents. Auth: `KIRO_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.**

- **Balanced Daily Driver**: `claude-sonnet-4.6`
- **Fast & Efficient**: `claude-haiku-4.5`
- **Max Reasoning**: `claude-opus-4.7`
- **OpenAI Integration**: `gpt-5.4`

## Subagents ([built-in])

Specialists run in isolated context. Specify via `--agent <name>`.

| Name | Role |
|------|------|
| `Codebase Analyst` | Deep codebase Q&A and dependency mapping. |
| `Implementation Specialist` | Focused on writing and refactoring code. |
| `Research Assistant` | Web research and technical documentation lookup. |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `chat --no-interactive` | Primary command for non-interactive execution. |
| `--trust-all-tools` | Auto-approve all tools, paths, and URLs (YOLO). |
| `--trust-tools=<list>` | Granular auto-approval (e.g., `read,grep`). |
| `--model <alias>` | Specify the model to use. |
| `--agent "<name>"` | Specify a subagent to handle the prompt. |
| `--require-mcp-startup`| Fail immediately if MCP servers don't connect. |

## Context Handling

- **Direct File Mention**: Use `@ FILENAME` in your prompt.
- **Exclusions**: Uses `.gitignore` and `.kiroignore`.

## Configuration

- `~/.kiro/settings.json`: Global settings and default model configuration.
- `kiro-cli settings chat.defaultModel <alias>`: Set the permanent default model.

## Delegation Checklist

1. **Full Goal**: Clearly state the desired outcome.
2. **Prior Decisions**: Explicitly mention tech stack, naming, and patterns.
3. **Scope**: Define `@files` or directories to work in.
4. **Constraints**: Performance, security, or style requirements.
5. **Desired Shape**: "Apply changes," "Provide a report," etc.
