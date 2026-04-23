---
name: codex-cli
description: Delegates large multi-step work to OpenAI Codex CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, and reasoning-intensive tasks. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenAI Codex CLI (subagent/task delegation)

Use **OpenAI Codex CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Codex CLI (powered by `o1` and `gpt-4o` architectures) excels at high-level reasoning and multi-turn autonomous problem solving.

## When to use Codex CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Codex drives `--full-auto` tool use while you summarize outcomes and merge.
- **Reasoning-heavy tasks**: Use when logical consistency and "Chain of Thought" are critical for the subtask.
- **Parallel mental lane**: you continue planning or reviewing while Codex runs a bounded task (optionally background—see [reference.md](reference.md)).
- **User explicitly asks** for Codex or “use Codex for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Codex does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits—see Cognition’s discussion of **sharing context** and **implicit decisions** in multi-step setups.

When composing the **single Codex prompt** (using `exec`), treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

**After Codex returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed “state of the union”) rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest OpenAI Codex model names and pricing before selecting a model.** 

- **Default (Reasoning/Complex)**: `o1-preview` (Deep reasoning, high logic).
- **Balanced (Speed/Edits)**: `gpt-4o` (Fast, multimodal, stable).
- **Strategy**: Default to `o1-preview` for complex architecture and `gpt-4o` for standard implementation or research.

## Programmatic usage (required)

You **MUST** use Codex CLI programmatically via the `exec` command. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `exec "prompt"` |
| **Auto-approval** | `--full-auto` or `-a full-auto` |
| **Model Selection** | `--model [model_name]` |
| **Ephemeral Run** | `--ephemeral` (Prevents local session bloat) |

## Command pattern

```bash
codex exec "[prompt]" --full-auto --model o1-preview 2>&1
```

## After Codex returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `codex exec "Implement [feature] per [spec]. Touch only [dirs]. Run in full-auto mode." --full-auto`
- **Logic Check**: `codex exec "Analyze this logic for edge cases and potential race conditions." --model o1-preview`
- **Audit**: `codex exec "Perform a security audit of the authentication layer." --full-auto`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, models, profiles: [reference.md](reference.md)
