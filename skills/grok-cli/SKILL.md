---
name: grok-cli
description: Use Grok CLI as a subagent. Lets the main agent prompt Grok CLI from the terminal in headless mode with the `grok` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Grok CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Grok CLI (subagent / task delegation)

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

- **Binary:** `grok`
- **Prompt form:** **flag.** The prompt is the value of `-p`, `--single <PROMPT>`.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `-p`, `--single <PROMPT>` |
| Output format | `--output-format plain\|json\|streaming-json` (examples in the docs use `plain`; it is not explicitly stated as the default) |
| Turn cap | `--max-turns <N>` |
| Run inline, not fullscreen | `--no-alt-screen` |
| Skip background update checks | `--no-auto-update` (recommended for scripts) |

### Approvals and permissions

`--always-approve` "skips ordinary permission prompts so tools run without waiting for a click" —
documented deny rules, hooks, and some shell `ask` rules still apply on top of it. **`--yolo` is not a
current flag or alias** — it exists only as a legacy `yolo = true` key in `config.toml`, superseded by
`permission_mode` / `--always-approve`; do not pass `--yolo` on the command line. Narrower options:
`--allow <RULE>` / `--deny <RULE>` (work in both interactive and headless sessions), and `--sandbox
<PROFILE>` (documented as a flag; its profile values are not documented).

**What happens when a tool needs approval and nothing can answer:** the call fails immediately and the
failure is reported back to the model in-band (e.g. "Auto mode blocked this action…"), so the model can
try another approach or give up — it does **not** hang and does **not** exit 0 with silent empty output.
A `dontAsk` permission mode does the same silently, denying anything without an explicit allow rule and
never surfacing a prompt at all. Separately, a recent update means non-interactive sessions no longer
fail when the agent asks for user input or plan approval — those specific requests are now auto-resolved
rather than causing a hard failure; tool-permission blocks still fail-and-report as above.

### Models and how to list them

Run **`grok models`** for the model IDs this install accepts. Selection is `-m`, `--model <MODEL>`.
`--effort <LEVEL>` sets reasoning effort; the accepted level values are not documented — check `grok
--help`. Omit `--model` to use the configured default.

If the user names a model or an effort level, use it. Otherwise ask the binary first. For capability
and price comparisons, check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own
documentation.

### Command pattern

```bash
grok -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --output-format json --always-approve --no-auto-update --max-turns 40 2>&1
```

### Prompt examples

- **Implement:** `grok -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: files changed" --output-format json --always-approve --no-auto-update`
- **Review (report only):** `grok -p "GOAL: Review [scope] for [concerns] | CONSTRAINTS: do not edit any file | OUTPUT: findings with severity" --output-format plain --always-approve`
- **Investigate:** `grok -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --output-format plain --always-approve`

### Docs and reference

- Flags, models, permissions, skills, paths: [reference.md](reference.md)
- Vendor documentation: <https://docs.x.ai/build/cli/reference> and <https://docs.x.ai/build/cli/headless-scripting>
- **Checked against the official xAI documentation on 2026-09-19. Not run against an installed binary —
  confirm with `grok --help` before trusting a flag.**
