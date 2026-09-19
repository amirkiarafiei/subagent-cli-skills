# Qwen-Code CLI — reference

> **Checked against the official Qwen Code documentation on 2026-09-19. Not run against an installed
> binary — confirm with `qwen --help` before trusting a flag.**

## Authentication

`/auth` (interactive) configures the provider and API key. Environment-variable auth (e.g.
`DASHSCOPE_API_KEY` or `OPENAI_API_KEY`, depending on provider) is also supported.

## Models

No model-listing command is documented. Select with `--model <identifier>`; `--fallback-model
<identifier>` sets a fallback if the primary is unavailable. No fixed catalog of accepted strings is
reproduced here — identifiers and tiers change frequently. Current offerings split roughly into a
coding-tuned tier for implementation and a higher-reasoning ("thinking") tier for complex architecture;
confirm current names and pricing via the web and
[Artificial Analysis](https://artificialanalysis.ai/) before selecting one, or use whatever the user
names directly.

## Essential Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--prompt` | `-p` | Execute prompt and exit (non-interactive). Prompt is the flag's value. |
| `--output-format` | | `text`, `json`, `stream-json`. |
| `--input-format` | | `stream-json`, for streamed input. |
| `--model` | | Specify the model to use. |
| `--fallback-model` | | Fallback model identifier. |
| `--approval-mode` | | `plan`, `default`, `auto-edit`, `auto`, `yolo` — see Approvals below. |
| `--yolo` | | Shorthand for `--approval-mode yolo`. |
| `--effort` | | Reasoning effort level. |
| `--max-wall-time` | | Wall-clock limit for the run. |
| `--max-tool-calls` | | Cap on tool calls in the run. |
| `--max-subagent-depth` | | Cap on nested subagent delegation depth. |
| `--deadline` | | Hard deadline for the run. |
| `--sandbox-image` | | Sandbox image to run tool execution in. |
| `--include-directories` | | Extra directories to include in context. |
| `--disabled-slash-commands` | | Disable specific slash commands. |
| `--core-tools` | | Restrict to specific core tools. |
| `--output-style` | | Output style setting. |
| `--bare` | | Minimal/bare output mode. |
| `--safe-mode` | | Safer execution mode (interacts with approval modes — see Approvals). |
| `--continue` | | Resume the most recent session. |
| `--resume` | | Resume a specific session by ID. |
| `--system-prompt` | | Override the default system instruction. |
| `--verbose` | | Enable detailed logging for debugging scripts. |
| `--include-partial-messages` | | Include partial/streamed message chunks in output. |

Not documented in the sources used here: a general exit-code table.

## Approvals and permissions

**Documented via a CLI flag — this was previously marked "not documented" in error.**
`--approval-mode <mode>` accepts `plan`, `default`, `auto-edit`, `auto`, or `yolo`; `--yolo` is shorthand
for `--approval-mode yolo`. In an interactive session, modes also cycle with Shift+Tab (Tab on Windows)
or via `/approval-mode [mode]`, and `/plan` / `/plan exit` toggle Plan Mode specifically.

| Mode | Behavior |
|---|---|
| `plan` | Read-only analysis; no file editing or command execution — do not use for delegation |
| `default` ("Ask Permissions") | Manual approval required for edits and commands |
| `auto-edit` | File-changing tools (`edit`, `write_file`, `notebook_edit`) auto-approved; shell commands still ask |
| `auto` | A classifier auto-approves read-only/build/test/in-workspace-edit actions and blocks destructive patterns (`rm -rf /`, credential theft, executing fetched code) |
| `yolo` | Every tool call — including shell commands and file writes — auto-approved |

**Headless default, stated explicitly by the vendor:** "When running headless commands, Ask Permissions
Mode is the default behavior." A plain `qwen -p "..."` therefore defaults to a mode that asks for
approval. What exactly happens to that ask with no TTY to answer it (stall vs. auto-deny) is not spelled
out in the docs consulted — treat it as an undefined stall risk and always pass `--yolo` or
`--approval-mode yolo` for unattended delegation.

`--yolo` only skips approval prompts; it does **not** enable a sandbox. Sandboxing is a separate,
explicit opt-in via `--sandbox`, the `QWEN_SANDBOX` environment variable, or `tools.sandbox` in
settings, and `--sandbox-image` sets which image that sandbox uses. Untrusted delegated work should
still run inside one of these rather than relying on `--yolo` alone.

## Subcommands

| Command | Purpose |
|---------|---------|
| `qwen sessions list` | List recent conversations. |
| `qwen sessions ps` | List currently running sessions. |
| `qwen sessions controllers` | Manage trusted controller tokens. |
| `qwen serve --open` | Start the web UI / daemon. |

## Agent Skills

Qwen Code loads Agent Skills from `SKILL.md` files.

| Scope | Path |
|---|---|
| Personal (user-level) | `~/.qwen/skills/` |
| Project-level | `.qwen/skills/` |

Frontmatter requires `name` (non-empty string matching `/^[\p{L}\p{N}_:.-]+$/u`) and `description`
(non-empty string describing what the skill does and when to use it); `priority` is optional.
Recommended convention: lowercase ASCII with hyphens for shareable skill names. Auto-managed skills
live under directories like `.qwen/skills/auto-skill-*` with `source: auto-skill` in frontmatter; after
30 days without a successful use or edit they're marked stale, and after 90 days moved to
`.qwen/archived-skills/`. Hand-authored, personal, extension, and bundled skills are never
auto-removed.

## Context Handling

- **Piping**: `cat file.ts | qwen -p "summarize"`.
- **Exclusions**: uses `.gitignore` and `.qwenignore`.

## Documentation

- Vendor documentation: <https://qwenlm.github.io/qwen-code-docs/en/users/features/approval-mode/>,
  <https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/>,
  <https://qwenlm.github.io/qwen-code-docs/en/users/configuration/settings/>
- **Checked against the official documentation on 2026-09-19. Not run against an installed binary —
  confirm with `qwen --help` before trusting a flag.**

## Delegation Checklist

1. **Full Goal**: Clearly state what needs to be achieved.
2. **Prior Decisions**: Stack, style, and API choices already made.
3. **Scope**: Define files or directories to work in.
4. **Constraints**: Performance, a11y, or compatibility requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Summarize results," "Apply diffs," etc.
