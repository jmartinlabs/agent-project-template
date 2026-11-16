---
name: work-issue
description: Take authorized work from Issues and an optional GitHub Project inside its phase gate.
---

# /work-issue — Claude Code adapter

Read and follow the canonical Skill `.agents/skills/work-issue/SKILL.md`; the only addition
is the Claude note below. Arguments: `$ARGUMENTS`. Codex `$name` maps to `/name` here; a
slash command grants no approval, model change or delegation by itself.

`/work-issue opencode` names the queue, not a parallel worker: one Claude session works that
agent's eligible Issues until the queue is empty, using `scripts/work-issue` for the mechanical
steps only. Approvals still come from the issue workflow, and merge keeps its own gate.
