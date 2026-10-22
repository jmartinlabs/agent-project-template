# Dynamic agent management

How orchestrate decides **how many specialist tasks to delegate**, writes their work packets,
supervises them and closes them. Read with [epic orchestration](epic-orchestration.md),
[model selection](model-selection.md) and the [visual operating guide](../../docs/GUIA_VISUAL_ORQUESTACION.md).

## Roles are profiles, not permanent workers

Reusable profiles: [Functional](../../.agents/roles/functional.md), [Implementation](../../.agents/roles/implementation.md),
[QA/Review](../../.agents/roles/qa-review.md) and [Infrastructure/DevOps](../../.agents/roles/infrastructure.md).
They shape behavior but **do not register running agents** or cap delegation at four. The coordinator may
run several tasks with the same profile or write a narrow temporary role (for example, a database
investigation) under the same rules.

The coordinator is the only scheduler and the only writer of the shared board. Subagents do not
spawn further agents unless the coordinator explicitly allows it in a supported runtime.

## Selection steps

1. **Inventory ready work** from the trusted checkpoint, approvals, dependencies and test/code evidence. Do not rebuild the whole queue after every action.
2. **Check necessity.** Default to one executor for a bounded task; assign a complete deliverable, not micro-steps. Bring in a separate reviewer for independent QA when the candidate reaches its gate.
3. **Size the pool.** Start with one executor. Run work in parallel only when it is disjoint, ready and worth more than the coordination overhead. Respect real client limits and quota. Consequential scope and destructive actions still need explicit approval.
4. **Write a compact [work packet](../../templates/agent-work-packet.md)** (work-packet template): scope, objective, ownership and isolation, deliverable, acceptance checks, prohibited actions, stop/gate conditions and the **applicable rules** — the few policy rules this task needs, one line each with a source link. Delegates read their role and the packet, not every policy. Link other documents instead of copying them. A delegate that finds a needed rule missing stops and asks the coordinator.
5. **Start only if supported.** Confirm the client really offers subagents before claiming a worker exists. Otherwise run the same queue sequentially and never pretend a delegate ran. Chats the user opened manually are not attached workers; they contribute only through recorded checkpoints, branches or PRs.
6. **Supervise at milestones.** Review the candidate diff and test evidence at handoff or on a material blocker, not after every message. Prevent overlapping edits: concurrent writers need disjoint ownership and authorized isolated checkouts, otherwise serialize. Checkouts follow [the local worktree policy](approvals.md#local-worktrees); the packet records responsibilities, not new consent.
7. **Close or reassign** when a deliverable completes, blocks or becomes redundant. Require the SHA, real PASS/FAIL/UNRUN evidence, blockers and next safe action. Do not auto-create replacement workers.

## Resource discipline
- Measure verified outcomes, not agent or message counts. Do not invent per-agent token costs without real telemetry.
- Investigations need a discriminating probe. After two comparable attempts with no progress, checkpoint and escalate.
- On quota warnings, save safe state and prioritize. Never skip required tests, independent QA or approval gates to save tokens.

## Prioritization and approvals
- A blocked financial specification blocks **only its own implementation**; other specs, investigations and provisional QA can continue.
- Approval gates stay in force for financial/accounting choices, security/architecture changes, approved Full specs, destructive actions, PR merges and production deployments. Creating a delegate never bypasses them.
- The coordinator may suggest a profile and model tier per packet, without claiming an automatic model switch.
- Infrastructure work has its own queue; it does not starve functional work unless it is a documented hard prerequisite.

## Capability boundaries
This repository holds **instructions and templates**: no subagent registration, always-on scheduler or job queue. Check what the actual client (Codex, Claude Code or another) supports for delegation and isolation before using it. API runtimes configured separately do not describe what an interactive session can do. Nothing keeps running after the active session ends.

## Result contract
Each packet returns: packet ID; done/blocked status; changed and read files; commit/revision; real tests and results (passed/failed/unrun); open decisions, collisions or blockers; evidence; next independent action. The coordinator verifies, updates the board and decides on the next packet. No delegate self-approves, merges or edits the board.

## Example: two existing chats
1. Ask each chat (for example Financial and Deployment) for a checkpoint: scope, branch/commit, decisions, tests, blockers. Keep unstaged changes.
2. Reconcile both in a new orchestrate session with a fresh scan of the repository.
3. Wind down those chats deliberately; the coordinator cannot message or close them.
4. With verified delegation, create fresh task-limited subagents as ready work requires; otherwise work sequentially.
5. The user still approves financial decisions, Full specs, merges and production deployment.

See the [illustrated migration steps](../../docs/GUIA_VISUAL_ORQUESTACION.md#7-migrar-dos-chats-existentes-a-un-coordinador).
