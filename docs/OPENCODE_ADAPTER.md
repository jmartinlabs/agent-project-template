# OpenCode adapter: native `review` subagent

This adapter registers **one** OpenCode-native subagent, `review`, for the pilot scope in
OPENCODE-NATIVE-AGENTS-01. It is a thin client wrapper over the canonical
[QA/Review role](../.agents/roles/qa-review.md). It is not a launcher or controller for
external OpenCode sessions and does not replace the role contracts.

## Registration

OpenCode V2 discovers Markdown agents under `.opencode/agents/<name>.md`. The file
[`.opencode/agents/review.md`](../.opencode/agents/review.md) sets:

- `mode: subagent`, so a primary agent can launch it through the native `subagent` tool;
- `description`, so the parent model can choose it explicitly;
- `permissions`, with a broad deny followed by narrow `read`, `glob` and `grep` allows.

No model is pinned. OpenCode's documented behavior is to inherit the parent session model
for a subagent without a model; this adapter does not configure a provider or model.

Check the registration on the installed client:

```sh
opencode debug agents | jq -r '.[] | select(.id=="review")'
```

## Canonical contract

The adapter body is deliberately short. It reads
[`.agents/roles/qa-review.md`](../.agents/roles/qa-review.md) as the single source of truth
and requires the coordinator's work packet, including its **Applicable rules** and return
schema. Role rules are not copied into the adapter.

The pilot narrows the QA/Review profile to a **read-only documentary audit**. It must not be
confused with functional QA: it cannot execute tests, edit files or run commands. A task that
needs those actions returns `BLOCKED` or `UNRUN` to the coordinator.

## Permissions

OpenCode applies permission rules in order, and the last matching rule wins. The adapter
denies `*`, then allows only local discovery and reading:

```yaml
permissions:
  - action: "*"
    resource: "*"
    effect: deny
  - action: read
    resource: "*"
    effect: allow
  - action: glob
    resource: "*"
    effect: allow
  - action: grep
    resource: "*"
    effect: allow
  - action: read
    resource: "*.env"
    effect: deny
  - action: read
    resource: "*.env.*"
    effect: deny
  - action: read
    resource: "*.env.example"
    effect: allow
```

Environment files are denied explicitly except `.env.example`. In a live V2.1.4 check,
`shell`, `edit`, `webfetch`, `websearch`, `browser` and `subagent` were absent from the tool
schema; `skill` remained listed but every call was rejected with `permission.rejected`, and a
read outside the workspace was rejected as `external_directory`. The restriction is enforced
by OpenCode permissions, not by asking the model to behave.

This is a documentary-audit boundary, not a general security sandbox. Broad workspace `read`
access is intentional so the agent can inspect repository documents; it is not suitable for
handling secrets.

## Delegation

A coordinator in a primary session can delegate explicitly:

```text
Use the review subagent to audit <path or candidate> against <spec>.
Return findings with file/line evidence and PASS, FAIL, BLOCKED or UNRUN.
```

The parent launch is visible as a `subagent` tool call with `agent: "review"`. When the user
has declared OpenCode available for the execution, a direct smoke test can start a session
with the same agent:

```sh
opencode run --agent review --model provider/model "Audit <path>. Do not edit files."
```

Passing `--model` is a test-time choice; it is not stored in the adapter.

## Limits and compatibility

- Verified against OpenCode V2.1.4 on 2026-11-02. Earlier versions or V1 configuration may
  register agents differently.
- The adapter is project-local; it does not alter global OpenCode configuration.
- Codex and Claude Code are unaffected. The existing `.claude/agents/qa-review.md` profile
  still offers `Bash` for a client-level QA task; it is not this read-only OpenCode agent.
- The pilot cannot run tests, write files, fetch the web or launch child agents. It is
  therefore not a replacement for functional QA or implementation review that needs execution.
- Background subagent support and external-session control are not claimed or tested here.

## Validation

The template validation keeps the adapter wired to its canonical role and read-only shape:

```sh
./scripts/validate-template
./scripts/test-validator
opencode debug agents | jq -r '.[] | select(.id=="review")'
```

A live smoke test should show the agent reading the canonical role, returning evidence, and
receiving no shell or edit tool. Do not claim live compatibility from file presence alone.

## Extending later

Do not add `functional`, `implementation` or `infrastructure` adapters merely for symmetry.
Each needs different capabilities and risk handling:

- `functional` needs scoped document writes and should not approve its own spec;
- `implementation` needs edit and test execution, which requires path/command scoping and the
  existing QA gates;
- `infrastructure` needs shell access, the hardest capability to bound safely.

Extend only with a concrete need, an explicit permission design, and separate validation of
registration, delegation and denied actions. Keep one canonical role file per profile and a
minimal adapter per client.
