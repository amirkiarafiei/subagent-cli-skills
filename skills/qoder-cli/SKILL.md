---
name: qoder-cli
description: Delegates large multi-step work to Qoder CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for multi-step implementation, code reviews, autonomous task execution, and codebase exploration. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Qoder CLI (subagent/task delegation)

Use **Qoder CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Qoder CLI provides tiered model selection (Auto, Efficient, Performance, Ultimate) and direct frontier model access, with built-in tools (Grep, Read, Write, Bash), web search, MCP tool integration, and a Plug-in/Skill system for specialized workflows.

## When to use Qoder CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Autonomous goal execution**: Use `/goal` or `auto` permission mode for zero-interruption bounded tasks.
- **Heavy code generation or editing**: Qoder CLI drives tool use while you summarize outcomes and merge.
- **Parallel mental lane**: you continue planning or reviewing while Qoder CLI runs a bounded task in the background (see `/tasks` in TUI).
- **Web search & research**: Built-in WebFetch/WebSearch for deep research or API documentation searches.
- **Plan-then-execute workflow**: Start in read-only Plan mode, review the proposal, then execute autonomously.
- **User explicitly asks** for Qoder or "use Qoder CLI for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Qoder CLI does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits—see Cognition's discussion of **sharing context** and **implicit decisions** in multi-step setups.

When composing the **single Qoder CLI prompt** (using `-p`), treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Qoder CLI returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed "state of the union") rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Qoder CLI model names, aliases, and pricing before selecting a model.** Consult [https://docs.qoder.com/en/cli/model](https://docs.qoder.com/en/cli/model) and [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date benchmarks, pricing, and model performance data.

Qoder CLI offers two model selection paths:

### Tiered Modes (Simplified Selection)

| Tier | Use Case | Credit Cost |
|------|----------|-------------|
| `auto` (Smart Routing) | Most daily development work (recommended default) | ~1.0x |
| `efficient` | Basic code generation, unit tests, daily Q&A | ~0.3x |
| `performance` | Core feature implementation, architecture design | ~1.1x |
| `ultimate` | Complex system design, high-difficulty problem analysis | ~1.6x |
| `lite` | Quick validation, basic logic (Team users, free) | Free |

### Frontier Models (Direct Selection)

- **Fast (Simple Tasks)**: `DeepSeek-V4-Flash` (Fast reasoning, low cost, balanced capabilities).
- **Balanced (Daily Driver)**: `MiniMax-M3` (Native multimodal, frontier coding, 1M context).
- **Coding Specialist**: `Kimi-K2.7-Code` (Long-context coding, precise instruction following).
- **Strong / Large (Heavy Reasoning)**: `DeepSeek-V4-Pro` (Complex reasoning, code gen, engineering), `Qwen3.7-Max` (Agentic capabilities, long-horizon complex tasks), or `GLM-5.2` (Complex systems engineering, long-horizon tasks).
- **Strategy**: Default to `efficient` tier or `DeepSeek-V4-Flash` for simple tasks to minimize costs. Use `ultimate` tier or `DeepSeek-V4-Pro`/`Qwen3.7-Max`/`GLM-5.2` for critical architecture and reasoning tasks. Always verify latest model versions and costs via the [model docs](https://docs.qoder.com/en/cli/model) and `qodercli --list-models`.

## Programmatic usage (required)

You **MUST** use Qoder CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p "prompt"` or `--print "prompt"` |
| **Auto-approval** | `--yolo` or `--dangerously-skip-permissions` |
| **Permission Mode** | `--permission-mode auto` (classifier-based) or `--permission-mode accept_edits` |
| **Model Selection** | `--model [tier_or_model_name]` |
| **Output Format** | `--output-format [text|json|stream-json]` |
| **Reasoning Effort** | `--reasoning-effort [low|medium|high|xhigh|max]` |
| **Context Window** | `--context-window [200000|400000|1000000]` |

## Command pattern

```bash
qodercli -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo --model efficient --output-format text 2>&1
```

For heavy reasoning tasks:

```bash
qodercli -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo --model ultimate --reasoning-effort high --output-format text 2>&1
```

## After Qoder CLI returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `qodercli -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo --model efficient --output-format text`
- **Investigate**: `qodercli -p "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --yolo --model efficient --output-format text`
- **Architecture / Heavy Reasoning**: `qodercli -p "GOAL: Design architecture for [feature] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: architecture plan" --yolo --model ultimate --reasoning-effort high --output-format text`
- **Web Research**: `qodercli -p "GOAL: Find latest documentation for [library] | CONSTRAINTS: focus on breaking changes in [version] | OUTPUT: summary report" --yolo --model efficient --output-format text`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, models, permissions, worktree: [reference.md](reference.md)
