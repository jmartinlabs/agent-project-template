# Agent project template
This repository contains a reusable development methodology, not an application.
Do not initialize a sample project here. In a derived project, replace this paragraph and
add its approved install, run and test commands after bootstrap.

- Validate template changes: `./scripts/validate-template`. Claude adapter: [guide](docs/CLAUDE_ADAPTER.md); agent behavioral evals: [guide](docs/AGENT_EVALS.md).
- Test the validator: `./scripts/test-validator`.
- Load only applicable [architecture](specs/guidelines/architecture.md), [UI](specs/guidelines/ui.md),
  [quality](specs/guidelines/quality.md), and [security](specs/guidelines/security.md).
- For development use `$orchestrate` and [adaptive workflows](specs/methodology/workflows.md) to classify Quick / Standard / Full. Quick needs no additional confirmation only for a clearly authorized, reversible, low-risk change with no protected gate. Consultation/analysis never authorizes edits; read-only Plan mode never permits implementation. Standard / Full require confirmation unless already explicitly authorized for the same scope.
- Load instructions on demand: [epic orchestration](specs/methodology/epic-orchestration.md) for overlapping epics; [dynamic agent management](specs/methodology/dynamic-agents.md) and role contracts before any delegation; [model selection](specs/methodology/model-selection.md) when advice matters (normally Standard / Full). Read the routed Skill and relevant approval evidence before acting; do not preload every policy. `/plan` is a planning mode, not a Skill invocation.
- Project-specific restrictions take precedence over generic workflow shortcuts. Preserve explicit approvals and required independent QA. Default to one executor; justify additional delegation.
- Adopt existing projects via [the copyable adoption prompt](ADOPT_EXISTING_PROJECT_PROMPT.md) and `$adopt-project`, preserving their code and prior decisions. Do not run `$init-project` on existing applications.
- Start or resume project initialization with `$init-project`; persist stage transitions
  in `specs/setup-progress.md`. See [document ownership](specs/README.md).
- Preserve existing work; stage only your own reviewed changes. Never commit secrets.
- Ask before material product/architecture decisions, destructive actions, security-sensitive
  changes, remote creation/publication, production deployment or visibility changes.
- Stop on conflicting approved requirements or missing permissions. Report blocked checks;
  do not mark a feature done while acceptance checks fail or remain unverified.
- Protected actions need an explicit, identifiable approval per [approvals](specs/methodology/approvals.md); generic assent never counts, and QA/CI or development approval never implies merge.
- In multi-epic work, only the coordinator updates specs/epic-board.md. Assign bounded agents dynamically using role contracts, the work packet template and real client capability; never invent running agents. Prepare independent tasks while specs await approval. Do not code unapproved specs or auto-merge PRs.
- To consolidate and stop without continuing work, use [$handoff](.agents/skills/handoff/SKILL.md) (Claude Code: `/handoff`): checkpoint current state, request cancellation of controllable workers, and do not auto-resume. Never claim to stop unrelated sessions or discard uncommitted work.
- Prefer the current checkout; local worktrees need no individual approval when they meet the [worktree policy](specs/methodology/approvals.md#local-worktrees). Preserve existing work and stricter project restrictions.
