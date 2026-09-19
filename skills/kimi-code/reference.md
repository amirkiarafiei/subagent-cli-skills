# Kimi Code CLI — reference

> **Checked against the official Moonshot AI documentation on 2026-09-19. Not run against an installed
> binary — confirm with `kimi --help` before trusting a flag.**
>
> **Version note:** Moonshot AI is winding down the legacy Python **Kimi CLI** (frozen since v1.44.0,
> 2026-05-13) in favor of the rewritten **Kimi Code CLI** (TypeScript). Both ship the `kimi` binary and
> the new one auto-migrates the old one's config/sessions, but flag semantics differ materially —
> notably around approvals. This reference describes **current Kimi Code CLI**.

## Authentication

Credential resolution order: an `api_key` field directly in `config.toml`, then a
`[providers.<name>.env]` sub-table pointing at a named env var via `api_key_env`, then startup fails
with an error if both are absent. Docs state explicitly: "Except for the explicitly declared
`api_key_env`, the CLI does not fall back to shell environment variables for credentials." For
Moonshot's own built-in provider specifically, the documented env vars are `KIMI_API_KEY` and
`KIMI_BASE_URL` (it can also read `OPENAI_API_KEY` for compatible providers configured that way).
`kimi login` runs an OAuth device-code flow (RFC 8628) without entering the TUI.

## Models

Selection is `-m`/`--model <alias>`; omitted, sessions use `default_model` from `config.toml`. No `kimi
models` subcommand exists — use **`kimi provider`** (non-interactive shell equivalent of the TUI's
`/provider` command), e.g. `kimi provider catalog list` to browse/filter the model catalog (fetched from
models.dev for third-party providers). A `/model list` picker exists in the TUI only. A moving "latest"
moving alias is not documented for the current CLI. Always check
[Artificial Analysis](https://artificialanalysis.ai/) and the vendor's docs for current names/pricing.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--prompt "prompt"` | Run a single prompt non-interactively, stream to stdout, no TUI. |
| `--output-format text\|stream-json` | Output format; only usable with `--prompt` (text is default). |
| `-m`, `--model <alias>` | Model alias for this launch. |
| `--yolo`, `-y` | "Ask When Needed": routine edits/commands auto-run; risky actions/questions/plans still ask. |
| `--auto` | "Never Ask": everything runs and is decided automatically; no short form documented. |
| `--plan` | Read-only exploration/planning mode — do not use for headless delegation. |
| `--agent`, `--agent-file` | Select or define a sub-agent. |

`--prompt` cannot be combined with `--yolo`, `--auto`, or `--plan`. `--yolo`/`--auto` are mutually
exclusive. `--final-message-only` and `--max-ralph-iterations` are legacy Kimi CLI flags not found in
current Kimi Code CLI docs — the closest current equivalent of Ralph-loop behavior, if it exists at all,
would be a `config.toml` field, not a CLI flag.

## Approvals and permissions

`--yolo` is a partial mode (routine actions auto-run, risky/questions/plans still ask); `--auto` is the
actual blanket auto-approve-everything mode. Never use `--plan` for delegation.

**Non-interactive (`-p`) mode always runs under an implicit `auto` permission policy** — this is
documented explicitly: "In `-p` mode, no human approval is requested — regular tool calls are handled
under the `auto` permission policy, while static deny rules remain in effect." Because of this, `-p`
cannot even be combined with `--yolo`/`--auto`/`--plan`. A `-p` run therefore never stalls or silently
no-ops waiting on approval; only explicit config-level deny rules block a call. Behavior of an
`AskUserQuestion`-style prompt specifically inside `-p` mode is not documented for the current CLI.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `kimi login` | OAuth device-code login, no TUI. |
| `kimi acp` | Agent Client Protocol / IDE JSON-RPC mode. |
| `kimi web` | Local REST/WebSocket server + web UI (replaces the deprecated `kimi server`, which now exits 1 with a deprecation notice). |
| `kimi doctor` | Validate configuration. |
| `kimi export` | Package a session as a ZIP. |
| `kimi migrate` | Import legacy Kimi CLI data. |
| `kimi upgrade` | Check/install updates. |
| `kimi vis` | Session visualizer. |
| `kimi provider [catalog list ...]` | Manage providers/models. |
| `kimi install-desktop` | Install desktop integration. |

## Agent Skills

Kimi Code CLI has a documented Agent Skills system. A skill is a Markdown document with YAML
frontmatter, either as a `SKILL.md` inside a directory (with supporting files alongside it) or a flat
standalone `.md` file for simple skills. Required frontmatter: `name`, `description`, `type`; optional:
`whenToUse`, `disableModelInvocation`, `arguments`. Load priority: **Project > User > Extra > Built-in**,
from `.kimi-code/skills/` (project), `$KIMI_CODE_HOME/skills/` (user), and `extra_skill_dirs` in
`config.toml`. A `--skills-dir` CLI flag was mentioned in one source but could not be re-confirmed —
treat its existence as unverified. Beyond Skills, Kimi Code CLI also documents Plugins, Sub-agents
(`--agent`, `--agent-file`), Hooks (script injection at lifecycle checkpoints: formatting, approvals,
notifications), MCP support, and Custom Themes as separate customization layers.

## Configuration and paths

| Component | Path |
|---|---|
| Project skills | `.kimi-code/skills/` |
| User skills | `$KIMI_CODE_HOME/skills/` |
| Extra skill dirs | `extra_skill_dirs` in `config.toml` |
| Legacy Ralph-loop setting | `[loop_control].max_ralph_iterations` in `config.toml` (legacy Kimi CLI only, per third-party analysis; not confirmed present in current Kimi Code CLI) |

## Documentation

- <https://moonshotai.github.io/kimi-code/en/reference/kimi-command.html>
- <https://moonshotai.github.io/kimi-code/en/configuration/providers.html>
- <https://moonshotai.github.io/kimi-code/en/customization/skills.html>
- <https://moonshotai.github.io/kimi-code/llms-full.txt>
- Legacy (frozen) docs for comparison: <https://moonshotai.github.io/kimi-cli/en/reference/kimi-command.md>

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
