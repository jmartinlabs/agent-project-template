# Project instructions
Project description: placeholder, replaced by `/agentic:init-project` or `/agentic:adopt-project`.

## Start
- Start with the agentic plugin's `verify-project` skill.
- Coordinator only: before each dispatch, load the plugin's `orchestrate` skill and apply
  its step 4 (active configuration in `.agents/harnesses/`).
- STOP rule: if the agentic plugin skills are unavailable, or plugin files cannot be read
  (permission denied), stop and direct the user to the plugin Quick start linked in README.md
  for user-level installation or permission setup.

## Protected actions
Require explicit, identifiable user approval: merge of any PR, releases, production
deployment, destructive actions, permission or visibility changes, security-sensitive
decisions. Follow the plugin's approvals policy; it is not restated here.

## Project rules
- Local rules live in `specs/project-rules.md`; context in `specs/project.md` and `specs/guidelines/`.
- The inherited `.github/workflows/template-ci.yml` belongs to the template; the owner decides this project's licence.
- This file does not define the common contract; the plugin does.
