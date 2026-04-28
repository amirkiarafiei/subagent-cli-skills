---
name: junie-cli
description: Delegates large multi-step work to Junie CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for code reviews, refactors, and CI/CD automation. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Junie CLI (subagent/task delegation)

Use **Junie CLI** to run a **separate long-horizon pass** over the repo: code reviews, multi-step implementation, or broad refactors—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn.

## When to use Junie CLI

- **Automated Code Reviews**: Use the specialized `--review` agent for deep diff-aware reviews.
- **Large or multi-step work**: several files, phases, or checkpoints.
- **Conflict Resolution**: Specialized `--merge` and `--rebase` modes for resolving git conflicts.
- **Parallel mental lane**: you continue planning or reviewing while Junie runs a bounded task.
- **User explicitly asks** for Junie or “use Junie for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Junie does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single Junie prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Junie model names and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data.

## Programmatic usage (required)

You **MUST** use Junie CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Authentication** | `--auth="$JUNIE_API_KEY"` |
| **Model Selection** | `--model [alias]` |
| **Output Format** | `--output-format [text|json]` |
| **Specialized Mode**| `--review`, `--merge`, `--rebase` |

## Command pattern

```bash
junie --auth="$JUNIE_API_KEY" "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: [format]" --model sonnet --output-format text 2>&1
```

## After Junie returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `junie --auth="$JUNIE_API_KEY" "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: [format]" --model sonnet`
- **Code Review**: `junie --auth="$JUNIE_API_KEY" --review "GOAL: Review my changes for [specific concerns] | SCOPE: [paths] | OUTPUT: review report"`
- **Conflict Resolution**: `junie --auth="$JUNIE_API_KEY" --merge [branch] "GOAL: Resolve conflicts between current branch and [branch] | CONSTRAINTS: prefer [strategy]"`
