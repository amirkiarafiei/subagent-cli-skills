# Junie CLI — reference

> **Checked against the official JetBrains documentation on 2026-09-19. Not run against an installed
> binary — confirm with `junie --help` before trusting a flag.**

## Authentication

`-a`, `--auth="$JUNIE_API_KEY"` (or the `JUNIE_API_KEY` env var referenced the same way in official
examples).

## Models

Selection is `--model [alias]`. Aliases are short vendor-neutral tags, not raw provider model IDs.
There is no `junie models` subcommand — list available aliases with `junie --help` or the interactive
`/model` slash command. Always confirm current aliases and pricing via
[Artificial Analysis](https://artificialanalysis.ai/) and JetBrains' own docs before pinning one.

## Essential Flags

| Flag | Purpose |
|------|---------|
| (positional prompt) | The documented headless prompt form. |
| `--task <text>` | Explicit flag alternative to the positional prompt. |
| `--prompt` | Starts an **interactive** session with this text as the pre-submitted first turn — not the headless form. |
| `-a`, `--auth` | Provide the Junie API token. |
| `--model` | Specify the model alias. |
| `--review` | Start a code review task. |
| `--merge [branch]` | Resolve merge conflicts with the specified branch/commit. |
| `--rebase` | Resolve rebase conflicts. |
| `--output-format` | `text` (default), `json`, or `json-stream`. |
| `--input-format` | `text` or `json`, for piped input. |
| `--json-output-file <path>` | Save JSON output to a file. |
| `-p`, `--project <path>` | Path to the project directory. |
| `--session-id <id>` | Resume or target a specific session. |
| `--resume` | Resume the most recent session, or the one named by `--session-id`. |
| `--brave` | Toggle Brave Mode — **interactive mode only**, cannot force auto-approval in a headless run. |
| `--sandbox` | OS-level command sandboxing — currently limited to development/nightly/experimental builds. |

There are no `chat`/`review` subcommands — review/merge/rebase are flags on the base `junie` binary.
Slash commands (`/model`, `/brave`, `/sandbox`, `/account`, `/mcp`, `/extensions`, `/settings`, etc.)
exist only inside interactive sessions.

## Approvals and permissions

Interactive default: Junie asks approval for sensitive actions (terminal commands, edits outside the
project, MCP calls) unless allowlisted. **Brave Mode** (Off / Auto / On) controls this, toggled with
`/brave` or Ctrl+B, or the `--brave` flag — but that flag is documented as interactive-mode-only.

**For headless/scripted use, no bypass flag is needed or offered: non-interactive invocations (positional
prompt, `--task`, piped input, ACP, Gateway) are "trusted by design"** — they cannot prompt for a trust
decision, so they load project config (MCP servers, hooks, agents, skills, guidelines) and execute
sensitive actions without asking. This is the practical equivalent of "yolo mode" for automation: simply
invoke non-interactively. JetBrains' own safety caveat: "Only run Junie non-interactively in projects you
trust."

Fine-grained control below that lives in the **Action Allowlist**, `~/.junie/allowlist.json` — rules of
`prefix`/`pattern` + `action: allow|ask`, across five categories: `fileEditing`, `executables`,
`mcpTools`, `readOutsideProject`, `readSecretFile`. How an `ask` rule resolves in a non-interactive
session specifically is not spelled out verbatim in the docs — most likely it resolves the same
"trusted by design" way, but this is inferred, not confirmed.

`--sandbox` / `/sandbox` (OS-level command sandboxing via `sandbox-runtime`/`srt`) exists to make Brave
Mode safer, but is currently only available in development/nightly/experimental builds — not in EAP or
release builds. Do not rely on it as a currently-usable safety net.

## Subcommands

None in the traditional sense — `--review`, `--merge`, `--rebase` are flags on the base `junie` binary,
not separate verbs.

## Configuration and paths

| Component | Path |
|---|---|
| Action Allowlist | `~/.junie/allowlist.json` |

No other general Junie-CLI-scoped config-file location was found documented (the IDE plugin's settings
page is scoped to the JetBrains IDE plugin, not the standalone CLI).

## Documentation

- <https://junie.jetbrains.com/docs/parameters.html> (CLI parameters reference)
- <https://junie.jetbrains.com/docs/junie-cli.html> (quickstart)
- <https://junie.jetbrains.com/docs/junie-headless.html> (headless mode)
- <https://junie.jetbrains.com/docs/action-allowlist-junie-cli.html> (also mirrored at jetbrains.com/help/junie/user-input.html)
- <https://junie.jetbrains.com/docs/slash-commands.html>
- <https://junie.jetbrains.com/docs/junie-cli-model-selection.html>
- Mirror: <https://www.jetbrains.com/help/junie/junie-cli.html>

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
