# Dynamic agent management (v2.4.1)

This document defines how `$orchestrate` chooses **how many specialist tasks to delegate**, creates work packets, supervises them, and closes them. Read with [epic orchestration](epic-orchestration.md), [model selection](model-selection.md) and the [visual operating guide](../../docs/GUIA_VISUAL_ORQUESTACION.md).

## Roles are profiles, not permanent workers

Available reusable task profiles: [Functional](../../.agents/roles/functional.md), [Implementation](../../.agents/roles/implementation.md), [QA/Review](../../.agents/roles/qa-review.md) and [Infrastructure/DevOps](../../.agents/roles/infrastructure.md). They constrain behavior, but **do not register four running agents** or limit delegation to four instances. The coordinator may assign multiple independent tasks of the same profile or write a temporary, narrowly specified task role (for example, database investigation) using the same rules.

The coordinator is the only scheduler and shared board writer. Subagents must not spawn further agents unless explicitly authorized by the coordinator in a supported runtime; avoid recursive uncontrolled delegation.

## Dynamic selection algorithm

1. **Inventory relevant ready work** from trusted checkpoint, approvals, dependencies and test/code evidence; avoid rebuilding full queue after every action.
2. **Check necessity**: Default to one executor for bounded tasks; assign a complete deliverable, not every microstep. Bring a separate reviewer for independent QA when the candidate reaches its gate.
3. **Size the pool**: Start with one executor; parallelize only disjoint ready work with a clear benefit above context/coordination overhead. Follow actual client limits and quotas. This is a heuristic, not a fixed Codex cap; consequential scope or destructive actions still need explicit approval.
4. **Pick a role dynamically** and issue a compact [work packet](../../templates/agent-work-packet.md): approved scope, objective, ownership and isolation, expected deliverable, acceptance checks, prohibited actions, stop/gate conditions and the **applicable rules**: the few policy rules this task needs, one line each with a source link. Delegates read their role and the packet, not every policy; link other source docs rather than copying large contexts. A delegate that finds a needed rule missing stops and asks the coordinator.
5. **Start only if supported**: Check actual available subagent tools/capabilities in this Codex session before claiming a worker exists. If unavailable, use sequential execution following the same ready queue; never pretend the delegate ran. External chats opened manually are **not** attached workers. They can only contribute via recorded checkpoints/branches/PRs.
6. **Supervise by milestone/exception**: Check candidate diff and test evidence at handoff or material blocker; do not reconcile after every worker message. Prevent duplicates/overlapping edits. Concurrent code writers need disjoint ownership and authorized isolated checkouts, otherwise serialize. Apply [the local worktree policy](approvals.md#local-worktrees) to checkout creation and preservation; the packet records responsibilities and existing authorization, not new consent.
7. **Close or reassign** when a deliverable completes, blocks or becomes redundant. Require concise SHA, actual PASS/FAIL/UNRUN evidence, blockers and next safe action. Do not automatically create replacement workers or claim background operation.

## Resource discipline
- Measure observable completed work and verified outcomes, not agent/message counts. Do not invent per-agent token costs without real runtime telemetry.
- Investigations need a discriminating probe; after two comparable no-progress attempts, checkpoint and escalate rather than repeat automatically.
- On quota warnings, preserve safe state and prioritize; never skip required tests, independent QA or approval gates to save tokens.

## Prioritization and approvals

- A blocked financial specification blocks **only its own implementation**; independent specifications, investigation and provisional QA can progress.
- Explicit approval gates remain for financial/accounting choices, security/architecture changes, approved Full specs, destructive actions, PR merges and production deployments. Merely creating a delegate cannot bypass them.
- A coordinator can choose specialization and model capability guidance per work packet without automatically switching models or claiming model-specific parallelism.
- Infrastructure work has its own queue; a SQLite research task cannot starve functional preparation unless its result is a documented hard prerequisite.

## Capability boundaries

This repository contains **instructions and templates**, not executable subagent registration, an always-on scheduler or a CI-managed job queue. In Codex Desktop/Web, confirm the client actually offers delegation and isolation before using it. The [OpenAI Agents API multi-agent guide](https://developers.openai.com/api/docs/guides/agents-api/multi-agent) documents a separately configured API runtime; its default concurrency or tools **must not be assumed for a Codex UI session**. No background operation is promised after the active execution ends.

## Result contract for each work packet

Return: packet ID; completed/blocked status; changed and read files; commit/revision if applicable; real tests and results (passed/failed/unrun); unresolved decisions, file collisions or blockers; evidence links; next independent action. The coordinator reconciles the board and decides whether to launch a new packet. No delegate may self-approve decisions, merge PRs or change the board.

## Example: two ongoing MyFinanzas chats

1. Request checkpoint from Financial and Deployment chats (scope, branch/commit, decisions, tests, blockers); do not abandon unstaged changes.
2. Reconcile both checkpoints in a new `$orchestrate` active session, with a fresh authoritative scan of repo state.
3. Finish/migrate work in those chats deliberately; **do not pretend the coordinator can message or terminate the existing chats**.
4. With verified delegation, create fresh task-limited Financial, Infrastructure, Functional and QA subagents as ready work requires; otherwise execute sequentially.
5. User remains the approver for consequential financial decisions, Full specifications, merges and production deployment.

See the [illustrated migration steps](../../docs/GUIA_VISUAL_ORQUESTACION.md#7-migrar-dos-chats-existentes-a-un-coordinador) for a graphical walkthrough.
