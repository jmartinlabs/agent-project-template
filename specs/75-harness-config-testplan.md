# SPEC 75 — verification plan

Approved contract: [revision 3](https://github.com/jmartinlabs/agent-project-template/issues/75#issuecomment-7146427251).
Base: `0890aa933e910330c0a463271ecf56d7e314f75b`. Execution is local in the candidate checkout and in template CI.

| Acceptance | Check and expected evidence |
| --- | --- |
| AC-01, AC-10 | Inspect the orchestration entry, worker packet and `harness-01..02` cases. One active file, no worker or ambiguous dispatch. Adapters with no effective profile evidence stay unsupported. |
| AC-02, AC-04 | Run `./scripts/validate-template` and `./scripts/test-validator`. Check closed schema, malformed and duplicate JSON, optional files, and direction-specific automatic review. |
| AC-03, AC-06 | Review the per-field table in the procedure and run the behavioral fixture cases. Check null and absent values, exact owner authorization, and stopping on explicit unavailable choices. |
| AC-05 | Compare the Git base v1 agents object with candidate `claude.json.external`. Inspect the preserved CLI constraints and compare negative directions. No external model execution. |
| AC-07 | Run template and validator checks, behavioral scorer and fixture runner. Independent QA checks the candidate and this mapping. |
| AC-08 | Review the Git diff and normal entry points. Confirm a single migration change, no v1 lookup and no startup/sibling reads. |
| AC-09 | For a native surface to claim support, execute standard and complex through the native path and capture the effective model and effort per child. No native surface ships as supported without that evidence. |

Behavioral fixture command: `python3 scripts/eval-agent-behavior --responses evals/sample-responses.json`. It checks the scorer, not execution on a real model. Native profile trials remain unrun and the corresponding capabilities remain unsupported.
