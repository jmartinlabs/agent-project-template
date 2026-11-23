---
name: codex-review
description: Ask the local Codex CLI for a read-only external review of a candidate, without replacing independent QA.
---

# /codex-review — Claude Code adapter

Read and follow the canonical Skill `.agents/skills/codex-review/SKILL.md`; this wrapper adds no
rules. Arguments: `$ARGUMENTS`. A command grants no approval or model change by itself; the standing
authorization and its limits are in
[dynamic-agents.md](../../../specs/methodology/dynamic-agents.md#standing-authorization-codex-cli-as-read-only-external-reviewer)
and [approvals.md](../../../specs/methodology/approvals.md).
