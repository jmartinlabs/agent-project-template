# Adopt the methodology in an existing project

This is the **copy-and-paste entry point for a repository that does not yet contain the Skills**. Open that existing project in Codex Desktop or Web, select Plan mode (or `/plan` where available), and paste the block below. Do not start by typing `$adopt-project`: a repository without the Skill will not discover it automatically.

## Copy this into Codex

```text
I want to adopt the Agent Project Template methodology in THIS existing repository.
Source: https://github.com/josemartin2000/agent-project-template
Adoption Skill: .agents/skills/adopt-project/SKILL.md
Direct source: https://raw.githubusercontent.com/josemartin2000/agent-project-template/main/.agents/skills/adopt-project/SKILL.md

Important: this repository may not have $adopt-project yet. First retrieve and READ the actual Skill from the source repository, using available GitHub tools or a temporary read-only checkout outside this project, and follow it as instructions for this task. Do not pretend the Skill is installed or recognized. If you cannot read it, stop and ask me to provide it.

Inspect existing code, AGENTS.md, Skills, architecture, documentation, specs, roadmap, CI, Git state and test commands. Keep all approved project decisions and working code.

Produce a file-by-file integration plan and identify conflicts. Ask for my explicit approval BEFORE modifying files. After I approve, use a separate Git branch if possible and integrate only the relevant methodology pieces: $orchestrate and Quick / Standard / Full support, with project-specific rules. Merge existing instructions; never overwrite them blindly.

This is NOT a new application. Do not recreate the project, run a new-project initialization, build another walking skeleton, manufacture a roadmap, or replace its working CI with the template's validation CI.

After integration run available project checks, review the diff, report any checks not run, and show me how to use $orchestrate for future work. Do not push, deploy, delete data or perform destructive operations without authorization.
```

## After adoption

The project should have its own `.agents/skills/orchestrate/SKILL.md` and relevant Skills. In a new Codex conversation, use `$orchestrate` (or explain the task in Plan mode, following project AGENTS.md). The new project's existing decisions take precedence where they are compatible with the methodology.

If Codex cannot access GitHub from its environment, provide the Skill content or a local checkout of the template; do not assume remote access is available. Copying a prompt does not automatically install a global Skill.
