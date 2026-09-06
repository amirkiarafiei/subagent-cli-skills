---
name: oh-my-pi
description: Delegates large multi-step work to the Oh My Pi CLI (omp) like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, time-bounded runs, and JSON event streams. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Oh My Pi CLI (subagent/task delegation)

> **Documented, not verified.** Written from Oh My Pi's own docs source on 2026-09-06 and **not** checked
> against an installed binary. Before trusting any flag here, run `omp --help`; on a mismatch use what the
> binary actually offers and tell the user which line in this file is wrong.

Use **Oh My Pi** (`omp`) to run a **separate long-horizon pass** over the repo: multi-step
implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a
subagent**. You stay orchestrator: smaller prompts, less context burn.

## When to use Oh My Pi

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Time-bounded delegation**: `--max-time <duration>` is a real wall-clock limit (`600`, `10m`, `1h`) — the only one among the CLIs in this repo, and the reason `omp` is a good fit for unattended runs.
- **Machine-readable progress**: `--mode json` emits a structured event stream for headless consumption.
- **Fine-grained approval control**: a documented three-level approval model (`always-ask` / `write` / `yolo`) rather than one all-or-nothing switch.
- **Session portability**: `--from-claude` / `--from-codex` import an existing Claude Code or Codex session.
- **User explicitly asks** for Oh My Pi or "use omp for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: if the task requires high precision over a single line, or composing the Handoff Table costs more than editing the file yourself.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: `omp` does not see the main session's
full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and
wasted edits.

When composing the **single Oh My Pi prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Oh My Pi returns**, pull **decisions and constraints** back into the main thread (what it
assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over
parallel runs that might diverge unless they share the same briefing.

## Model Selection & Discovery (Mandatory)

**Run `omp models`** for the model strings this install accepts — it "prints provider-grouped tables of
every available model." `omp models find <substring>` filters, `omp models refresh` re-fetches the
catalog, and `--json` gives machine-readable output. `--model <id-or-role>` accepts a role (`slow`,
`@slow`), a fuzzy match (`opus`), or an exact `provider/modelId`. Use an exact `provider/modelId` when
the same id exists under multiple providers. Role-specific overrides: `--smol`, `--slow`, `--plan`. Use
the web for pricing and benchmarks only.

## Programmatic usage (required)

You **MUST** use Oh My Pi programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p`, `--print` — processes the prompt, streams to stdout, exits without the TUI. **The prompt itself is POSITIONAL.** |
| **Output mode** | `--mode text\|json\|rpc\|acp\|rpc-ui` (`text` is the default) |
| **Auto-approval** | `--auto-approve` or `--yolo` (force `tools.approvalMode: yolo`) |
| **Explicit approval level** | `--approval-mode always-ask\|write\|yolo` |
| **Wall-clock limit** | `--max-time <duration>` (e.g. `600`, `10m`, `1h`) |
| **Model** | `--model <id-or-role>` |
| **Skill scoping** | `--skills <globs>`, `--no-skills` |
| **Auth override** | `--api-key <key>` |

The documented approval model:

| Mode | Auto-approves | Prompts for |
|---|---|---|
| `always-ask` | read | write, exec |
| `write` | read, write | exec |
| `yolo` (default) | read, write, exec | none |

> ⚠️ **`yolo` is not absolute, and that is a feature.** A `bash` safety override still prompts on
> "critical destructive patterns such as `rm -rf /`, fork bombs, remote-fetch-then-execute, writes to
> `/etc/passwd`, and host shutdown commands." In `yolo` a bare critical override is ignored, but an
> explicit tool or user `prompt`/`deny` policy is still enforced.
>
> Also documented: **"Subagents run headless with `tools.approvalMode: yolo` so ordinary tier-based
> prompts do not stall them"** — and a `prompt` policy "cannot be satisfied in a headless subagent and
> **rejects the call**" rather than hanging. So an unexpected refusal, not a hang, is the signature of a
> policy problem here.
>
> Note too: "Tool approval does not authorize the underlying real-world action" — consequential actions
> can still require confirmation at the point of risk.

**No exit-code table is documented** — treat empty output as failure rather than trusting the status.

## Command pattern

Composed from individually documented flags (not quoted verbatim from a single doc example):

```bash
omp -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --yolo --mode json --max-time 45m 2>&1
```

The docs' own verbatim examples, for reference:

```bash
omp -p "List all .ts files in src/"
omp -p --mode json "List every TODO in src/" > todos.json
```

## After Oh My Pi returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly:

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout arms. `omp`
  is the one CLI here with a real internal limit — prefer `--max-time` sized to the task — but still bound
  it from outside in case the process fails to exit.
- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr — a tool
  permission the CLI could not prompt for, and a prompt that never arrived, both look like success.
- **Never carry a flag habit across CLIs.** The same short flag means different things in different
  tools — in OpenCode `-p` is `--password`, so passing a prompt to it silently empties the message and
  hangs the run forever. In `omp`, `-p` is `--print` and the prompt is positional. Confirm every flag
  against `omp --help`.
- **An unrecognized-flag error means this skill is stale, not that the task is impossible.** Run
  `omp --help`, proceed with the flags that exist, and tell the user which line here needs updating.
- **A refused tool call is the documented failure mode, not a hang.** A `prompt` policy in a headless
  subagent rejects the call. If a delegation comes back refusing to act, check the approval policy
  rather than assuming the model declined.

## Quick prompts

- **Delegate implementation**: `omp -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --yolo --max-time 45m`
- **Investigate (report only)**: `omp -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --approval-mode always-ask`
- **Machine-readable run**: `omp -p --mode json "GOAL: [task] | ..." --yolo --max-time 30m > run.json`
- **Edits but no shell**: `omp -p "GOAL: [task] | ..." --approval-mode write --max-time 20m`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, approval modes, models, skills, auth: [reference.md](reference.md)
