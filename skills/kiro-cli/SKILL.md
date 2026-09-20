---
name: kiro-cli
description: Use Kiro CLI as a subagent. Lets the main agent prompt Kiro CLI from the terminal in headless mode with the `kiro-cli` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Kiro CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Kiro CLI (subagent / task delegation)

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

> **Note:** AWS has moved Kiro CLI's authoritative docs to kiro.dev/docs; `docs.aws.amazon.com` now
> mostly hosts a migration notice pointing there (the Amazon Q Developer CLI → Kiro CLI rename took
> effect 2025-11-17).

### Binary and prompt form

- **Binary:** `kiro-cli`
- **Prompt form:** **positional**, on the `chat --no-interactive` subcommand: `kiro-cli chat
  --no-interactive "prompt"`. Reference a file directly with **`@path`** — no space after the `@`
  (e.g. `@src/auth.rs`, `@./relative/path`, `@"path with spaces.txt"`, `@dir/` for a directory tree).
  Tab-completion is supported; the content is expanded inline before sending, not fetched via a tool call.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `chat --no-interactive "prompt"` |
| List available models | `chat --list-models` (supports `--format json`) |
| Fail if MCP servers don't come up | `--require-mcp-startup` — exits with code 3 if MCP servers don't start or report status within a 30-second window; without the flag, startup problems are only logged and execution continues |

No dedicated `text`/`json` output-format flag beyond `--list-models --format json` was found documented.

### Approvals and permissions

`--trust-all-tools` auto-approves all tool calls without prompting — the docs explicitly flag that this
includes arbitrary shell execution ("use with caution"). `--trust-tools=<comma-list>` (e.g.
`read,grep,write`) grants granular auto-approval instead, and the docs recommend it over
`--trust-all-tools` on least-privilege grounds. **What happens if neither flag is passed and a tool needs
approval during `--no-interactive` is NOT DOCUMENTED** — AWS's own docs do not state the fallback
(stall, error, or silent exit 0). Do not assume any of the three; pass an explicit trust flag rather than
relying on undocumented default behavior.

### Models and how to list them

Run **`kiro-cli chat --list-models`** (add `--format json` for machine-readable output). Selection is
`--model <alias>` on `chat`; the permanent default is set with `kiro-cli settings
chat.defaultModel <alias>`.

If the user names a model, use it. Otherwise ask the binary first. Kiro bills by a **credit-based
subscription** (Free/Pro/Pro+/Pro Max/Power tiers, each with a monthly credit allotment; add-on credits
and overage both bill at a flat per-credit rate) and gates newer/premium models behind a paid tier — the
Free tier gets a baseline model plus open-weight models only. Check
[Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own pricing docs before assuming
availability or cost for a given model.

**Built-in agents**, selectable via `--agent "<name>"` (list with `kiro-cli agent list`): **Default**
(general-purpose, all tools — the one to use for delegation), **Spec** (structured feature development
with approval gates), **Quick Spec** (auto-generates all phases, no gates), **Bug Fix** (structured bug
investigation/resolution). **Do not select `Plan`** (explores and produces a plan; cannot write files or
execute commands — read-only by design) **or `Guide`/`Help`** (CLI-only, documentation-grounded Q&A over
an indexed-docs tool, not general coding agents) for headless delegation — none of the three can do real
work. Users can also define custom agents (`kiro-cli agent create|edit|validate|migrate|set-default`).

### Command pattern

```bash
kiro-cli chat --no-interactive "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --trust-all-tools --model <alias> 2>&1
```

### Prompt examples

- **Implement:** `kiro-cli chat --no-interactive "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: [format]" --trust-all-tools`
- **Investigate:** `kiro-cli chat --no-interactive "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --agent "Default" --trust-tools=read,grep`
- **Refactor:** `kiro-cli chat --no-interactive "GOAL: Refactor [area] for better performance | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: summary of edits" --trust-all-tools`

### Docs and reference

- Delegation checklist, agent/model tables, config paths: [reference.md](reference.md)
- Vendor documentation: <https://kiro.dev/docs/cli/headless/> and <https://kiro.dev/docs/reference/cli-commands/>
- **Checked against the official Kiro (kiro.dev) documentation on 2026-09-19. Not run against an
  installed binary — confirm with `kiro-cli --help` before trusting a flag.**
