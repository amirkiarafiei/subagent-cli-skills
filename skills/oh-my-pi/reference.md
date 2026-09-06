# Oh My Pi (`omp`) — reference

> **Documented, not verified.** Written on 2026-09-06 and **not** checked against an installed binary.
> `omp --help` and `omp models` are the only authorities. On an unrecognized flag, re-read `--help`, use
> what exists, and report that this skill needs updating.
>
> **Sourcing caveat:** `omp.sh/docs/*` is a client-rendered SPA that returns HTTP 403 to non-browser
> fetches and serves an empty JS shell. The facts below come from the vendor's own documentation source
> (`docs/*.md` in the `can1357/oh-my-pi` repository), which is what that site renders — vendor-authored,
> but not the rendered page.

Auth: per-provider environment variables rather than one key — e.g. `ANTHROPIC_OAUTH_TOKEN` (takes
precedence) or `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, and more. `--api-key <key>`
overrides. `/login` is an interactive TUI slash command; **no headless `omp login` subcommand is
documented**.

## Models

Run **`omp models`** (default `ls`) — "prints provider-grouped tables of every available model".
`omp models find <substring>` filters; `omp models refresh` forces an online catalog re-fetch; any
provider name doubles as a filter (`omp models openai-codex`). Flags: `--json`, `-e <path>`,
`--no-extensions`, `--config <overlay>`.

`--model <id-or-role>` takes a role (`slow` / `@slow`), a fuzzy match (`opus`, `gpt-5.2`), or an exact
`provider/modelId` — use the exact form when an id exists under multiple providers. Role overrides:
`--smol <id>`, `--slow <id>`, `--plan <id>`. `--models <a,b,c>` is for cycling; `--provider <name>` is
legacy. A fixed list of accepted IDs is **NOT DOCUMENTED**.

## Approval model

| Mode | Auto-approves | Prompts for |
|---|---|---|
| `always-ask` | read | write, exec |
| `write` | read, write | exec |
| `yolo` (**default**) | read, write, exec | none |

Set with `--auto-approve` / `--yolo` (force `yolo`), or `--approval-mode <mode>` for an explicit level.
Config equivalent: `tools: { approvalMode: yolo }`.

Documented caveats:

- A `bash` safety override still prompts on "critical destructive patterns such as `rm -rf /`, fork
  bombs, remote-fetch-then-execute, writes to `/etc/passwd`, and host shutdown commands." Under `yolo` a
  bare critical override is ignored, but an explicit tool/user `prompt` or `deny` policy is still enforced.
- "Tool approval does not authorize the underlying real-world action… Consequential actions still require
  point-of-risk confirmation… unless the user's direct message already authorized them."
- **Subagents**: "Subagents run headless with `tools.approvalMode: yolo` so ordinary tier-based prompts do
  not stall them" — and a `prompt` policy "cannot be satisfied in a headless subagent and rejects the
  call." A refusal, not a hang.
- **ACP**: "The schema default is `yolo`, but default-config ACP sessions still keep the client permission
  gate; set `tools.approvalMode: yolo` explicitly when the client wants unattended execution."

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Non-interactive: process the prompt, stream to stdout, exit. **Prompt is positional.** |
| `--mode <mode>` | `text` (default), `json` (structured event stream), `rpc`, `rpc-ui`, `acp`. |
| `--print-thoughts` | Include thinking blocks in printed text output (opt-in). |
| `--auto-approve`, `--yolo` | Force `tools.approvalMode: yolo`. |
| `--approval-mode <mode>` | `always-ask`, `write`, or `yolo`. |
| `--max-time <duration>` | Stop the session after this duration (`600`, `10m`, `1h`). |
| `--model <id-or-role>` | Model or configured role. |
| `--smol`, `--slow`, `--plan <id>` | Role-specific model overrides. |
| `--skills <globs>` | Comma-separated glob filter (e.g. `git-*,docker`). |
| `--no-skills` | Disable skill discovery and loading. |
| `-c`, `--continue` | Continue the previous session. |
| `-r`, `--resume [id]`, `--session [id]` | Resume by ID prefix or path; picker when empty. |
| `--fork <session>` | Fork a saved session into a new one. |
| `--from-claude`, `--from-codex` | Import a Claude Code / Codex session. |
| `--export <session>` | Export a session to HTML and exit. |
| `--prewalk`, `--no-prewalk` | Prewalk behaviour. |
| `--plan-yolo`, `--plan-yolo-into <id>` | Force read-only plan mode, auto-approve the plan on first resolve, then implement. |
| `--profile <name>` | Named profile (relocates the agent directory — see paths). |
| `--config <file>` | Config overlay. Repeatable. |
| `-e <path>`, `--no-extensions` | Extension loading. |
| `--api-key <key>` | API key (defaults to env vars). |

**Not documented:** a quiet/silent flag, and an exit-code table. Documented failure behaviour: an invalid
persistent settings file is moved to a `.broken-*` backup and `omp` exits with the original error plus
the backup path; unknown keys passed to `omp config get` exit non-zero. With `--advisor`, print mode
"waits up to ten minutes for final reviews before disposing the session," and "error exits use a
30-second drain budget so failed automation can terminate."

## Agent Skills

Layout is `<skills-root>/<skill-name>/SKILL.md`, **one level deep and non-recursive** — "Nested patterns
like `<skills-root>/group/<skill>/SKILL.md` are not discovered by provider loaders."

| Provider | Priority | Paths |
|---|---|---|
| `native` | 100 | **User: `~/.omp/agent/skills/`**; project: `<ancestor>/.omp/skills/` (walks up from cwd) |
| `omp-plugins` | 90 | `<extension-package-root>/skills/` |
| `claude` | 80 | User `~/.claude/skills/` (gated by `skills.enableClaudeUser`); project `<ancestor>/.claude/skills/` |
| `claude-plugins` | 70 | `~/.claude/plugins/cache/<plugin>/skills/` |
| `agents` | 70 | Project `.agent/skills`, `.agents/skills`; user `~/.agent/skills`, `~/.agents/skills` |
| `codex` | 70 | User `~/.codex/skills/` (gated by `skills.enableCodexUser`, off by default); project `.codex/skills/` |
| `opencode` | 55 | User `~/.config/opencode/skills/`; project `.opencode/skills/` |
| `github` | 30 | Project only: `.github/skills/<name>/SKILL.md` |
| `omp-managed` | 5 | `~/.omp/agent/managed-skills` — **auto-learn output, not where you install skills** |

`skills.customDirectories` is scanned separately and a custom directory **overrides** a same-named
default-provider skill.

Frontmatter: `name` optional (defaults to the directory name); `description` optional in general but
**mandatory** for the `native`, `omp-plugins`, `github` providers and `customDirectories` scans — a skill
missing it is silently skipped. Optional: `globs`, `alwaysApply`, `hide`, `disableModelInvocation`
(kebab-case `disable-model-invocation` is normalised). `enabled: false` excludes the skill entirely.
Unknown keys are preserved as metadata.

`omp` reads **Claude Code's `~/.claude/skills/`** (both user and project) at priority 80, so skills
installed for Claude Code are visible to `omp` too. No `omp skills` subcommand is documented.

## Essential Paths

| Component | Path |
|---|---|
| **Global skills (install here)** | `~/.omp/agent/skills/` |
| Project skills | `<ancestor>/.omp/skills/` |
| Global config | `~/.omp/agent/config.yml` (or existing `config.yaml`) |
| Project config | `<cwd>/.omp/config.yml` |
| Auto-learn skills | `~/.omp/agent/managed-skills` |
| Show active agent dir | `omp config path` |

`PI_CODING_AGENT_DIR` overrides the agent directory **for the default profile only**, moving user-level
native skills to `<PI_CODING_AGENT_DIR>/skills/`; named profiles ignore it. Under `--profile <name>` the
path becomes `~/.omp/profiles/<name>/agent/skills/`.

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
