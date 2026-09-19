---
name: <skill-name>
description: Use <Tool> as a subagent. Lets the main agent prompt <Tool> from the terminal in headless mode, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to <Tool>, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# <Tool> (subagent / task delegation)

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

- **Binary:** `<cli>`
- **Prompt form:** `<flag | positional>` — *state which, because getting this wrong hangs the run.*
  <!-- Example: "flag: -p <PROMPT>" or "positional: the first non-flag argument" -->
- **Install / availability:** `<how the user gets it, one line>`

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `<flag>` |
| Plain text output | `<flag>` |
| Structured output | `<flag, or "NOT DOCUMENTED">` |
| Quiet / no banner | `<flag, or "NOT DOCUMENTED">` |

### Approvals and permissions

Headless mode cannot ask the user for permission. State what this CLI does instead.

- **Approve-all flag:** `<flag, or "none exists — say so plainly">`
- **Narrower option:** `<scoped rule, sandbox, added directory, or "none">`
- **Behaviour when a tool needs approval:** `<stalls | rejects the call | auto-denies and exits 0>`
- **Warnings:** `<any documented carve-out, e.g. a flag that still prompts on destructive commands>`

### Models and how to list them

- **List command:** `<cli> models` *(ask the binary — do not copy model names into this file)*
- **Flag:** `<--model, plus any effort/variant flag>`
- **Accepted shape:** `<slug | family + effort | provider/model>`
- **If the model is unknown:** `<hard-fails | falls back silently>`

If the user names a model or an effort level, use it. Otherwise ask the binary first. Model names
change often, and a model list written into this file goes stale. For capability and price
comparisons, check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own docs.

### Command pattern

```bash
<cli> <headless flag> "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" <approval flag> <output flag> 2>&1
```

<!-- If you assembled this line from separate flags rather than copying a vendor example, say so. -->

### Prompt examples

- **Implement:** `<one line the reader can copy>`
- **Review:** `<one line>`
- **Investigate, no edits:** `<one line>`

### Docs and reference

- Flags, models, authentication and paths: [reference.md](reference.md)
- Vendor documentation: `<live URL, so the agent can check a flag itself>`
- **Verified against `<cli>` `<version>` on `<YYYY-MM-DD>`.**
  <!-- If you could not run the binary, replace this line with:
       > **Documented, not verified.** Written from <vendor> docs on <date> and not checked against
       > an installed binary. Run `<cli> --help` before trusting a flag, and report any difference. -->
