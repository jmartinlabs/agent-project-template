# Agent project template
This repository contains a reusable development methodology, not an application.
Do not initialize a sample project here. In a derived project, replace this paragraph and
add its approved install, run and test commands after bootstrap.

Skill names: Codex uses `$name` (`$orchestrate`); Claude Code uses `/name` (`/orchestrate`).
Both run the same canonical Skill in `.agents/skills/`.

## Commands
- Validate template changes: `./scripts/validate-template`. Test the validator: `./scripts/test-validator`.
- Guides: [Claude adapter](docs/CLAUDE_ADAPTER.md), [agent behavioral evals](docs/AGENT_EVALS.md).

## How to work
- Use orchestrate and [adaptive workflows](specs/methodology/workflows.md) to classify work as Quick, Standard or Full.
- Quick proceeds without extra confirmation only if clearly requested, reversible, low risk and free of protected gates.
- Standard and Full need confirmation unless the same scope is already explicitly authorized.
- Consultation/analysis never authorizes edits. Read-only planning mode never permits implementation.
- Load documents on demand, not all at once:
  - applicable [architecture](specs/guidelines/architecture.md), [UI](specs/guidelines/ui.md),
    [quality](specs/guidelines/quality.md) and [security](specs/guidelines/security.md) guidelines;
  - [epic orchestration](specs/methodology/epic-orchestration.md) for overlapping epics;
  - [dynamic agent management](specs/methodology/dynamic-agents.md) and role contracts before delegating;
  - [model selection](specs/methodology/model-selection.md) when model advice matters.
- Project-specific restrictions take precedence over generic shortcuts.
- Default to one executor. Keep required independent QA.

## Approvals and safety
- Protected actions need an explicit, identifiable approval per [approvals](specs/methodology/approvals.md). Generic assent never counts; QA, CI or development approval never implies merge.
- Ask before material product or architecture decisions, destructive actions, security-sensitive changes, remote creation or publication, production deployment, or visibility changes.
- Stop on conflicting approved requirements or missing permissions.
- Do not mark work done while acceptance checks fail or are unverified. Report blocked checks.
- Preserve existing work; stage only your own reviewed changes. Never commit secrets.
- Prefer the current checkout. A local worktree that meets the [worktree policy](specs/methodology/approvals.md#local-worktrees) is ordinary work inside the authorized scope, not a protected action.

## Project lifecycle
- New project: start or resume with `init-project`; record stages in `specs/setup-progress.md`. See [document ownership](specs/README.md).
- Existing project: use [the adoption prompt](ADOPT_EXISTING_PROJECT_PROMPT.md) and `adopt-project`; keep its code and decisions. Never run `init-project` on it.
- Multi-epic work: only the coordinator updates `specs/epic-board.md`. Assign bounded agents with role contracts and the work packet, based on real client capability. Prepare independent work while specs await approval. Never code unapproved specs or auto-merge PRs.
- To stop and hand over: use [handoff](.agents/skills/handoff/SKILL.md). It checkpoints state, asks controllable workers to stop and never auto-resumes.
