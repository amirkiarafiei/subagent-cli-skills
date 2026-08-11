# GitHub Copilot CLI — reference

Concise reference for agents. Auth: `COPILOT_GITHUB_TOKEN` or `GH_TOKEN`.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Copilot is a **multi-provider gateway** — OpenAI, Anthropic, Google, xAI, and Moonshot models all
ship through the same `--model` flag. Availability varies by plan, org policy, and region.

| Model | Tier / Use |
|-------|-----------|
| `gpt-5.6-luna` | Fast, cheap — default for simple edits and exploration |
| `gpt-5.6-terra` | Balanced everyday implementation |
| `gpt-5.6-sol` | OpenAI flagship — complex reasoning, refactors |
| `claude-sonnet-5` | Anthropic workhorse, strong agentic coding |
| `claude-opus-5` | Anthropic flagship — hardest long-horizon tasks |
| `claude-haiku-4.5` | Anthropic fast/cheap tier |
| `gemini-3.6-flash` | Google fast tier, 1M context |
| `gemini-3.1-pro-preview` | Google Pro (line frozen at 3.1) |
| `grok-4.5` | xAI |
| `kimi-k2.7-code` / `kimi-k3` | Moonshot open-weight coding models |

> **Retiring** `gpt-5.4` and `gpt-5.4-mini` retire 2026-08-31 → use `gpt-5.6-terra` / `gpt-5.6-luna`.
> `o3-mini` and the o-series are **not** offered by Copilot — reasoning is set via `--effort`, not
> a separate model.

## Agents ([built-in])

Specialists run in isolated context. Specify via `--agent <name>`.

| Name | Role |
|------|------|
| `explore` | Codebase Q&A, architectural research, "how does X work?" |
| `general-purpose` | Default chat agent for broad tasks and edits. |
| `task` | Specialized for command execution and scripting tasks. |
| `research` | Deep research using GitHub and web sources. |
| `code-review` | Runs a code review pass over recent changes or specific files. |

## Programmatic Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--prompt` | Execute prompt and exit (Non-interactive). |
| `-s`, `--silent` | Output ONLY agent response (no decorations/stats). |
| `--yolo` | Auto-approve all tools, paths, and URLs. |
| `--allow-all-tools` | Specifically allow tool execution (required for headless). |
| `--model` | Select AI model (e.g., `gpt-5.6-luna`). |
| `--effort` | Reasoning effort: `low`, `medium`, `high`, `xhigh`. |
| `--output-format json` | Output JSONL (one JSON object per line). |
| `--autopilot` | Allow agent to perform multiple cycles without prompting. |
| `--share [path]` | Export session transcript to Markdown file. |

## Context Handling

- **Direct File Mention**: Use `@ FILENAME` in your prompt to force inclusion.
- **Project Instructions**: `copilot init` creates `.github/copilot-instructions.md`.
- **Exclusions**: Uses `.gitignore` and `.copilotignore`.

## JSON Output (`--output-format json`)

Copilot outputs JSONL. Each line is a JSON object representing a turn, tool call, or response.

## Environment Variables

- `COPILOT_GITHUB_TOKEN`: Authentication token.
- `COPILOT_SUBAGENT_MAX_DEPTH`: Max recursion depth (default 6).
- `COPILOT_SUBAGENT_MAX_CONCURRENT`: Max parallel subagents (default 32).

## Delegation Checklist

1. **Full Goal**: State the desired outcome clearly.
2. **Prior Decisions**: Explicitly mention tech stack, naming conventions, and patterns.
3. **Scope**: Define `@files` or directories to work in.
4. **Constraints**: Mention performance, security, or style requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes directly," "Provide a report only," etc.
