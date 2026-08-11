---
name: opencode-cli
description: Delegates large multi-step work to OpenCode CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for deep architectural changes, complex code generation, and CI automation. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenCode CLI (subagent/task delegation)

Use **OpenCode CLI** to run a **separate long-horizon pass** over the repo: deep architectural changes, multi-step implementation, or broad refactors—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn.

## When to use OpenCode CLI

- **Deep Architectural Changes**: OpenCode is optimized for complex code generation and tool-calling.
- **CI Automation**: Use `github run` for automated tasks in CI pipelines.
- **Large or multi-step work**: several files, phases, or checkpoints.
- **Parallel mental lane**: you continue planning or reviewing while OpenCode runs a bounded task.
- **User explicitly asks** for OpenCode or “use OpenCode for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: OpenCode does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single OpenCode prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest OpenCode model names and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data.

## Programmatic usage (required)

You **MUST** use OpenCode CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `run "[prompt]"` |
| **Auto-approval** | `--auto` (auto-approves permissions not explicitly denied) |
| **Model Selection** | `-m` or `--model [provider/model]` |
| **Agent Selection** | `--agent build` (edits) or `--agent plan` (read-only analysis) |
| **Output Format** | `--format [default|json]` |
| **Reasoning Effort** | `--variant [high|max|minimal]` (provider-specific) |

There is **no** `--dangerously-skip-permissions` flag. OpenCode's CLI silently ignores
unknown flags, so passing it fails open rather than erroring — the run proceeds with
permissions unchanged and blocks on anything set to `ask` (e.g. `doom_loop`,
`external_directory`). Use `--auto`.

## Command pattern

```bash
opencode run "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --auto --model [model] 2>&1
```

Read-only pass (no edits — use the `plan` agent rather than trusting prompt wording):

```bash
opencode run "GOAL: [analysis task] | SCOPE: [paths] | OUTPUT: report only" --agent plan 2>&1
```

## After OpenCode returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `opencode run "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --auto`
- **Architectural Analysis**: `opencode run "GOAL: Analyze architecture for [concerns] | SCOPE: [paths] | VERIFICATION: [check_command] | OUTPUT: architecture report" --agent plan --model [heavy-model]`
- **Investigate**: `opencode run "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --agent plan`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, agents, models, auth: [reference.md](reference.md)
