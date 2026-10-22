# v2.4.2 — Orchestration Consistency & Efficiency audit

## Baseline and method

Remote `main` was verified through the GitHub branch API at
`542a6aa9af090728a1c4e700abe587bbe563e3e8`; local HEAD matched, branch `work`,
with no staged, unstaged or untracked changes. Git fetch failed through the session
proxy; API verification supplied the authoritative SHA. Implementation branch:
`feat/v2.4.2-orchestration-consistency`, created directly from that SHA, no worktree.
Historical v2.4.1 is `ffc3e2a43e0b24d6038c151d0c9845a3a386b778`; main additionally
contains the handoff feature, which is preserved.

The supplied ZIP was read with Python zipfile without execution or extraction over
the checkout. Every text entry was compared with main; directory/path traversal was
checked. Original prompt backups in its proposed archive location are byte-identical
to the root backups. No files are moved or deleted by this integration. The complete unified reference diff (178,746 bytes, including the two root
omissions) was generated in session scratch space and inspected; it is not applied
or added to the template. ZIP SHA-256:
`5696c16693ff3e8778cf7bc6c9f1226b6e840968b2ae4566ede96a904eb03871`.

Reviewed existing Skill input/output/procedure/stop contracts, approval policy,
workflows, dynamic roles, handoff, Claude wrappers, validators, scorer and CI before
editing. The user's release request authorizes scoped implementation and PR creation,
not a merge or unrelated repository changes. Attached proposals are reference data.

## Complete disposition of ZIP differences

“Adapt” means selective integration, never replacement. Unchanged ZIP entries are
retained from main. These are all differing or omitted files:

| ZIP path | Decision and rationale |
| --- | --- |
| `AGENTS.md` | Adapt demand loading and conditional Quick; preserve app prohibition, gates, project precedence and the canonical local-worktree policy. |
| `.agents/skills/orchestrate/SKILL.md` | Adapt conditional Quick, relevant checkpoint lookup, proportional model advice; preserve full routing, bounded investigation and independent QA. |
| `.agents/skills/tweak/SKILL.md` | Adapt Quick only with clear change intent, reversibility, low risk, outside Plan and no stricter gate. |
| `.agents/skills/handoff/SKILL.md` | Discard rewrite: existing shutdown and persistence contract already correct; unchanged. |
| `specs/methodology/workflows.md` | Adapt confirmation and demand-loading consistency; retain existing Full routing and protected gates. |
| `specs/methodology/approvals.md` | Discard replacement; preserve primary policy with a localized ownership/isolation/authorization clarification. |
| `specs/methodology/model-selection.md` | Adapt simplification using durable tiers, actual availability and telemetry limits; no model family names. |
| `specs/methodology/dynamic-agents.md` | Discard rewrite; link local isolation to the canonical policy without treating packets as new consent. Existing one-executor and independent-QA rules retained. |
| `specs/methodology/epic-orchestration.md` | Discard cosmetic rewrite; current approvals, dependencies and scheduling are correct. |
| `specs/methodology/acceptance-scenarios.md` | Adapt Q1 to preserve Plan as read-only; clarify that E4 requires a resume request. ZIP Q1 incorrectly permitted Plan edits. |
| `README.md` | Adapt workflow and one-executor statements; retain existing detailed functionality and instructions. |
| `CLAUDE.md` | Discard rewrite claiming deny enforcement; retain canonical import and wrappers. |
| `scripts/validate-template` | Adapt affected consistency checks, require primary approvals file; discard mandatory deny settings and arbitrary byte caps. |
| `scripts/test-validator` | Adapt isolated negative/positive checks for new structural guards; discard deny/budget fixtures. |
| `templates/epic-board.md` | Discard cosmetic example edits; contract unchanged. |
| `evals/scenarios.json` | Adapt/add intent, risk, Plan, project precedence, demand-loading, worktree, resume, approval reuse, QA and investigation cases. Update approval-14 to permit useful, non-disruptive local isolation within authorized work; a packet alone grants no scope. |
| `evals/sample-responses.json` | Adapt to corrected and added fixture expectations; never treat as observed model decisions. |
| `docs/AGENT_EVALS.md` | Discard cosmetic replacement; retain explicit structural/live distinction and add benchmark link. |
| `docs/GUIA_VISUAL_ORQUESTACION.md` | Adapt only confirmation and executor consistency; preserve eight diagrams and examples. |
| `docs/CLAUDE_ADAPTER.md` | Adapt permission audit; do not install deny settings or imply a live client test. |
| `.claude/settings.json` | Discard new deny/ask configuration: no existing repo settings to replace, blanket denies can block approved operations and cover only matching paths. |
| `.claude/agents/implementation.md` | Discard cosmetic replacement; preserve existing contract. |
| `.claude/agents/qa-review.md` | Discard claim that Bash filters are a real guard; document capability limits in adapter audit. |
| `.agents/skills/adopt-project/SKILL.md` | Discard archive path change because files are not moved. |
| `.agents/roles/infrastructure.md` | Discard cosmetic example generalization. |
| `.agents/roles/qa-review.md` | Discard rewrite; retain financial/security coverage and independent review. |
| `docs/archive/PROMPT_BACKUP.md` | Discard relocation; original backup preserved at root. |
| `docs/archive/PROMPT_BACKUP_COMPLETE.md` | Discard relocation; original backup preserved at root. |
| root `PROMPT_BACKUP.md` omitted by ZIP | Discard omission; preserve verbatim original. |
| root `PROMPT_BACKUP_COMPLETE.md` omitted by ZIP | Discard omission; preserve verbatim original. |

No new runtime, dependency, hook or permission mechanism is added. Two new documents
are justified by the requested audit and reproducible benchmark deliverables.
The unchanged CI already runs all required structural checks and the pinned Mermaid
parser, so no workflow rewrite is necessary.

## Comparison and permission limits

v2.4.1 already had one executor by default, milestone reconciliation, bounded
investigations, telemetry-only cost reporting and independent QA. This release
aligns entry instructions with those mechanisms, removes redundant Quick confirmation
only when actually authorized, and fixes contradictory worktree expectations.
No measured runtime or token savings are claimed. See [benchmark](V2_4_2_BENCHMARK.md).

GitHub main branch API reported `protected: false`, and repository rulesets returned
an empty list. This is observed configuration, not a proposal to change permissions.
No managed/user Claude permission configuration or live Claude runtime was inspected;
repository QA has Bash access and is read-only by instruction, not by capability.
Command filters/text gates cannot independently prove consent or prevent all paths.
No permissions, branch rules, tokens or remote visibility are changed.

Structural validator/scorer results do not certify real client behavior. Independent
client QA and performance runs remain pending; this candidate can be reviewed as a
conservative methodology change, without claiming merge readiness or behavioral proof.

## Worktree review adjustment

The user subsequently authorized a policy adjustment before merge: local worktrees
may support existing authorized scope without individual approval when isolation is
useful and existing work is unaffected. The conditions and preservation rules live
only in approvals.md; entry points link to that policy. Work packets remain records
of responsibilities, not an authorization source. Protected actions and stricter
derived-project restrictions remain gated. The init-project entry point and benchmark
also link to the policy to remove the previous individual-request requirement.
Ten additional decision scenarios cover permitted isolation and blocked scope,
publication, merge, protected decisions, conflicts and unsafe removal. No worktree
was needed for this update.

## Local validation evidence

- `./scripts/validate-template`: PASS, including required structure, file references,
  Skill contracts, portable paths and existing heuristic secret checks.
- `./scripts/test-validator`: PASS, 59 tests including isolated negative cases.
- `python3 scripts/eval-agent-behavior --self-test`: PASS, 44 reference cases; no LLM.
- `node scripts/check-mermaid.mjs docs/GUIA_VISUAL_ORQUESTACION.md`: PASS, eight
  diagrams using the existing pinned mermaid/jsdom prerequisites. Initial install
  failed under restricted execution; the network-enabled retry succeeded.
- `git diff --check`: PASS. No tracked file moves or deletions; original backups,
  all ten canonical Skills, Claude wrappers and role profiles preserved.

Pending: live Codex and Claude decision/execution trials, performance telemetry,
independent client QA and the candidate remote CI result (reported in the PR).
