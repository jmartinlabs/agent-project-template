# Quality guidelines

## Template commands
Run `./scripts/validate-template` and `./scripts/test-validator` with Python 3.10+.
Run `python3 scripts/test-agent-relay` for the optional two-participant relay protocol.
Run `python3 scripts/test-agent-usage` and `python3 scripts/test-auto-agent-usage`
for local usage reporting and its advisory Codex lifecycle adapter.
Python checks need no package installation. The real Mermaid parser requires its
pinned Node packages. CI runs one `required` job on PRs to main —including
`ready_for_review`, with drafts still gated—, pushes to main and manual dispatch;
working-branch pushes do not duplicate PR runs.

## Enforced rules
The validator checks required structure, local Markdown file links (including AGENTS),
restricted Skill frontmatter, workflow contracts, initialization stage/state markers,
copyable prompt content, portable paths and common credential patterns. The test harness
runs valid fixtures and isolated corruptions for every check category, including legitimate
placeholder, interface and language choices. See [validator](../../scripts/validate-template)
and [regression tests](../../scripts/test-validator).
It is not a full Markdown/YAML parser, secret scanner or semantic architecture reviewer.
It checks local file destinations, not remote availability or heading anchors. Human review
must verify coherent instructions, neutral technology advice, privacy, and GitHub settings.
Project stacks in project guidelines are allowed: imposing a stack on all projects is not.
Add project-specific enforcement only after decisions; prove positive and negative cases.

## Project initialization — UNDECIDED
Record actual install, run, test, type-check, lint and formatting commands and their working
directories after bootstrap. Mark inapplicable tools explicitly, with reasons.
Use relevant unit/integration tests plus acceptance checks that can fail for broken behavior.
Review regressions, errors, accessibility and security in proportion to the change.
Definition of Done: approved scope implemented; every acceptance check passes with evidence;
required automated checks pass; documentation and progress updated; reviewed changes committed.
Blocked/skipped/unrun is not passed. No zero-test readiness claim.

## Derived-project CI
Before implementation, map acceptance criteria to checks, local/CI environment, owner
and expected evidence in the existing test plan. Check platform prerequisites first;
an incompatible local run cannot replace the required CI gate. Use focal checks per
delta and required verification per stable candidate, recording reasons for repeats.
QA independently assesses candidate/diff/evidence and unresolved risks. Reuse valid
evidence without suppressing mandatory financial, security or CI controls. At closure,
link one current checkpoint rather than duplicate historical statuses.

Bootstrap must implement the [change-aware CI contract](../methodology/ci-policy.md).
Use a shared conservative `docs`/`full` classifier and test workflow execution
conditions, including mandatory documentation/security controls and failure fallbacks.
The template validator checks preservation of these instructions structurally;
derived-project harness tests must prove the actual classifier and workflow behavior.
Ordinary Markdown documentation may live at the root, under `docs/`, `specs/` or
nested directories. A Markdown extension alone is insufficient to override
protected exclusions taking precedence: agent instructions, operational paths and
functional Markdown require `full`. Adapt protected paths to the project and test
real Git add/modify/delete/rename regressions.

Use one canonical verification command locally and in CI, reusing an adequate existing
command. Bootstrap records its prerequisites, working directory, comparison inputs
and forced full mode in AGENTS.md and these guidelines. Follow the entry point's
failure, coverage and regression requirements in the CI contract.

The CI contract separates delivery coverage from execution profiles: local-full QA,
fast CI and independent critical CI. Complete application regressions and E2E stay
local in compatible environments; critical-path checks remain independent in CI.
The existing testplan/checkpoint binds evidence to candidate, base, environment and
raw logs. Independent QA verifies validity and freshness before integration; an agent's
PASS claim or green fast CI is insufficient. See the canonical contract for stale
evidence, cancellation and conservative-selector requirements. Codex and Claude Code
use the same policy through the existing adapters; optional hooks are not gates.
