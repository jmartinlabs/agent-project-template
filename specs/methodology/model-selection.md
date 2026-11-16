# Adaptive model selection

The user controls the coordinator model; never change it as a consequence of delegation.
Verify client capabilities before selecting subagent settings. Unknown availability is not
permission to inherit an unchecked model. Model choice never replaces verification,
independent QA or protected approvals. Report savings only from real telemetry.

## Codex subagents: absolute ceiling
The maximum permitted combination is `gpt-6.1-sol` + `low` (UI: GPT-6.1 Sol Light).
Never automatically escalate model or reasoning above this ceiling, including for QA.
Use an explicitly selected economical available model for straightforward bounded work;
reserve `gpt-6.1-sol` + `low` for complex or critical work. There is no numeric cost or
capability ordering across model families: use a verified permitted economical option,
not an inferred ranking. Never substitute Astra or another unverified family/version.

Before dispatch, record requested model/effort, available controls and the selection
assurance supplied by the runtime. In this Codex runtime, explicit `model` and
`reasoning_effort` overrides require fresh context (`fork_turns="none"`); full-history
forks inherit settings. Recheck this capability in other clients/versions. If selection
cannot be guaranteed within the ceiling, do not spawn; record the limitation and work
sequentially within authorization, or propose a manual permitted alternative. Never
silently inherit an unchecked coordinator model. Do not raise the coordinator model.

After dispatch, verify observed model/effort from attributable runtime metadata or local
records when exposed. Record requested versus observed values and evidence; an agent's
self-report is insufficient. Missing metadata means **effective selection unverified**,
not a passed check. A mismatch stops further dispatch and requires investigation at a
safe boundary; never compensate by escalating.

### Delegation routes

A delegation route is a **slot**, not a fixed model: a named entry in the client's
`delegation.backends.model_map.options` that maps a label to a provider, a model and an optional
reasoning effort. `worker`, `advisor` or any other name may change provider, model or effort
without touching the verifier, its tests or this document. Treat the values as configuration the
user owns; portable guidance never hardcodes a provider, model or effort.

A per-task route parameter can fail to reach the tool: the call arrives without it, no error is
raised, and the task runs on the backend's `default` route — for example, a review requested on a
review slot silently executed on the default worker. The failure is silent, so the result alone
never proves which route ran. As a mitigation, keep `goal` short and carry the payload in
`context`; the runtime copies the arguments it receives verbatim, and an argument lost before
dispatch cannot be recovered downstream. That reduces the risk; it never replaces verification.

Read the effective route from attributable metadata. While a delegation runs, a client that
exposes per-child state may report each child's model; afterwards,
`scripts/check-delegation-route` reads the profile's `state.db`:

```sh
scripts/check-delegation-route --profile <profile> --delegation <id> \
    --expect-label <option> [--expect-provider <provider>] \
    [--expect-model <model>] [--expect-effort <effort>]
```

It is read-only (`mode=ro`), makes no network or model calls and changes no configuration. It
respects the active profile: `--state-db` wins, then `--profile`, then `HERMES_HOME`. It emits
PASS only when the delegation and every task finished `completed` and every requested
expectation matched.

- `0`: the delegation completed and every task finished on every requested expectation.
- `1`: a task did not finish, did not match, or the delegation has no results or did not complete.
- `2`: no verdict is possible here — no expectation, a missing or unreadable `state.db`, an
  unknown delegation, or unreadable or malformed metadata. Exit 2 is never a pass.

Where the expectations come from:

- **Recovered per task**: route `label`, `provider`, `model`, `reasoning_effort` and task `status`.
- **Not recovered**: the option name requested at dispatch. The runtime persists the resolved
  route and `task_json.model` (the model resolved at dispatch, blank when a batch mixed routes),
  not the requested `option`, provider or effort.
- Supply expectations from the `options` entry actually used **at dispatch** — never from
  configuration read afterwards and never from an observed value, which would make the check
  circular. Configuration can change between dispatch and check, so a model configured now is
  not the one expected then.
- Prefer `--delegation <id>` over `--latest`: with concurrent sessions the newest row may belong
  to another delegation.

On a client whose state is not this local store, the verifier cannot answer (exit 2). Report the
route as unverified and use that client's attributable records; missing metadata is not evidence
that a route failed and says nothing about another client's quota.

## Portable advice
| Work | Suggested tier | Suggested reasoning |
| --- | --- | --- |
| Straightforward Quick | efficient | low |
| Bounded Standard implementation | balanced | within client policy |
| Architecture, ambiguous debugging or critical review | advanced | within client policy |

These are advisory capability labels, not permission to exceed the Codex ceiling.
Keep the current coordinator model when adequate. In Claude Code retain existing
`model: inherit` profiles unless an authorized client-specific selection is supported;
Claude model/effort names are not equivalent to GPT settings. Codex limits apply to
Codex subagents even when another client coordinates them. Do not invent cross-client
quota or telemetry. When unavailable, use smaller verifiable increments or report a blocker.

Load this document when model advice matters, normally Standard / Full. Report one compact
line: task, client, requested model/effort, assurance and observed evidence (or
`suggested, availability unverified`). Add no separate approval gate beyond quota and
existing project approvals. Native client settings remain subject to actual availability.
