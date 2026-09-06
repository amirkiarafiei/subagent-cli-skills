---
name: grok-cli
description: Delegates large multi-step work to xAI's Grok CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, reasoning-intensive passes, and machine-readable JSON runs. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Grok CLI (subagent/task delegation)

> **Documented, not verified.** Written from xAI's published CLI docs on 2026-09-06 and **not** checked
> against an installed binary. Before trusting any flag here, run `grok --help`; on a mismatch use what
> the binary actually offers and tell the user which line in this file is wrong.

Use **Grok CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad
refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay
orchestrator: smaller prompts, less context burn, often lower spend than doing the same work in-session.

## When to use Grok CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Reasoning-heavy passes**: `--effort` exposes a reasoning-effort control for harder problems.
- **Machine-readable results**: `--output-format json` returns one JSON object; `streaming-json` emits newline-delimited events for progress.
- **Bounded runs**: `--max-turns` caps how many agent turns a delegation may take.
- **User explicitly asks** for Grok or "use Grok for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: if the task requires high precision over a single line, or composing the Handoff Table costs more than editing the file yourself. Delegate only when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Grok does not see the main session's
full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and
wasted edits.

When composing the **single Grok prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Grok returns**, pull **decisions and constraints** back into the main thread (what it assumed,
what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel
runs that might diverge unless they share the same briefing.

## Model Selection & Discovery (Mandatory)

**Run `grok models` to list the model IDs this install accepts.** The docs describe `-m, --model <MODEL>`
as taking a "Model ID" but **do not enumerate the valid strings**, so there is nothing to copy from this
file — ask the binary. Use the web (or [Artificial Analysis](https://artificialanalysis.ai/)) for pricing
and benchmarks only. Omit `--model` to use the configured default.

`--effort <LEVEL>` controls reasoning effort; the accepted levels are **NOT DOCUMENTED** in the pages this
skill was written from. Check `grok --help` before passing it.

## Programmatic usage (required)

You **MUST** use Grok CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p`, `--single <PROMPT>` — **the prompt is a FLAG argument, not positional** |
| **Output format** | `--output-format plain\|json\|streaming-json` (`plain` is the default) |
| **Auto-approval** | `--always-approve` (alias `--yolo`) |
| **Model** | `-m`, `--model <MODEL>` |
| **Turn cap** | `--max-turns <N>` |
| **No TUI takeover** | `--no-alt-screen` (run inline rather than fullscreen) |
| **Quiet automation** | `--no-auto-update` (skips background update checks — recommended for scripts) |

> **The prompt goes in `-p`, not after the command.** `grok "do the thing"` is not the documented
> headless form. Narrower alternatives to blanket approval also exist — `--allow <RULE>`, `--deny <RULE>`
> and `--sandbox <PROFILE>` — prefer them when you can scope the run.

No quiet/silent flag beyond the above is documented, and **no exit-code table is documented** — so treat
empty output as failure rather than trusting the status alone.

## Command pattern

Composed from individually documented flags (not quoted verbatim from a single doc example):

```bash
grok -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --output-format json --always-approve --no-auto-update --max-turns 40 2>&1
```

The docs' own verbatim example, for reference:

```bash
grok -p "Explain the architecture" --output-format streaming-json
```

## After Grok returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly:

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout arms.
  Grok documents `--max-turns` but **no wall-clock limit**, so the bound has to come from outside.
- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr — a tool
  permission the CLI could not prompt for, and a prompt that never arrived, both look like success.
- **Never carry a flag habit across CLIs.** The same short flag means different things in different
  tools — in OpenCode `-p` is `--password`, so passing a prompt to it silently empties the message and
  hangs the run forever. Here `-p` *is* the prompt. Confirm every flag against `grok --help`.
- **An unrecognized-flag error means this skill is stale, not that the task is impossible.** Run
  `grok --help`, proceed with the flags that exist, and tell the user which line here needs updating.

## Quick prompts

- **Delegate implementation**: `grok -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --output-format json --always-approve --no-auto-update`
- **Investigate (report only)**: `grok -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --output-format plain --always-approve`
- **Watch progress on a long run**: `grok -p "GOAL: [large task] | ..." --output-format streaming-json --always-approve`
- **Bounded pass**: `grok -p "GOAL: [task] | ..." --max-turns 15 --always-approve --output-format json`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, output formats, sessions, skills, auth: [reference.md](reference.md)
