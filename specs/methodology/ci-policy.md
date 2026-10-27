# Change-aware CI contract for derived projects

Bootstrap implements this contract in the generated project harness. This template
keeps its own lightweight validation workflow; it has no application stack to test.
The local-first policy below applies to derived projects without adding a new Skill,
agent service, attestation system or mandatory client hook.

## Classification
Use one reusable classifier locally and in CI, with exactly `docs` and `full` results.
`docs` requires a nonempty set containing only explicitly allowlisted documentation
paths. A Markdown extension alone is insufficient; backlog is not the only eligible
product documentation.
Instructions, Skills, methodology, harness scripts, workflows, configuration, SQL,
dependencies and lockfiles always require `full`, even when written in Markdown.
Unknown paths, mixed documentation/code, invalid input, missing Git base, empty or
incomplete change lists and classification errors default to `full`.
Inspect the complete event comparison, including additions, deletions and both sides
of renames. Document PR and push comparison bases; never silently inspect only HEAD's
last commit. Parse filenames safely, including spaces and unusual characters.

## Adaptable product-document allowlist
Record the exact allowlist in each project's CI policy and implement it in the shared
classifier. Start with these bounded product-document families, adapting paths and
naming to the existing project rather than renaming its documents:

- Direct backlog documents under an explicitly named product backlog directory.
- Direct numbered brainstorming, specification, progress and testplan documents.
  For this template's convention, match the whole relative path with
  `specs/[0-9]{2}-[a-z0-9]+(?:-[a-z0-9]+)*-(?:brainstorming|specification|progress|testplan)\.md`.
  Do not match arbitrary suffixes, nested directories or every file in `specs/`.
- Exact context/plan/tracking files reviewed as product documentation, such as
  `specs/project.md`, `specs/roadmap.md`, `specs/setup-progress.md` and
  `specs/epic-board.md`. Additional references need explicit exact paths or bounded
  families, with rationale and positive/negative tests. A README is not automatically
  eligible: it may contain operational agent instructions.

Protected exclusions take precedence over every allowlist entry. Exclude instructions
(including AGENTS.md, CLAUDE.md, SKILL.md and instructions.md regardless of case), Skills,
operational methodology, guidelines, harness, workflows and configuration, even if
stored beside product documents or matching an allowed name. Code, SQL, dependencies,
lockfiles, mixed changes and unknown paths remain `full`. Never use a blanket `*.md`
or `specs/**` exemption. If a product document becomes operational instructions,
reclassify its path as `full`; review this boundary when changing document ownership.
Changes to the allowlist or classifier themselves require `full`.

Adapt existing projects without init-project, replacing functional decisions or
reinitializing their harness. This is a CI scope policy, not product approval.
Reference: [MyFinanzas PR #55](https://github.com/josemartin2000/myfinanzas-app/pull/55)
illustrates the correction; its project-specific filenames are not universal defaults.

## Required checks and workflow enforcement
Documentation and security controls are mandatory for both classes. `full` defines
required delivery coverage: all applicable type, build, API/integration and E2E checks.
It does not require running every suite on every GitHub event. Record exact commands,
execution profiles, critical paths and platform requirements in project quality guidelines;
do not invent a browser, API or database requirement for stacks that do not use them.

Use local-first QA with a minimal CI gate:

- Local development and independent QA run E2E and complete regressions for each stable
  candidate. Platform-dependent checks require a compatible isolated environment;
  a host OS that cannot exercise them is not equivalent evidence.
- Every PR has one unconditional `required` job: baseline documentation/security controls,
  the shared conservative classifier and the project's fast type/build checks.
  Critical persistence, migration, financial, security and dependency changes also run
  independent checks in CI on the required platform. Keep their commands and path map
  in the project, including indirect consumers; unknown paths or uncertain impact select
  critical verification or fail visibly, never a successful omission.
- Automatic push runs target only `main`, providing a fast post-merge gate. PR runs
  compare the complete base/head change; working-branch pushes must not duplicate them.
  Include `ready_for_review` so a draft that becomes ready is validated, and keep the
  fast gate active on drafts unless the project explicitly decides otherwise. Keep
  manual full verification available. Cancel superseded PR runs using a PR-specific
  concurrency group; never let a push cancel the PR check or silently pass a cancellation.
- Keep a single habitual job rather than separate baseline/full/aggregator runners.
  Preserve the check identity through migration or explicitly coordinate protection
  updates with user approval. A job named `required` alone does not enforce branch
  protection; inspect actual required checks and bypass settings before claiming enforcement.

The project harness (for example `scripts/check-project`) must validate workflow
structure and execution conditions, not merely command text. Require unconditional
baseline controls, conservative profile selection and a required result that rejects
failures and unexpected skipped checks. Missing or invalid classifier output must
select critical/full verification or fail visibly. Reject disabled controls (`if: false`),
commented-only commands, `continue-on-error` on required checks and event/path filters
that omit the PR gate. Preserve approved security controls, including permissions,
action pins, checkout credentials and history requirements; classification never relaxes them.

Use an execution-profile matrix that keeps delivery coverage separate from the checks
selected for an event. The names below are semantic categories; projects map them to
their own commands and may omit a category only with a documented reason.

| Profile | Minimum check coverage |
| --- | --- |
| `docs` | Baseline documentation and security controls. |
| `fast` | Baseline plus the project's fast type, lint and build checks. |
| `critical` | Fast plus independent persistence, migration, security, dependency and API/integration checks on the required platform. |
| `full` | Every applicable check, including end-to-end and acceptance coverage. |

Each profile must have a bounded timeout. A timeout, cancellation or unexpected skip
is a failure, never a successful omission. Profiles are check categories, not
universal commands: a project without a database, API or browser records the
justified omission instead of inventing checks.

For automatic `push` events to the integration branch, select only `docs` or `fast`;
never select `critical` or `full` automatically after merge. The PR gate must already
have validated the exact integration tree against the current base, and branch
protection must prevent stale or bypassed merges. If the base or tested tree changes,
rerun the affected critical checks. Validate a high-risk merge with a manual `full`
run rather than duplicating the critical suite automatically. A fast post-merge run
does not attest local QA or replace the PR gate.

A PR can modify its own workflow, classifier or workflow validator. No in-repository
check can prove that this did not weaken the gate. Require explicit review of CI,
classifier and validator changes, and do not claim that branch protection alone
resolves this risk.

## Evidence validity and independent QA
Reuse the existing testplan/checkpoint, not a second evidence registry. Before integration,
the coordinator and independent QA verify the clean candidate commit, current base commit,
complete comparison and tested environment against reachable raw logs and artifacts.
Record exact commands, tool/runtime versions, platform/architecture, run time, test counts,
exit statuses and expected coverage. Dirty/untracked inputs must be identified and cannot
be represented as evidence for a clean commit. A PASS declared by an agent or a self-authored
manifest is not sufficient evidence. QA inspects raw output and candidate diff and reruns
checks that resolve material risks; it does not merely repeat the author's conclusion.

After a candidate, base, dependency, toolchain, filesystem or environment change, reassess
impact and rerun affected checks; uncertain impact requires complete verification. Reuse
unchanged evidence only with an explicit equivalence rationale verified independently.
Missing, stale, inaccessible or incompatible evidence blocks integration even if CI is green.
The fast CI gate does not attest that local QA ran. Keep explicit merge approval; no
repository-controlled PASS file, client hook or successful check substitutes for it.
Codex and Claude Code follow this same canonical policy through their existing adapters;
do not make correctness depend on optional lifecycle hooks or a particular client.

## Canonical verification entry point
Bootstrap establishes one canonical verification command for local use and CI.
Reuse an existing command when it already covers this contract; do not add a wrapper
or rename commands merely for uniformity. The command name and implementation belong
to the approved project stack (for example a script, task runner or package command).
Record its working directory, prerequisites, comparison inputs and a way to force
`full` verification in AGENTS.md and project quality guidelines.

The entry point coordinates the shared classifier and required checks; keep their
logic in existing tools rather than copying it. Use explicit local-full, fast-CI and critical-CI profiles in the existing entry point.
Apply the same check selection and failure semantics for equivalent inputs within each
profile; profile differences are intentional and documented, not silent skips.
Environment preparation may differ and must be documented. The required CI result
verifies its profile coverage; the independent integration review verifies local-full
evidence. Keep conservative docs/full coverage classification separate from execution venue.
Within one verification run, execute each required suite once unless a documented
repeat is needed for an acceptance criterion or flakiness investigation. This does
not remove independent QA or require reusing stale evidence between candidates.

Propagate a nonzero exit status for any required failure or missing prerequisite.
An invalid mode must fail visibly. Report passed, failed, intentionally skipped and
unrun checks separately; unexpected skips and unexpectedly zero discovered tests
must not count as success. Classification uncertainty retains the conservative
`full` or visible failure behavior specified above. Successful `docs` verification
must say that application checks were intentionally omitted, not claim they passed.
Verification must not install dependencies, change task state, commit, deploy or
reinitialize a project implicitly; provision the documented environment separately.

Derived-project regression tests must invoke the real entry point and demonstrate:
valid docs/full paths, forced full mode, each required check failing, missing tooling,
invalid modes, unexpected zero tests/skips, local/CI selection parity within profiles, and each suite
executing once per run. Prove reuse of an adequate existing command without a second
verification layer. These are generated-harness behavioral tests; this template's
validator only protects preservation of the contract.

## Local regression evidence
The harness regression suite (for example `scripts/test-checks`) must exercise the
same classifier used by CI and valid/invalid workflow fixtures. Cover at least:

| Input or mutation | Expected result |
| --- | --- |
| Only allowlisted backlog documentation | `docs`, baseline controls required |
| Each allowed brainstorming/specification/progress/testplan and exact tracking path: additions, modifications and deletions | `docs`, baseline controls required |
| Renames between two allowed product-document paths | `docs`, both endpoints checked |
| Protected/unknown to product documentation, and product documentation to protected/unknown | `full`, both rename directions checked |
| Each protected category added, modified or deleted, alone and mixed with allowed product documentation | `full` |
| Markdown lookalikes: nested paths, wrong suffix/extension, arbitrary specs files or protected names in allowed directories | `full` |
| Documentation plus code | `full` delivery coverage; CI follows the explicit execution profile |
| SQL, dependencies, lockfiles, workflows, harness, configuration, instructions or Skills | `full` |
| Unknown path, empty input, invalid output, missing comparison base or classifier failure | `full` or visible CI failure; never successful omission |
| Rename from code to documentation, or deleted protected file | `full` |
| Paths containing spaces or unusual characters | Parsed without losing changes |
| Missing classifier, disabled required check, broken dependency or unexpected skip | Workflow rejected |
| Commented command, allowed failure or filter skipping all validation | Workflow rejected |
| Valid docs and full workflow execution paths | Accepted with their required checks |

Prove the contract with local tests before changing Actions execution. Regressions
must check behavior, not repeat the implementation's string-presence assertions.
Also exercise working-branch push exclusion, PR/main/manual admission, PR cancellation,
failed/cancelled/timed-out checks, invalid profile selection and unknown critical paths.
Evidence validity tests cover stale candidate/base, dirty inputs, incompatible environment,
missing/raw-log mismatch and a forged PASS claim. Keep environment caching optional and
review its trust boundary separately.

For every allowed family and exact path, use real Git comparisons for additions,
modifications, deletions and renames. Exercise both rename endpoints even if the old
file no longer exists. Include protected files mixed with each product-document
family; one protected or unknown path makes the whole comparison `full`. Test policy
adaptations with valid alternate product paths and rejected broad Markdown exemptions.

## Template repository workflow

This repository's one `required` job keeps its complete lightweight template checks,
including the real Mermaid parser and a malformed-diagram rejection. It runs on PRs
to main —including `ready_for_review`, with drafts still gated—, pushes to main and
manual dispatch, with no working-branch push runs. This
repository has no API, database or E2E application suite; do not manufacture one.
Validator fixtures check the parsed workflow, unconditional execution and safe event
selection. They do not prove live GitHub cancellation or branch protection enforcement.
