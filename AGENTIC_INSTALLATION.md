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
    oh-my-pi         omp

## What to work out

**Where to install.** You know where you load skills from and what layout you expect, so use that.
If you are unsure, `install.sh` in this repository lists the directory for every supported agent.
Ask the user whether they want the skills available everywhere or only in this project.

**Which skills.** A skill is only worth installing if its command exists, so probe with
`command -v`. Two exceptions: skip the skill for yourself, since you would only be delegating to
yourself, and do not probe for `agent` — the name is too generic to be evidence of Cursor.

**Anything else you cannot settle.** Ask the user, in your own words. Do not install before they
answer.

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
