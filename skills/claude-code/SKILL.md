---
name: claude-code
description: Delegates large multi-step work to Claude Code CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, and agentic coding. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Claude Code CLI (subagent/task delegation)

Use **Claude Code CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

## When to use Claude Code CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Claude Code drives tool use while you summarize outcomes and merge.
- **Parallel mental lane**: you continue planning or reviewing while Claude Code runs a bounded task.
- **User explicitly asks** for Claude Code or “use Claude Code for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Claude Code does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single Claude Code prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Claude model names and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data.

## Programmatic usage (required)

You **MUST** use Claude Code CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p` or `--print` |
| **Auto-approval** | `--permission-mode auto` or `--dangerously-skip-permissions` |
| **Model Selection** | `--model [model_name]` |
| **Minimal Startup** | `--bare` |

## Command pattern

```bash
claude -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --permission-mode auto --model [model] 2>&1
```

## After Claude Code returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `claude -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --permission-mode auto`
- **Investigate**: `claude -p "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --permission-mode plan`
- **Plan**: `claude -p "GOAL: Design architecture for [feature] | SCOPE: [paths] | OUTPUT: architecture plan" --permission-mode plan`
