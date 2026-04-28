---
name: openhands-cli
description: Delegates large multi-step work to OpenHands CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for autonomous implementation, batch processing, and CI/CD integration. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenHands CLI (subagent/task delegation)

Use **OpenHands CLI** to run a **separate long-horizon pass** over the repo: autonomous implementation, broad refactors, or batch file writes—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn.

## When to use OpenHands CLI

- **Autonomous Implementation**: OpenHands is designed for long-running, multi-step tasks with minimal supervision.
- **Headless Automation**: Ideal for CI/CD pipelines and automated scripting.
- **Batch Processing**: Handle large-scale codebase changes in an isolated process.
- **Parallel mental lane**: you continue planning or reviewing while OpenHands runs a bounded task.
- **User explicitly asks** for OpenHands or “use OpenHands for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: OpenHands does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single OpenHands prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest OpenHands model configurations and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data.

## Programmatic usage (required)

You **MUST** use OpenHands CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Headless Mode** | `--headless` |
| **Task Specification** | `-t "[prompt]"` or `-f [file]` |
| **Auto-approval** | Included in `--headless` (always-approve mode) |
| **Output Format** | `--json` (for structured JSONL output) |

## Command pattern

```bash
openhands --headless -t "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: [format]" 2>&1
```

## After OpenHands returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `openhands --headless -t "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: [format]"`
- **Batch Refactor**: `openhands --headless -t "GOAL: Refactor [area] for [reason] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: summary report"`
- **Automated Scripting**: `openhands --headless -t "GOAL: Write a script to [task] | SCOPE: [paths] | OUTPUT: implementation"`
