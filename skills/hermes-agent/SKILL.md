---
name: hermes-agent
description: Use Hermes Agent CLI as a subagent. Lets the main agent prompt Hermes Agent CLI from the terminal in headless mode with the `hermes` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Hermes Agent CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Hermes Agent CLI (subagent / task delegation)

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

- **Binary:** `hermes`
- **Prompt form:** **flag.** The prompt is the argument of `-q` on the `chat` subcommand:
  `hermes chat -q "prompt"`. Always add `-Q` (quiet) alongside it for programmatic use — it suppresses
  the banner, spinner, and tool previews so stdout carries only the final response and a session id.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `chat -q "prompt"` (single-query mode) |
| Quiet, script-safe output | `-Q`, `--quiet` — suppresses banner/spinner/tool previews |
| Verbose/debug output | `--verbose`, `-v` |
| Turn cap | `--max-turns N` (default 90) — bounds a stuck delegation |
| Tag session as third-party | `--source tool` — keeps it out of the user's own session list |

No dedicated `--output-format json` flag is documented for Hermes; `-Q` plus the final response is the
machine-readable surface.

### Approvals and permissions

`--yolo` skips permission checks and auto-approves all tools; the env var `HERMES_YOLO_MODE=true` does
the same and also disables prompts. `--accept-hooks` auto-approves shell hooks without a TTY prompt.
No narrower per-tool allow-rule flag is documented (permission granularity in this CLI comes from
`--toolsets`, which enables or omits whole tool bundles, not individual approvals). What happens if a
prompt is needed and `--yolo`/`--accept-hooks` were not passed is **NOT DOCUMENTED** — treat empty
stdout with a clean exit code as a stalled or silently-denied run, per the general CLI failure guidance,
and read stderr.

`--checkpoints` snapshots files before destructive operations (`/rollback` restores them) — a cheap
safety net for a delegation that writes, independent of the approval flag.

### Models and how to list them

Models are specified as `provider/model-name` (e.g. `anthropic/<identifier>`, `openrouter/<provider>/<model>`,
`ollama/<model-name>`). Run **`hermes model --refresh`** to re-fetch each authenticated provider's live
`/v1/models` list rather than guessing an ID, or `hermes model` for the interactive provider+model
picker. `hermes config show` / `hermes status` show current configuration, but `config show` prints a
formatted box, not `key=value` lines — grepping it for a field name returns nothing.

Provider keys are `nous`, `openrouter`, `anthropic`, `openai`, `google`, `xai`, `mistral`, `deepseek`,
`moonshotai`, `minimax`, `groq`, `zai`, `ollama` (note `zai`, not `zhipuai`). Model availability depends
entirely on which providers the user has authenticated — search the web or check
[Artificial Analysis](https://artificialanalysis.ai/) for current pricing and benchmarks, then confirm
the exact ID against `hermes model --refresh` before pinning it in a delegation.

### Command pattern

```bash
hermes chat -q "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --yolo -Q --toolsets "file,terminal,web,skills" --model "provider/<identifier>" 2>&1
```

### Prompt examples

- **Implement:** `hermes chat -q "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: files changed" --yolo -Q --toolsets "file,terminal,web,skills"`
- **Review:** `hermes chat -q "GOAL: Review [scope] for [concerns] | OUTPUT: review report with severities" --yolo -Q --toolsets "file,terminal,web" -s requesting-code-review`
- **Research (report only):** `hermes chat -q "GOAL: Find latest documentation for [library] | CONSTRAINTS: do not edit any file | OUTPUT: summary report" --yolo -Q --toolsets "web,file"`

### Docs and reference

- Delegation checklist and full flag/tool/toolset/model tables: [reference.md](reference.md)
- Vendor documentation: no single canonical URL captured in source; auth via `hermes setup` /
  `hermes setup --portal` / `hermes model`
- Flags taken from this repo's existing skill and reference docs; no installed-binary verification
  stamp is recorded in the source. Confirm against `hermes --help` before relying on this in production.
