---
name: hermes-agent
description: Delegates large multi-step work to Hermes Agent CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for multi-step implementation, code review, research, and autonomous task execution. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Hermes Agent CLI (subagent/task delegation)

Use **Hermes Agent CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, deep research, or code review—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Hermes Agent provides a rich tool system with file editing (`patch`, `read_file`, `write_file`, `search_files`), terminal access, web search/extraction, browser automation, delegation (`delegate_task`), code execution, and a large built-in skills catalog. It supports multiple model providers (Nous Portal, OpenRouter, Anthropic, OpenAI, Ollama, etc.) and can run background tasks in parallel.

## When to use Hermes Agent CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Deep research**: Built-in web search, web extraction, and browser automation for documentation digging or investigative research.
- **Code review**: Built-in `requesting-code-review` skill and `github-code-review` skill for PR-style analysis.
- **Heavy code generation or editing**: Hermes drives tool use (file tools, terminal) while you summarize outcomes and merge.
- **Parallel work**: Use `/background` or `delegate_task` to spawn isolated subagent sessions for concurrent tasks.
- **Background investigations**: Start long-running research tasks while you continue working in the foreground.
- **Plan-then-execute**: Use the built-in `plan` skill for structured markdown planning before execution.
- **User explicitly asks** for Hermes or "use Hermes Agent for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Hermes Agent does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single Hermes prompt** (using `-q`), treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Hermes returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed "state of the union") rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Hermes Agent compatible models and pricing before selecting a model.** Hermes Agent uses a provider-based model system where models are specified as `provider/model-name`. Available models depend on the authenticated providers (Nous Portal, OpenRouter, Anthropic, OpenAI, Ollama, etc.).

Since model availability depends on the user's configured providers, use the following discovery strategy:

1. **Search the web first**: Look for the latest recommended models compatible with the user's provider (e.g., Claude Sonnet, GPT, Gemini, DeepSeek, Qwen, etc.).
2. **Fallback**: Consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date benchmarks, pricing, and model performance data.
3. **Provider-aware selection**: Format models as `provider/model-name` (e.g., `anthropic/claude-sonnet-4`, `openrouter/deepseek-v4`, `ollama/llama-4`).

General recommendations (subject to change—always verify):

- **Fast / Simple Tasks**: Flash or mini-tier models via the configured provider (low cost, fast).
- **Heavy / Complex Tasks**: Frontier models like Claude Opus, GPT, Gemini Pro, or DeepSeek via the configured provider (deep reasoning).
- **Strategy**: Default to fast/cheap models for simple delegations. Escalate to frontier models for critical architecture and reasoning tasks. Always verify the latest model names, aliases, and costs via web search.

## Programmatic usage (required)

You **MUST** use Hermes CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `chat -q "prompt"` (single query mode) |
| **Quiet output (programmatic)** | `-Q` (suppress banner, spinner, tool previews — **always use for subagent**) |
| **Auto-approval** | `--yolo` (bypasses permission checks) |
| **Auto-approval (env)** | `HERMES_YOLO_MODE=true` (also disables prompts) |
| **Model Selection** | `--model "provider/model-name"` or `-m` |
| **Provider Selection** | `--provider [provider-name]` |
| **Toolsets** | `--toolsets "file,terminal,web,skills"` (comma-separated) or `-t` |
| **Skill Preloading** | `-s skill-name` (preload one or more skills, comma-separated or repeat flag) |
| **Worktree** | `-w` (run in isolated git worktree for parallel agents) |
| **Isolated run** | `--ignore-user-config --ignore-rules` (bypass config/skills for CI-like execution) |

## Command pattern

```bash
hermes chat -q "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo -Q --toolsets "file,terminal,web,skills" 2>&1
```

With specific model:

```bash
hermes chat -q "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo -Q --model "anthropic/claude-sonnet-4" --toolsets "file,terminal,web,skills" 2>&1
```

In isolated worktree (parallel agent sessions):

```bash
hermes chat -q "GOAL: [task]" --yolo -Q -w 2>&1
```

## After Hermes Agent returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `hermes chat -q "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo -Q --toolsets "file,terminal,web,skills"`
- **Investigate**: `hermes chat -q "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --yolo -Q --toolsets "file,terminal"`
- **Code Review**: `hermes chat -q "GOAL: Review changes for [concerns] | SCOPE: [paths] | OUTPUT: review report with severities" --yolo -Q --toolsets "file,terminal,web" -s requesting-code-review`
- **Web Research**: `hermes chat -q "GOAL: Find latest documentation for [library] | CONSTRAINTS: focus on breaking changes in [version] | OUTPUT: summary report" --yolo -Q --toolsets "web,file"`
- **Background Task**: Start a long-running task in the orchestrator session with `/background` (if using interactively) or delegate via `delegate_task`.

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, tools, toolsets, models, skills: [reference.md](reference.md)
