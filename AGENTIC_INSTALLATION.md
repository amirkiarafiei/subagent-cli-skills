# Agentic Installation

**You are an AI coding agent reading this file because your user asked you to install Subagent CLI Skills. Follow these instructions, then report back.**

Everything you need is in this file. Work through the steps in order.

---

## What you are installing

This repository is a catalog of **Agent Skills for cross-agent task delegation**. Each skill teaches an orchestrator agent (you) how to drive a *different* vendor's CLI agent in headless mode as a **subagent**.

The point is context and cost offloading: you stay the strategic orchestrator, while grep sweeps, log trawls, broad refactors, and research get shipped out to a cheaper isolated process that hands back only a summary. The delegation pattern follows [Cognition's "Don't Build Multi-Agents"](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles) — every delegated prompt carries a full "Handoff Table" of shared state, because the subagent cannot see your conversation.

Each skill is exactly two files: `SKILL.md` (behavioural instructions) and `reference.md` (flags, models, auth).

Repository: `https://github.com/amirkiarafiei/subagent-cli-skills`
Raw base URL: `https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main`

---

## Step 1 — Ask the user first. Install nothing yet.

You need three answers before you touch the filesystem. Ask for all three in **one** message, then wait.

### 1a. First, look around so you can offer good defaults

This probe is read-only and instant. Run it *before* asking, so your question comes pre-filled instead of making the user recite a list:

```bash
for b in agy gemini copilot qwen codex kiro-cli junie openhands opencode claude vibe kimi qodercli hermes; do
  command -v "$b" >/dev/null 2>&1 && echo "found: $b"
done
```

Map what you found using this table — these are the tools the user could hand work to:

| Binary | Skill to install | The tool, in plain terms |
|---|---|---|
| `agy` | `antigravity-cli` | Google Antigravity |
| `gemini` | `gemini-cli` | Gemini (older, still works) |
| `copilot` | `copilot-cli` | GitHub Copilot |
| `qwen` | `qwen-code` | Qwen Code |
| `codex` | `codex-cli` | OpenAI Codex |
| `kiro-cli` | `kiro-cli` | AWS Kiro |
| `junie` | `junie-cli` | JetBrains Junie |
| `openhands` | `openhands-cli` | OpenHands |
| `opencode` | `opencode-cli` | OpenCode |
| `claude` | `claude-code` | Claude Code |
| `vibe` | `mistral-vibe` | Mistral Vibe |
| `kimi` | `kimi-code` | Kimi Code |
| `qodercli` | `qoder-cli` | Qoder |
| `hermes` | `hermes-agent` | Hermes Agent |

Two things to bear in mind when forming your suggestion:

- **Leave yourself out.** If you are Claude Code, do not suggest `claude-code` — you would only be handing work to yourself.
- **Cursor's command is just `agent`**, which is too generic to detect reliably. Only suggest `cursor-cli` if the user mentions Cursor.

### 1b. Then ask, in plain language

Use plain words. Do **not** say "orchestrator", "subagent", "headless", "scope", or "delegation" — the user did not ask for a glossary. Adapt this template, filling in what you actually found:

> I can set this up. Three quick questions:
>
> **1. Which assistant should get these skills?** I'm Claude Code, so I'd add them to myself unless you meant a different one — Cursor, Codex, Gemini, Copilot, Antigravity, Kiro, OpenHands, OpenCode, Qwen, Junie, Mistral Vibe, Kimi, Qoder and Hermes are all supported.
>
> **2. Which other AI tools should I be able to hand work off to?** These skills let me pass heavy jobs — big searches, long refactors, research — to another AI tool running in the background, so the work stays out of our conversation. Looking at your machine, you already have **Antigravity, GitHub Copilot and OpenCode** installed, so I'd suggest those three. Want all three, just some, or something else from the full list of 15?
>
> **3. Everywhere, or just this project?** *Everywhere* saves them in your home folder so they work in every project. *Just this project* keeps them inside this folder only.
>
> Reply however is easiest — "all three, everywhere" is plenty.

Then **stop and wait for the reply.**

- If the user already answered part of this in their original request, don't re-ask that part.
- If they say "you decide" or "just do it", go with your suggested defaults: yourself as the assistant, every detected tool, saved everywhere — and say plainly that's what you picked.
- If the probe found **nothing**, say so and ask which tools they use or plan to install, rather than guessing or installing all 15.
- If they name tools that aren't installed yet, install those skills anyway and mention which commands are missing so they know to install them later.

---

## Step 2 — Work out where the files go

Two decisions from Step 1 determine the path.

**If they chose *everywhere*,** use the folder belonging to the assistant they picked:

| Assistant | Folder |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Cursor | `~/.cursor/skills/` |
| Antigravity | `~/.gemini/antigravity-cli/skills/` |
| Codex | `~/.agents/skills/` |
| Gemini | `~/.gemini/skills/` |
| GitHub Copilot | `~/.copilot/skills/` |
| Junie | `~/.junie/skills/` |
| Kiro | `~/.kiro/skills/` |
| OpenHands | `~/.openhands/skills/installed/` |
| OpenCode | `~/.config/opencode/skills/` |
| Qwen Code | `~/.qwen/skills/` |
| Mistral Vibe | `~/.vibe/skills/` |
| Kimi Code | `~/.kimi/skills/` |
| Qoder | `~/.qoder/skills/` |
| Hermes Agent | `~/.hermes/skills/` |

**If they chose *just this project*,** use `./.skills/` in the repository you are working in.

If their assistant isn't on the list, ask where it loads skills from rather than guessing.

---

## Step 3 — Install

Substitute `<DIR>` with the directory from Step 2 and `<SKILL>` with each skill name.

```bash
mkdir -p "<DIR>/<SKILL>"
curl -fsSL "https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main/skills/<SKILL>/SKILL.md"     -o "<DIR>/<SKILL>/SKILL.md"
curl -fsSL "https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main/skills/<SKILL>/reference.md" -o "<DIR>/<SKILL>/reference.md"
```

If the machine cannot reach `raw.githubusercontent.com`, clone instead and copy:

```bash
git clone --depth 1 https://github.com/amirkiarafiei/subagent-cli-skills /tmp/subagent-cli-skills
cp -r /tmp/subagent-cli-skills/skills/<SKILL> "<DIR>/"
```

There is also an interactive installer (`./install.sh`) for humans. **Do not run it** — it needs a terminal you cannot drive.

---

## Step 4 — Verify, because a zero exit code is not proof

Every file must exist, be non-empty, and begin with YAML frontmatter. A 404 or captive-portal page can arrive with a success status, so check the content:

```bash
for f in "<DIR>/<SKILL>/SKILL.md" "<DIR>/<SKILL>/reference.md"; do
  if [ ! -s "$f" ]; then echo "EMPTY: $f"; fi
done
head -1 "<DIR>/<SKILL>/SKILL.md"     # must print exactly: ---
grep -qi '<!doctype\|<html' "<DIR>/<SKILL>/SKILL.md" && echo "GOT HTML, NOT A SKILL"
```

If any file is empty or contains HTML, delete it, retry once, and report the failure rather than claiming success.

---

## Step 5 — Report back and offer a smoke test

Tell the user, briefly and without jargon:

1. Which skills you installed, and where they went.
2. Anything that failed.
3. That they need to **restart or reload their assistant** before the new skills show up.

Then offer this smoke test, substituting one skill you installed:

> Use the `<SKILL>` skill to ping the subagent: ask it to reply with exactly ALIVE

If that comes back `ALIVE`, everything works end to end.

---

## Guardrails

- **Ask before you write.** Step 1 is not optional; nothing gets installed before the user answers.
- **Only write inside the skills directory.** Never touch the user's agent config, shell profile, or unrelated files.
- **Ask again before installing outside `$HOME`** or into a system path.
- **Overwriting a skill of the same name is fine** — that is how updates work — but say so in your report.
- **Never pipe credentials** into a delegated prompt, and redact secrets before delegating.
- **If a step fails, stop and report.** Do not improvise a different install location.

---

## After installing: how to actually use these

Read the installed `SKILL.md` before your first delegation. The essentials:

- **Always pass a full Handoff Table.** The subagent sees none of your conversation: `GOAL: … | DECISIONS: … | SCOPE: … | CONSTRAINTS: … | VERIFICATION: … | OUTPUT: …`
- **Verify flags against the binary**, not against memory or vendor docs. CLI flags change fast; `<cli> --help` is the only authority. If a documented flag is rejected, the skill is stale — proceed with what exists and tell the user which line needs updating.
- **Exit code 0 is not success.** If a delegated call returns empty stdout, treat it as failed and read stderr; the usual cause is a tool permission the CLI could not prompt for in headless mode.
- **Wrap delegated calls in an external timeout**, since a headless CLI can stall before its own timeout arms.
- **Reconcile after every delegation:** pull the subagent's assumptions, files changed, and open risks back into your main thread.
