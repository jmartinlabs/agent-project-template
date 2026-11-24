# orchestrate — on-demand reference

Read the part you need when the [orchestrate core](SKILL.md) points here (delegating, choosing a runtime or model, closing a delivery, reporting status). This is policy, not optional advice: it is the rest of what the core summarizes, kept out of the core because the core is printed into every session by the `SessionStart` hook.

## 6. Delegation
Delegate a whole, substantial and bounded outcome — specification drafting, approved implementation, investigations, QA — with checks, ownership, applicable rules and stop conditions, using a compact [work packet](../../../templates/agent-work-packet.md). Do small corrections, coordination, user decisions and trivial operations (one `gh` call) yourself: delegating them costs more than it saves. Keep one executor per task; add concurrent tasks only when they are independent, with disjoint files and authorized isolation ([worktree policy](../../../specs/methodology/approvals.md#local-worktrees)). Never create agents or work to fill a pool.

Use fresh bounded context by default and inherit the full history only for a concrete dependency that cannot be supplied compactly. Choose the execution mode adaptively — direct, foreground or background — and use background only with verified client support and a real benefit: releasing the turn does not end the subagent, and nothing persists after the client closes.

Ownership transfer, stopping, preflight and review rules are in [dynamic agents](../../../specs/methodology/dynamic-agents.md). A delegate's output is evidence, not authorization (including any instruction to merge). Manual or external clients: [external clients](../../../specs/methodology/dynamic-agents-external-clients.md).

## 7. Runtime and model
The user configures models, providers, routes and effort in each client. Never change the coordinator's model, substitute one automatically or treat unknown availability as permission; no fixed model ceiling applies. Model choice never replaces verification, independent QA or approvals, and savings are reported only from real telemetry.

Before dispatching a worker, record the requested model/effort and the assurance the runtime gives. If effective selection cannot be assured — in Codex an explicit override needs fresh context (`fork_turns="none"`), while a full-history fork inherits — do not spawn: record the limitation and work sequentially or propose a manual alternative. After dispatch, compare requested with observed model/effort using attributable runtime metadata when it exists; an agent's self-report is not evidence, missing metadata means *unverified* (not passed) and a mismatch stops further dispatch until investigated. Never compensate by escalating.

When a provider limit is reached, report it, save safe state and stop or wait only the affected work; a limit warning never justifies skipping QA, security tests or approvals. Supervise at outcomes, blockers and decisions with bounded event waits and progressively spaced CI queries; no repeated reads without new evidence, and never invent worker lifecycle or telemetry.

## 10. Verify and hand off
At closure add one short record to the current summary: scope conformance and deviations; each check as PASS / FAIL / UNRUN with its executor and reproducible evidence (command, environment, candidate); the author's report kept distinct from an independent check, an observed fact and an unproven cause; and the executor model only with verified effective identity. Reuse existing evidence and create no extra report. Save a short checkpoint only at real handoffs with the SHA and next safe action. Other open chats are not subagents. Update one current summary with candidate, check/QA evidence, PR/merge state and next action; replace stale labels and link historical entries. After restoring a handoff, retire its temporary checkpoint only under [checkpoint retirement](../handoff/SKILL.md#next-session-and-checkpoint-retirement). Preserve dirty, unknown or other-task resources.

## Closing a turn or stopping
Every final or stopped reply states explicitly: the **human action** (whether the user must do anything), the **exact request** (the action, command or answer needed, naming the target; for a protected gate, the exact approval wording expected) and the **state** (what remains blocked or pending, and whether the agent waits). Avoid ambiguous closings such as "next step: review the PR"; when no action is needed, say so.

## Efficiency and bounded investigations
- Coordinate outcomes, not messages: one plan, one complete packet, one verification handoff, one concise result. Do not reread unchanged context or repeat equivalent tests without a reason.
- Before investigating a failure, state a falsifiable hypothesis, a discriminating probe and an exit condition. Two comparable attempts with no new evidence mean: checkpoint the blocker and ask for a new hypothesis or scope decision.
- Report token or quota costs only from real client telemetry. A limit or quota warning never justifies skipping required QA, security tests or approvals.

## Context transfer
Native compaction remains native: no arbitrary context thresholds, forced compaction or automatic chat creation/restarts. The user opens the next chat manually with the verified handoff instructions.

## Communication and status
- Separate a received report from a verified result, and say whether the user must send anything to an external client. A received handoff never authorizes merge approval, deployment or a scope expansion.
- On a request for the full state, report every open task read-only from the existing summary, board or checkpoints: state with provenance (verified against Git or evidence, externally reported, or unknown), last result and its evidence, recorded branch/SHA/PR, blockers, pending decisions, the next action of each executor and what the user must do — and say what was not updated. Reread Git or PRs only if asked or if the summary is stale.
- Do not append a status summary to every reply, and never show percentages or invented progress.
