# Qoder CLI — reference

Concise reference for agents. Auth: `qodercli login` or browser-based OAuth.

## Models (Mandatory Search Required)

Model names change frequently. **Always search for latest pricing/aliases.** Consult [https://docs.qoder.com/en/cli/model](https://docs.qoder.com/en/cli/model) and [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data. Use `qodercli --list-models` to see models available to your account.

### Tiered Models

| Tier | Flag | Use Case |
|------|------|----------|
| Auto (Smart Routing) | `--model auto` | Most daily development work (recommended default) |
| Ultimate | `--model ultimate` | Complex system design, deep reasoning |
| Performance | `--model performance` | Core features, architecture, refactoring |
| Efficient | `--model efficient` | Basic code gen, tests, daily Q&A |
| Lite | `--model lite` | Quick validation, basic logic (free for Team users) |

### Frontier Models

| Model | Description | Credit Rate |
|-------|-------------|-------------|
| `DeepSeek-V4-Flash` | Fast reasoning, low cost, balanced capabilities | 0.1x |
| `DeepSeek-V4-Pro` | Complex reasoning, code generation, engineering | 0.5x |
| `GLM-5.2` | Complex systems engineering, long-horizon tasks | 0.6x |
| `Qwen3.7-Max` | Agentic capabilities, long-horizon complex tasks | 0.5x |
| `Kimi-K2.7-Code` | Long-context coding, precise instruction following | 0.3x |
| `MiniMax-M3` | Native multimodal, frontier coding, 1M context | 0.2x |

## Built-in Tools

| Tool | Purpose |
|------|---------|
| `Read` | Read file contents |
| `Write` | Write or edit files |
| `Grep` | Search file contents |
| `Glob` | Find files by pattern |
| `Bash` | Execute shell commands |
| `WebFetch` | Fetch web page content |
| `WebSearch` | Search the web |
| `Agent` | Launch subagents |

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Execute prompt and exit (Non-interactive). |
| `--yolo` | Skip permission checks (bypass_permissions). |
| `--dangerously-skip-permissions` | Same as `--yolo`. |
| `--permission-mode` | Set permission mode: `default`, `accept_edits`, `auto`, `bypass_permissions`, `dont_ask`. |
| `--model` | Specify model tier or name (e.g., `efficient`, `ultimate`, `DeepSeek-V4-Flash`). |
| `--reasoning-effort` | Thinking depth: `low`, `medium`, `high`, `xhigh`, `max`. |
| `--context-window` | Max context: `200000`, `400000`, `1000000`. |
| `--output-format` | Output format: `text` (default), `json`, `stream-json`. |
| `--list-models` | Print available models without opening TUI. |
| `-w` | Specify workspace directory. |
| `--worktree [name]` | Start in a separate Git worktree. |
| `--allowed-tools` | Allow only specified tools (e.g., `Read,Grep,Bash`). |
| `--disallowed-tools` | Disallow specified tools. |
| `--max-turns` | Limit maximum dialog turns. |

## Permission Modes

| Mode | Best For | Behavior |
|------|----------|----------|
| `default` | Normal interactive use | Sensitive actions require confirmation |
| `accept_edits` | Routine coding tasks | Auto-approves safe file edits |
| `auto` | Autonomous runs, goal execution | AI classifier evaluates action safety |
| `bypass_permissions` (`yolo`) | Trusted local experiments | Skips all approval prompts |
| `dont_ask` | Headless flows | Denies anything requiring approval |

## Configuration

- `~/.qoder/settings.json`: User global settings.
- `<project>/.qoder/settings.json`: Project-level settings.
- `<project>/.qoder/settings.local.json`: Machine-local settings (add to `.gitignore`).
- `<project>/AGENTS.md` or `<project>/.qoder/AGENTS.md`: Project memory.
- `~/.qoder/skills/`: User-level skills directory.
- `<project>/.qoder/skills/`: Project-level skills directory.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
