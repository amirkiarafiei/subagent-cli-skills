# Agentic Installation

You are an AI agent. Your user asked you to install Subagent CLI Skills. This file gives you the
facts you cannot work out yourself. Decide the rest on your own judgement.

## What these are

Each skill teaches you to hand a bounded task to a different vendor's CLI agent running headless,
and to send enough of your context with it that the other agent does not guess. One skill per CLI.

## Facts you need

Repository: `https://github.com/amirkiarafiei/subagent-cli-skills`
Raw base: `https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main`

Every skill is a folder holding exactly two files, one level deep:

    skills/<skill>/SKILL.md
    skills/<skill>/reference.md

The skills, and the command each one drives:

    antigravity-cli  agy         gemini-cli     gemini
    copilot-cli      copilot     qwen-code      qwen
    codex-cli        codex       kiro-cli       kiro-cli
    cursor-cli       agent       junie-cli      junie
    openhands-cli    openhands   opencode-cli   opencode
    claude-code      claude      mistral-vibe   vibe
    kimi-code        kimi        qoder-cli      qodercli
    hermes-agent     hermes      grok-cli       grok
    devin-cli        devin       pi-cli         pi
    oh-my-pi         omp         openclaw-cli   openclaw
    cline-cli        cline       kilocode-cli   kilo
    goose-cli        goose       deepagents-code  dcode

## Find out what is on the machine

Probe for the commands above with `command -v`. A skill is only worth installing if its command
exists. Two exceptions: skip the skill for yourself, because you would only be delegating to
yourself, and do not probe for `agent` — the name is too generic to prove that Cursor is installed.

## Explain it, then ask

Your user may not know what any of this changes. Explain it before you ask them to choose. Write in
plain, simple English: short sentences, common words, one idea per sentence. Do not say
"orchestrator", "headless", "delegation", "context window" or "handoff" to them.

Make sure they understand three things:

- You are the main agent. You stay in this conversation, and you keep the plan and the decisions.
- A subagent is a different AI tool already on their computer. You can send it one job. It does that
  job on its own and sends the result back to you.
- A skill is only instructions. Installing one does not run anything and does not cost anything. It
  teaches you how to use one of those tools when you need it.

Then tell them which tools you actually found, say which ones you would pick and why, and ask what
they want. Also ask whether the skills should work everywhere on their computer, or only in this
project. Keep it to a few sentences — they asked for an install, not a lecture.

Wait for their answer before you install anything. Use your own words throughout; there is no script
to copy here.

## Where the skills go

You should already know where you load skills from and what layout you expect, so use that. If you
are not sure, find out rather than guessing a path:

- read your own vendor's documentation,
- use your vendor's self-configuration skill if one ships with you,
- search the web for your agent's skills directory,
- or read `install.sh` in this repository, which lists the directory for every supported agent.

Never invent a path. A skill written to the wrong directory is silently ignored, and the user will
think the install worked.

## Install

    mkdir -p <dir>/<skill>
    curl -fsSL <raw-base>/skills/<skill>/SKILL.md     -o <dir>/<skill>/SKILL.md
    curl -fsSL <raw-base>/skills/<skill>/reference.md -o <dir>/<skill>/reference.md

If the machine cannot reach `raw.githubusercontent.com`, clone the repository and copy the folders
instead. `install.sh` exists for humans and needs a terminal you cannot drive, so do not run it.

## Check what you got

A download can succeed and still write the wrong thing: a 404 or a captive portal arrives with a
success status. Each file must be non-empty and begin with `---`. If it begins with `<!doctype` or
`<html`, the download failed. Delete it, retry once, and report the failure rather than reporting
success.

## Finish

Tell the user which skills went where, and that most agents need a restart before new skills load.
Then read the `SKILL.md` you installed before your first delegation — it carries the rest.

Stay inside the skills directory. Do not touch their agent config, shell profile, or unrelated
files, and ask before writing outside their home directory.
