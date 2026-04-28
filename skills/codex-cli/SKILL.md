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

Codex CLI (powered by the latest GPT-5 architectures) excels at high-level reasoning, multi-turn autonomous problem solving, and native environment interaction.

## When to use Codex CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Codex drives `--full-auto` tool use while you summarize outcomes and merge.
- **Reasoning-heavy tasks**: Successor to the o-series; use when PhD-level logic and native "Thinking" modes are required.
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

**MANDATORY: Search the web for latest OpenAI model names and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data. GPT-4o is legacy/old for Codex CLI.

- **Default (Reasoning/Complex)**: `gpt-5.4-thinking` (Successor to o3; PHd-level logic).
- **Standard (Speed/Implementation)**: `gpt-5.4` (Balanced, incorporates GPT-5.3-Codex logic).
- **Strategy**: Default to `gpt-5.4` for standard tasks and `gpt-5.4-thinking` for complex architecture. Verify current version via search to avoid stale names.

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
codex exec "[prompt]" --full-auto --model gpt-5.4 2>&1
```

## After Codex returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `codex exec "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | OUTPUT: [format]" --full-auto`
- **Logic Check**: `codex exec "GOAL: Analyze logic for edge cases and potential race conditions | SCOPE: [paths] | OUTPUT: detailed report" --model gpt-5.4-thinking`
- **Audit**: `codex exec "GOAL: Perform a security audit of the authentication layer | SCOPE: [paths] | OUTPUT: audit report" --full-auto`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, models, profiles: [reference.md](reference.md)
