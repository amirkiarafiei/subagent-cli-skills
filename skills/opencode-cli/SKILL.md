---
name: opencode-cli
description: Delegates large multi-step work to OpenCode CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for deep architectural changes, complex code generation, and CI automation. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# OpenCode CLI (subagent/task delegation)

Use **OpenCode CLI** to run a **separate long-horizon pass** over the repo: deep architectural changes, multi-step implementation, or broad refactors—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn.

## When to use OpenCode CLI

- **Deep Architectural Changes**: OpenCode is optimized for complex code generation and tool-calling.
- **CI Automation**: Use `github run` for automated tasks in CI pipelines.
- **Large or multi-step work**: several files, phases, or checkpoints.
- **Parallel mental lane**: you continue planning or reviewing while OpenCode runs a bounded task.
- **User explicitly asks** for OpenCode or “use OpenCode for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task is "needle-in-a-haystack" (requires high precision over a single line) or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: OpenCode does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single OpenCode prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

## Model Selection & Discovery (Mandatory)

**Run `opencode models` for the exact `provider/model` strings this install accepts** — it is the only
authority, and it reflects the providers the user is actually authenticated against. Use the web (or
[Artificial Analysis](https://artificialanalysis.ai/)) for pricing and benchmarks only; it returns
marketing names, not the strings the CLI takes. Omit `--model` to use the configured default.

## Programmatic usage (required)

You **MUST** use OpenCode CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `run "[prompt]"` |
| **Auto-approval** | `--auto` (auto-approves permissions not explicitly denied) |
| **Model Selection** | `-m` or `--model [provider/model]` |
| **Agent Selection** | `--agent build` (the default; leave it alone unless you have a reason) |
| **Output Format** | `--format [default|json]` |
| **Reasoning Effort** | `--variant [high|max|minimal]` (provider-specific) |
| **Logs to stderr** | `--print-logs` (see the hang section — often the only output you get) |

> **Never use `--agent plan` for delegation.** OpenCode's `plan` agent exists to *plan changes*, not to
> answer questions: asked to investigate, it stops and requests permission to run its probes instead of
> running them, which in headless mode is a wasted round-trip and an empty answer. Read-only is not the
> point — say "report only, no edits" in the prompt and pass `--auto` from the start. `opencode agent list`
> is the authority on what agents exist here (`build`, `plan`, `explore`, `general`, plus internal
> `compaction`/`summary`/`title`); do not import mode names from other CLIs.

There is **no** `--dangerously-skip-permissions` flag. OpenCode's CLI silently ignores
unknown flags, so passing it fails open rather than erroring — the run proceeds with
permissions unchanged and blocks on anything set to `ask` (e.g. `doom_loop`,
`external_directory`). Use `--auto`.

> **`-p` is `--password`, not the prompt.** The prompt is a **positional** argument. Writing
> `opencode run -p "GOAL: ..."` (the habit from `claude -p` / `copilot -p` / `qwen -p`) feeds your
> prompt to basic-auth and leaves the message **empty** — and an empty message makes the process
> **wait on stdin forever**: no session is created, no output is produced, and it never exits.
> The same happens whenever `"$(cat prompt.txt)"` resolves to an empty string. Always pass the
> prompt positionally, and never let an unquoted or missing file become the message.

## Command pattern

```bash
opencode run "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --auto --model [model] --print-logs 2>&1
```

Report-only pass — ask for it in the prompt and still pass `--auto`, so the run never stalls on a
permission it cannot obtain:

```bash
opencode run "GOAL: [analysis task] | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: report only" --auto --print-logs 2>&1
```

### Don't let it hang your session — watch it, don't guess a duration

OpenCode can finish a task and then fail to exit, so a plain blocking call can hold your session open on
a job that is already done. A fixed timeout is a poor answer to that: too short and it destroys
completed work (the answer sits in a block-buffered stdout that dies with the process), too long and you
sit an hour on a run that stalled in the first ten seconds.

**If your harness can run a command in the background — most can — do that and judge from the log:**

```bash
opencode run "[prompt]" --auto --print-logs > /tmp/oc-run.log 2>&1 &
```

Merge both streams into one file so the answer and the logs land together, then read that file
periodically and decide from what it shows:

| Log state | Meaning | Do |
|---|---|---|
| no `created id=ses_...` yet, only `init` | never really started | give it ~a minute, then kill and check the prompt argument |
| new lines still arriving | alive and working | keep waiting, **for as long as the task needs** |
| `disposing instance` | work finished | take the answer from the log, kill the process |
| no new line for several minutes | stalled | kill it, report, retry once |

**Judge silence, not elapsed time.** A real delegation may legitimately run for an hour, and there is no
duration that separates "still thinking" from "hung". Log activity does: a working run keeps emitting
tool and step lines, while a stalled one goes quiet within seconds and stays quiet. How long to tolerate
silence is your call — a run compiling or executing a long test suite earns more patience than one that
went quiet mid-sentence.

**Only if you cannot background a command:** fall back to one blocking call wrapped in `timeout`, and
pick the number yourself from the size of the job. There is no correct default to copy — make it
comfortably larger than the work could plausibly need, and treat it purely as a backstop.

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly. Treat these as defaults, not ceremony:

- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr — the usual
  cause is a tool permission the CLI could not prompt for, or a prompt that never arrived.
- **Never leave a blocking call unbounded.** OpenCode can finish the work and then fail to exit, so an
  unwatched call holds your session forever on a job that is already done. Background it and watch the
  log (see the Command pattern section) rather than picking a duration out of the air.
- **Add `--print-logs` and read stderr.** The answer goes to stdout, which is block-buffered when it is
  not a terminal: if the process is killed before it flushes, **stdout is lost and you get zero bytes**
  while stderr still has the whole story. Two distinct signatures, and `--print-logs` is what tells
  them apart:

  | Logs show | Meaning |
  |---|---|
  | `init`, then only `cleanup prune=7.days` ~60s later, no `created id=ses_...` | No session was created — the **prompt never arrived**. Check the prompt argument, not the model. |
  | `created id=ses_...`, `exiting loop`, `disposing instance` — then no exit | The work **finished**; the process is hanging on shutdown. The answer was produced. Take it from stderr and let the timeout reap the process. |

  The `cleanup prune=7.days` line is a routine 60-second startup timer present in **every** run,
  successful ones included. It is the last line before silence in a hang only because nothing else is
  logging — it is never the cause.
- **Pipe versus file redirection is not the variable.** A `> file` run and a `| pipe` run hang
  identically (measured both ways, plus inside a real terminal, plus with `--pure`, plus with stdin
  closed, plus with no stale process holding the database). Do not rearrange redirection; wrap in
  `timeout` and read stderr.
- **Beware recipes built from a handful of runs.** When this stalls, *where* it stalls varies between
  otherwise identical invocations — sometimes before the session is created, sometimes after the answer
  has already been produced. A few trials in one shape can therefore look like a firm rule and not
  replicate. Re-test before believing any "always do X" recipe, this file's included.
- **Unknown flags are silently ignored**, so a wrong flag fails open instead of erroring. Verify flags
  against `opencode run --help` — it is the only authority — and if this skill names a flag that no
  longer exists, proceed with what does and tell the user which line needs updating.
- **Separate a broken environment from a broken prompt** before debugging the prompt: re-run with a
  trivial prompt and minimal flags (e.g. `Reply with exactly: ALIVE`).
- **Need progress on a long run?** Prefer `--format json` or `--print-logs` over guessing — silence
  and progress look identical otherwise.

## After OpenCode returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `opencode run "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --auto`
- **Architectural Analysis**: `opencode run "GOAL: Analyze architecture for [concerns] | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: architecture report" --auto --model [heavy-model] --print-logs > /tmp/oc-run.log 2>&1 &` then watch the log
- **Investigate**: `opencode run "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --auto --print-logs > /tmp/oc-run.log 2>&1 &` then watch the log

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, agents, models, auth: [reference.md](reference.md)
