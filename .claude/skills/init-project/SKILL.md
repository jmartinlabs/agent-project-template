---
name: init-project
description: Plan and resume staged initialization of a new project with explicit decisions.
---

# Claude Code adapter for init-project

Read and follow the canonical workflow at `.agents/skills/init-project/SKILL.md` **from the repository root**. Read `AGENTS.md` and `specs/methodology/approvals.md` first, and follow any stricter project-local restrictions.

This is only a discovery adapter. It must not reinterpret approvals, import a second implementation, or claim that subagents/hooks are active. If the canonical skill is absent, stop and report the mismatch.
