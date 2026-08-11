# Kiro CLI — reference

Concise reference for agents. Auth: `KIRO_API_KEY`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Kiro bills in **credit multipliers**, so model choice maps directly to spend.

| Model | Tier | Notes |
|-------|------|-------|
| `claude-sonnet-5` | Balanced daily driver | 1M context, 1.3x credits. Most agentic Sonnet yet. |
| `claude-haiku-4.5` | Fast & efficient | Cheapest — quick suggestions, simple edits. |
| `claude-opus-5` | Max reasoning | 1M context, 2.2x credits. Hardest long-horizon agentic work. |
| `gpt-5.6-sol` / `gpt-5.6-terra` / `gpt-5.6-luna` | OpenAI tiers | Added Jul 2026 — flagship / balanced / fast. |
| `glm-5` | Open-weight | Sparse MoE alternative. |
| `minimax-m2.5` | Open-weight | Lower-cost option. |

> Sonnet 5 / Opus 5 are **experimental preview** in the Kiro CLI and gated to Pro, Pro+, Pro Max,
> and Power tiers. Older `claude-sonnet-4.6`, `claude-opus-4.7`, and `claude-opus-4.8` remain
> selectable. Verify against `kiro-cli` model selection for your plan before pinning.

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
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Provide a report," etc.
