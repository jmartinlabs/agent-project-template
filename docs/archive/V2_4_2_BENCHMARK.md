# v2.4.1 vs v2.4.2 reproducible client benchmark

This protocol is a deliverable, not a completed performance experiment. No client
telemetry or real benchmark runs were provided; all performance results are UNRUN.
Static file sizes and scorer fixtures do not measure tokens consumed or agent behavior.

## Revisions and controls

- Historical v2.4.1: `ffc3e2a43e0b24d6038c151d0c9845a3a386b778`.
- Integration baseline: `542a6aa9af090728a1c4e700abe587bbe563e3e8` (v2.4.1 plus handoff).
- Candidate: resolve the exact PR HEAD before running and record its full SHA.

Use a disposable fixture repository, identical tracked files, clean Git state and
identical tool permissions for each run. Provision separate copies within the authorized benchmark scope, applying the
[local worktree policy](../../specs/methodology/approvals.md#local-worktrees) where relevant; a packet grants no new scope. Install each revision's
methodology into its own copy, preserving identical project restrictions. To separate
the handoff addition from this release, compare the integration baseline as a third arm.
Pin fixture commit, prompts, client/version, model/effort, OS, tools and dependency
versions. Use fresh sessions with matching cache conditions, no previous approvals
except those specified below. Do not silently force a workflow label or bypass a gate.
Run Codex and Claude Code separately, with at least three paired repetitions per task;
alternate revision order. Preserve raw client traces and artifact diffs for each run.

## Fixed tasks

Use the same fixture at both revisions: a documentation typo `teh`, a CLI without a limit option and with existing tests, and a second independent module. Include
only the relevant project stack in guidelines. Record fixture SHA and exact commands.

| Class | Exact user prompt | Observable success |
| --- | --- | --- |
| Quick | Fix `teh` to `the` in the fixture README; change nothing else. | Only typo changes; diff reviewed; no protected action. |
| Standard | Add a CLI `--limit` option using existing patterns, default 10, accepting 1 through 100; print the selected integer instead of ready, reject invalid input with a nonzero exit and explanatory error, and test default, bounds and invalid input. Propose Standard first. | Plan confirmed, implementation and meaningful tests pass. |
| Full | Plan a change spanning the CLI and second module to share limit validation. Propose Full, provide a shared integer validator raising ValueError outside 1–100, preserve CLI behavior, and specify compatibility and errors before implementation. | Spec and any project gates approved, candidate verified and required independent QA complete. |

For Standard/Full respond to the first workflow request with an explicit approval
naming its exact scope. Approve the presented specification only if it meets the
fixed criteria, using an explicit approval verb and revision. Do not pre-approve
unseen specs. Count necessary confirmations separately from repeated ones. Never
merge, deploy or mutate production during the experiment. Historical v2.4.1 lacks
handoff: record that as unsupported rather than simulating a pass.

## Capture schema and measurement

One row per run, with trace references and units:

```csv
run_id,revision_sha,fixture_sha,client_version,model,effort,cache_state,task,input_tokens,output_tokens,cached_tokens,files_loaded,bytes_loaded,time_to_first_change_ms,confirmations,tool_calls,delegations,result,trace_ref
```

Read tokens exclusively from actual client telemetry, retaining its definitions
and treatment of cached/tool tokens. Record unavailable values as `NA`, never zero.
For files/bytes loaded count content actually delivered to the agent according to
the trace (partial reads and repeated loads included); also retain distinct file
paths. Do not substitute the size of repository files or requested tool output.
Time starts at the initial submitted prompt and ends at the first observed file
mutation; retain wall time and user-wait time separately. If no change occurs,
record `NA` and the blocker. Count tool invocations including failures, confirmations
that required user response, and actual delegate launches, not role files. Record
PASS/FAIL/BLOCKED/UNRUN against the observable criteria, checks and candidate SHA.

Report paired per-task medians and ranges with raw rows, sample count, missing
metrics and failures. Do not infer token/latency savings from instruction length.
Run the decision scenarios using the procedure in [agent evals](../AGENT_EVALS.md) in
both clients as a separate experiment. A decision-only trial is not an execution
benchmark, and the scorer self-test invokes no model.

Current results: Quick UNRUN; Standard UNRUN; Full UNRUN on both revisions and clients.

## Deterministic fixture source

In the authorized disposable fixture directory, run this Python 3 standard-library
setup once, commit the output and record its SHA. It intentionally contains a
separate `limits.py` so the Full task can move the Standard validation into it.
Copy this same fixture commit for every methodology revision; never modify it
between paired runs. Use `python3 -m unittest -v` as the initial check. Standard
acceptance includes CLI calls with omitted limit, 1, 100, 0, 101 and non-integer
input; invalid values must return a nonzero exit code and an explanatory error.
Full must preserve these observable results while sharing validation with the
second module, including direct-call tests. Require tests against the actual code.

```python
from pathlib import Path
files = {
    'README.md': '# Fixture\nFix teh typo.\n',
    'cli.py': '''import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.parse_args()
    print("ready")


if __name__ == "__main__":
    main()
''',
    'limits.py': '''"""Second module for the shared validation task."""


def describe():
    return "limit validation fixture"
''',
    'test_cli.py': '''import subprocess
import sys
import unittest


class CLITests(unittest.TestCase):
    def test_ready(self):
        result = subprocess.run([sys.executable, "cli.py"], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), "ready")


if __name__ == "__main__":
    unittest.main()
''',
}
for name, content in files.items():
    path = Path(name)
    if path.exists():
        raise SystemExit('Refusing to overwrite fixture file: ' + name)
    path.write_text(content, encoding='utf-8')
```

The Standard expected output becomes the selected integer limit instead of `ready`;
record this requirement with the unchanged prompt above before each run. Existing
smoke tests must be updated to the new expected output, not removed. For Full, ask
for a shared callable that validates integer inputs and rejects values outside
1–100 with `ValueError`; it must preserve CLI behavior and avoid unrelated changes.
These criteria form the fixed approval checklist, not an automatic spec approval.
