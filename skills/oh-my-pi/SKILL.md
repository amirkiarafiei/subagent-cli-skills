---
name: oh-my-pi
description: Use Oh My Pi CLI as a subagent. Lets the main agent prompt Oh My Pi CLI from the terminal in headless mode with the `omp` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Oh My Pi CLI, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Oh My Pi CLI (subagent / task delegation)

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

- **Binary:** `omp`
- **Prompt form:** **positional**, gated by a boolean flag. `-p`/`--print` takes no value of its own —
  it only switches off the TUI. The prompt text is a separate positional argument, e.g.
  `omp -p "prompt"` or `omp -p --mode json "prompt"`. A bare `omp` (no `-p`) opens the interactive TUI
  and never returns.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `-p`, `--print` (prompt follows positionally) |
| Plain text | `--mode text` (the default) |
| JSON event stream | `--mode json` |
| Other protocols | `--mode rpc`, `--mode acp`, `--mode rpc-ui` |
| Wall-clock limit | `--max-time <duration>` (`600`, `10m`, `1h`) — the one CLI here with a real internal timeout |

### Approvals and permissions

Three documented levels, set with `--approval-mode <mode>` (or `--auto-approve`/`--yolo` to force
`yolo`):

| Mode | Auto-approves | Prompts for |
|---|---|---|
| `always-ask` | read | write, exec |
| `write` | read, write | exec |
| `yolo` (**default**) | read, write, exec | none |

For subagent-style delegation, the docs state plainly: **"Subagents run headless with
`tools.approvalMode: yolo` so ordinary tier-based prompts do not stall them."** A `prompt` (ask) policy
"cannot be satisfied in a headless subagent and rejects the call" — the documented failure mode is a
**rejection**, not a hang. A `bash` safety override still blocks "critical destructive patterns" (e.g.
`rm -rf /`, fork bombs) even under `yolo`; an explicit tool/user `deny` policy is also still enforced.
No exit-code table is documented — treat empty stdout as failure.

### Models and how to list them

Run **`omp models`** for provider-grouped tables of every available model; `omp models find <substring>`
filters, `omp models refresh` re-fetches the catalog, `--json` for machine-readable output.

Selection is `--model <id-or-role>`, which accepts a role (`slow`, `@slow`), a fuzzy match, or an exact
`provider/modelId` (use the exact form when an id exists under multiple providers). Role-specific
overrides: `--smol <id>`, `--slow <id>`, `--plan <id>`. A fixed list of accepted IDs is NOT DOCUMENTED.

If the user names a model or an effort level, use it. Otherwise ask the binary first. For capability
and price comparisons, check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own
documentation.

### Command pattern

```bash
omp -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --yolo --mode json --model <id-or-role> --max-time 45m 2>&1
```

### Prompt examples

- **Implement:** `omp -p "GOAL: [goal] | SCOPE: [paths] | VERIFICATION: [test_command] | OUTPUT: files changed" --yolo --max-time 45m`
- **Review (report only):** `omp -p "GOAL: Review [scope] for [concerns] | CONSTRAINTS: do not edit any file | OUTPUT: findings with severity" --approval-mode always-ask`
- **Investigate:** `omp -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --yolo`

### Docs and reference

- Flags, approval modes, models, skills, auth, paths: [reference.md](reference.md)
- Vendor documentation: `omp.sh/docs` (a client-rendered SPA; the facts here come from the vendor's own
  `docs/*.md` source in the `can1357/oh-my-pi` repository, not the rendered page)
- **Documented, not verified.** Written from that docs source on 2026-09-06 and not checked against an
  installed binary. Run `omp --help` before trusting any flag here.
