---
name: kimi-code
description: Use Kimi Code CLI as a subagent. Lets the main agent prompt Kimi Code CLI from the terminal in headless mode with the `kimi` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Kimi Code CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Kimi Code CLI (subagent / task delegation)

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

> **Version note:** Moonshot AI ships a full rewrite, **Kimi Code CLI** (TypeScript), which is replacing
> the legacy Python **Kimi CLI** (frozen since v1.44.0, 2026-05-13). Both use the `kimi` binary and the
> new one auto-migrates config/sessions from the old one, but flag semantics changed. This card documents
> **current Kimi Code CLI**. If your install still reports itself as the legacy `kimi-cli`, several flags
> below (`--yolo`, `--auto`) will not exist — run `kimi --help` to check which generation you have.

### Binary and prompt form

- **Binary:** `kimi`
- **Prompt form:** **flag.** `-p`, `--prompt "prompt"` runs a single prompt non-interactively and
  streams output to stdout; it does not open the TUI.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `-p`, `--prompt "prompt"` |
| Output format | `--output-format text\|stream-json` (text default; only usable with `--prompt`) |
| Specify a model for the launch | `-m`, `--model <alias>` |

`--prompt` cannot be combined with `--yolo`, `--auto`, or `--plan` (see Approvals, below) — headless mode
runs under its own implicit permission policy regardless. A `--final-message-only` flag and a
`--max-ralph-iterations` flag are documented for the **legacy** Kimi CLI only; neither was found anywhere
in current Kimi Code CLI's docs (the closest legacy equivalent, Ralph-loop iteration count, appears only
as a `max_ralph_iterations` field under `[loop_control]` in `config.toml`, not as a current CLI flag).
Treat both as **NOT DOCUMENTED for the current CLI.**

### Approvals and permissions

Current Kimi Code CLI's approval model:

- **`--yolo`, `-y`** — "Ask When Needed" mode: routine edits and commands run automatically; risky
  actions, questions, and plans still ask.
- **`--auto`** — "Never Ask" mode: nothing interrupts you; everything runs and is decided automatically.
  This is the current blanket auto-approve-everything flag (no short form documented).
- `--yolo` and `--auto` are mutually exclusive.
- **Never use `--plan`** — read-only exploration/planning mode, unsuitable for headless delegation per
  this project's policy.

**Headless behavior is resolved and simpler than it looks:** `--prompt` cannot be combined with
`--yolo`, `--auto`, or `--plan` at all, because **non-interactive (`-p`) mode always runs under an
implicit `auto` permission policy** — "no human approval is requested; regular tool calls are handled
under the `auto` permission policy, while static deny rules remain in effect." So a `-p` run never stalls
waiting for approval and never silently no-ops: routine tool calls simply execute, and only explicit
config-level deny rules still block a call. What happens to an `AskUserQuestion`-style interactive
question specifically inside `-p` mode is **NOT DOCUMENTED** for the current CLI (the legacy CLI
explicitly auto-dismissed these under `--afk`; no equivalent statement was found for the current one).

### Models and how to list them

Selection is `-m`/`--model <alias>`; omit it to use `default_model` from `config.toml`. There is **no
`kimi models` subcommand.** Model and provider management goes through **`kimi provider`** (the
non-interactive shell equivalent of the TUI's `/provider` command) — e.g. `kimi provider catalog list`
to browse/filter the model catalog (fetched from models.dev for third-party providers). An interactive
`/model list` picker also exists inside the TUI, but is not a separate CLI subcommand. A moving "latest"
moving alias is **not documented** — do not assume it exists or warn against it as fact.

If the user names a model, use it. Otherwise ask `kimi provider catalog list` first. For capability and
price comparisons, check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own
documentation.

### Command pattern

```bash
kimi --prompt "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --model <alias> --output-format stream-json 2>&1
```

### Prompt examples

- **Implement:** `kimi --prompt "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: [format]" --model <alias>`
- **Investigate (report only):** `kimi --prompt "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --model <alias>`
- **Interactive-only escalation (not for headless):** `--yolo` and `--auto` only matter outside `--prompt` mode; a `-p` delegation is already running under `auto` permissions by default.

### Docs and reference

- Flags, models, skills, subcommands: [reference.md](reference.md)
- Vendor documentation: <https://moonshotai.github.io/kimi-code/en/reference/kimi-command.html>
- **Checked against the official Moonshot AI documentation on 2026-09-19. Not run against an installed
  binary — confirm with `kimi --help` before trusting a flag**, and confirm which generation (legacy
  `kimi-cli` vs current `kimi-code`) is actually installed.
