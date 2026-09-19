---
name: qoder-cli
description: Use Qoder CLI as a subagent. Lets the main agent prompt Qoder CLI from the terminal in headless mode with the `qodercli` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Qoder CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Qoder CLI (subagent / task delegation)

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

- **Binary:** `qodercli`
- **Prompt form:** **flag.** The prompt is the value of `-p`/`--print "prompt"`.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `-p`, `--print "prompt"` |
| Plain text | `--output-format text` (the default) |
| One JSON object | `--output-format json` |
| Event stream | `--output-format stream-json` |
| Context window | `--context-window <200000\|400000\|1000000>` |
| Reasoning depth | `--reasoning-effort <low\|medium\|high\|xhigh\|max>` |

### Approvals and permissions

`--permission-mode <mode>` selects the gate, and two flags force full bypass:

| Mode | Behavior when approval would be needed |
|---|---|
| `default` | Sensitive actions require confirmation — **will stall** headless with nobody to answer |
| `accept_edits` | Auto-approves safe file edits only |
| `auto` | AI classifier evaluates action safety and proceeds |
| `bypass_permissions` (`--yolo` / `--dangerously-skip-permissions`) | Skips all approval prompts |
| `dont_ask` | **Denies** anything requiring approval — a rejection, not a hang |

For unattended delegation, use `--yolo` (or `--dangerously-skip-permissions`, documented as identical)
so nothing is left for a prompt that can't be answered. `--allowed-tools`/`--disallowed-tools` scope
which tools are available at all, and `--max-turns` bounds the dialog length.

### Models and how to list them

Run **`qodercli --list-models`** to see the models available to the authenticated account.

Selection is `--model <tier-or-name>`. Five simplified tiers exist: `auto` (smart routing, recommended
default), `efficient`, `performance`, `ultimate`, and `lite` (free, for Team users). `--model` also
accepts a specific vendor-hosted frontier model identifier directly, listed by `--list-models` — do not
hardcode one here, since these names and their credit costs change; check
[the model docs](https://docs.qoder.com/en/cli/model) and [Artificial Analysis](https://artificialanalysis.ai/)
for current names and pricing.

### Command pattern

```bash
qodercli -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --yolo --model <tier-or-identifier> --output-format text 2>&1
```

### Prompt examples

- **Implement:** `qodercli -p "GOAL: [goal] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo --model efficient --output-format text`
- **Investigate:** `qodercli -p "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --yolo --model efficient --output-format text`
- **Heavy reasoning:** `qodercli -p "GOAL: Design architecture for [feature] | SCOPE: [paths] | OUTPUT: architecture plan" --yolo --model ultimate --reasoning-effort high --output-format text`

### Docs and reference

- Flags, model tiers, permission modes, config paths: [reference.md](reference.md)
- Vendor documentation: <https://docs.qoder.com/en/cli/model>
- No version or verification date is recorded in the source skill. Confirm every flag against
  `qodercli --help` before relying on it.
