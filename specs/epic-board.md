# Epic execution board

> Live coordination state for **this template repository** (the reusable harness), not for a
> derived product. Derived projects replace this file with their own board or remove it. It is
> the single operational state owner; approvals remain in their canonical PR/issue records.

Repository: `jmartinlabs/agent-project-template`
Last reconciled: 2026-11-04, against `main` `c0ee565` and PR #44 candidate `2afd322`.
Coordinator next action: request the two user decisions below and keep both candidates verified.
Current summary owner/link: this board; evidence links to PR #44 and issue #22.
External clients / IDs / start-stop owners / notification routes: NONE VERIFIED.

| Functional ID | Priority | SPEC status / approval evidence | DEV status / blocks | QA status | MERGE status | Functional acceptance | Hard dependencies | Owner / isolated branch | Blocker / decision needed | Next independent action | Evidence / last verified |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| HARNESS-PROACTIVE-01 — coordinator look-ahead | P1 | n/a — documentation change; no separate SPEC gate | verified / `DEV-01 — look-ahead section, scenarios and validator contract` | passed at `23806c9`; delta `2afd322` re-check pending | authorization-pending / PR #44 at `2afd322` | pending | none | coordinator / `orch/proactive-planning-01` | user approves merging PR #44 | re-run validators and independent review on `2afd322`, then update PR #44 | PR #44; `2afd322` |
| HARNESS-PROPOSALS-01 — registered proposals and ownership preflight | P2 | awaiting-approval / issue #22 audit proposal (2026-11-04) | not-ready / `DEV-01 — Git status and ownership preflight in task`, `DEV-02 — definition of a registered proposal`, `DEV-03 — validator coverage` planned | test-design | not-ready | pending | user approves or rejects the issue #22 proposal | functional / none yet | user decision on issue #22 | do not code; if approved, open a separate branch/PR with the two normative sentences and mutation tests | issue #22 comment; audit completed, nothing implemented |

DEV blocks are local to each functional ID and carry a descriptive name. `DEV-01`, `DEV-02`, …
are sequential; a block number does not imply completion. `MERGE` states are `not-ready`,
`PR-open`, `ready-for-review`, `authorization-pending`, `approved`, `merged` or `closed`.

## Approvals needed

- PENDING — **merge**: approve PR #44 at candidate `2afd322` (`orch/proactive-planning-01`).
  Owner: user. Canonical record: PR #44. Required wording: `Apruebo PR #44`.
  A green check, the earlier review and any earlier scope authorization do not approve merge.
- PENDING — **scope**: approve or reject the normative proposal recorded in issue #22
  (Git/ownership preflight in the `task` Skill; definition of a "registered proposal";
  validator regression coverage). Owner: user. Canonical record: issue #22.
  It does not depend on PR #44 and is not implemented before an explicit answer.

## Ready queue

- P1 after merge approval: recheck PR #44 head and required check, merge, then close the task's
  clean local branch/worktree under the post-merge cleanup policy.
- P2 after issue #22 approval: implement the two normative sentences plus validator mutation
  tests in an independent branch/PR. Until then it stays a proposal; no DEV is authorized.
- P1 without either decision: update this board only when a verified state changes.
  No other independent work is ready; do not invent tasks.

## Technical investigations

| ID | Question and exit criteria | Priority | Blocking which item and why | Owner | Status / evidence |
| --- | --- | --- | --- | --- | --- |
| NONE | — | — | — | — | — |

## Handoffs and checks

- HARNESS-PROACTIVE-01: `./scripts/validate-template` PASS; `./scripts/test-validator` PASS
  (209 tests); `eval-agent-behavior --self-test` PASS (146 cases); scorer 146/146 at
  `23806c9`; `check-mermaid` PASS (8 diagrams). Independent read-only review PASS with
  low-severity findings fixed in `23806c9`; one remaining fixture inconsistency fixed in
  `2afd322` and pending re-verification. PR #44 published; merge approval pending.
- HARNESS-PROPOSALS-01: read-only audit completed and recorded in issue #22. No code, no
  branch, no approval. The proposal is a draft, not an approved specification.

After confirmed integration, update current PR/merge/SHA/check fields, explicitly
superseding historical pending states. Preserve history behind links.

## Next-session resume

- Read this board, PR #44 and issue #22; reconcile Git/check state before acting.
- Never merge without the exact user approval recorded above; never implement issue #22
  without its own approval.
- Select the next independent ready task; if none is ready, report the pending decisions and stop.
