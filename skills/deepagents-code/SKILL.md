---
name: deepagents-code
description: Use Deep Agents Code as a subagent. Lets the main agent prompt Deep Agents Code from the terminal in headless mode with the `dcode` command, and send the goal, the decisions and the scope with the task. Use when the user asks to delegate work to Deep Agents Code, when a task needs a second independent agent, or when a plan needs a fresh perspective.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Deep Agents Code (subagent / task delegation)

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

- **Binary:** `dcode` (Deep Agents Code). Installed with
  `curl -LsSf https://langch.in/dcode | bash`, not from a package registry.
- **Prompt form:** **flag.** `dcode -n "prompt"` (`-n`, `--non-interactive TEXT` — "Run a single task
  non-interactively and exit"). A bare `dcode` opens the interactive interface and never returns.
- **Piped input also works.** When stdin is piped, the run goes non-interactive automatically, and
  `--stdin` forces that instead of relying on detection. Combining a pipe with `-n` puts the piped
  content first, then the flag text. The maximum piped input is 10 MiB.
- **The verified trap — `-m` is `--message`, not `--model`.** The binary defines `-m, --message TEXT`
  ("Initial prompt to auto-submit on start") and `-M, --model MODEL` for the model. Cline and Kilo
  Code both use `-m` for the model, so carrying that habit here silently passes a model identifier as
  the prompt. `-a` is `--agent`, not anything else. Use the long names: `--model`, `--agent`.
- **A second trap:** several unrelated `dcode` packages exist on npm and PyPI. Do not install one.
  The only correct source is the vendor's own script above.

### Headless and output flags

| Need | Flag |
|---|---|
| Run once and exit | `-n`, `--non-interactive <text>` |
| Read the prompt from stdin | `--stdin` |
| Answer only on stdout | `-q`, `--quiet` — requires `-n` or piped stdin |
| One buffered write instead of streaming | `--no-stream` |
| Cap the turns | `--max-turns <n>` |
| Cap wall-clock time | `--timeout <seconds>` |
| Run a named skill on launch | `--skill <name>` |
| Acceptance criteria | `--rubric <text\|@path>` |

`--max-turns` and `--timeout` both **exit `124`**, matching GNU `timeout`. The `--help` text names 124
only under `--timeout`, but the source returns it for the turn budget too — **and an internal turn
limit applies even when you never pass `--max-turns`**. So a run that keeps retrying commands you did
not allow with `-S` ends in `124`, not `1`. Exit `124` therefore means "a budget was hit", wall-clock
or turns; read stderr to tell which. Both flags need `-n` or piped stdin. Both flags need `-n` or piped stdin. With
`--show-reasoning`, reasoning goes to stderr so the answer on stdout stays pipeable.

### Approvals and permissions

**Shell execution is off by default in non-interactive mode, and `-S` alone turns it on.**

- `-S`, `--shell-allow-list <CMDS>` — "Comma-separated cmds, `recommended`, or `all`". This is the
  switch. With no `-S`, the run answers but never executes anything. Also settable through
  `DEEPAGENTS_CODE_SHELL_ALLOW_LIST`.
- `--allow-fs-tools <LIST>` — a *restricting* filesystem allowlist. All filesystem tools are exposed
  by default, so you only pass this to narrow them. It does **not** enable shell — but it can remove
  it: `execute` is the shell tool, so omitting `execute` from an explicit list takes shell away even
  when `-S` is set. If you pass an explicit list, the binary requires it to contain `read_file` and
  exits `2` otherwise; `all` on its own is accepted.

**The vendor documentation disagrees here.** It says to "pass both" and gives
`--allow-fs-tools execute -S "..."` as the non-interactive example. That example fails on this build,
because the list omits `read_file`. The binary's own help examples pass `-S` alone, and its source
gates shell on the allow-list being non-empty. Follow the binary.

**`-S recommended` is readers only.** The list is `ls, dir, cat, head, tail, grep, wc, strings, cut,
tr, diff, md5sum, sha256sum, pwd, which, uname, hostname, whoami, id, groups, uptime, nproc, lscpu,
lsmem, ps`. It contains **no `git`, `python`, `pytest`, `npm` or `make`**, so a build or test task
given `-S recommended` cannot run its own verification. Name the commands you need, or use `-S all`.

The binary's own non-interactive examples:

```bash
dcode -n 'Summarize README.md'          # no local shell access
dcode -n 'List files' -S recommended    # safe read-only commands
dcode -n 'Search logs' -S ls,cat,grep   # explicit list
dcode -n 'Fix tests' -S all             # any command
```

**`-y`/`--auto-approve` and `--yolo` do nothing here.** Both are marked "(TUI or ACP); ignored with a
warning in headless mode". They neither stall nor grant anything — the run continues without them and
prints a warning to stderr. Reaching for them out of habit from another CLI produces an agent with no
shell and no explanation. `-S` is the only lever.

### Models and how to list them

Select with `-M`/`--model <MODEL>`. A provider-prefixed identifier (`<provider>:<model-id>`) works,
and so does a bare model name when the provider is unambiguous — the binary's own help shows an
unprefixed example. **There is no command that lists models from the shell**; the picker is
interactive only. Take the identifier from the user or leave the configured default alone. Credentials resolve through `dcode auth list`,
`dcode auth status <provider>` and `dcode auth set <provider>`; `dcode auth path` prints the
credential store.

`dcode config` prints every option's effective value and where it resolves from (`--verbose`
adds descriptions), and `dcode config path` prints the config file locations. `--default-model` sets
or shows the persistent default. There is no working-directory flag — `cd` before the call. All management subcommands accept `--json`.
If the user names a model, use it. For capability and price comparisons, check
[Artificial Analysis](https://artificialanalysis.ai/).

### Command pattern

```bash
dcode -n "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [absolute paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  -S "git,pytest,npm,make" --model <model> \
  --max-turns 80 --timeout 900 --quiet 2>&1
```

For a long handoff, pipe it in instead — piped input switches the run to non-interactive on its own:

```bash
cat task.md | dcode --stdin -S "git,pytest" --quiet
```

### Prompt examples

- **Implement:** `dcode -n "GOAL: [goal] | SCOPE: [absolute paths] | VERIFICATION: [test_command] | OUTPUT: files changed" -S "git,pytest,npm,make" --max-turns 80`
- **Review (no shell needed):** `dcode -n "GOAL: Review [scope] for [concerns] | CONSTRAINTS: do not edit any file | OUTPUT: findings with severity" --allow-fs-tools ls,read_file,glob,grep --quiet`
- **Investigate:** `dcode -n "GOAL: Map how [feature] works | SCOPE: [absolute paths] | CONSTRAINTS: do not edit any file | OUTPUT: file:line map" --quiet --timeout 600`

### Docs and reference

- Flags, models, approvals, skills and paths: [reference.md](reference.md)
- Vendor documentation: <https://docs.langchain.com/oss/deepagents/code/cli-reference>
- **Verified against `deepagents-code` 0.1.72 on 2026-09-21** by running `--help`, `config --help`,
  `config --path`, `skills --help`, `skills list`, and a real `-n` invocation, and by reading the
  installed package source for the `recommended` command list, the shell gating and the exit codes.
  The vendor documentation disagrees with this build in several places; each is called out above and
  the binary wins. A model turn was not completed, because that needs provider credentials, so the
  exit codes are read from source rather than observed. This build was released the same day —
  re-check before trusting it later.
