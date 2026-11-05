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

- **Binary:** `openhands`
- **Install:** `uv tool install openhands --python 3.12` (needs Python 3.12+ and uv 0.11.6 or newer), or
  `curl -fsSL https://install.openhands.dev/install.sh | sh` for the executable binary (official page
  <https://docs.openhands.dev/openhands/usage/cli/installation>).
- **Maintenance status:** the official headless page says **"The OpenHands CLI is no longer actively
  maintained"** and points to Agent Canvas for a maintained local setup. The GitHub repo
  `OpenHands/OpenHands-CLI` is not archived and still gets commits (last push seen: 2026-10-22). The
  signals conflict. Tell the user before relying on this CLI.
- **Prompt form:** **flag.** The task is the value of `-t`/`--task "[prompt]"`, or load it from a file
  with `-f`/`--file [file]`. One of the two is required to run headless — there is no bare positional
  form.

### Headless and output flags

| Need | Flag |
|---|---|
| Run without the interactive UI | `--headless` |
| Task text | `-t`, `--task "[prompt]"` |
| Task from file | `-f`, `--file [file]` |
| Structured JSONL event stream | `--json` |
| Resume a previous conversation | `--resume` |

### Approvals and permissions

No separate approve-all flag exists to name, and none is needed: the official docs state plainly,
**"Headless mode always runs in `always-approve` mode."** Every action executes automatically without
confirmation, and this "cannot be changed" — `--llm-approve` (the interactive approval toggle) is
unavailable in headless mode. There is no narrower or three-level scheme documented, and no separate
case of a tool call that still can't be resolved — headless is unconditionally auto-approve.

### Models and how to list them

No CLI command to list models is documented, and the official headless page does not say how a
headless run picks its model. The official installation page says the LLM settings live in
**`~/.openhands/agent_settings.json`**: the CLI asks for them on the first interactive run and reuses
them in later sessions. Configure the model once with an interactive `openhands` run (or edit that
file) **before** delegating headless. A third-party, source-derived index (DeepWiki) says the model is
read from that file and that no `LLM_MODEL`/`LLM_API_KEY` environment variables exist. This card does
not document those variables or an `--override-with-envs` flag: the official docs do not mention them.
For capability and price comparisons, check [Artificial Analysis](https://artificialanalysis.ai/) and
the vendor's own documentation.

### Command pattern

```bash
openhands --headless -t "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" 2>&1
```

### Prompt examples

- **Implement:** `openhands --headless -t "GOAL: [goal] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]"`
- **Batch refactor:** `openhands --headless -t "GOAL: Refactor [area] for [reason] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: summary report"`
- **Automated scripting:** `openhands --headless -t "GOAL: Write a script to [task] | SCOPE: [paths] | OUTPUT: implementation"`

### Docs and reference

- Flags, models, delegation checklist: [reference.md](reference.md)
- Vendor documentation: <https://docs.openhands.dev/openhands/usage/cli/headless> and
  <https://docs.openhands.dev/openhands/usage/cli/installation>
- **Checked against the official documentation on 2026-11-05; not run against an installed binary.**
  Latest release on PyPI: `openhands` 1.16.0. Confirm with `openhands --help` before trusting a flag.
