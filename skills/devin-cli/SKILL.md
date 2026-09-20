---
name: devin-cli
description: Use Devin CLI as a subagent. Lets the main agent prompt Devin CLI from the terminal in headless mode with the `devin` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Devin CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Devin CLI (subagent / task delegation)

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

> **Documented, not run against a binary.** Checked against `docs.devin.ai` on 2026-09-19. Confirm
> every flag with `devin --help` before trusting it, especially the permission-mode value — see
> below.

### Binary and prompt form

- **Binary:** `devin`
- **Prompt form:** **flag.** `-p`, `--print [PROMPT]` is documented as "print response and exit
  (non-interactive mode)," with the prompt as its argument, e.g. `devin -p "prompt text"`. The
  prompt can also be given after a bare `--` (`devin -- add a login page`), but for delegation use
  `-p` so the run is explicitly non-interactive and exits.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `-p`, `--print [PROMPT]` |
| Load the initial prompt from a file | `--prompt-file <path>` |
| Export the conversation after each turn | `--export <file>` |
| Config file | `--config <path>` |
| Workspace trust check (default `true`) | `--respect-workspace-trust [true\|false]` |

No output-format flag (text/json) and no exit-code table are documented.

### Approvals and permissions

Set with `--permission-mode <MODE>` (or `DEVIN_PERMISSION_MODE`). The current docs give:

| Mode | Behavior |
|---|---|
| `normal` (alias `auto`) | Default; read-only tools auto-run, writes/shell prompt. |
| `accept-edits` | Auto-approves file edits in the workspace; still prompts for shell/fetch. |
| `smart` | Auto-approves edits; a fast model judges fetch/shell safety and falls back to prompting. |
| `dangerous` (aliases `bypass`, `yolo`) | Auto-approves **all** tool calls, including shell. |
| `autonomous` | **Requires `--sandbox`.** Shell commands and fetches auto-approve inside the OS sandbox; direct file edits via the `edit`/`write` tools still prompt, because those tools run in the CLI process rather than inside the sandbox. Granting a `Write(...)` scope mid-session dynamically expands the sandbox. |

**Resolved naming conflict:** earlier docs disagreed on whether the bypass mode is called `dangerous`
or `bypass`. The current reference page states the flag's literal value is `dangerous`, with `bypass`
and `yolo` as documented aliases — pass whichever your installed binary's `--help` accepts.

**What happens with nobody to answer:** the docs state `--print`/`-p` "cannot show the workspace
trust prompt, so it fails in an untrusted directory" — that specific case is a hard failure, not a
stall. Beyond workspace trust, the general fallback for an unanswered tool-approval prompt in
`normal`/`accept-edits`/`smart` mode is **not documented** — avoid the situation by running
`dangerous` (or `autonomous` with `--sandbox`) for headless delegation.

### Models and how to list them

Run **`devin models list`** — "list available models, organized by model family." Select for a run
with `--model <MODEL>` (or `DEVIN_MODEL`).

If the user names a model, use it. Otherwise run `devin models list` first, and use the web /
[Artificial Analysis](https://artificialanalysis.ai/) only for pricing and benchmark comparisons.

### Command pattern

```bash
devin -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --permission-mode dangerous 2>&1
```

### Prompt examples

- **Implement:** `devin -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --permission-mode dangerous`
- **Investigate (report only):** `devin -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map"`
- **Sandboxed autonomous run:** `devin -p "GOAL: [task] | ..." --permission-mode autonomous --sandbox`

### Docs and reference

- Flags, permission modes, models, skills, auth: [reference.md](reference.md)
- Vendor documentation: <https://docs.devin.ai/cli/reference/commands> and
  <https://docs.devin.ai/cli/reference/permissions>
- **Checked against the official Devin documentation on 2026-09-19. Not run against an installed
  binary — confirm with `devin --help` before trusting a flag**, particularly the exact
  `--permission-mode` bypass value.
