# Hermes Agent CLI — reference

Concise reference for agents. Auth: `hermes setup` (interactive), `hermes setup --portal` (Nous Portal), or `hermes model` (configure provider + model).

## Models (Mandatory Search Required)

Model names and provider availability change frequently. **Always search for latest pricing and model names.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Hermes uses a provider-based model system. Models are specified as `provider/model-name`:

| Provider | Model Format | Notes |
|----------|-------------|-------|
| Nous Portal | `nous/model-name` | 300+ models, one subscription (`hermes setup --portal`) |
| OpenRouter | `openrouter/provider/model` | Aggregator, broadest selection |
| Anthropic | `anthropic/claude-sonnet-4` | Direct Anthropic API |
| OpenAI | `openai/gpt-5.4` | Direct OpenAI API |
| Ollama | `ollama/model-name` | Local or cloud (Ollama Cloud) |

Use `hermes model` for the interactive provider+model picker. Use `hermes config show | grep '^model\.'` and `hermes status` to inspect current configuration.

## Built-in Tools

| Tool | Toolset | Purpose |
|------|---------|---------|
| `read_file` | file | Read text files with line numbers |
| `write_file` | file | Write content to files |
| `patch` | file | Targeted find-and-replace edits |
| `search_files` | file | Search file contents or find by name |
| `terminal` | terminal | Execute shell commands |
| `process` | terminal | Manage background processes |
| `web_search` | web | Search the web for information |
| `web_extract` | web | Extract content from web pages |
| `delegate_task` | delegation | Spawn isolated subagent instances |
| `memory` | memory | Persistent cross-session memory |
| `execute_code` | code_execution | Run Python scripts with tool access |
| `vision_analyze` | vision | Analyze images with AI vision |
| `skill_view` / `skill_manage` / `skills_list` | skills | Load, manage, and list skills |

## Bundled Skills (Partial)

Hermes ships with a large built-in skill library at `~/.hermes/skills/`. Notable skills relevant to subagent delegation:

| Skill | Purpose |
|-------|---------|
| `plan` | Write actionable markdown plans, no execution |
| `requesting-code-review` | Pre-commit security scan and quality gates |
| `github-code-review` | Review PRs via diffs and inline comments |
| `github-pr-workflow` | Full PR lifecycle (branch, commit, open, CI, merge) |
| `spike` | Throwaway experiments to validate an idea |
| `systematic-debugging` | 4-phase root cause debugging |
| `test-driven-development` | RED-GREEN-REFACTOR TDD workflow |
| `codebase-inspection` | Inspect codebases (LOC, languages, ratios) |

Use `-s skill-name` to preload a skill at launch (e.g., `-s plan`). All installed skills are also available as slash commands (e.g., `/plan`).

## Essential Flags

| Flag | Purpose |
|------|---------|
| `chat -q "prompt"` | Single query mode (non-interactive). |
| `-Q`, `--quiet` | **Suppress banner, spinner, tool previews — always use for programmatic delegation.** Only outputs final response + session_id. |
| `--yolo` | Skip permission checks (auto-approve all tools). |
| `-s skill-name` | Preload a skill for the session. Repeatable or comma-separated. |
| `--model "provider/model"` or `-m` | Specify model (e.g., `anthropic/claude-sonnet-4`). |
| `--provider name` | Force a specific provider. |
| `--toolsets "list"` or `-t` | Enable tool bundles (e.g., `file,terminal,web,skills`). |
| `-w`, `--worktree` | Start in an isolated git worktree (auto-cleanup). |
| `-c`, `--continue` | Resume the most recent session. |
| `-r`, `--resume <id>` | Resume a specific session by ID or title. |
| `--verbose` or `-v` | Enable debug/verbose output. |
| `--ignore-user-config` | Bypass `~/.hermes/config.yaml` (isolated CI-like run). |
| `--ignore-rules` | Skip `AGENTS.md`, `SOUL.md`, memory injection. |
| `--accept-hooks` | Auto-approve shell hooks without TTY prompt. |

## Toolsets

| Toolset | Included Tools | Purpose |
|---------|---------------|---------|
| `file` | read_file, write_file, patch, search_files | File reading, writing, editing |
| `terminal` | terminal, process | Shell commands and background processes |
| `web` | web_search, web_extract | Web search and page extraction |
| `browser` | browser_navigate, browser_click, browser_snapshot, etc. | Full browser automation |
| `skills` | skill_view, skill_manage, skills_list | Skill loading and management |
| `delegation` | delegate_task | Spawn subagents |
| `memory` | memory | Persistent memory |
| `code_execution` | execute_code | Python scripting with tool access |
| `vision` | vision_analyze | Image analysis |
| `coding` | composite (file+terminal+web+skills+browser+todo+memory+delegation+code_execution) | Full coding bundle |

## Configuration

- `~/.hermes/config.yaml`: Main configuration file (model, provider, toolsets, skills, etc.).
- `~/.hermes/skills/`: Skills directory. Each skill is a subfolder with `SKILL.md`.
- `~/.hermes/state.db`: SQLite session database (history, metadata).
- `~/.hermes/plans/`: Plan files created by the `plan` skill.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
