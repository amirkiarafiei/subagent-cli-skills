---
name: cline-cli
description: Use Cline CLI as a subagent. Lets the main agent prompt Cline CLI from the terminal in headless mode with the `cline` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Cline CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Cline (subagent / task delegation)

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

- **Binary:** `cline`
- **Prompt form:** **positional.** `cline "prompt"` — the usage line is
  `cline [options] [command] [prompt]`, and the argument help reads "Your prompt. Default to start in
  act mode with auto-approve enabled."
- **The verified trap:** `-p` is **`--plan`**, not "print" or "prompt". In several other CLIs `-p`
  passes the prompt; here it switches the run into **plan mode**, which this skill forbids. Writing
  `cline -p "GOAL: ..."` does not pass a prompt — it makes the other agent plan for itself and return
  nothing useful. Pass the prompt positionally, with no flag.
  Note also that `-p` means something different again inside `cline auth`, where it is `--provider`.
- **Two undocumented gotchas, both found by running the binary:**
  1. **A single-token prompt is rejected.** `cline "hi"` fails with `error: Unknown command or
     unquoted prompt: hi` and exit 1, even though it was quoted. Any prompt containing whitespace
     works — which a real six-field handoff always does, so this only bites on a smoke test.
  2. **Piping alone is not enough.** `echo "..." | cline --json` fails with
     `JSON output mode requires a prompt argument or piped stdin`. Piping *plus* a positional prompt
     works. Always pass the prompt positionally, even when you also pipe content in.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | *(nothing — a bare positional prompt already runs once and exits)* |
| Machine-readable output | `--json` — NDJSON, one object per line |
| Working directory | `-c`, `--cwd <path>` |
| Deadline | `-t`, `--timeout <seconds>` — the default is `0`, meaning **no timeout** |
| Stop runaway retries | `--retries <n>` — consecutive mistakes before exit, default `6` |
| Reasoning effort | `--thinking none\|low\|medium\|high\|xhigh` |
| Resume a session | `--id <session-id>` |
| Isolated state | `--data-dir <path>` (default `~/.cline/data`) |

The interactive interface is opt-in through `-i`/`--tui`, so a plain call stays non-interactive. Do
not pass `-i` from a script.

### Approvals and permissions

**Cline already auto-approves.** `--auto-approve <boolean>` carries a documented default of `true`,
and the positional prompt help states the run starts "in act mode with auto-approve enabled". So a
plain `cline "prompt"` does the work without stopping to ask, and no extra flag is needed.

Pass `--auto-approve false` only when the user explicitly asks for a run that stops at every tool.
That is not useful headless, because nobody can answer. Note the default flips to `false` in ACP
mode, and that when stdin/stdout is not a TTY, calls that still require approval are denied.

To restrict which shell commands are allowed, use the environment rather than a flag:
`CLINE_COMMAND_PERMISSIONS='{"allow":["npm *"],"deny":["rm -rf *"]}'`. Deny wins over allow.

**Never pass `-p`/`--plan`.** Plan mode makes the other agent write a plan for itself and wait for
someone to approve it, so the run returns nothing. For a no-edit run, keep the default act mode and
write "report only, no edits" in the **Output** field of the handoff.

### Models and how to list them

`cline auth` configures the provider and the model, and it accepts `-p`/`--provider <id>`,
`-m`/`--modelid <id>`, `-k`/`--apikey`, and `-b`/`--baseurl`. Inspect the result with
`cline config`.

Per run, select with `-P`/`--provider <id>` and `-m`/`--model <model-id>`. The default provider is
`cline`. This build ships **no** command that prints a list of model identifiers — check
`cline auth --help` and the vendor documentation, and prefer whatever the user names. For capability
and price comparisons, check [Artificial Analysis](https://artificialanalysis.ai/).

### Command pattern

```bash
cline "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [absolute paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --cwd /absolute/path/to/repo --json --timeout 900 2>&1
```

`--timeout` defaults to `0`, which means the run has no deadline of its own. Set it, or run the call
in the background and watch the log.

### Prompt examples

- **Implement:** `cline "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [absolute paths] | VERIFICATION: [test_command] | OUTPUT: files changed" --cwd /abs/repo --timeout 900`
- **Review:** `cline "GOAL: Review [scope] for [concerns] | CONSTRAINTS: do not edit any file | OUTPUT: findings with severity" --cwd /abs/repo --json`
- **Investigate:** `cline "GOAL: Map how [feature] works | SCOPE: [absolute paths] | CONSTRAINTS: do not edit any file | OUTPUT: file:line map" --cwd /abs/repo --json`

### Docs and reference

- Flags, models, approvals, skills and paths: [reference.md](reference.md)
- Vendor documentation: <https://docs.cline.bot/>
- **Verified against `cline` 3.0.62 by running `--help`, `auth --help` and `skill --help` on
  2026-09-21. Flags came from the binary, not from documentation. A full delegation was not run,
  because that needs provider credentials.**
