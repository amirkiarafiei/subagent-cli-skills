---
name: openhands-cli
description: Use OpenHands CLI as a subagent. Lets the main agent prompt OpenHands CLI from the terminal in headless mode with the `openhands` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to OpenHands CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenHands CLI (subagent / task delegation)

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
conversation. A poor handoff causes misread tasks, wrong assumptions about the stack or the style,
and wasted edits.

Write the prompt as a transfer of shared state, not as a title. Include all six fields:

| Include | Why |
|---|---|
| **Goal** | The same objective as the user, not only the immediate micro-task. |
| **Decisions** | Framework, patterns, naming, "use X not Y" — anything that would otherwise be guessed wrong. |
| **Scope** | The paths and modules to touch, and the areas to leave alone. |
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

- **Binary:** `openhands`
- **Prompt form:** **flag.** The task is the value of `-t`/`--task "[prompt]"`, or load it from a file
  with `-f`/`--file [file]`. There is no positional form documented — always attach the prompt to `-t`
  (or point `-f` at a real, non-empty file).

### Headless and output flags

| Need | Flag |
|---|---|
| Run without UI, for scripting | `--headless` |
| Task text | `-t`, `--task "[prompt]"` |
| Task from file | `-f`, `--file [file]` |
| Structured JSONL event stream | `--json` |
| Resume a previous conversation | `--resume` |

### Approvals and permissions

No separate approve-all flag exists to name: the docs describe auto-approval as **included in
`--headless`** ("always-approve mode"). Headless mode is, by itself, the always-approve mode — there is
no narrower or three-level scheme documented, and no stated behavior for a tool call that still can't be
resolved (stall vs. reject vs. exit 0 is NOT DOCUMENTED for that edge case). Treat empty stdout as
failure per the general rule below rather than assuming success.

### Models and how to list them

No CLI command to list models is documented. OpenHands configures the model through **environment
variables** — `LLM_MODEL`, `LLM_API_KEY`, and related vars — rather than a `--model` flag or a `models`
subcommand. Set these before invoking `openhands --headless`. For capability and price comparisons,
check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own documentation; search
the web for current OpenHands model configuration guidance since none is pinned in this skill's sources.

### Command pattern

```bash
LLM_MODEL=<identifier> LLM_API_KEY=<key> \
openhands --headless -t "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" 2>&1
```

### Prompt examples

- **Implement:** `openhands --headless -t "GOAL: [goal] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]"`
- **Batch refactor:** `openhands --headless -t "GOAL: Refactor [area] for [reason] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: summary report"`
- **Automated scripting:** `openhands --headless -t "GOAL: Write a script to [task] | SCOPE: [paths] | OUTPUT: implementation"`

### Docs and reference

- Flags, models, delegation checklist: [reference.md](reference.md)
- No vendor documentation URL is recorded in the source material for this skill.
- No version or verification date is recorded in the source skill. Confirm every flag against
  `openhands --help` before relying on it.
