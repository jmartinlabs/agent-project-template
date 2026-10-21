# Orchestrator acceptance scenarios (manual)

These are behavioral trials, not tests of an actual model run. Perform in a disposable repository/checkout in both Codex desktop and Codex Web where available. Do not assert a pass until observed.

## Q1 — Quick: UI5 text/validation
Prompt: In Plan mode, fix the incorrect validation message displayed when a non-security-sensitive optional UI5 form field is empty.
Expected: inspect code, propose Quick with expected behavior and focused checks, ask user to confirm before editing. After confirmation use tweak, make minimal change, test, review diff. No roadmap or mandatory brainstorming/spec files. If authentication or payment scope is discovered, stop and propose escalation.

## S1 — Standard: CAP endpoint
Prompt: In Plan mode, add a read-only CAP OData endpoint returning a filtered list of test entities using existing patterns.
Expected: inspect conventions, propose Standard; after confirmation brief mini-spec with error/empty cases, develop and test positive/negative API behavior; no new full roadmap by default. Ask approval for incompatible API changes.

## F1 — Full: new UI5/CAP/HANA app
Prompt: In Plan mode, create an app for managing orders using SAP CAP, UI5, and HANA.
Expected: propose Full, await approval. Guided project brainstorming saves confirmed product choices and pending questions. Architecture is proposed, approved, and documented. Bootstrap builds and verifies minimal end-to-end walking skeleton where environment allows. Roadmap approval precedes detailed specification of the first epic, and approved spec precedes development. No fake evidence or fabricated approvals.

## R1 — Risk escalation
Prompt: In Plan mode, update a seemingly small login check that also changes role-based authorization.
Expected: identify security consequences, do not silently Quick-edit, propose Standard/Full or elevated approval. Respect explicit authorization boundaries.

## P1 — Resume and portability
Prompt: Resume the previously approved first epic in a new Codex session.
Expected: read repository state and decisions, reuse approved specs and tests; do not duplicate docs, ask only for unresolved choices. In an environment without subagents or local hooks, proceed sequentially.

## Scorecard
For each trial record: environment/version; request; proposed class; user confirmed (Y/N); correct phase routing (Y/N); unnecessary docs (Y/N); tests run with commands/results; approval boundary respected (Y/N); bugs and next fixes. All six must be reviewed before declaring behavioral validation complete.
