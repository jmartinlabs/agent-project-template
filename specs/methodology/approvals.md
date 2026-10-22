# Explicit approvals for protected operations (v2.3.2)

This policy applies to `$orchestrate`, all delegated agents, and all workflows. It is an **instruction-level gate**, not an independently enforced security control. A repository may impose stricter project-specific authorization.

## Protected decisions

Individual user authorization is required before: merging a PR; approving a Full specification/wireframes or substantive financial/product decisions; authorizing development when a project has a separate development gate; material security/architecture changes; destructive actions; production deployment or operational data migration; and any other approval explicitly required by the project.

A green CI, completed QA, pre-approved plan, previous scope authorization, or finished implementation **does not imply** approval of another protected action.

## Required wording and scope

- Clearly present **one identifiable approval decision** at a time, including its target and, when relevant, PR number and HEAD SHA, specification ID/revision, deployment environment, or changed scope. When several independent decisions are pending, separate them and require distinct affirmative decisions.
- Positive authorization must use an **explicit approval verb**, e.g. `Approve PR #34 merge`, `I approve specification 07`, `Apruebo PR #34`, or `Aprobada la especificación 07`. A short `Approved` / `Aprobado` / `Apruebo` is acceptable **only** if it unambiguously answers exactly one immediately preceding, clearly identified approval request.
- `ok`, `okk`, `dale`, `continúa`, `continue`, `go ahead`, `adelante`, silence, reactions, or a generic assent **never approve a protected action**. They may continue work already authorized.
- Never bundle a PR merge, specification acceptance, deployment, or development authorization into one inferred approval. If the target, revision, intent, or source of authorization is uncertain, ask one concise question and stop only the affected gated action. Independent permitted work may continue.
- The coordinator records the exact scope, concrete target, relevant revision/SHA, and source/message of an explicit approval in the resumable project record. Agent-generated assertions or commit messages claiming "user approved" **are not themselves evidence** of a user authorization.
- Reuse a specific valid approval; do not ask again for the same unchanged decision. Before performing the approved action, independently verify its target, current Git/revision state, tests, and any project-specific gates. Material changes after approval require fresh consent; do not silently extend approval to another artifact or SHA.

## GitHub PR merge example

1. Report `PR #34 ready for review, HEAD abc123, checks green. To authorize merge reply: Apruebo PR #34`.
2. `Dale` does not permit merge. `Apruebo PR #34` permits consideration of that **one PR**.
3. Recheck the PR HEAD and required checks. If material contents changed since the approved revision, request approval again. Merge only when current, scoped approval and all repository gates hold.

## Scope and limitations

Ordinary technical implementation, use of subagents, worktrees, routine tests, branch/push/PR preparation, and other steps **within a previously approved scope** need no new per-step approval unless local policy requires one. This policy does not install a tool hook or GitHub ruleset; stronger independent enforcement needs separate configuration and an authorization source agents cannot forge or edit.
