# Change-aware CI contract for derived projects

Bootstrap implements this contract in the generated project harness. This template
keeps its own complete validation workflow; it has no application stack to test.

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
Documentation and security controls are mandatory for both classes. `full` also runs
all applicable type, build, API/integration and E2E checks. Record exact commands and
explicit reasons for inapplicable checks in project quality guidelines; do not invent
a browser, API or database requirement for stacks that do not use them.

The project harness (for example `scripts/check-project`) must validate workflow
structure and execution conditions, not merely command text. Require the shared
classifier, unconditional baseline controls, and full checks unless classification
has successfully produced exactly `docs`. Missing or invalid classifier output must
run full checks or fail visibly; it must never yield a green run with no validation.
Check job dependencies, conditions and a final required result that rejects failures
and unexpected skipped checks. Reject disabled controls (`if: false`), commented-only
commands, `continue-on-error` on required checks and event/path filters that omit all
validation. Preserve approved security controls, including permissions, action pins,
checkout credentials and history requirements; classification never relaxes them.

## Canonical verification entry point
Bootstrap establishes one canonical verification command for local use and CI.
Reuse an existing command when it already covers this contract; do not add a wrapper
or rename commands merely for uniformity. The command name and implementation belong
to the approved project stack (for example a script, task runner or package command).
Record its working directory, prerequisites, comparison inputs and a way to force
`full` verification in AGENTS.md and project quality guidelines.

The entry point coordinates the shared classifier and required checks; keep their
logic in existing tools rather than copying it. Apply the same check selection and
failure semantics locally and in CI for equivalent inputs. Environment preparation
may differ and must be documented. CI may split work across jobs through explicit
modes of the same entry point; the required final result must still verify coverage.
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
invalid modes, unexpected zero tests/skips, local/CI selection parity, and each suite
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
| Documentation plus code | `full`, complete applicable battery required |
| SQL, dependencies, lockfiles, workflows, harness, configuration, instructions or Skills | `full` |
| Unknown path, empty input, invalid output, missing comparison base or classifier failure | `full` or visible CI failure; never successful omission |
| Rename from code to documentation, or deleted protected file | `full` |
| Paths containing spaces or unusual characters | Parsed without losing changes |
| Missing classifier, disabled baseline/full check, broken dependency or unexpected skip | Workflow rejected |
| Commented command, allowed failure or filter skipping all validation | Workflow rejected |
| Valid docs and full workflow execution paths | Accepted with their required checks |

Prove the contract with local tests before changing Actions execution. Regressions
must check behavior, not repeat the implementation's string-presence assertions.
UI-specific classification, event deduplication and environment caching are separate
changes requiring their own evidence and scope.

For every allowed family and exact path, use real Git comparisons for additions,
modifications, deletions and renames. Exercise both rename endpoints even if the old
file no longer exists. Include protected files mixed with each product-document
family; one protected or unknown path makes the whole comparison `full`. Test policy
adaptations with valid alternate product paths and rejected broad Markdown exemptions.
