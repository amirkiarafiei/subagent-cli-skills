---
name: opencode-cli
description: Use OpenCode CLI as a subagent. Lets the main agent prompt OpenCode CLI from the terminal in headless mode with the `opencode` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to OpenCode CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenCode CLI (subagent / task delegation)

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

- **Binary:** `opencode`
- **Prompt form:** **positional**, after the `run` subcommand: `opencode run "prompt"`.
- **The known trap:** `-p` is `--password`, not the prompt. Writing `opencode run -p "GOAL: ..."` (a
  habit carried over from `claude -p` / `copilot -p` / `qwen -p`) feeds the prompt to basic-auth and
  leaves the message **empty** — an empty message makes the process **wait on stdin forever**: no
  session is created, nothing is produced, and it never exits. Always pass the prompt positionally.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `run "prompt"` |
| Plain output | `--format default` |
| Structured events | `--format json` |
| Diagnostics to stderr (often the only output you get) | `--print-logs`, `--log-level <DEBUG\|INFO\|WARN\|ERROR>` |

### Approvals and permissions

`--auto` auto-approves permissions not explicitly denied. **There is no `--dangerously-skip-permissions`
flag** — OpenCode's parser silently accepts unknown flags rather than erroring, so passing that name
fails open: the run proceeds as if unflagged. Without `--auto`, the documented behavior is that the run
**blocks** — stalls waiting — on any permission set to `ask` (e.g. `doom_loop`, `external_directory`);
it does not auto-deny or exit early. Always pass `--auto` for unattended delegation.

**Never use `--agent plan` for delegation.** It plans *changes*, not answers — asked to investigate, it
stops to request permission for its own probes, which headless mode cannot grant, producing an empty
answer. For a no-edit run, keep `--agent build` (the default) or `--auto`, and write "report only, no
edits" in the prompt. `opencode agent list` is the authority on which agents exist (`build`, `plan`,
`explore`, `general`, plus internal `compaction`/`summary`/`title`).

### Models and how to list them

Run **`opencode models`** for the exact `provider/model` strings this install accepts — the only
authority, and it reflects only the providers the user is authenticated against. Select with
`-m`/`--model <provider/model>`. Omit `--model` to use the configured default. Use the web (or
[Artificial Analysis](https://artificialanalysis.ai/)) for pricing and benchmarks only — it does not
give you the exact string the CLI accepts.

### Command pattern

```bash
opencode run "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --auto --model <provider/model> --print-logs 2>&1
```

OpenCode can finish and then fail to exit — prefer backgrounding a long run and watching the log rather
than a blocking call with a guessed timeout:

```bash
opencode run "[prompt]" --auto --print-logs > /tmp/oc-run.log 2>&1 &
```

### Prompt examples

- **Implement:** `opencode run "GOAL: [goal] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: [format]" --auto`
- **Report only:** `opencode run "GOAL: [analysis task] | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: report only" --auto --print-logs`
- **Investigate (background, watch log):** `opencode run "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --auto --print-logs > /tmp/oc-run.log 2>&1 &`

### Docs and reference

- Flags, agents, models, auth: [reference.md](reference.md)
- No vendor documentation URL is recorded in the source material for this skill; `opencode run --help`
  and `opencode agent list` are the authorities used to compile it.
- No version or verification date is recorded in the source skill. Confirm every flag against
  `opencode run --help` before relying on it.
