---
name: goose-cli
description: Use Goose CLI as a subagent. Lets the main agent prompt Goose CLI from the terminal in headless mode with the `goose` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Goose CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Goose (subagent / task delegation)

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

- **Binary:** `goose`
- **Prompt form:** **flag**, after the `run` subcommand. `goose run` is described as "Execute
  commands from an instruction file or stdin" and takes the task either way:
  - `-t`, `--text <TEXT>` — the prompt inline
  - `-i`, `--instructions <FILE>` — read the prompt from a file; use `-` for stdin
  There is no positional prompt. `goose session` is the interactive surface; use `goose run` instead.
- **The verified trap:** `-n` is **`--name`**, the session name — not "non-interactive". Several
  other CLIs use `-n` for a one-shot run. Here `goose run` is already one-shot, and `-n` only labels
  the session. Do not reach for `-n` expecting headless behaviour.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `run -t "prompt"` or `run -i <file>` |
| Answer only on stdout | `-q`, `--quiet` — "Suppress non-response output" |
| Plain text / JSON / events | `--output-format text\|json\|stream-json` (default `text`) |
| Do not write a session file | `--no-session` — documented as "Useful for automated runs" |
| Cap the run | `--max-turns <n>` — default 1000 |
| Stop repeat-call loops | `--max-tool-repetitions <n>` — "Helps prevent infinite loops" |
| Extra system instructions | `--system <TEXT>` |
| Print token and cost stats | `--stats` |

Do not pass `-s`/`--interactive`; it keeps the session open after the task instead of exiting.

### Approvals and permissions

Approvals are set by the **`GOOSE_MODE` environment variable**, not by a flag on `goose run`. There
is no `--mode`, `--yolo`, `--auto-approve` or `--permission-mode` on this binary. The documented
values are `auto`, `approve`, `smart_approve` (underscore, not hyphen) and `chat`, and the documented
default is `auto`.

`GOOSE_MODE` does not appear in `--help`; it comes from the vendor's configuration and headless
documentation. Environment beats the saved `config.yaml`, so set it inline and do not rely on the
default — a user may have `approve` or `smart_approve` persisted.

Always prefix the call:

```bash
GOOSE_MODE=auto goose run -t "[prompt]" --no-session
```

`approve` and `smart_approve` stop on a prompt nobody can answer; `chat` disables tool calls
altogether. Never edit `~/.config/goose/config.yaml` on the user's behalf — pass the variable for your
own call instead. `GOOSE_DISABLE_SESSION_NAMING=true` additionally skips a background model call used
only to name the session.

### Models and how to list them

Provider and model come from the `GOOSE_PROVIDER` and `GOOSE_MODEL` environment variables, and both
can be overridden for a single run:

- `--provider <PROVIDER>` — overrides `GOOSE_PROVIDER`
- `--model <MODEL>` — overrides `GOOSE_MODEL`; the model must be supported by that provider

Run **`goose info`** to see the resolved configuration and paths, and `goose configure` to change
them interactively. `goose local-models` (alias `lm`) manages local inference models. If the user
names a model, use it. For capability and price comparisons, check
[Artificial Analysis](https://artificialanalysis.ai/).

### Command pattern

```bash
GOOSE_MODE=auto goose run -t "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [absolute paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --no-session --quiet --max-turns 60 --output-format text 2>&1
```

For a handoff too long for one command line, write it to a file and read it back:

```bash
GOOSE_MODE=auto goose run -i ./task.md --no-session --quiet --max-turns 60
```

### Prompt examples

- **Implement:** `GOOSE_MODE=auto goose run -t "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [absolute paths] | VERIFICATION: [test_command] | OUTPUT: files changed" --no-session --max-turns 80`
- **Review:** `GOOSE_MODE=auto goose run -t "GOAL: Review [scope] for [concerns] | CONSTRAINTS: do not edit any file | OUTPUT: findings with severity" --no-session --quiet`
- **Investigate:** `GOOSE_MODE=auto goose run -t "GOAL: Map how [feature] works | SCOPE: [absolute paths] | CONSTRAINTS: do not edit any file | OUTPUT: file:line map" --no-session --quiet --output-format json`

### Docs and reference

- Flags, models, modes, skills and paths: [reference.md](reference.md)
- Vendor documentation: <https://goose-docs.ai/docs/>
- **Verified against `goose` 1.51.0 on 2026-09-21** by running `--help`, `run --help`,
  `skills --help`, `skills list` and `info`. Flags came from the binary. `GOOSE_MODE` and its default
  are from the vendor's configuration and headless docs — the variable is not mentioned in `--help`.
  A model turn was not completed, because that needs provider credentials. Note the vendor moved:
  docs are now at `goose-docs.ai` and the repository org is `aaif-goose`.
