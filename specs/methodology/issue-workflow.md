# Issue workflow

The portable protocol for tracking authorized work in Issues with an **optional** GitHub
Project. It extends [adaptive workflows](workflows.md) and [epic orchestration](epic-orchestration.md);
the `$work-issue` Skill is its procedure and `scripts/work-issue` is its GitHub adapter.
GitHub is not a logical requirement: another tracker implements the same states, owners and
gates instead of inventing a second state engine.

## Two entry paths

- **Project start → epics → SPEC → Issues → PR.** Initialization analyses scope, proposes
  epics, prepares the planning tickets needed to write or review each SPEC and, once a SPEC is
  approved, generates the executable Issues derived from it. Creating a ticket or an Issue
  never authorizes its execution. Small projects may skip formal epics or SPECs when the
  decision is justified and recorded.
- **Direct Issue → PR (or Issue → SPEC → PR).** Errors, CI, infrastructure, maintenance and
  bounded changes are registered as one Issue with scope and acceptance checks; uncertainty
  first needs analysis, a contractual or complex change needs an approved SPEC. Reuse the same
  Issue as the follow-up thread instead of duplicating tickets. A trivial correction needs no
  SPEC.

## Single source of operational state

- **With a Project, the Project `Status` is the only phase gate and the only operational
  queue.** It replaces `specs/epic-board.md`; the board remains only for projects without an
  external tracker. `templates/progress.md` keeps per-task evidence and progress, never a
  competing status list.
- **Without a Project, the manual protocol below applies**: phase and scope are authorized by
  an identifiable human instruction recorded in the Issue, and the reservation, delivery and
  acceptance are recorded there. No status is invented, no queue is simulated and no
  automation collects work.
- A Project that exists but cannot be read or written is a **blocker**, not a fallback: do not
  present unreadable state as an empty backlog and do not silently switch to the manual
  protocol. Offer read-only work and ask for the missing access.
- `phase:analysis` / `phase:implementation` labels are informative metadata only. No label,
  assignee or agent comment authorizes a phase.

## The 12 statuses

Twelve statuses, exact names and owners. A Project configured with this model uses these
options; the harness never creates or edits Project fields.

| # | Status | Who acts | Meaning |
| --- | --- | --- | --- |
| 1 | `Backlog` | User | Registered, not authorized to start. |
| 2 | `Ready Analysis` | Agent (pick up) | Only investigation and a proposal are authorized. |
| 3 | `Analysis In Progress` | Agent | Analyses and publishes findings; no implementation. |
| 4 | `Analysis In Review` | User | Accepts, rejects, or authorizes the next phase. |
| 5 | `Ready Specification` | Agent (pick up) | Only preparing or adjusting a SPEC is authorized. |
| 6 | `Specification In Progress` | Agent | Writes requirements and acceptance checks; documentation PR only. |
| 7 | `Specification In Review` | User | Approves the SPEC or returns it for correction. |
| 8 | `Ready Development` | Agent (pick up) | Only implementation of the authorized scope. |
| 9 | `Development In Progress` | Agent | Implements, tests and opens a PR; no merge or deploy. |
| 10 | `Development In Review` | User | Reviews the diff, checks and QA; decides corrections and integration. |
| 11 | `Blocked` | Agent records; user or owner unblocks | Pending dependency or decision. |
| 12 | `Done` | User | Scope completed and accepted. |

## Ownership of transitions

- **User:** moves work into `Backlog`, into each `Ready {Phase}` after authorizing **that
  phase**, attends every `{Phase} In Review`, rejects to the same phase or authorizes the next
  one, and accepts `Done`. Approving an analysis never authorizes specification; approving a
  SPEC never authorizes development; a merge is not acceptance.
- **Agent:** takes only work already in a `Ready {Phase}`, reserves it, moves it to that
  phase's `In Progress`, works, publishes evidence and delivers into `{Phase} In Review`. It
  may declare `Blocked` from its own `{Phase} In Progress`.
- **Rejected review:** the user records the observations and returns the Issue to the same
  phase's `In Progress`. The agent works only on the requested corrections; a new
  authorization is neither created nor implied.
- **Blocked:** before changing the Status, publish a comment with `Previous Status: <exact
  value>`, reason, dependency or decision, owner of the unblocking action, exit condition and
  date. On resolution, record it and restore the previous Status only while that permission
  still holds; a pending review returns to review, never to agent work. If the authorization
  expired or changed, ask the user before moving.
- **Automated restoration is bounded:** the tool restores only an agent `{Phase} In Progress`
  recorded in its own latest block record, and only once. A human-owned review, `Ready*`,
  `Backlog` or `Done` status is restored by the human who owns it.
- Approval gates stay separate: phase authorization, SPEC approval, PR/merge approval and
  promotion to the main branch are different decisions.

## Manual protocol without a Project

When no tracker is configured, or the project deliberately works without one:

1. The Issue states the requested phase, scope, acceptance checks, dependencies and the
   **identifiable human authorization** for that phase (who, what, when). An agent comment is
   never that authorization.
2. The agent publishes a start comment (identity header, phase, scope) before substantive
   work: that comment plus the assignee is the **reservation**; announce it and re-read the
   Issue before writing.
3. Work stays inside the authorized phase; findings, blockers and questions are recorded in
   the Issue. Dependencies and ownership are checked exactly as with a Project.
4. Delivery is a report, a SPEC or a PR with evidence, plus an explicit request for review.
   The action then passes to the user.
5. `Blocked` keeps its `Previous Status`, reason, owner and exit condition in the Issue.
6. Acceptance and closure are human. Nothing is "Done" because work was delivered or merged.

The same protocol applies when a Project exists but the phase is authorized in the Issue: the
Status is then updated by the user, and the agent neither invents nor edits it. Do not rebuild
the protocol as a new state machine or as a second board.

## Taking one Issue

1. **Discover.** Read the Project or the identified Issue: body, recent comments, linked SPEC
   and PR, dependencies, assignee and real state. `work-issue` without arguments lists every
   Issue in the three `Ready` groups with a proposed distribution; `next --agent X` reduces it
   to that agent's queue.
2. **Verify.** Require the specific `Ready` status, identifiable human authorization,
   sufficient scope, ownership and no open dependency. An agent never creates permission by
   moving the Status itself.
3. **Recover context.** Read the whole history with pagination, the linked sources and the
   decision hierarchy (latest explicit user instruction, approved scope, real state). Publish
   a short receipt bound to a fingerprint; on material contradiction or unverifiable
   authorization, stop dependent work and report.
4. **Reserve.** Re-read the Status, confirm no other assignee or claim, publish the claim
   comment, assign and move to `{Phase} In Progress`. Re-read afterwards; a drifted Status
   retracts the writes. Reservation is best-effort (GitHub has no compare-and-set): one
   reservation at a time, never a lock service.
5. **Execute** the authorized phase with the Skill that owns it (`orchestrate`, `spec`, `dev`,
   `task`, `tweak`) and deliver the branch, PR and evidence. Never skip a gate because the
   work is "small"; never exceed the scope because the Tool allows it.
6. **Communicate** in the Issue, deliver into `{Phase} In Review`, and continue the session.
7. **Block** and restore as described above; **accept** only as the user.
8. **Resume** from Issue + SPEC + PR + handoff comments, without depending on a chat. Never
   take over an apparently abandoned Issue unilaterally.

## Agent routing

Routing uses simple labels `opencode`, `hermes`, `codex`. A namespaced `agent:X` or `to:X` is
accepted for the same catalogue and **fails closed** when X is unknown. At most one recognized
agent label; no agent label means any compatible agent. Two agent labels, an unknown agent or
insufficient capability mean report and wait. The label is routing, not authorization and not
a reservation, and it is distinct from the GitHub assignee.

## Session continuity

`@work-issue <agent>` is one session over that agent's eligible queue, not a single
reservation: it recomputes the queue, recovers context, reserves, executes, delivers into
review and returns to the queue until no eligible work remains or a real blocker appears. It
holds **one reservation at a time**, never re-claims a returned Issue as a second reservation,
and finishes with a short ledger. Nothing schedules this loop: **no cron, webhook, bot or
login hook**, and no queue survives the session — the Project is the queue. An agent that
cannot start another agent's session publishes the assignment and says that agent has not
started.

## Communication and document ownership

The Issue is the main thread: objective, tracking, owners, phases, questions, human decisions
and authorizations, dependencies, results and links. Every substantive agent comment starts
with a header declaring real identity, so a shared GitHub account is never mistaken for
authorization:

```text
Author: <agent>
Role: Coordinator | Executor | Reviewer
Phase: Analysis | Specification | Development
Type: Start | Context | Progress | Report | Block | Review | Handoff | Proposal
Executor: <when the publisher differs from the executor>
```

| Surface | Owns |
| --- | --- |
| Issue | Objective, tracking, owners, phases, questions, human decisions and authorizations, dependencies, results; links the SPEC and PR. |
| SPEC and versioned documents | Approved requirements, architecture, contracts, acceptance criteria and durable procedures. |
| PR | Proposed change, technical review, test/QA evidence and the merge decision. |
| Harness | Reusable agent protocol and Skills; changed through a PR in the template, not through an Issue comment. |
| Project | Operational status and priority view; it never replaces the Issue or the SPEC contract. |

Link sources instead of copying them. Debates and authorizations belong in the Issue; durable
rules belong in a SPEC or the harness. A chat decision that affects the work is summarized in
the Issue before acting on it. Never attribute a decision to a human without explicit
confirmation, and never rewrite historical comments to add an identity.

## PR ↔ Issue linkage

The Issue is the work frame and may hold several PRs. Every PR is linked so it appears in the
Issue's `Development` section, and **merging never closes the Issue**: closure follows the
user's `Done` decision.

1. Open the PR into the project's target branch (`feature/* → main`, or `feature/* → test →
   main` when the project requires it) with `Refs #N` in the body. `Closes`/`Fixes` keywords
   only act against the default branch, so they are unreliable for intermediate branches.
2. Link immediately after creation: `addCloseIssueReferences(issueId, [pullRequestId])` through
   `gh api graphql`; verify both directions (`closedByPullRequestsReferences` on the Issue,
   `closingIssuesReferences` on the PR).
3. **Guard after merge:** re-read the Issue after any merge; if it closed, reopen it and record
   the incident. An Issue closed by a merge is not acceptance. The harness documents this
   capability and guard; it installs no bot and moves no Status on merge.

## Tool adapter

```bash
scripts/work-issue --repo OWNER/NAME --project N inventory
scripts/work-issue --repo OWNER/NAME --project N next --agent hermes [--exclude 1,2]
scripts/work-issue --repo OWNER/NAME --project N take --issue N --agent hermes [--dry-run]
scripts/work-issue --repo OWNER/NAME --project N context --issue N --agent hermes \
  [--publish --summary-file path]
scripts/work-issue --repo OWNER/NAME --project N move --issue N --agent hermes \
  --to "Development In Review" --note "..."
scripts/work-issue --repo OWNER/NAME --project N move --issue N --agent hermes \
  --to Blocked --previous-status "Development In Progress" --note "Reason: ... Exit: ..."
scripts/work-issue --repo OWNER/NAME --project N move --issue N --agent hermes --restore
```

Configuration is explicit and its flags precede the subcommand: `--repo` is required, `--owner`
overrides an organization-owned Project and `--project` is **never guessed**. Without `--project`
the adapter fails closed and points to this protocol; it writes nothing, invents no queue and
does not fall back to a local state. Exit codes: `0` ok, `2` refused by the protocol (nothing
changed, or its own writes were retracted), `3` blocked or failed write (the output lists what
could not be undone), `4` the agent's queue is empty. `inventory`, `next` and every `--dry-run`
are read-only.

Limits to declare, never overclaim: markers are unauthenticated structure (a shared account can
publish them), the receipt proves structure rather than reading, reservation has a
read-then-write window, and continuity belongs to the active session. No bot, cron, webhook or
deployment is part of this protocol.

## Adopting it in a project

Adopt the statuses, the routing labels and this protocol together; keep the project's existing
branch model and CI contract. Do not migrate the historical backlog: apply the protocol to new
and open work only, and record the decision once. A derived project may keep working without a
Project through the manual protocol, and may adapt the protocol to another tracker, but never
with a second operational state.

## Stop conditions

Stop and report, without writing, when the Project or its permissions are unavailable, the
agent identity is not in the catalogue, the routing label is ambiguous or unknown, the Issue is
assigned or already claimed elsewhere, a dependency is open or unverifiable, the history
exceeds the read limit, or the requested transition belongs to the user. Stopping one Issue
never stops a session: record the reason, keep it out of the queue and continue with the next
eligible Issue.
