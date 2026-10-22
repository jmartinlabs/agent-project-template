---
name: adopt-project
description: Adopt the shared agent workflow in an existing repository without overwriting existing decisions.
---

# Claude Code adapter for adopt-project

Read and follow the canonical workflow at `.agents/skills/adopt-project/SKILL.md` **from the repository root**. Read `AGENTS.md` and `specs/methodology/approvals.md` first, and follow any stricter project-local restrictions.

This is only a discovery adapter. It must not reinterpret approvals, import a second implementation, or claim that subagents/hooks are active. If the canonical skill is absent, stop and report the mismatch.
