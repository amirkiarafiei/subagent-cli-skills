# Oh My Pi (`omp`) — reference

> **Checked against the official oh-my-pi documentation on 2026-09-19. Not run against an installed
> binary — confirm with `omp --help` and `omp models` before trusting a flag.**
>
> **Sourcing note:** `omp.sh/docs` is a client-rendered SPA that returns HTTP 403 to non-browser
> fetches. The facts below come from the vendor's own documentation source
> (`docs/*.md` in the `can1357/oh-my-pi` GitHub repository), which is what that site renders.

## Authentication

Per-provider environment variables rather than one key — e.g. `ANTHROPIC_OAUTH_TOKEN` (takes
precedence) or `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, and more. `--api-key <key>`
overrides. `/login` is an interactive TUI slash command; no headless `omp login` subcommand is
documented.

## Models

Run **`omp models`** (default `ls`) — prints provider-grouped tables of every available model.
`omp models find <substring>` filters; `omp models refresh` forces an online catalog re-fetch; a bare
provider name also filters (`omp models openai-codex`). Flags: `--json`, `-e <path>`,
`--no-extensions`, `--config <overlay>`.

`--model <id-or-role>` accepts:

- an exact `provider/modelId` (unambiguous when the same id exists under multiple providers),
- a bare model ID (resolved case-insensitively against available models),
- a fuzzy/substring match,
- a glob scope pattern (`openai/*`, `*-mini*`),
- each optionally suffixed `:thinkingLevel` (`off|minimal|low|medium|high|xhigh|max`).

Roles are semantic aliases resolved through `settings.modelRoles`: `default`, `smol`, `slow`, `vision`,
`plan`, `commit`, `tiny`, `task`, `advisor`. `--smol <id>`, `--slow <id>`, `--plan <id>` override
specific roles for the run; `--models <a,b,c>` is a comma-separated list for interactive `Ctrl+P`
cycling only. A fixed list of accepted model IDs is not published — ask the binary.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Non-interactive: process the prompt, stream to stdout, exit. Prompt is positional. |
| `--mode <mode>` | `text` (default), `json`, `rpc`, `rpc-ui`, `acp`. |
| `--print-thoughts` | Include thinking blocks in printed text output. |
| `--max-time <duration>` | Stop the session after this duration (`600`, `10m`, `1h`). |
| `--model <id-or-role>` | Model or configured role, see Models above. |
| `--smol`, `--slow`, `--plan <id>` | Role-specific model overrides. |
| `--thinking <level>` | `off\|minimal\|low\|medium\|high\|xhigh\|max\|auto`. |
| `--hide-thinking` | Suppress thinking-block display in the TUI. |
| `--api-key <key>` | API key (defaults to env vars). |
| `--service-tier <tier>` | OpenAI service tier (`none` omits the parameter). |
| `--provider-session-id <id>` | Reuse a provider-side session ID. |
| `-c`, `--continue` | Continue the previous session. |
| `-r`, `--resume [id]` | Resume by ID prefix or path; picker when empty. |
| `--fork <session>` | Fork a saved session into a new one. |
| `--from-claude`, `--from-codex` | Import a Claude Code / Codex session. |
| `--export <session>` | Export a session to HTML and exit. |
| `--no-session` | Ephemeral run, not saved. |
| `--no-title` | Disable automatic session title generation. |
| `--prewalk`, `--no-prewalk`, `--prewalk-into <id>` | Switch to a cheap model at the first edit/write once the plan's todo list exists. |
| `--plan-yolo`, `--plan-yolo-into <id>` | Force read-only plan mode, auto-approve the plan on first resolve, then implement — plans instead of acting; not for delegation. |
| `--tools <a,b,c>` | Allowlist specific tools. |
| `--no-tools`, `-nbt`/`--no-builtin-tools` | Disable all / built-in tools. |
| `--no-lsp` | Disable LSP features and diagnostics. |
| `--no-pty` | Disable interactive bash execution. |
| `--profile <name>` | Isolated profile for auth, sessions, settings, caches. |
| `--config <file>` | Config overlay, repeatable. |
| `-e <path>`, `--extension <path>` | Load an extension, repeatable. |
| `--trusted-extension <abs-path>` | Load a trusted extension by absolute path. |
| `--no-extensions` | Disable extension discovery (explicit `-e` still works). |
| `--plugin-dir <dir>` | Add a local plugin directory to discovery. |
| `--skills <globs>` | Comma-separated glob filter for skills. |
| `--no-skills` | Disable skill discovery and loading. |
| `--no-rules` | Disable context-file rules. |
| `--system-prompt <text\|file>` | Override the default system prompt. |
| `--append-system-prompt <text\|file>` | Extend the system prompt. |
| `--advisor` | Enable the advisor runtime (passively reviews each turn). |

Documented failure behavior: an invalid persistent settings file is moved to a `.broken-*` backup and
`omp` exits with the original error plus the backup path; unknown keys passed to `omp config get` exit
non-zero. With `--advisor`, print mode "waits up to ten minutes for final reviews before disposing the
session," and "error exits use a 30-second drain budget so failed automation can terminate." No quiet/
silent flag and no general exit-code table are documented.

## Approvals and permissions

Three tiers, set with `--approval-mode <mode>` (or `--auto-approve`/`--yolo` to force `yolo`):

| Mode | Auto-approves | Prompts for |
|---|---|---|
| `always-ask` | read | write, exec |
| `write` | read, write | exec |
| `yolo` (**default**) | read, write, exec | none |

Config equivalent: `tools: { approvalMode: yolo }`. Documented caveats:

- **Subagents**: "Subagents run headless with `tools.approvalMode: yolo` so ordinary tier-based prompts
  do not stall them." A `tools.approval.<tool>` override still applies: `deny` blocks the tool, `allow`
  permits it, and `prompt` "cannot be satisfied headlessly and thus rejects the call" — a rejection, not
  a hang.
- A `bash` safety override still prompts on "critical destructive patterns such as `rm -rf /`, fork
  bombs, remote-fetch-then-execute, writes to `/etc/passwd`, and host shutdown commands." Under `yolo` a
  bare critical override is ignored, but an explicit tool/user `prompt`/`deny` policy is still enforced.
- "Tool approval does not authorize the underlying real-world action" — consequential actions can still
  require confirmation at the point of risk.
- **ACP**: the schema default is `yolo`, but default-config ACP sessions still keep the client
  permission gate; set `tools.approvalMode: yolo` explicitly when the client wants unattended execution.

## Agent Skills

Layout is `<skills-root>/<skill-name>/SKILL.md`, one level deep and non-recursive — nested patterns like
`<skills-root>/group/<skill>/SKILL.md` are not discovered by provider loaders.

| Provider | Priority | Paths | `description` required |
|---|---|---|---|
| `native` | 100 | User: `~/.omp/agent/skills/`; project: `<ancestor>/.omp/skills/` (walks up from cwd) | Yes |
| `omp-plugins` | 90 | `<extension-package-root>/skills/` | Yes |
| `claude` | 80 | User `~/.claude/skills/` (gated by `skills.enableClaudeUser`); project `<ancestor>/.claude/skills/` | No |
| `claude-plugins` | 70 | `~/.claude/plugins/cache/<plugin>/skills/` | No |
| `agents` | 70 | Project `.agent/skills`, `.agents/skills`; user `~/.agent/skills`, `~/.agents/skills` | No |
| `codex` | 70 | User `~/.codex/skills/` (gated by `skills.enableCodexUser`, off by default); project `.codex/skills/` | No |
| `opencode` | 55 | User `~/.config/opencode/skills/`; project `.opencode/skills/` | No |
| `github` | 30 | Project only: `.github/skills/<name>/SKILL.md` | Yes |
| `omp-managed` | 5 | `~/.omp/agent/managed-skills` — auto-learn output, not where you install skills | No |

`skills.customDirectories` is scanned separately (`description` mandatory there too) and a custom
directory overrides a same-named default-provider skill.

Frontmatter: `name` optional (defaults to the directory name); `description` mandatory only for
`native`, `omp-plugins`, `github`, and `customDirectories` scans — a skill missing it there is silently
skipped. Optional: `globs`, `alwaysApply`, `hide`, `disableModelInvocation` (kebab-case
`disable-model-invocation` is normalised). `enabled: false` excludes the skill entirely. Unknown keys
are preserved as metadata.

`omp` reads Claude Code's `~/.claude/skills/` (both user and project) at priority 80, so skills
installed for Claude Code are visible to `omp` too. No `omp skills` subcommand is documented.

## Configuration and paths

| Component | Path |
|---|---|
| Global skills (install here) | `~/.omp/agent/skills/` |
| Project skills | `<ancestor>/.omp/skills/` |
| Global config | `~/.omp/agent/config.yml` (or existing `config.yaml`) |
| Project config | `<cwd>/.omp/config.yml` |
| Auto-learn skills | `~/.omp/agent/managed-skills` |
| Show active agent dir | `omp config path` |

`PI_CODING_AGENT_DIR` overrides the agent directory for the default profile only, moving user-level
native skills to `<PI_CODING_AGENT_DIR>/skills/`; named profiles ignore it. Under `--profile <name>` the
path becomes `~/.omp/profiles/<name>/agent/skills/`.

## Documentation

- Vendor documentation: <https://github.com/can1357/oh-my-pi/tree/main/docs> (source of the
  client-rendered `omp.sh/docs` site)
- Key pages used: `docs/approval-mode.md`, `docs/cli-reference.md`, `docs/models.md`, `docs/skills.md`
- **Checked against the official documentation on 2026-09-19. Not run against an installed binary —
  confirm with `omp --help` before trusting a flag.**

## Delegation Checklist

1. **Full Goal**: clearly state the final objective.
2. **Prior Decisions**: stack, style, and API choices already made.
3. **Scope**: exact modules or directories to touch, and what not to touch.
4. **Constraints**: performance, security, or style requirements.
5. **Verification**: the explicit command the subagent must run and pass before returning.
6. **Desired Shape**: "apply changes," "report only," "return JSON," etc.
