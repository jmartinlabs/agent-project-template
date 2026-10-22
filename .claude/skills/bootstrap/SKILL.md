---
name: bootstrap
description: Create or extend an approved walking skeleton without assuming a stack.
---

# /bootstrap — Claude Code adapter

**Canonical workflow:** `.agents/skills/bootstrap/SKILL.md`.
Read that exact file and follow its full instructions; do not substitute this
short wrapper for the approved contract. Read `AGENTS.md` and applicable
project-specific policies, especially `specs/methodology/approvals.md`.

Requested scope or arguments: `$ARGUMENTS`.

Translate **invocation syntax only**: Codex `$orchestrate`, `$spec`, `$dev`
and related names refer in Claude Code to `/orchestrate`, `/spec`, `/dev`,
and corresponding project Skills. Do not infer that a slash command changes
plan mode, selects models, launches agents, grants permissions, or executes
work by itself. Check the real runtime before delegating.

Never interpret `ok`, `dale`, or `continúa` as approval for a protected
operation. Follow the canonical stop conditions and return verified results.
