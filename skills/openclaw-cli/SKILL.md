---
name: openclaw-cli
description: Use OpenClaw as a subagent. Lets the main agent prompt OpenClaw from the terminal in headless mode with the `openclaw agent exec` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to OpenClaw, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenClaw (subagent / task delegation)

<!-- =============================================================================
     GLOBAL HALF — sections 1 to 5.
     These sections are identical in every skill in this repository.
     Copy them without any change. Do not put a vendor name or a flag in them.
     A change here must be made in all skills at the same time.
     ============================================================================= -->

## What is it

This skill teaches your agent to use an agent from another vendor as a subagent.

Almost every coding agent has a headless mode. Headless mode runs the agent from the terminal with
one command and returns the answer to stdout. This skill gives the command pattern for one such
agent, and the protocol to transfer enough context with the task.

You stay the main agent. You keep the plan, the decisions and the conversation with the user. The
subagent does one bounded task and reports back.

## When to delegate

- **The user asks for it.** The user names another agent, or asks for a second opinion.
- **Large or multi-step work.** The task covers several files, phases or checkpoints.
- **Code review with a fresh mind.** Another agent reviews the work with a different lens and no
  memory of the decisions that produced it.
- **Planning that needs different ideas.** A second agent proposes options that you did not consider.
- **An internal council.** Several subagents answer the same question, and you compare the answers.
- **Deep research.** The other CLI has web search, web extraction or browser automation.
- **Background investigation.** A long task runs in the background while you continue in the
  foreground.

## When not to delegate

- **Small or single-step tasks.** One or two edits, or a short explanation, are faster in this thread.
- **Tight feedback loops.** The user wants quick back-and-forth in one conversation.
- **Secrets or policy-sensitive work.** Do not pipe credentials into a subagent. Redact first.
- **Context you already hold.** Repeating the whole plan in a prompt adds no value.
- **Low return on investment.** If writing the handoff costs more than doing the edit, do the edit.
- **Work that needs high precision and full judgement.** A subagent without your context will break a
  task that depends on a detail only this session knows.

## Delegation and context transfer protocol

An isolated subagent saves tokens, but it splits the story. The subagent does not see this
conversation. It has no memory of the goal you agreed with the user, the decisions you already made,
or the paths you agreed not to touch. A poor handoff causes misread tasks, wrong assumptions about
the stack or the style, and wasted edits.

Treat every call as **stateless delegation**: the subagent keeps nothing between calls, so each
command must carry its own state. A good handoff happens when you keep these practices in mind:

- **Shared state handoff.** The prompt carries the original goal, the decisions already made, and the
  explicit scope, to bridge the subagent's missing session history.
- **Contextual preservation.** The high-volume work stays in the isolated process, so the bulk never
  enters this conversation and no "split story" forms from missing history.
- **Result reconciliation.** What comes back is folded into this thread afterwards, so there is a
  single source of truth.

Write the prompt as a transfer of shared state, not as a title. Include all six fields:

| Include | Why |
|---|---|
| **Goal** | The same objective as the user, not only the immediate micro-task. |
| **Decisions** | Framework, patterns, naming, "use X not Y" — anything that would otherwise be guessed wrong. |
| **Scope** | The absolute paths and modules to touch, and the areas to leave alone. A relative path may not resolve where you expect. |
| **Constraints** | Performance, accessibility, compatibility, review gates, "no new dependencies". |
| **Verification** | The exact command the subagent must run and pass before it returns. |
| **Output** | For example: "report only, no edits", "apply edits with a minimal diff", "list the files changed". |

Prefer sequential delegations with explicit carry-over. Parallel runs diverge unless every run gets
the same briefing.

**Run the subagent in the mode that does the work without asking for approval.** Headless mode has
nobody to answer a permission prompt. Any mode that stops to ask will stall, or return an empty
answer with a success exit code. Each CLI names this mode differently — take the flag from the vendor
card below.

**Never call a subagent in plan mode.** Many CLIs have a plan or read-only mode. That mode makes the
other agent write a plan *for itself*, which is not what you asked for: you want its work or its
answer, and you keep the planning. Plan mode also waits for someone to approve that plan, so the run
comes back with nothing. If you want no file changes, keep the auto-approving mode and write "report
only, no edits" in the **Output** field. Do not use plan mode to make a run read-only.

After the subagent returns:

- **Report to the user.** Give a short summary. Do not paste long logs unless the user asks.
- **Reconcile the context.** Record the decisions it made, the files it changed, and the open risks,
  so this session stays the single source of truth.

## CLI failure modes

Every vendor has its own terminal rules. A headless run fails quietly more often than it fails
loudly.

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout starts.
- **Exit code 0 is not success.** If stdout is empty, treat the run as failed and read stderr. A
  permission the CLI could not ask for, and a prompt that never arrived, both look like success.
- **Never carry a flag habit from one CLI to another.** The same short flag means different things in
  different tools. In OpenCode, `-p` is `--password`: passing a prompt to it empties the message and
  the run waits on stdin forever. Confirm every flag against the CLI's own `--help`.
- **An unrecognized-flag error means this skill is stale, not that the task is impossible.** Read
  `--help`, continue with the flags that exist, and tell the user which line in this file is wrong.

<!-- =============================================================================
     VENDOR HALF — section 6.
     Everything below is specific to this CLI.
     Keep all seven sub-headings, in this order, even if the answer is "none".
     Take every flag from the installed binary (`<cli> --help`), not from memory
     and not from another skill in this repository.
     ============================================================================= -->

## Vendor card

### Binary and prompt form

- **Binary:** `openclaw`
- **Prompt form:** **positional**, after the `agent exec` subcommand:
  `openclaw agent exec "prompt"` (usage: `openclaw agent exec [options] [message]`). For a long
  handoff, use `--message-file <path>` instead, or `--message-file -` to read it from stdin.
- **Use `agent exec`, not plain `agent`.** The binary describes `openclaw agent` as "Run an agent turn
  via the Gateway", so it routes through a Gateway service that must already be running. `agent exec`
  is "Run one isolated headless embedded agent turn" and needs no Gateway, no daemon and no prior
  setup. It is the only form that works on a machine where nothing else was started first.
- **The verified trap:** on `openclaw agent`, `-m` is **`--message`**, not `--model`. `--model` has no
  short form. A habit carried over from another CLI where `-m` selects the model will silently send
  the model name as the prompt. `agent exec` has no `-m` at all — pass the prompt positionally.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit, no Gateway | `agent exec "prompt"` |
| Prompt from a file | `--message-file <path>` (`-` reads stdin) |
| One JSON envelope | `--json` |
| Deadline | `--timeout <seconds>` — default 600 |
| Workspace and tool working directory | `--cwd <dir>` |
| Ignore the ambient config | `--isolated` |
| Keep a state directory instead of a temporary one | `--state-dir <dir>` |
| Reasoning effort | `--thinking off\|minimal\|low\|medium\|high\|xhigh\|adaptive\|max\|ultra` |

`--json` belongs to the subcommand, not to `openclaw` itself. The global flags are `--container`,
`--dev`, `--log-level`, `--no-color`, `--profile`, `-V` and `-h`.

With `--json`, **stdout carries the envelope alone and every diagnostic goes to stderr**, so
`openclaw agent exec "…" --json` can be parsed directly without filtering. Read the answer from
`.final`. The envelope also carries `ok`, `status`, `payloads`, `model`, `provider`, `sessionId`, and
`error` with `message` and `kind` when the run fails.

Exit codes: `0` for a completed turn, `1` for a model or result error, `2` for a timeout. Only `1` was
reproduced when this card was written — treat `0` and `2` as documented rather than proven. A failed
run still prints a well-formed envelope with `"ok": false`, so check `.ok` as well as the exit code.

### Approvals and permissions

**Verified: OpenClaw already auto-approves by default, so a headless run does not stall.**
`openclaw exec-policy show` on a clean install reports `security=full`, `ask=off` and
`askFallback=deny`, all marked as OpenClaw's own defaults. There is no per-run approve-all flag in
`agent exec`, and none is needed.

This is the one CLI in this catalogue where the mode that works without asking is not a flag but the
default state of the host. So:

1. **Check, do not assume.** Run `openclaw exec-policy show` and read the **Effective** column. If it
   shows `security=full` and `ask=off`, delegate normally.
2. **If the host has been tightened** — `cautious` or `deny-all` — say so and stop. Tell the user
   they can restore auto-approval with `openclaw exec-policy preset yolo`, and let them run it.
   **Do not change their approval policy yourself**: it is host-wide configuration, not a flag on
   your call.
3. `askFallback=deny` means an **exec** request that falls through to asking is denied, not queued, so
   a tightened host fails fast rather than hanging. Plugin and system-agent approvals are a separate
   queue and can still be waiting: list them with `openclaw approvals pending` and clear them with
   `openclaw approvals resolve`.

### Models and how to list them

Run **`openclaw models list --json`** for the identifiers this install accepts — the only authority.
`--all` shows the full catalogue, `--refresh` rediscovers providers first, and `--provider <id>`
filters.

Select with `--model <provider/model>`. Add `--fallback <provider/model>` for an ordered fallback
chain; it is repeatable and requires `--model`. If the user names a model, use it. Otherwise ask the
binary first. For capability and price comparisons, check
[Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own documentation.

### Command pattern

```bash
openclaw agent exec "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --json --model <provider/model> --cwd /absolute/path/to/repo --timeout 900
```

For a handoff too long to sit comfortably on one command line, write it to a file first:

```bash
openclaw agent exec --message-file ./task.md --cwd /absolute/path/to/repo --json --timeout 900
```

### Prompt examples

- **Implement:** `openclaw agent exec "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: files changed" --cwd /abs/repo --json --timeout 900`
- **Review:** `openclaw agent exec "GOAL: Review [scope] for [concerns] | CONSTRAINTS: do not edit any file | OUTPUT: findings with severity" --cwd /abs/repo --json`
- **Investigate:** `openclaw agent exec "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: file:line map" --cwd /abs/repo --json`

### Docs and reference

- Flags, models, approvals, Gateway and paths: [reference.md](reference.md)
- Vendor documentation: <https://docs.openclaw.ai/cli/agent>
- **Checked against `openclaw` 2026.9.5 on 2026-09-20.** Flags came from `--help`; the JSON envelope,
  the stdout/stderr split, exit code `1` and the default approval policy came from real runs; the skill
  limits and the frontmatter contract were read from the installed package. Exit codes `0` and `2` are
  documented but were not reproduced, because a successful delegation needs provider credentials.
  `reference.md` states the provenance of each claim.
