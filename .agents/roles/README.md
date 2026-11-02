# Epic orchestration specialist role contracts

These files are **reusable role profiles**, not registered or permanent agents. The coordinator can assign zero, one or several independent tasks using the same role; see [dynamic agent management](../../specs/methodology/dynamic-agents.md). Read them when constructing bounded subagent tasks. If delegation is unavailable, the coordinator performs the same roles sequentially.

OpenCode additionally registers one optional native `review` subagent that loads the QA/Review contract with read-only tools for independent code, specification, Git and PR/CI audit; see the [OpenCode adapter](../../docs/OPENCODE_ADAPTER.md). It is a client adapter, not a new role or an always-running worker.

- [Functional](functional.md): discovery, brainstorming and specs without self-approval
- [Implementation](implementation.md): approved-spec-only development
- [QA / Review](qa-review.md): independent acceptance and regression checks
- [Infrastructure / DevOps](infrastructure.md): Docker, CI, data environment and bounded deployment preparation

For each new instance the coordinator provides an [agent work packet](../../templates/agent-work-packet.md) with file ownership, applicable rules and expected evidence. The coordinator owns dependency scheduling and `specs/epic-board.md`. Parallel read-only preparation is safe; parallel writes need non-overlapping ownership and authorized isolation.
