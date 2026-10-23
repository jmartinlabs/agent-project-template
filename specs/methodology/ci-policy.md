# Change-aware CI contract for derived projects

Bootstrap implements this contract in the generated project harness. This template
keeps its own complete validation workflow; it has no application stack to test.

## Classification
Use one reusable classifier locally and in CI, with exactly `docs` and `full` results.
`docs` requires a nonempty set containing only explicitly allowlisted documentation
paths (for example a project backlog). A Markdown extension alone is insufficient.
Instructions, Skills, methodology, harness scripts, workflows, configuration, SQL,
dependencies and lockfiles always require `full`, even when written in Markdown.
Unknown paths, mixed documentation/code, invalid input, missing Git base, empty or
incomplete change lists and classification errors default to `full`.
Inspect the complete event comparison, including additions, deletions and both sides
of renames. Document PR and push comparison bases; never silently inspect only HEAD's
last commit. Parse filenames safely, including spaces and unusual characters.

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

## Local regression evidence
The harness regression suite (for example `scripts/test-checks`) must exercise the
same classifier used by CI and valid/invalid workflow fixtures. Cover at least:

| Input or mutation | Expected result |
| --- | --- |
| Only allowlisted backlog documentation | `docs`, baseline controls required |
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
