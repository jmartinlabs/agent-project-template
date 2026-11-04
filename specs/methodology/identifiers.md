# Identifier and stage convention

Status: **approved methodology** · Scope: every project derived from this template.
This is additive: it does not rename existing documents, branches, PRs or historical IDs.

## 1. Functional identifier

Each project declares its own **functional identifier** grammar in `AGENTS.md` or in its
`specs/README.md`, once, before the first work packet. The identifier:

- names a **capability or initiative**, never a phase, agent or document;
- is **stable and unique** for its whole life; never reused or renumbered;
- is **traceable** to its canonical documents, tasks, tests, PRs and commits.

Recommended default grammar: `[A-Z][A-Z0-9]*(-[A-Z0-9]+)*` and an optional numeric segment,
for example `AUTH`, `BILLING-02`, `E4.10`. A project may use another documented grammar when
its domain requires it. Do not impose one project's grammar on another.

A material scope change creates a **new** functional identifier. Do not recycle an old one.

## 2. Stages

Exactly four stages, each with independent state:

| Stage | Purpose | States |
| --- | --- | --- |
| `SPEC` | Requirements, decisions, contracts, acceptance design | planned → drafting → awaiting-approval → approved → superseded |
| `DEV` | Authorized implementation | not-ready → ready → implementing → testing → verified |
| `QA` | Independent verification against the candidate | planned → test-design → awaiting-candidate → verifying → passed / failed / blocked |
| `MERGE` | Publication and merge gate | not-ready → PR-open → ready-for-review → authorization-pending → approved → merged / closed |

Rules:

1. A state in one stage never implies a state in another.
2. `SPEC approved` authorizes drafting only where the project says so; it never authorizes DEV.
3. `DEV verified` and `QA passed` never authorize MERGE.
4. Only the user grants functional acceptance and merge approval.
5. A blocked stage names its prerequisite and owner; it is not marked "done by inference".

### Functional acceptance

Keep acceptance as a **separate verdict**, not a fifth stage:
`pending / favorable-with-reservations / accepted / rejected`, with source and date.
It never replaces per-stage evidence and never turns a partial or unrun check into a pass.

## 3. Development blocks

- Blocks are named `DEV-01`, `DEV-02`, … with a short functional description:
  `DEV-02 — Read model and API`.
- Numbering is **local to the functional identifier**, never global across projects or features.
- A block keeps its identity while pending; its number does not mean completed.
- Historical labels such as `A`, `B`, `C` remain valid aliases. Record their equivalence in
  the project's index; do not mass-rename history.
- New blocks continue the sequence after the historical aliases (for example `DEV-04` when
  `A/B/C` map to `DEV-01/02/03`). A project that starts fresh begins at `DEV-01`.
- Each block has one owner, one isolated checkout or disjoint write ownership, its own
  verification and a return to the coordinator.

## 4. Traceability without a second tracker

The existing `specs/epic-board.md` remains the single operational state owner when several
live workstreams need scheduling. A bounded feature uses its progress and testplan documents.

Each row records:

- functional identifier and descriptive name;
- `SPEC`, `DEV`, `QA` and `MERGE` states, plus functional acceptance;
- DEV blocks with their descriptions and state;
- canonical documents, work packets, owner/role and isolated branch;
- evidence and verification links;
- blocker or decision needed, and next independent action.

Do not create a parallel tracker, duplicate status table or second board. Link documents;
do not copy their status. Historical records stay available behind links.

## 5. Work packets and PRs

- Work packet ID: `<functional-id> · <STAGE>-<NN>`, for example `E4.10 · DEV-02`.
- A packet names one stage and, for DEV, one block. Corrections keep the same packet ID.
- Commit messages and PR descriptions reference the functional identifier and stage; they do
  not invent new tracking IDs.

### Pull request titles

Recommended format:

```text
<type>(<scope>): <STAGE>[-<BLOCK>] — <description>
```

- `<type>` is a conventional type: `feat`, `fix`, `test`, `docs`, `chore`, `refactor`.
- `<scope>` is the stable functional ID as a lowercase slug without separators that break
  parsing (`E4.10` → `e410`). Cross-cutting work uses a documented slug such as `theme` or
  `ci`.
- `<STAGE>` is `SPEC`, `DEV` or `QA`. `MERGE` is a tracking stage and never needs its own PR.
- `<BLOCK>` is `DEV-01`, `DEV-02`, … when the PR covers one block. If it covers several,
  use `DEV` and list the included blocks in the description.
- Keep the GitHub `#NNN` number; never renumber or mass-rename historical PRs.
- Keep titles short and descriptive; they must remain valid under the project's existing
  conventions and validators.

Examples:

```text
docs(e410): SPEC — reapertura de cierres
feat(e410): DEV-01 — modelo de reapertura
feat(e410): DEV-02 — API y controles
test(e410): QA — pruebas de reapertura
fix(e410): DEV-02 — corrección del bloqueo histórico
feat(theme): DEV-01 — sistema de temas y shell
```

## 6. Compatibility and validation

- Existing documentation numbers, `SPECnn`/`DEVnn`, PR numbers and A/B/C labels are historical
  references; keep them and map them in one index.
- Validators check structure only: identifier presence, stage/state vocabulary, board columns,
  packet fields and alias uniqueness. They never infer approval or state truth.
- A new project documents its grammar and adopts the four stages before the first DEV block.
- A project that does not adopt this convention keeps working; adoption is additive.
