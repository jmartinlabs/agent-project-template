# Agent project template
This repository contains a reusable development methodology, not an application.
Do not initialize a sample project here. In a derived project, replace this paragraph and
add its approved install, run and test commands after bootstrap.

- Validate template changes: `./scripts/validate-template`. Claude adapter: [guide](docs/CLAUDE_ADAPTER.md); agent behavioral evals: [guide](docs/AGENT_EVALS.md).
- Test the validator: `./scripts/test-validator`.
- Read [architecture](specs/guidelines/architecture.md), [UI](specs/guidelines/ui.md),
  [quality](specs/guidelines/quality.md), and [security](specs/guidelines/security.md).
- For any development request, read [adaptive workflows](specs/methodology/workflows.md), [epic orchestration](specs/methodology/epic-orchestration.md), [dynamic agent management](specs/methodology/dynamic-agents.md) and [model selection](specs/methodology/model-selection.md); use `$orchestrate` to propose Quick / Standard / Full plus an advisory model/reasoning recommendation, then confirm the workflow level before implementation. In supported clients `/plan` is a planning mode, not a Skill invocation.
- Adopt existing projects via [the copyable adoption prompt](ADOPT_EXISTING_PROJECT_PROMPT.md) and `$adopt-project`, preserving their code and prior decisions. Do not run `$init-project` on existing applications.
- Start or resume project initialization with `$init-project`; persist stage transitions
  in `specs/setup-progress.md`. See [document ownership](specs/README.md).
- Preserve existing work; stage only your own reviewed changes. Never commit secrets.
- Ask before material product/architecture decisions, destructive actions, security-sensitive
  changes, remote creation/publication, production deployment or visibility changes.
- Stop on conflicting approved requirements or missing permissions. Report blocked checks;
  do not mark a feature done while acceptance checks fail or remain unverified.
- Follow [explicit protected approvals](specs/methodology/approvals.md): `ok`, `dale`, `continue`, or generic go-ahead messages never approve protected actions. Request identifiable approval for each protected decision; never infer PR merge permission from QA/CI or development approval.
- In multi-epic work, only the coordinator updates specs/epic-board.md. Assign bounded agents dynamically using role contracts, the work packet template and real client capability; never invent running agents. Prepare independent tasks while specs await approval. Do not code unapproved specs or auto-merge PRs.
- Use the current isolated checkout. Do not create a worktree unless explicitly requested.
