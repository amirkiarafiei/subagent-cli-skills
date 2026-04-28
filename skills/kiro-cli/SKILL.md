---
name: kiro-cli
description: Delegates large multi-step work to Kiro CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, and codebase analysis. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Kiro CLI (subagent/task delegation)

Use **Kiro CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Kiro CLI (formerly Amazon Q Developer CLI) is powered by the latest frontier models (Claude 4.x, GPT-5.x) and is highly optimized for deep codebase intelligence and agentic coding.

## When to use Kiro CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Kiro drives tool use while you summarize outcomes and merge.
- **Deep exploration**: Use specialized agents like "Codebase Analyst" for architecture / dependency mapping.
- **Parallel mental lane**: you continue planning or reviewing while Kiro runs a bounded task (optionally background—see [reference.md](reference.md)).
- **User explicitly asks** for Kiro or “use Kiro for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Kiro does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits—see Cognition’s discussion of **sharing context** and **implicit decisions** in multi-step setups.

When composing the **single Kiro prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

**After Kiro returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed “state of the union”) rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Kiro model names/aliases and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data. 

- **Default (Simple Tasks)**: `claude-haiku-4.5` (Inexpensive, fast, ideal for quick command suggestions).
- **Standard (Implementation)**: `claude-sonnet-4.6` (Balanced daily driver; high intelligence).
- **Heavy Tasks**: `claude-opus-4.7` or `gpt-5.4` (PhD-level logic for complex architecture).
- **Strategy**: Always default to Sonnet/Haiku to minimize costs. Escalating to Opus/GPT-5 only for critical architecture tasks after verifying latest version and cost via search.

## Programmatic usage (required)

You **MUST** use Kiro CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `chat --no-interactive "prompt"` |
| **Auto-approval** | `--trust-all-tools` |
| **Model Selection** | `--model [model_alias]` |
| **Agent Selection** | `--agent "[Agent Name]"` |

## Command pattern

```bash
kiro-cli chat --no-interactive "[prompt with @ FILENAME as needed]" --trust-all-tools --model claude-sonnet-4.6 2>&1
```

## After Kiro returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `kiro-cli chat --no-interactive "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --trust-all-tools`
- **Investigate**: `kiro-cli chat --no-interactive "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --agent "Codebase Analyst"`
- **Refactor**: `kiro-cli chat --no-interactive "GOAL: Refactor [area] for better performance | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: summary of edits" --trust-all-tools`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, models, subagents, permissions: [reference.md](reference.md)
