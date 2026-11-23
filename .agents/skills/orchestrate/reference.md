# orchestrate — on-demand reference

Read the part you need when the [orchestrate core](SKILL.md) points here (delegating, choosing a runtime, closing a delivery, reporting status). This is policy, not optional advice: it is the rest of what the core summarizes, kept out of the core because the core is printed into every session by the `SessionStart` hook.

## 6. Delegation
Reserve direct execution for small corrections, coordination, user decisions and operations where delegation does not pay. Delegate a whole outcome with checks, ownership, applicable rules and stop conditions, and use fresh bounded context. Choose the execution mode adaptively — direct, foreground or background — background only with verified client support and real benefit. Announce task and ID, executor, mode, isolation and coordinator availability when substantial work starts. Add concurrent tasks only for independent work with disjoint ownership. Manual clients get identity, the copyable packet and the mandatory `HANDOFF → CODEX` return, as set out in [coordinator communication](../../../specs/methodology/coordinator-communication.md).

## 7. Runtime
Apply the route rules with the quota dispatch gate. Keep the current model when adequate. Releasing the turn for a background subagent does not end its runtime; closing the client or runtime may. Never invent worker lifecycle or telemetry. Supervise at outcomes, blockers and decisions with bounded event waits and progressively spaced CI queries; no repeated reads without new evidence.

## 10. Verify and hand off
At closure, the delivery-evidence record goes into the current summary: scope conformance and deviations, each check with its executor and reproducible evidence, and author report, independent verification, observed fact and unproven cause kept distinct. Name an executor model only with verified effective identity; never infer causality or general reliability from one delivery. Reuse existing evidence and create no extra report. Save a short checkpoint only at real handoffs with the SHA and next safe action. Other open chats are not subagents. Update one current summary with candidate, check/QA evidence, PR/merge state and next action; replace stale labels and link historical entries. After restoring a handoff, retire its temporary checkpoint only under [checkpoint retirement](../handoff/SKILL.md#next-session-and-checkpoint-retirement). Preserve dirty, unknown or other-task resources.

## Efficiency and bounded investigations
- Coordinate outcomes, not messages: one plan, one complete packet, one verification handoff, one concise result. Do not reread unchanged context or repeat equivalent tests without a reason.
- Before investigating a failure, state a falsifiable hypothesis, a discriminating probe and an exit condition. Two comparable attempts with no new evidence mean: checkpoint the blocker and ask for a new hypothesis or scope decision.
- Report token or quota costs only from real client telemetry. A quota warning never justifies skipping required QA, security tests or approvals.

## Context transfer
Native compaction remains native: no arbitrary context thresholds, forced compaction or automatic chat creation/restarts. The user opens the next chat manually with the verified handoff instructions.

## Communication and status
- Manual delegation, corrections and queries follow the [coordinator communication](../../../specs/methodology/coordinator-communication.md) contract: Task ID, functional name and session reference, never an invented ID. Corrections repeat the return instruction, not the packet.
- Each reply names the task and session, separates a received report from a verified result, and says whether the user must send anything. Update only the matching task.
- States are PENDIENTE, ENVIADO, RECIBIDO, VERIFICADO and BLOQUEADO; `DESCONOCIDO` only as an escape hatch. Never infer execution from a delivered prompt; never invent percentages.
- End with a 2–4 line status only when open work exists, from the current summary and events, with no read or write per message. A request for the full state is read-only: every open task with provenance, last result, recorded Git/PR data, blockers and next actions, plus what was not updated.
- A received handoff never authorizes merge approval, deployment or a scope expansion.
