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
2. **Delegate when it pays.** Prefer a specialist for substantial, autonomous, bounded work — specification drafting, approved implementation, investigations and QA — when the client supports it. Reserve direct coordinator execution for small corrections, coordination, user decisions and operations where delegation costs more than it saves. Assign a complete deliverable, not micro-steps. Bring in a separate reviewer for independent QA when the candidate reaches its gate.
3. **Size the pool.** Keep **one executor per task**, not one executor per session. Start additional concurrent tasks only when they are disjoint, ready and worth more than the coordination overhead. Never create agents or work to fill a pool. Respect real client limits and quota. Consequential scope and destructive actions still need explicit approval.
4. **Write a compact [work packet](../../templates/agent-work-packet.md)** (work-packet template): scope, objective, ownership and isolation, deliverable, acceptance checks, prohibited actions, stop/gate conditions and the **applicable rules** — the few policy rules this task needs, one line each with a source link. Delegates read their role and the packet, not every policy. Link other documents instead of copying them. A delegate that finds a needed rule missing stops and asks the coordinator.
5. **Start only if supported.** Confirm the client really offers subagents before claiming a worker exists. Otherwise run the same queue sequentially and never pretend a delegate ran. Chats the user opened manually are not attached workers; they contribute only through recorded checkpoints, branches or PRs.
6. **Supervise at milestones.** Review the candidate diff and test evidence at handoff or on a material blocker, not after every message. Prevent overlapping edits: concurrent writers need disjoint ownership and authorized isolated checkouts, otherwise serialize. Checkouts follow [the local worktree policy](approvals.md#local-worktrees); the packet records responsibilities, not new consent.
7. **Close or reassign** when a deliverable completes, blocks or becomes redundant. Require the SHA, real PASS/FAIL/UNRUN evidence, blockers and next safe action. Do not auto-create replacement workers.

## Delegation preference

Delegate substantial, autonomous and bounded work whenever the active client supports it and the
benefit exceeds the coordination cost: specification drafting, approved implementation, bounded
investigations and QA. Prefer **background** execution when it is verifiably supported and the
coordinator can advance independent authorized work or does not need the result to continue; use
**foreground** when the next step depends on the result; reserve **direct** coordinator execution
for small corrections, coordination, user decisions and operations where delegation does not pay.

Keep **one executor per task**. Several tasks may run concurrently only with real independence,
disjoint ownership and authorized isolation. Never create artificial agents, duplicate reviewers
or work merely to fill a pool.

## Execution mode: direct, foreground, background

Choose the execution mode per task, before dispatch, with the lowest cost that still delivers the
required outcome. Do not create a delegate for a trivial task, and do not defer work in background
when its result is needed to continue.

- **Direct (coordinator).** Small corrections, low-cost operations, coordination, product decisions
  that need immediate user interaction, consolidation, supervision and brief verifications where
  delegation costs more than it saves.
- **Foreground subagent.** The coordinator needs the result immediately, the task is short enough
  for reasonable synchronous delegation, or dependencies prevent useful work until it returns.
- **Background subagent.** Substantial specification creation or review, autonomous implementation,
  bounded investigations and audits, independent QA once a verifiable candidate exists, and other
  delimited work that needs no continuous supervision. Prefer this mode when support is verified
  and the coordinator can advance independent authorized work or does not need the result to
  continue.

Background requires **verified client support** for non-blocking subagents in the active client (for
example a `background` option or an equivalent asynchronous task API) and a benefit that justifies
its cost. Without that support, use direct or foreground execution and say so; never simulate or
assume background work. Releasing the coordinator's turn to a background subagent does not finish
or end the subagent's runtime: the task is still running until it reports or fails. Closing the
client or the runtime may stop it. Promise no background persistence after that close unless the
specific client verifies it.

Parallelism is allowed only for authorized, independent tasks with disjoint ownership and real
isolation. Keep one executor per task; add concurrent tasks only when independence and value exceed
the coordination cost. No universal agent count applies: respect the verified client limit and the
quota gate.

At the start of each substantial task, state briefly: task and identifier; who executes (coordinator
or subagent profile); mode (direct, foreground or background); isolation (checkout or worktree when
applicable); and whether the coordinator stays available. Add no extra report and no repeated status
messages. Never claim a subagent, a background mode or isolation that was not actually verified.

## Quota and dispatch gate

The quota gate has a single canonical definition in
[model selection](model-selection.md#quota-and-dispatch-gate); this document does not restate its
thresholds. Apply it before dispatching any new task or subagent, **including QA**. A quota
warning is not approval and never waives QA or any other gate.

## Dispatch decision and ownership transfer

Before substantial autonomous bounded work, record a short decision in the current summary:
delegate with the expected benefit, or execute directly for a concrete reason — capability,
isolation, quota, indivisible context or coordination cost. No universal threshold in minutes or
files applies. Reevaluate when the scope grows, criteria or modules are added, or correction
cycles change the economics. Never fabricate parallel work.

Contract loading by actor: the coordinator loads orchestrate and the packet rules; the executor
loads its role and the phase Skill before working; QA loads its role and the verification rules
before reviewing. Each actor reads them once; after compaction it reloads only what changed or is
needed, keeping access to the canonical approvals. Packet excerpts never replace the Skill the
responsible actor must load.

An active worker's files are closed to parent writes. Before transferring ownership: obtain an
end/stop acknowledgement and a checkpoint (candidate, dirty files, checks, next action), and name
the new owner explicitly. A timeout or an interruption request is not an acknowledgement. Prefer
returning bounded corrections to the same worker while its context is still useful.

## Resource discipline
### Preparation and blocking operations
Before dispatch, perform a scope-sized preflight: checkout/revision and pending changes,
write ownership/access, required runtimes/dependencies, platform and test prerequisites.
Documentation work does not require provisioning an application or browser. Reuse a
valid prepared environment; repeat affected checks after checkout, lockfile, platform
or permission changes. Access checks do not grant authorization or predict every sandbox
restriction. Never broaden permissions or bypass client trust to make preflight pass.

Assign an operation owner for steps likely to need permissions (such as branch creation
or browser startup), plus a permitted notification route. Before requesting a potentially
suspending escalation, the worker notifies the coordinator of the operation, reason,
owner and next independent action. A suspended worker may be unable to notify afterward.
Advance notice is not another user approval gate: preserve native approval and protected
gates. Without a notification route, agree on manual relay or coordinator execution
before that operation. Report unexpected denials at the next controllable boundary;
pause only affected work. Never race another executor on the same resource.

### Context and supervision
Use fresh bounded context by default when supported. Supply objective, approval source,
relevant decisions, ownership, applicable rules and checks; link canonical sources.
Inherit full history only for a concrete dependency that cannot be supplied compactly,
recording the reason. Disclose runtime limitations; never omit safety rules to save tokens.
The coordinator also resumes from the current summary and relevant deltas at delivery
boundaries, rather than preloading completed deliveries. Do not force compaction or
create another chat automatically; retain access to canonical decisions and approvals.

Coordinate by outcome, blocker or decision, not repeated status reminders. Prefer bounded
runtime completion/event waits within client limits. A timeout without new evidence is
not a reason to reread unchanged files or wake a worker. Space CI queries progressively
while status is unchanged; reset after a meaningful transition or failure. During waits,
advance independent authorized work; return pending state only when no independent authorized
work is ready. Do not add a polling agent
or service, promise monitoring between turns, or delay attention to new user input.

Use focal checks during development and complete required verification for each stable
candidate at its gate. Evidence identifies commit plus dirty/untracked changes, command,
environment and result. After a delta, repeat affected checks; full verification remains
required for uncertain impact, mandatory gates or financial/security risk. QA independently
inspects the candidate and evidence, runs checks that resolve risks and records reasons
for repeats; it does not merely accept the author's summary. Consolidate findings into
a bounded correction packet, then review the delta.

## Supervision, stop and critical technical review

### Checkpoints and triggers
Agree checkpoints and measurable triggers per packet, not generalized probing. For long tasks with
exposed observable state, about five minutes is an adjustable reference; inspect the bounded diff,
number of files, own commands and processes, tests, useful progress, elapsed time and real cost only
when available. Without observable state, bound duration and scope and require a recorded return;
never claim live monitoring. Use bounded event waits between checkpoints.

### Trigger classes
Four classes apply: change radius; silence or repetition; prohibited risk; cost without a useful
artifact. A doubling of the expected files or time, or two attempts without new information, are
diagnostic examples adjusted to the packet, never permission to write outside scope. Any unapproved
out-of-scope output requires a stop and clarification. A prohibited or unsafe operation requires an
immediate stop with no threshold and containment. Start diagnosis with observable focal checks
unless the baseline checks are already necessary; the required final suite stays mandatory.

### Stopping and recovery
Stop only your own tasks and processes, with the supported controls. Preserve a snapshot of the
packet, requested/observed route, candidate, dirty files, logs, trigger and controlled resources.
Inspect and preserve previous or third-party changes before a selective, reversible recovery of the
attributable edits; never global cleanup, reset, or killing processes by port or name. Obtain an
acknowledgement before transferring ownership. Record the trigger and action, observed fact versus
suspected cause, reviewer and resumption condition in the existing Issue. Resume with a reduced
packet, a falsifiable hypothesis and every original gate.

### Critical technical review
Critical technical review is a capability: an independent executor or context; a different model is
not required for independence. Prefer a verified adequate route when one is designated. Record
requested versus observed identity: a mismatch means the designated route failed; missing metadata
means identity unverified, not proof of failure. An alternative competent reviewer in the same client
or an explicit manual handoff is valid; never launch another client automatically, except the
standing authorization below. Without a
reviewer, continue only small, reversible, authorized, objectively checkable work and record the
limitation; block material or unsafe work and required independent QA. Silence is never approval.

#### Standing authorization: Codex CLI as read-only external reviewer
This template grants a permanent, bounded exception to a **Claude Code coordinator only**: it may
use the local Codex CLI as an additional, **read-only** reviewer when justified (a financial,
security, persistence or data-integrity risk, an explicit owner request, or an Issue that
expressly asks for it), without asking each time. It is the only automatic client launch allowed.
It is not a reviewer slot, not independent QA and not an approval; no other client acquires it.
Procedure: [codex-review](../../.agents/skills/codex-review/SKILL.md).

- Scope: `codex review` or `codex exec`, both forced to `sandbox_mode=read-only` and
  `approval_policy=never` and checked against the CLI header; never edits, commits, PRs, `Status`
  moves or merges. No new hooks, plugins or dependencies, and the user's Codex configuration,
  model and effort are left as they are.
- The [quota gate](model-selection.md#quota-and-dispatch-gate) applies unchanged; this
  authorization is general and does not replace a task-specific one when the gate requires it.
- Independent QA, ownership, approvals and merge gates are unchanged. Findings are evidence to
  verify against the code, never a verdict.

## External clients
Manual OpenCode allocation, workers in other clients (Agent Relay, Hermes, external chats) and the
two-chats example live in [dynamic agents — external clients](dynamic-agents-external-clients.md).
Load it only when such a client is involved. Every gate in this document still applies to them:
authorization, quota, ownership, independent QA and the result contract.

## Delivery evidence at closure

Closure adds one short record to that current summary, not a new report per delivery. It states:

- **Scope conformance:** whether the delivered change stayed inside the authorized scope, with any
  observed deviation; out-of-scope work is disclosed, never hidden.
- **Verification:** each acceptance check as PASS / FAIL / UNRUN, who ran it, and its reproducible
  evidence (command, environment and candidate revision when applicable). Reuse valid existing
  evidence; repeat a check only for a concrete reason such as a changed delta, uncertain impact or a
  mandatory gate. A reported but unverified result stays distinct from PASS and from FAIL.
- **Defects and resolution:** defects found by review or CI, the correction, the check that confirmed
  it and any pending regression. "Fixed to good quality" without that evidence is not a resolution.
- **Provenance:** distinguish the author's reported result, an independent check actually performed,
  a verified observation and a cause that remains a hypothesis. Restating the author's report never
  turns it into independent QA.
- **Executor identity:** record the client and model actually used only with the identity evidence
  defined in [model selection](model-selection.md), such as attributable runtime metadata or local
  records. A requested model, a packet label or an agent's self-declaration is not verified identity;
  without that evidence, record identity as unverified and keep the result attached to the
  task/client, without inventing a model.
- **No causal or reliability inference:** identifying the executor does not show that it caused a
  failure or a success, and one delivery never proves its general reliability. Derive no rankings,
  scores or automatic model changes from it.

Keep the record brief and proportional: use the existing summary, link evidence instead of copying it,
and avoid new files, repeated tests or history queries without a concrete reason. The same record
serves Codex and Claude Code. Fixture or text checks do not prove that a real closure was complete;
independent QA still reviews it.

## Measurement discipline
- Measure verified outcomes, not agent or message counts. Do not invent per-agent token costs without real telemetry.
- Investigations need a discriminating probe. After two comparable attempts with no progress, checkpoint and escalate.
- On quota warnings, save safe state and prioritize. Never skip required tests, independent QA or approval gates to save tokens.

## Prioritization and approvals
- A blocked financial specification blocks **only its own implementation**; other specs, investigations and provisional QA can continue.
- Approval gates stay in force for financial/accounting choices, security/architecture changes, approved Full specs, destructive actions, PR merges and production deployments. Creating a delegate never bypasses them.
- The coordinator may suggest a profile and model tier per packet, without claiming an automatic model switch.
- Infrastructure work has its own queue; it does not starve functional work unless it is a documented hard prerequisite.

## Capability boundaries
This repository holds **instructions and templates**: it provides no universal agent registry,
always-on scheduler or job queue. No universal agent count is claimed. The repository-local native
agent registrations are the optional OpenCode adapters (`review`, `functional`, `implementation`
and `infrastructure`) installed by the [OpenCode adapter](../../docs/OPENCODE_ADAPTER.md). `review`
is a read-only audit surface; the specialized adapters use OpenCode's default tools under their
role and packet contracts. They are not launchers, schedulers or controllers for external OpenCode
sessions. The `review` adapter (agent, plugin and wrapper) may be removed as a unit; specialized adapters are independently optional.
Check what the actual client (Codex, Claude Code or another) supports for delegation, non-blocking
execution and isolation before using it, per execution. API runtimes configured separately do not
describe what an interactive session can do. Releasing a coordinator turn does not end a running
subagent's runtime, but nothing keeps running after the active session or client closes.

## Result contract
Each packet returns: packet ID; done/blocked status; changed and read files; commit/revision; real tests and results (passed/failed/unrun); open decisions, collisions or blockers; evidence; next independent action. The coordinator verifies, updates the board and decides on the next packet. No delegate self-approves, merges or edits the board.
