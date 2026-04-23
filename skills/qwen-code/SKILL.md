---
name: qwen-code
description: Delegates large multi-step work to Qwen-Code CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, and coding assistance. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Qwen-Code CLI (subagent/task delegation)

Use **Qwen-Code CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Qwen-Code is highly optimized for deep architectural changes and complex code generation, making it a perfect specialist for heavy implementation tasks.

## When to use Qwen-Code CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Qwen-Code drives tool use while you summarize outcomes and merge.
- **Parallel mental lane**: you continue planning or reviewing while Qwen-Code runs a bounded task (optionally background—see [reference.md](reference.md)).
- **User explicitly asks** for Qwen or “use Qwen for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Qwen-Code does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits—see Cognition’s discussion of **sharing context** and **implicit decisions** in multi-step setups.

When composing the **single Qwen prompt** (using `-p`), treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

**After Qwen-Code returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed “state of the union”) rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Qwen-Code model names/aliases and pricing before selecting a model.** 

- **Default (Simple Tasks)**: `qwen-coder-plus` (Latest standard for efficient coding).
- **Heavy Tasks**: `qwen-coder-max` (Deep reasoning and complex architecture).
- **Strategy**: Always default to `plus` for general work. Escalating to `max` only for critical architecture tasks after verifying latest version and cost via search.

## Programmatic usage (required)

You **MUST** use Qwen-Code CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p "prompt"` or `--prompt "prompt"` |
| **Silent output** | `-o text` (for clean response) |
| **Model Selection** | `--model [model_name]` |
| **JSON stats** | `-o json` (if statistics are needed) |

## Command pattern

```bash
qwen -p "[prompt with paths as needed]" -o text --model qwen-coder-plus 2>&1
```

## After Qwen-Code returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `qwen -p "Implement [feature] per [spec]. Touch only [dirs]. Apply changes; do not ask for confirmation." -o text`
- **Investigate**: `qwen -p "Map how [feature] works; output a concise file:line map." -o text`
- **Refactor**: `qwen -p "Refactor [area] for better performance; return summary of edits." -o text`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, JSON output, models: [reference.md](reference.md)
