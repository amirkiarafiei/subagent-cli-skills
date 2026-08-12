---
name: copilot-cli
description: Delegates large multi-step work to GitHub Copilot CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, codebase research, @explore, @general-purpose, or @code-review. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# GitHub Copilot CLI (subagent/task delegation)

Use **GitHub Copilot CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Inside Copilot CLI, **agents** are specialists. Force one using the `--agent` flag in non-interactive prompts. Core specialists include `explore`, `general-purpose`, `task`, `research`, and `code-review`.

## When to use Copilot CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Copilot drives `--yolo` tool use while you summarize outcomes and merge.
- **Parallel mental lane**: you continue planning or reviewing while Copilot runs a bounded task (optionally background—see [reference.md](reference.md)).
- **Built-in specialists**: `explore` for architecture / dependency mapping; `general-purpose` for heavy multi-file subtasks with isolated context; `code-review` for review-style analysis.
- **User explicitly asks** for Copilot or “use Copilot for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Copilot does not see your full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits—see Cognition’s discussion of **sharing context** and **implicit decisions** in multi-step setups.

When composing the **single Copilot prompt** (using `-p`), treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, env (@ FILENAME), and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

**After Copilot returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks)—so the next step or a **follow-up** `copilot` call does not contradict earlier work. Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed “state of the union”) rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Copilot model names/aliases and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data. Availability of specific high-end models varies by account and region.

- **Default (Simple Tasks)**: `gpt-5.6-luna` (inexpensive, fast, ideal for simple edits and exploration).
- **Standard (Implementation)**: `gpt-5.6-terra` or `claude-sonnet-5`.
- **Heavy Tasks**: `gpt-5.6-sol` or `claude-opus-5` (complex reasoning and refactoring).
- **Strategy**: Always default to the cheap tier to save credits. Escalate only for critical tasks after verifying latest version and cost via search. Prefer raising `--effort` over switching to a bigger model — Copilot offers no o-series/"thinking" models.
- **Deadline**: `gpt-5.4` / `gpt-5.4-mini` **retire 2026-08-31** — do not pin them.

## Programmatic usage (required)

You **MUST** use Copilot CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p "prompt"` or `--prompt "prompt"` |
| **Silent output** | `-s` or `--silent` (removes stats/decorations) |
| **Auto-approval** | `--yolo` (or `--allow-all-tools` to avoid hangs) |
| **Model Selection** | `--model [model_name]` |
| **Reasoning Effort** | `--effort [low|medium|high|xhigh]` |

## Command pattern

```bash
copilot -p "[prompt with @ FILENAME as needed]" --yolo -s --model gpt-5.6-luna 2>&1
```

With specific agent:

```bash
copilot -p "[task]" --agent general-purpose --yolo -s 2>&1
```

## After Copilot returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** what you send upstream: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly:

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout arms.
- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr — a tool
  permission the CLI could not prompt for, and a prompt that never arrived, both look like success.
- **Never carry a flag habit across CLIs.** The same short flag means different things in different
  tools — in OpenCode `-p` is `--password`, so passing a prompt to it silently empties the message and
  hangs the run forever. Confirm every flag against `copilot --help`.
- **An unrecognized-flag error means this skill is stale, not that the task is impossible.** Run
  `copilot --help`, proceed with the flags that exist, and tell the user which line here needs updating.

## Quick prompts

- **Delegate implementation**: `copilot -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo -s`
- **Investigate**: `copilot -p "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --agent explore --yolo -s`
- **Audit**: `copilot -p "GOAL: Audit the codebase for security issues | SCOPE: [paths] | OUTPUT: security report" --agent code-review --yolo -s`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, JSON output, agents, autopilot, models: [reference.md](reference.md)
