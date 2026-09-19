---
name: junie-cli
description: Use Junie CLI as a subagent. Lets the main agent prompt Junie CLI from the terminal in headless mode with the `junie` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Junie CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Junie CLI (subagent / task delegation)

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

- **Binary:** `junie`
- **Prompt form:** **positional** is the documented headless form: `junie --auth="$JUNIE_API_KEY"
  "prompt text" --model <alias>`. A `--task <text>` flag also exists as an explicit alternative to the
  positional argument. **Do not confuse this with `--prompt`** — that flag starts an *interactive*
  session with the prompt pre-submitted as the first turn; it is not the headless form.

### Headless and output flags

| Need | Flag |
|---|---|
| Non-interactive run | prompt as a positional argument, or `--task <text>` |
| Output format | `--output-format text\|json\|json-stream` (three values) |
| Input format (piped input) | `--input-format text\|json` |
| Save JSON output to a file | `--json-output-file <path>` |
| Project directory | `-p`, `--project <path>` |
| Resume a session | `--session-id <id>` or `--resume` (resumes the last session, or the one named by `--session-id`) |
| Specialized modes | `--review`, `--merge [branch]`, `--rebase` (flags on the base binary — there are no `chat`/`review` subcommands) |

### Approvals and permissions

Junie's approval system is **Brave Mode**, three levels — **Off** (ask before every sensitive action not
already allowlisted; the interactive default), **Auto** (auto-approve actions it safety-classifies as
safe, still ask for risky/unrecognized ones), and **On** (execute everything, no prompts). It is toggled
interactively with `/brave` or Ctrl+B, and there is a `--brave` CLI flag — but the docs state it is
**"Interactive mode only."** It cannot be used to force On in a headless/scripted invocation.

**This does not leave headless runs blocked.** JetBrains' own docs state that non-interactive sessions
(a positional prompt, `--task`, piped input, ACP, or Gateway) *"cannot ask for a trust decision, so they
are trusted by design"* — they load project config (MCP servers, hooks, agents, skills, guidelines) and
execute sensitive actions without ever prompting. There is no TTY block and no hang; the documented
caveat is simply "only run Junie non-interactively in projects you trust." Fine-grained control below
that still exists via the persistent **Action Allowlist** at `~/.junie/allowlist.json` (rules of
`prefix`/`pattern` + `action: allow|ask` across `fileEditing`, `executables`, `mcpTools`,
`readOutsideProject`, `readSecretFile`) — how an `ask` entry resolves in a non-interactive run specifically
is not spelled out verbatim in the docs; treat it as most likely resolving the same "trusted by design"
way, but unconfirmed. A `--sandbox` flag / `/sandbox` command also exists for OS-level command
sandboxing, but is currently limited to development/nightly/experimental builds — **do not rely on it in
a stable release.**

### Models and how to list them

Selection is `--model [alias]`; aliases are short vendor-neutral tags. There is **no separate `junie
models` subcommand** — list them with `junie --help` or the interactive `/model` slash command.

If the user names a model, use it. Otherwise ask the binary first. For capability and price comparisons,
check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own documentation.

### Command pattern

```bash
junie --auth="$JUNIE_API_KEY" "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --model <alias> --output-format text 2>&1
```

### Prompt examples

- **Implement:** `junie --auth="$JUNIE_API_KEY" "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: [format]" --model <alias>`
- **Code review:** `junie --auth="$JUNIE_API_KEY" --review "GOAL: Review my changes for [concerns] | SCOPE: [paths] | VERIFICATION: [check_command] | OUTPUT: review report"`
- **Conflict resolution:** `junie --auth="$JUNIE_API_KEY" --merge [branch] "GOAL: Resolve conflicts between current branch and [branch] | CONSTRAINTS: prefer [strategy]"`

### Docs and reference

- Flags, allowlist, model selection: [reference.md](reference.md)
- Vendor documentation: <https://junie.jetbrains.com/docs/junie-headless.html> and
  <https://junie.jetbrains.com/docs/parameters.html>
- **Checked against the official JetBrains documentation on 2026-09-19. Not run against an installed
  binary — confirm with `junie --help` before trusting a flag.**
