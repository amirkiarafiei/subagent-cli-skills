# Hermes Agent CLI — reference

Concise reference for agents. Auth: `hermes setup` (interactive), `hermes setup --portal` (Nous Portal), or `hermes model` (configure provider + model).

## Models (Mandatory Search Required)

Model names and provider availability change frequently. **Always search for latest pricing and model names.** Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date model performance and pricing data.

Hermes uses a provider-based model system. Models are specified as `provider/model-name`:

| Provider | Model Format | Notes |
|----------|-------------|-------|
| Nous Portal | `nous/model-name` | 300+ models, one subscription (`hermes setup --portal`) |
| OpenRouter | `openrouter/provider/model` | Aggregator, broadest selection |
| Anthropic | `anthropic/claude-sonnet-5` | Direct Anthropic API (also `claude-opus-5`, `claude-haiku-4-5`) |
| OpenAI | `openai/gpt-5.6-sol` | Direct OpenAI API (also `-terra` balanced, `-luna` fast) |
| Google | `google/gemini-3.6-flash` | Also `gemini-3.1-pro` (Pro line frozen at 3.1) |
| Ollama | `ollama/model-name` | Local or cloud (Ollama Cloud) |

Current frontier picks by tier, assuming the provider is authenticated:

| Tier | Examples |
|------|----------|
| Fast / cheap | `openai/gpt-5.6-luna`, `google/gemini-3.6-flash`, `anthropic/claude-haiku-4-5`, `deepseek/deepseek-v4-flash` |
| Balanced | `openai/gpt-5.6-terra`, `anthropic/claude-sonnet-5` |
| Heavy reasoning | `openai/gpt-5.6-sol`, `anthropic/claude-opus-5`, `google/gemini-3.1-pro` |
| Open weight | `moonshotai/kimi-k2.7-code`, `zai/glm-5.2`, `minimax/minimax-m3`, `deepseek/deepseek-v4-pro` |

Hermes provider keys are `nous`, `openrouter`, `anthropic`, `openai`, `google`, `xai`, `mistral`,
`deepseek`, `moonshotai`, `minimax`, `groq`, `zai`, `ollama`. Note **`zai`** (not `zhipuai`) for
the GLM family. Run `hermes model --refresh` to re-fetch every provider's live `/v1/models` list
rather than guessing an ID.

Use `hermes model` for the interactive provider+model picker, and `hermes config show` / `hermes status` to inspect current configuration. Note that `config show` prints a formatted box, **not** `key=value` lines — grepping it for `^model\.` returns nothing.

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
| `--model "provider/model"` or `-m` | Specify model (e.g., `anthropic/claude-sonnet-5`). |
| `--provider name` | Force a specific provider. |
| `--toolsets "list"` or `-t` | Enable tool bundles (e.g., `file,terminal,web,skills`). |
| `-w`, `--worktree` | Start in an isolated git worktree (auto-cleanup). |
| `-c`, `--continue` | Resume the most recent session. |
| `-r`, `--resume <id>` | Resume a specific session by ID or title. |
| `--verbose` or `-v` | Enable debug/verbose output. |
| `--max-turns N` | **Cap tool-calling iterations per turn (default 90).** Use it to bound a delegated run so a stuck subagent cannot loop indefinitely. |
| `--checkpoints` | Snapshot files before destructive operations (`/rollback` restores). Cheap safety net for delegations that write. |
| `--ignore-user-config` | Bypass `~/.hermes/config.yaml` (isolated CI-like run). |
| `--ignore-rules` | Skip `AGENTS.md`, `SOUL.md`, `.cursorrules`, memory, and preloaded skills. |
| `--safe-mode` | Disable **all** customization — config, rules, plugins, MCP servers (implies the two flags above). Use to isolate whether a failure is your setup or Hermes. |
| `--source tool` | Tag the session as third-party so it stays out of the user's session lists. |
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
| `todo` | todo tools | Task planning |
| `session_search` | session search | Search prior session history |
| `clarify` | clarifying questions | Ask the caller for missing detail |
| `cronjob` | cron tools | Scheduled jobs |
| `image_gen` | image generation | Create images |
| `tts` | text-to-speech | Audio output |
| `video` / `video_gen` | video analysis / generation | Disabled by default |
| `x_search` | X (Twitter) search | Disabled by default |
| `context_engine` | context engine | Disabled by default |
| `computer_use` | computer use | GUI control (macOS/Windows/Linux) |
| `coding` | composite (file+terminal+web+skills+browser+todo+memory+delegation+code_execution) | Full coding bundle |

Run `hermes tools list` to see which toolsets are enabled for your install — several ship disabled
(`video`, `video_gen`, `x_search`, `context_engine`, `homeassistant`, `spotify`, `yuanbao`). Note
that `coding` is a valid composite but does **not** appear in `hermes tools list` output.

## Configuration

- `~/.hermes/config.yaml`: Main configuration file (model, provider, toolsets, skills, etc.).
- `~/.hermes/skills/`: Skills directory, grouped by **category** — each skill lives at
  `<category>/<skill>/SKILL.md` (e.g. `software-development/plan/SKILL.md`), not as a flat
  subfolder. `-s <name>` still resolves by bare skill name, so the nesting does not affect usage.
- `~/.hermes/state.db`: SQLite session database (history, metadata).
- `<workspace>/.hermes/plans/`: Plan files created by the `plan` skill — written **relative to the
  active workspace**, not under `~/.hermes/`.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
