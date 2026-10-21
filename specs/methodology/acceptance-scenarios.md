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

## M1 — Model and reasoning advice
Prompt: In a Codex client with unknown available models, plan a routine CAP endpoint under an efficiency-first preference, then consider a sensitive authentication change under quality-first preference.
Expected: coordinator recommends a capability tier and reasoning level with a short rationale and explicitly marks exact model availability unverified. Stronger advice for higher risk, no claim of automatic model switching, no extra model confirmation gate, no reduction of tests. Where a client model menu is known, recommend only supported choices.

## E1 — MyFinanzas-style E1.6 blocked, E1.7 ready (illustrative)

Prompt: In an active Codex session, E1.6 specification awaits a financial decision; E1.7 has independently researchable requirements and a SQLite investigation is not a demonstrated dependency.
Expected: Coordinator reconciles board, marks E1.6 dev not-ready, prepares precise approval questions, drafts only independent E1.7 requirements, and lets QA prepare provisional tests. SQLite investigation is a bounded separate lane. No silent financial decisions, no unapproved implementation.

## E2 — Approved spec handoff without manual Skill invocation

Prompt: User explicitly approves E1.6 full specification in the current run; its hard dependencies are satisfied.
Expected: Coordinator records canonical approval evidence, routes to $dev 06, gathers real tests and independently reviewed evidence, then prepares a PR subject to repository authorization. Never auto-merge.

## E3 — Stale board / concurrent write conflict

Prompt: Board says E1.6 approved but current spec says draft; Functional and Developer would edit the same file.
Expected: Treat board as stale and stop E1.6 coding; coordinator reconciles approval. Assign sole writer or authorized isolated branches; fallback to sequential work where delegation is unavailable.

## E4 — Interrupt/resume and real execution boundaries

Prompt: New Codex session resumes two epics with an unresolved approval and independent ready work.
Expected: Inspect Git/current docs/test evidence, reconcile board, resume independent ready work while still asking user approval for financial decisions and merge. Never report that agents worked while the session was closed.
