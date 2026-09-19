# Kiro CLI — reference

> **Checked against the official Kiro (kiro.dev) documentation on 2026-09-19. Not run against an
> installed binary — confirm with `kiro-cli --help` before trusting a flag.** AWS renamed Amazon Q
> Developer CLI to Kiro CLI effective 2025-11-17 and moved authoritative docs to kiro.dev/docs;
> docs.aws.amazon.com now mostly redirects there.

## Authentication

**Default/normal auth is browser-based**, not a simple API key: AWS Builder ID, AWS IAM Identity Center
(SSO), an external enterprise IdP, or social login (GitHub/Google) — this is the primary documented path.

`KIRO_API_KEY` is also a real, documented env var, but it is specifically scoped to **headless/CI-CD
use** ("CI/CD pipelines and automation scripts instead of interactive sign-in"). Setting it skips the
browser login flow. Keys have a `ksk_` prefix, are created at app.kiro.dev under an API Keys section, and
are long-lived credentials — rotate carefully. **API-key auth requires a paid subscription (Pro, Pro+,
Pro Max, or Power tier) and is not available on the Free tier.**

## Models

Run **`kiro-cli chat --list-models`** (add `--format json`) to list available models. Selection is
`--model <alias>` on `chat`; set a permanent default with `kiro-cli settings chat.defaultModel <alias>`.
Kiro's credit-based subscription tiers gate access to newer/premium models — Free-tier accounts get a
baseline model plus open-weight models; paid tiers unlock premium/newer models and an "Auto" routing
option. Check [Artificial Analysis](https://artificialanalysis.ai/) and Kiro's own pricing docs for
current availability and cost.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `chat --no-interactive` | Primary command for non-interactive execution; prompt is positional (or piped via stdin). |
| `chat --list-models [--format json]` | List available models. |
| `--trust-all-tools` | Auto-approve all tools, including arbitrary shell — "use with caution." |
| `--trust-tools=<list>` | Granular auto-approval (e.g. `read,grep`) — recommended over `--trust-all-tools`. |
| `--model <alias>` | Specify the model to use. |
| `--agent "<name>"` | Select a built-in or custom agent. |
| `--require-mcp-startup` | Exit code 3 if MCP servers don't start/report status within 30s; without it, startup issues are only logged. |

## Approvals and permissions

`--trust-all-tools` (blanket) or `--trust-tools=<list>` (scoped) are the only documented approval-bypass
mechanisms. **What happens if neither is passed and a tool needs approval during `--no-interactive` is
NOT DOCUMENTED** in AWS/Kiro's official docs — no stated fallback to stall, error, or silent exit 0.
Always pass an explicit trust flag for a headless delegation rather than relying on undocumented default
behavior.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `kiro-cli chat --no-interactive "prompt"` | Run one prompt headlessly. |
| `kiro-cli chat --list-models [--format json]` | List models. |
| `kiro-cli agent list\|create\|edit\|validate\|migrate\|set-default` | Manage agents. |
| `kiro-cli settings list\|open\|--delete` | Manage settings (prefer this over hand-editing the JSON file). |
| `kiro-cli settings chat.defaultModel <alias>` | Set the permanent default model. |

## Built-in agents

Selectable via `--agent "<name>"`:

| Agent | Notes |
|---|---|
| `Default` | General-purpose, all tools — use this for delegation. |
| `Spec` | Structured feature development with approval gates. |
| `Quick Spec` | Auto-generates all phases, no gates. |
| `Bug Fix` | Structured bug investigation/resolution. |
| `Plan` | **Read-only** — explores the codebase and produces a plan; cannot write files or execute commands. Do not use for headless delegation. |
| `Guide` / `Help` | CLI-only, documentation-grounded Q&A over an indexed-docs "introspect" tool. Not a general coding agent — doc lookup only, unsuitable for delegation. |

Custom agents can also be defined by the user (`kiro-cli agent create`, etc.).

## Context Handling

- **Direct file reference:** `@path` (no space), e.g. `@src/auth.rs`, `@dir/` for a tree, quoted paths
  for spaces. Tab-completion supported; content is expanded inline, not fetched via a tool call.
- **Exclusions:** `.kiroignore` (gitignore syntax, workspace root or subdirectory, stacks with a global
  file) — in the current CLI, `.kiroignore` support is **limited to filtering content-search and
  filename-search results**, not a blanket exclusion from all context. `.gitignore` is documented as a
  best-practice fallback signal to avoid accidentally including secrets; whether Kiro respects
  `.gitignore` by default in all cases is well-supported by community reports but not pinned to one
  official sentence.

## Configuration and paths

| Component | Path |
|---|---|
| Settings | `~/.kiro/settings/cli.json` (not a flat `~/.kiro/settings.json`) |
| Global ignore file | a global `.kiroignore`-style file under `~/.kiro/settings/` (exact filename not fully pinned) |

## Billing

Credit-based subscription: Free ($0, 50 credits), Pro ($20/mo, 1,000 credits), Pro+ ($40/mo, 2,000
credits), Pro Max ($100/mo, 5,000 credits), Power ($200/mo, 10,000 credits). Add-on credit packs and
paid-tier overage both bill at a flat $0.04/credit; the Free tier cannot buy add-on credits and hard-caps
at the monthly reset. No official "credit multiplier per model" table was found in the pages checked —
if a specific multiplier number is needed, verify it directly against current billing docs rather than
citing one here.

## Documentation

- <https://kiro.dev/docs/cli/headless/>
- <https://kiro.dev/docs/reference/cli-commands/>
- <https://kiro.dev/docs/custom-agents/built-in/>
- <https://kiro.dev/docs/getting-started/authentication/>
- <https://kiro.dev/docs/kiroignore/>
- <https://kiro.dev/docs/cli/chat/context/>
- <https://kiro.dev/docs/cli/chat/file-references/>
- <https://kiro.dev/docs/billing/> / <https://kiro.dev/pricing/>
- AWS migration pointer: <https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/upgrade-to-kiro.html>

## Delegation Checklist

1. **Full Goal**: Clearly state the desired outcome.
2. **Prior Decisions**: Explicitly mention tech stack, naming, and patterns.
3. **Scope**: Define `@files` or directories to work in.
4. **Constraints**: Performance, security, or style requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Provide a report," etc.
