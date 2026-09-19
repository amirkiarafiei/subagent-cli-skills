# Contributing to Subagent CLI Skills

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new skills

## Our Development Process

1. **Fork the repo** and create your branch from `main`.
2. **Copy the template.** Start every new skill from [`_skill_template/SKILL.md`](_skill_template/SKILL.md):
   `cp _skill_template/SKILL.md skills/<new-skill>/SKILL.md`. Copy the global half (sections 1-5)
   without any change, and write only the Vendor card. See `HOW_TO.md` for the full procedure.
3. **Update the installer**: If adding a new tool, update `install.sh` with the correct paths.
4. **Test your changes**: Ensure the `SKILL.md` and `reference.md` follow the Handoff Table format, and **verify every flag and model name against the installed binary** (`tool --help`, `tool models`)—not against vendor docs. Run the smoke test in `HOW_TO.md` before opening the PR.
5. **Submit a Pull Request**.

## Style Guide

- **Start from `_skill_template/SKILL.md`.** Do not write a skill from a blank file, and do not copy
  another skill and edit it — copy the template.
- **Do not edit the global half.** Sections 1 to 5 are identical in every skill. A change there
  belongs in the template and in all skills, in one pull request.
- **Keep the seven Vendor card headings and their order.** What goes under them is yours to write.
  If a tool has no answer for a heading, say so under it rather than deleting the heading.
- **Never use a symlink or an include.** The installer copies only `SKILL.md` and `reference.md`, so
  each skill folder must work on its own after it is copied. Repeating the shared text in every skill
  is intended.
- **Do not write model names into a skill.** Give the command that lists the models instead. Model
  names go stale faster than anything else in these files.
- Use structured placeholders (GOAL, DECISIONS, etc.) in prompt examples.
- Always include a `reference.md` for technical flags.

## License

By contributing, you agree that your contributions will be licensed under its MIT License.
