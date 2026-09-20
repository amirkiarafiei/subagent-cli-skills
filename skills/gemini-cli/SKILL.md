---
name: gemini-cli
description: Use Gemini CLI as a subagent. Lets the main agent prompt Gemini CLI from the terminal in headless mode with the `gemini` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Gemini CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Gemini CLI (subagent / task delegation)

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

> **Deprecated by the vendor** in favor of Antigravity CLI (`agy`) — legacy support for `gemini`
> remains available. Prefer the `antigravity-cli` skill for new delegations; use this card only when
> `gemini` is what's installed or explicitly requested.

### Binary and prompt form

- **Binary:** `gemini`
- **Prompt form:** **flag, for reliability.** `--prompt` / `-p <text>` takes the prompt as its value
  and explicitly "forces non-interactive mode." A positional query string is also accepted
  (`gemini "prompt text"`), but non-interactive behavior is normally triggered by piping stdin or a
  non-TTY session, not guaranteed by the bare positional form alone — so for a scripted/headless
  delegation always pass the prompt via `-p` to be certain the run exits instead of opening the
  interactive UI.

### Headless and output flags

| Need | Flag |
|---|---|
| Force non-interactive mode with the prompt | `-p`, `--prompt <text>` |
| Skip the interactive folder-trust check (headless) | `--skip-trust` |
| Run in a Git worktree (needs `experimental.worktrees: true`) | `-w`, `--worktree [name]` |
| Sandboxed execution | `-s`, `--sandbox` |

No dedicated JSON/text `--output-format` flag is documented for this CLI's core output (unlike its
approval-mode and model flags, which are documented in detail below).

### Approvals and permissions

- **`--approval-mode <default\|auto_edit\|yolo\|plan>`** is the current, non-deprecated control:
  - `default` — prompts for approval on each tool call.
  - `auto_edit` — auto-approves edit tools only.
  - `yolo` — auto-approves all tool calls.
  - `plan` — read-only; the docs themselves flag it as "currently under development and not yet
    fully functional." Do not use it for delegation — it doesn't do the work, and it is not a
    reliable no-op either.
- **`-y`, `--yolo` is deprecated.** Use `--approval-mode=yolo` instead; the two cannot be combined.
- **What happens with nobody to answer:** confirmed from the source — in non-interactive mode, a
  tool call that needs confirmation under `default` (or `auto_edit`, for the tools it doesn't cover)
  is **treated as a denial** (the policy engine maps `ask_user` to `deny`; the scheduler marks the
  call as errored with `CONFIRMATION_REQUIRED`). The run continues; that specific tool call simply
  fails. Pass `--approval-mode=yolo` before running headless if the task needs those calls to
  succeed.

### Models and how to list them

No CLI subcommand to list models is documented. Select with `--model`, `-m <alias-or-name>` — the
default is an automatic-routing alias. Note: `--model` (and the interactive `/model` command) does
**not** override the model used by sub-agents, so a model report can show other models in use even
after you set `--model`.

If the user names a model, use it. Otherwise search the web for current identifiers/aliases and
consult [Artificial Analysis](https://artificialanalysis.ai/) for capability and price comparisons.

### Command pattern

```bash
gemini -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths, @paths as needed] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --approval-mode yolo --skip-trust -m <identifier> 2>&1
```

### Prompt examples

- **Implement:** `gemini -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --approval-mode yolo --skip-trust`
- **Investigate:** `gemini -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: report only, no edits | OUTPUT: concise file:line map" --approval-mode default --skip-trust`
- **Security:** `gemini -p "GOAL: Audit for injection/XSS/auth issues | SCOPE: @./src | CONSTRAINTS: report only, no edits | OUTPUT: report with severities" --approval-mode default --skip-trust`

### Docs and reference

- Flags, approval modes, delegation checklist: [reference.md](reference.md)
- Vendor documentation: <https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/cli-reference.md>
  and <https://geminicli.com/docs/cli/headless/>
- **Checked against the official Google/Gemini CLI documentation on 2026-09-19. Not run against an
  installed binary — confirm with `gemini --help` before trusting a flag.** Note: `--yolo`/`-y`,
  used throughout the previous version of this card, is now documented as **deprecated** in favor of
  `--approval-mode=yolo`.
