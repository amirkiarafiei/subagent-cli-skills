---
name: antigravity-cli
description: Delegates large multi-step work to Antigravity CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, web search, and read-only plan-mode reviews. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Antigravity CLI (subagent/task delegation)

Use **Antigravity CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

## When to use Antigravity CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Antigravity drives automated tool use while you summarize outcomes and merge.
- **Read-only review passes**: `--mode plan` cannot edit by construction, which makes it the right mode for audits, reviews, and "explain how this works" work.
- **Powerful Web Search**: Delegate deep research or API documentation searches to Antigravity to leverage its integrated web search grounding.
- **Fresh tool stack**: Native Google search grounding, MCP tools, sandbox protection, and other Antigravity-only capabilities.
- **User explicitly asks** for Antigravity or "use Antigravity CLI for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task requires high precision over a single line or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Antigravity does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single Antigravity prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Antigravity returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed "state of the union") rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: run `agy models` to list the slugs this build actually accepts before selecting a model.** Also consult [Artificial Analysis](https://artificialanalysis.ai/) for up-to-date benchmarks and pricing. Names change frequently.

Slugs carry a reasoning tier. Pass either a **full slug** (`gemini-3.6-flash-medium`) or a **family name plus `--effort`** (`--model gemini-3.6-flash --effort medium`). A family name **alone is rejected**.

- **Default (Simple Tasks)**: `gemini-3.6-flash` + `--effort low|medium` (speed, research, formatting).
- **Heavy Tasks**: `gemini-3.1-pro` + `--effort high` (deep reasoning, large refactors).
- **Strategy**: Default to Flash to minimize cost; escalate to Pro only for critical architecture work.

Headless mode does **not** silently fall back on an unknown model—it exits non-zero with an `ERROR` status, so a typo fails the run rather than quietly switching models.

## Programmatic usage (required)

You **MUST** use Antigravity CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag / Option |
|-------------|---------------|
| **Non-interactive** | `-p` / `--print` / `--prompt` (**required**—see below) |
| **Output format** | `--output-format text` (default; also `json`, `stream-json`) |
| **Model Selection** | `--model [slug]`, plus `--effort low\|medium\|high` |
| **Read access to files** | `--add-dir /absolute/path` (repeatable, **absolute paths only**) |
| **Read-only pass** | `--mode plan` (also `accept-edits`) |
| **Long runs** | `--print-timeout 15m` (default is only `5m`) |
| **Auto-approval** | `--dangerously-skip-permissions` (blunt—prefer `--add-dir` / allow-rules) |

A bare `agy "prompt"` starts an **interactive session**. Without `-p` a delegated call opens the TUI
and hangs instead of running and exiting, so every programmatic invocation must pass it.

### Permissions in headless mode

Headless mode cannot prompt, so any tool needing approval is **auto-denied** and the run still **exits 0** with an empty response. Grant the narrowest access that lets the task finish:

1. **`--add-dir /abs/path`** for files it must read. Reads are *not* granted by the shell's working directory, and a relative path such as `.` does not resolve to your cwd—**pass absolute paths**.
2. **Allow-rules** in `~/.gemini/antigravity-cli/settings.json` under `permissions.allow` for shell use, e.g. `"command(git)"`. Inspect what is currently in effect with `agy -p "/permissions"` (a free query—no quota, no conversation).
3. **`--dangerously-skip-permissions`** only as a last resort; it approves file writes and command execution alike.

## Command pattern

```bash
agy -p "[prompt]" --output-format text --model gemini-3.6-flash --effort medium \
  --add-dir /abs/path/to/repo --print-timeout 15m 2>&1
```

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly. Treat these as defaults, not ceremony:

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout arms, so bound it from outside (`timeout 900 agy -p ...`).
- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr—the usual cause is a tool permission the CLI could not prompt for.
- **`flags provided but not defined` means this skill is stale, not that the task is impossible.** Run `agy --help`, proceed with the flags that exist, and tell the user which line here needs updating. Vendor docs and changelogs can describe flags the installed build does not have—`--help` is the only authority.
- **Never carry a flag habit across CLIs.** The same short flag means different things in different tools — in OpenCode `-p` is `--password`, so passing a prompt to it silently empties the message and hangs the run forever. Confirm every flag against `agy --help`.
- **Separate a broken environment from a broken prompt** before debugging the prompt: re-run with a trivial prompt and minimal flags (e.g. `reply with exactly ALIVE`).
- **Need progress on a long run?** Prefer `--output-format stream-json` over removing quiet flags—structured output stays parseable while showing tool calls and token usage as they happen.

## After Antigravity returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `agy -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --output-format text --model gemini-3.6-flash --effort medium --add-dir /abs/repo --print-timeout 15m`
- **Investigate (read-only)**: `agy -p "GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --mode plan --output-format text --add-dir /abs/repo`
- **Web Search**: `agy -p "GOAL: Find latest documentation for [library] | CONSTRAINTS: focus on breaking changes in [version] | OUTPUT: summary report" --output-format text`
- **Security (read-only)**: `agy -p "GOAL: Audit for injection/XSS/auth issues | SCOPE: src/ | OUTPUT: report with severities" --mode plan --output-format text --model gemini-3.1-pro --effort high --add-dir /abs/repo --print-timeout 15m`
- **Structured result**: `agy -p "[prompt]" --output-format json --json-schema '{"type":"object","properties":{"findings":{"type":"array","items":{"type":"string"}}},"required":["findings"]}'` then read `.structured_output`.

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, output formats, models, conversations, permissions: [reference.md](reference.md)
