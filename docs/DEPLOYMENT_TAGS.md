# Optional pattern: deployment by immutable GitHub tags

> **Status:** optional, reusable pattern documented on **2026-11-05**. It is **not
> installed, enabled or required** by this template. It does not change `$orchestrate`,
> Skills, roles, approvals, CI or the existing project lifecycle. Every adopter decides
> whether it fits, and each implementation phase needs its own authorization.

This page records a GitHub-specific deployment pattern for projects that publish
immutable release artifacts and operate more than one environment. It is an option,
not a default and not a universal stack decision. Projects using another platform,
a single environment or manual releases should ignore it without adapting the
template.

## Problem it addresses

A successful merge is not a deployment authorization, and a mutable branch or image
tag is not a release identity. The pattern makes three things explicit:

- **what** is deployed: a commit SHA and an immutable artifact digest;
- **where** it is deployed: a named environment with its own credentials and state;
- **who** authorized it: a restricted tag publisher for TEST and a protected GitHub
  Environment approval for production.

It does not replace CI, independent QA, backups, recovery drills, acceptance or the
project's merge and deployment gates. Those remain separate.

## Tag convention

Use two namespaces and a complete semantic version:

```text
deploy-test-vMAJOR.MINOR.PATCH   → TEST
deploy-prod-vMAJOR.MINOR.PATCH   → PRODUCTION
```

- A published tag is **immutable**: do not move, delete or reuse it. A retry after a
  failed validation uses the same tag only if the SHA and artifact are unchanged;
  otherwise publish a new patch version after a new TEST cycle.
- The tag points to a concrete commit, never to a short branch name or a mutable
  merge ref.
- The commit must be reachable from the origin branch the project authorizes for
  that environment. A common starting policy is `feature/* → main`, with both tags
  targeting commits on `main`.
- If the project later adopts `feature/* → test → main`, change only the tag origin
  policy: TEST may consume the integration origin and PROD must consume the commit
  promoted to `main`. The tag names, immutability and artifact controls do not
  change. Do not create the extra branch merely to copy this pattern.

The tag message should carry a short, non-secret deployment intent: version, commit
SHA, artifact manifest digest, schema contract, QA reference and seed reference for
TEST. Whether tags are annotated or signed is a project decision, not a template
default.

## TEST flow

1. A restricted publisher creates `deploy-test-v<version>` on an authorized commit.
2. The workflow validates the tag name, publisher, repository and commit ancestry.
   An unknown or ambiguous origin stops before any host access.
3. It resolves and records the exact 40-character SHA.
4. It checks the required CI result and the project's independent QA evidence for
   that SHA, plus any mandatory infrastructure gate (for example rootless).
5. It builds or retrieves the release for that SHA and verifies the manifest,
   checksums and immutable image digest. A mismatch stops the run.
6. It verifies schema, seed, backup and recovery preconditions defined by the
   project.
7. Only when the project's enablement switch is on and every control passed, it
   deploys to TEST.
8. It runs the agreed smoke checks and records the result, SHA, artifact digest and
   final state. A validation failure must stop before modifying the host.

TEST is useful only if it is disposable, reproducible and isolated from production.
A TEST deployment is not production acceptance.

## Production flow

1. A restricted publisher creates `deploy-prod-v<version>`.
2. The workflow verifies the same version, SHA and artifact digest that passed TEST.
   If the artifact is missing or different, stop; do not rebuild a new artifact in
   production.
3. It verifies the production-specific controls: real-data authorization, migration
   authorization, backup, restore drill, rollback pair and smoke plan.
4. It stops at a protected GitHub Environment (`production`).
5. Required reviewers approve; the author of the tag should not be the sole approver.
6. Only after **Approve and deploy** may environment-scoped credentials be released
   and the deployment executed.
7. It verifies the result and preserves evidence.

An environment approval is operational authorization for that run only. It does not
approve a merge, a new development scope, real-data import or a later version.

## Controls worth copying

| Control | Minimum expectation |
| --- | --- |
| Tag protection | Restrict creation to an authorized group; block update and deletion; verify the effective GitHub rule, not only the documented intent |
| Artifact identity | Verify commit, manifest, checksums and immutable digest; never rely on a mutable image tag |
| Promotion | Production consumes the artifact validated in TEST, not a fresh rebuild |
| Concurrency | One active deployment per environment; reject a second one instead of running them in parallel |
| Credentials | Separate TEST and PROD principals, least privilege, no secrets in Git or artifacts, environment-scoped release after approval |
| Backup | No deployment without a validated backup and a recovery plan; production real data needs its own gate |
| Fail closed | Unknown user, SHA, artifact, schema, backup or smoke result stops the run; no silent repair |
| Audit | Record actor, tag, SHA, digest, approvals, backup, smoke and outcome without secrets or private financial data |
| Rollback | Return only to a proven exact pair; do not force an in-place downgrade or automatic restore |

These controls are intentionally platform-neutral except for the GitHub tag and
Environment mechanics. The project's own security, quality and operations documents
remain authoritative.

## Adoption checklist

1. Confirm that immutable artifacts, two environments and a real operational need
   justify the pattern. A single-user local project may not need it.
2. Decide artifact storage and transport, deployment execution and credentials, tag
   protection, QA evidence, backup/restore and rollback before writing workflows.
3. Resolve the cross-repository contract: the application owns the tag, release and
   promotion; the host owns isolation, activation, permissions, backups and recovery.
4. Protect tags and create the production Environment first; verify the effective
   settings with a read-only query.
5. Implement checks in dry-run mode with a manual trigger and no host credentials;
   test negative cases and keep the host untouched.
6. Enable TEST with a reversible first release and smoke evidence.
7. Enable PROD only after backup/restore, acceptance and reviewer separation. Keep a
   separate authorization for that phase.
8. If a new integration branch is adopted later, update only the tag origin policy.

Do not copy a workflow from another repository without revalidating its permissions,
pinned actions, event filters and secret exposure. A green pipeline is not evidence
that a deployment happened or that recovery works.

## Anti-patterns

- Deploying from a branch name, a moving `latest` tag or an unverified PR merge ref.
- Reusing or moving a published tag after a failure.
- Rebuilding a different artifact in production and calling it a promotion.
- Letting TEST and PROD share credentials, data roots, ports or backup destinations.
- Automatically restoring a backup or forcing a schema downgrade after a failed smoke
  test without an authorized recovery procedure.
- Treating a GitHub Environment approval as approval to merge, import real data or
  change the project roadmap.
- Making this pattern mandatory for every derived project.

## References

- MyFinanzas [`DEPLOY-TAGS-01`](https://github.com/jmartinlabs/myfinanzas-app/pull/233)
  (application-side design, documentation PR in review)
- [`vps-infra` deployment contract](https://github.com/jmartinlabs/vps-infra/pull/18)
  (host-side design, documentation PR in review)
- [Approvals](https://github.com/jmartinlabs/agent-project-template/blob/main/specs/methodology/approvals.md)
- [CI policy](https://github.com/jmartinlabs/agent-project-template/blob/main/specs/methodology/ci-policy.md)
- [Security guidelines](../specs/guidelines/security.md)
