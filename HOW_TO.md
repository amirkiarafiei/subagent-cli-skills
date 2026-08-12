# How to Create and Maintain Subagent Skills

This guide is a checklist for writing programmatic delegation skills for additional CLI tools, and for keeping the existing ones honest as those tools change.

The core philosophy is based on **[Cognition-style delegation](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles)**, where the main agent acts as a strategic orchestrator and offloads tactical execution to specialized subagents.

## Rule zero: the installed binary is the only authority

Every flag, model name, and subagent name in a skill must be verified by **running the tool**. Not from vendor docs, not from a changelog, not from another skill in this repo, and never from memory.

This is not pedantry—it is the failure mode this repo actually suffers:

- `agy --bare` and `-o text` were documented, shipped in this repo, and **both had been removed** from the CLI. Every delegation using that pattern failed at argument parsing.
- `agy models --output-format json` is **announced in the vendor changelog** and rejected by the binary that ships with it.
- `--yolo` was listed as an alias for `--dangerously-skip-permissions`. It does not exist.
- `@codebase_investigator`, `@generalist`, and `@gemini-cli-security` were documented as "core specialists." `agy agents` returns an empty list; the `@name` prefix is not a dispatch mechanism at all, so the text was silently read as part of the prompt.
- Model names taken from the web (`gemini-3.6-flash`, `pro`) are rejected: the CLI wants a tiered slug (`gemini-3.6-flash-medium`) or a family plus `--effort`.

A skill that names a flag the binary rejects is worse than no skill, because the orchestrator will trust it and burn a delegation on a parse error.

**Flags never transfer between tools.** `-p` is the prompt in `claude`, `copilot`, and `qwen`—and in OpenCode it is `--password`, which swallows your prompt, leaves the message empty, and hangs the process **forever** waiting on stdin. Assume nothing carries over.

## Skill Creation Checklist

When creating a new skill (e.g. `tool-cli`), address the following in your `SKILL.md` and `reference.md`:

### 0. Agent vs. IDE Compatibility
- [ ] **Verify CLI Support**: Only tools with a programmatic CLI/headless mode can be used as **subagents**.
- [ ] **IDE-only or Orchestrator Tools**: Orchestrators can **learn and use** these skills to delegate *to* other subagents, while programmatic CLIs can act as subagents themselves.

### 1. Mandatory Programmatic Constraints
Run `tool --help` and `tool <subcommand> --help` **first**, and take every flag below from that output.
- [ ] **Force Non-Interactive Mode**: the flag or subcommand that makes the tool run once and exit. Confirm whether the prompt is a **flag argument or a positional**—getting this wrong is the single most common cause of an infinite hang.
- [ ] **Clean Output**: the flag that returns only the response, without banners, spinners, or stats.
- [ ] **Auto-Approval**: the flag that lets the subagent use tools unattended. Prefer the **narrowest** option the tool offers (scoped allow-rules, an added directory, or a read-only/plan mode) and document the blunt "approve everything" flag as a last resort rather than the default.
- [ ] **No invented aliases**: if `--help` shows no short form, do not write one. A skill listing `-m` for `--model` will fail on a tool that has no `-m`.

### 2. Context & Delegation Depth
- [ ] **Context Handoff**: Include a "Delegation and context (critical)" section. Emphasize that the subagent doesn't see the main history.
- [ ] **Handoff Table**: Provide a table of what to include in the prompt (Goal, Decisions, Scope, Constraints, Verification, Expected Output).
- [ ] **Post-Execution Reconciliation**: Instruct the agent on how to merge the subagent's results back into the main thread.

### 3. Model Discovery
- [ ] **Ask the tool, not the web**: use the CLI's own listing command (`tool models`, `tool model`, `tool config`) for the exact accepted strings. Web search is for **pricing and benchmarks only**—it returns marketing names, and the CLI wants slugs.
- [ ] **Record the accepted shape**: some tools require a tier suffix, a separate `--effort`/`--variant` flag, or a `provider/model` prefix. Document which.
- [ ] **Note the failure behaviour**: does an unknown model fall back silently, or hard-fail? Both matter to a caller.
- [ ] **Avoid Stale Versions**: do not hardcode one model as the only option; give a cheap default and a heavy-reasoning tier.

### 4. Specialized Capabilities
- [ ] **Identify Strengths**: Mention what the tool is best at (e.g. "Deep Research," "Code Mapping," "Security Audits").
- [ ] **Quick Prompts**: Provide 3-5 high-signal example prompts—each one a command you have actually run.

### 5. Headless Permissions and Failure Modes
- [ ] **Name what happens when the tool cannot prompt**: headless mode has nobody to ask, so tools get denied, and the denial is usually **silent**. Document whether a denied run exits non-zero or exits 0 with empty output.
- [ ] **Include the shared "If the call fails or hangs" section** (copy it from any existing skill, substituting the binary name). All 15 skills carry it; new ones should too.

### 6. Reference File (`reference.md`)
- [ ] **Essential Flags**: A concise table, verified against `--help`.
- [ ] **Dead flags**: If you removed a flag that older versions of this skill documented, list it as *not* a flag on this build. A future reader hitting the error should recognize it instantly.
- [ ] **Subagent/Agent List**: Only if the CLI's own listing command returns them. If it returns nothing, **omit the section**—do not populate it from docs or guesswork.
- [ ] **Authentication**: Which env vars or login command the tool needs.
- [ ] **Verification stamp**: note the version and date you verified against, e.g. `Verified against agy v1.1.12 on 2026-08-12`. A visibly old stamp is useful; a silently wrong flag is not.

## Prove it works before opening a PR

A skill is a promise that a command runs. Test the promise:

1. **Smoke test** — the cheapest signal that exists:
   ```bash
   timeout 60 <your exact command pattern, prompt replaced with> "Reply with exactly: ALIVE"
   ```
   If this does not print `ALIVE` and exit, the skill is not ready.
2. **Run every Quick Prompt** at least once. They are the lines people copy.
3. **Check the empty case**: confirm you know what a *failed* run looks like. Many CLIs exit **0** with empty stdout when a tool was denied, and some **silently ignore unknown flags** so a wrong flag fails open instead of erroring. If you never see a failure, you cannot document one.
4. **Prefer a real long task** over a trivial one if the tool has a startup timeout, a permission model, or background housekeeping—short prompts hide all three.

## Maintaining skills over time

These CLIs ship breaking changes fast, and a wrong skill fails silently. When maintaining:

- **Re-verify before trusting, not after failing.** If you are editing a skill for any reason, re-run `--help` while you are in there.
- **Treat an unrecognized-flag error as a stale skill, not a failed task.** The correct response is: read `--help`, proceed with what exists, then fix the skill and say which line was wrong.
- **Correlation is not cause in a log.** A hang is usually the *absence* of progress, so the last line before silence is whatever happens to be on a timer—not the culprit. Confirm a cause by reproducing it and by showing a healthy run that survives the same event.
- **Fix the sibling skills too.** These files are copied from each other, so a bad pattern is rarely in only one. Grep the whole `skills/` tree for the dead flag before closing the issue.
- **Keep the shared failure section identical** across skills apart from the binary name, so it stays greppable and fixable in one sweep.

## Philosophy Reference
All skills in this repo are inspired by the delegation principles described by Cognition AI in:
[Don't Build Multi-Agents - Applying the Principles](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles)
