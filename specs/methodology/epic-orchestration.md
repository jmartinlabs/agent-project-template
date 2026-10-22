# Epic orchestration: lightweight delivery without bypassing approvals (v2.4.1)

This policy applies to complex **Full** work and to Standard work with several independent workstreams. It extends [adaptive workflows](workflows.md) rather than replacing `$roadmap`, `$spec` or `$dev`. Quick remains single-stream by default.

## Persistent board and single writer

Keep `specs/epic-board.md` only when multiple live epics or independent workstreams need scheduling; use existing progress/testplan for a single bounded feature. Reconcile the board at session start and major gates with approved spec, checkpoints, Git and tests. Mark unavailable evidence `unknown`/`unverified`, never infer approval.

The coordinator is the **only writer** of the shared board. Delegates return concise outcomes, SHA and test evidence. Update changed fields only when ownership, authorization, candidate, QA verdict, blocker or PR state materially changes; not on every intermediate worker message.

Each row has a unique feature ID and tracks stage, scope/dependencies, approval, assigned role, isolated branch/checkout (if applicable), blockers, evidence link, next action and last verification. A ready task is not the same as an approved spec. A PR opened is not a merge.

## Stage/gate rules

- `spec`: planned → drafting → awaiting-approval → approved. Drafts and brainstorming may be prepared autonomously, but **only the user approves functional/financial decisions and the final spec**. A prepared next epic remains draft until approved.
- `dev`: not-ready → ready → implementing → testing/review → verified. `dev` is ready only with a recorded **approved** spec, satisfied hard dependencies and authorization for its scope. If there is no approved spec, the implementation lane cannot start. QA may still draft test cases without altering production code.
- `QA`: planned → test-design → awaiting-implementation → verifying → passed/failed/blocked. Independent test design and investigation can overlap another feature's spec or dev. Never claim tests passed before execution against the actual candidate.
- `merge`: proposed PR → ready-for-user-review → user-approved → merged. Never auto-merge or push/create remote PR without required repository authorization. PR readiness requires current tests/review evidence; branch merge is a separate approval gate.

## Scheduler: reconcile at meaningful milestones

1. On resume, verify Git/PR/approval deltas since the last trusted checkpoint and read only the documents needed for the next gate. Reload full sources when stale, conflicting or needed for safety.
2. Identify gates and hard dependencies. Mark blocked only where there is a real dependency; cite the specific prerequisite and owner. Distinguish user decision needed from environment/technical blocker.
3. Recompute **ready** work only when prerequisites or gates change: (a) approved/authorized implementation, (b) candidate QA, (c) independent spec drafting up to approval, (d) bounded investigation with an explicit hypothesis and exit condition.
4. Prefer user priorities and critical-path work, but do not starve next-feature preparation because an unrelated investigation is running. When any work is blocked, promptly pick the next independent ready item.
5. Prefer one complete development packet per feature and a required independent QA handoff when a candidate exists. Parallelize only distinct ready work with benefits greater than coordination/context cost. For concurrent edits use authorized isolated checkouts and disjoint ownership, otherwise serialize.
6. At the approved-spec, completed-candidate, QA-verdict and PR/approval milestones, update only changed state and hand off a concise evidence summary. Approved spec plus dev authorization → dev; candidate → required independent QA; checks and QA green → PR for approval. Never re-plan or re-approve unchanged work.
7. End an active run with a concise board summary: completed, underway, waiting on user, blocked, newly ready, and exact next action. No claim of background processing between sessions; rescan on next invocation.

Use [dynamic agent management](dynamic-agents.md) to size useful delegation. **Default to one executor**, plus required independent QA/review at the appropriate handoff; add parallel specialists only if tasks are genuinely independent and benefit exceeds overhead. This is not a platform cap; retain sequential fallback and protected gates.

## Bounded technical investigations
Start with a falsifiable hypothesis, one discriminating probe and expected evidence. After two comparable attempts without new findings, preserve logs, candidate state and failing gates, and escalate to a new hypothesis or scope decision; do not repeat blindly. This never waives QA, regression checks or urgent safety containment.

## Independent specialist work packets

The coordinator gives each delegate: feature ID, role, source spec and approval state, concrete deliverables, read/write files, dependencies, prohibited actions, validation checks, and a result format (outcome, evidence, blockers, proposed next work). See [role contracts](../../.agents/roles/README.md) and the [work packet template](../../templates/agent-work-packet.md). Specialists cannot promote draft to approved, merge a PR or update the shared board themselves.

## Financial and security decisions

Never infer approval from a checked proposed option, chatbot silence, previous related approval, or a PR review. Require explicit user approval for changes to accounting semantics, financial calculations, migrations, security, published contracts, material scope, production changes and merges. Research, test planning and drafting that do not commit those decisions may continue.

## Worked example: MyFinanzas (illustrative only)

- E1.6 `spec=awaiting-approval`: Functional agent prepares concrete decision questions; **dev E1.6 is blocked**.
- E1.7 `spec=drafting`: Preparation agent analyzes requirements not dependent on E1.6, marks any dependent contract `pending`, and prepares brainstorming without approving anything.
- QA can independently map E1.6 draft acceptance checks to prospective tests, clearly labeling them provisional.
- SQLite investigation is a separate technical lane with a bounded objective; it blocks E1.6 only if a documented hard dependency exists.
- As soon as E1.6 spec is explicitly approved, the coordinator starts `$dev 06` (or its equivalent) within the approved scope, while the E1.7 draft may continue in parallel if write isolation is safe.

The sample is **not** a real status report for MyFinanzas. Always inspect its actual repository before populating the board.

## Illustrated guide

The [Spanish visual guide](../../docs/GUIA_VISUAL_ORQUESTACION.md) includes eight editable Mermaid diagrams of scheduling, delegation, approvals, write isolation and migration from existing chats.

## Resume and verification

Resuming a session: use AGENTS.md and the last verified checkpoint, reconcile relevant Git/approval/test deltas, and load full board/spec/roadmap only when necessary. Record blocked, failed, unrun and passed checks accurately. Template CI does not prove live Codex/Claude behavior or efficiency.
