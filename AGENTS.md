# Project instructions
Project description: placeholder, replaced by `/agentic:init-project` or `/agentic:adopt-project`.

## Start
- Start with `/agentic:verify-project`.
- STOP rule: if the agentic plugin skills are unavailable, or plugin files cannot be read
  (permission denied), stop and tell the user to install the plugin or add the read rule
  (the plugin prints it with `agentic-verify-project --print-rules`). Do not continue
  without the common methodology.

## Protected actions
Require explicit, identifiable user approval: merge of any PR, releases, production
deployment, destructive actions, permission or visibility changes, security-sensitive
decisions. Follow the plugin's approvals policy; it is not restated here.

## Project rules
- Local rules live in `specs/project-rules.md`; context in `specs/project.md` and `specs/guidelines/`.
- This file does not define the common contract; the plugin does.
