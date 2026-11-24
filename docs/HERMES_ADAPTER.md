# Hermes adapter

Status: **implemented and verified at the depth stated below**. Hermes is an **additional
client** of the existing methodology: nothing was removed, no canonical contract was edited,
and `.claude/`, `.opencode/`, `.codex/`, relay, usage metrics and the board template stay as
they were.

**Delegation with Hermes is not validated.** No delegated run exists: `delegate_task` has
never been exercised by this harness, foreground or background, so P2 and P2b remain
**UNRUN**. Everything proven here is a single foreground session.

Governing constraint: **compatibility at the lowest possible cost.** A canonical file changes
only for a reproducible defect, with the smallest edit that removes it. Everything else stays
listed as optional and unapplied.

Evidence legend, used for every claim:

- **[OBS]** observed in this checkout or in a recorded probe run.
- **[DOC]** stated by the Hermes documentation or its shipped source contract (file and line
  cited).
- **[UNRUN]** not exercised; a probe exists, or the stage is described in §6.

A documented capability is never promoted to a passed check.

## 1. What changed in this repository

| File | Change | Why |
| --- | --- | --- |
| `AGENTS.md` | Three lines: Hermes added to the invocation mapping, plus `hermes skills trust` and the adapter link | A Hermes session read a mapping that excluded it (§2) |
| `README.md` | One paragraph and link in the portability section | Discoverability of the third client |
| `scripts/validate-template` | `docs/HERMES_ADAPTER.md` added to `REQUIRED` and to the link-checked docs | Keeps the adapter from drifting silently |
| `docs/HERMES_ADAPTER.md` | This document | The adapter itself |
| `evals/results/2026-11-10-hermes-*` | P0, P-ISO and P1 probes, logs and summaries | Evidence, exactly as executed |

No Skill, role, workflow, spec or other client's file was modified.

## 2. Compatibility that already exists

| Harness element | Hermes surface | Evidence |
| --- | --- | --- |
| `AGENTS.md` as canonical entry point | Injected from the session cwd, capped at 20,000 chars (current file ≈5 KB) | [OBS] P1: the session quoted Skill names that appear only in `AGENTS.md` |
| `.agents/skills/*/SKILL.md` (11 Skills at verification time) | Native project-skill path, highest-precedence tier, rendered as `[project]` rows | [OBS] P0 and P1: 11/11 discovered, 11/11 visible to a live session (§6) |
| Skill frontmatter (`name`, `description`) | Same format; description ≤60 chars recommended, the current ones are longer | [DOC] |
| Work packet + role contracts | Map onto `delegate_task(goal, context)` and to kanban task descriptions | [DOC] |
| Scorer contract `{"version","responses":[...]}` | Platform-neutral, no change needed | [OBS] source read |
| Structural validation | `./scripts/validate-template` passes with this adapter | [OBS] |

`.claude/skills/` (thin wrappers, 11 at verification time) is **not** a Hermes candidate directory: candidates are
`<project>/.hermes/skills` and `<project>/.agents/skills`. [OBS] P0 asserted the wrappers are
never scanned, so nothing double-loads or shadows.

## 3. Using Hermes with this template

```sh
hermes skills trust <repo>     # once per checkout; revocable with `hermes skills untrust`
hermes                         # start at the repository root, never in a subdirectory
/orchestrate                   # project Skills are exposed as slash commands
```

Two operational facts that cost real time if unknown:

1. **Trust is per checkout and per profile home.** Without it no project Skill loads, and
   `hermes skills list` will still print `0 hub-installed, 0 builtin, 0 local` — that command
   does not enumerate the project tier at all. Verify discovery through the resolved index or
   a live session instead. [OBS]
2. **`AGENTS.md` is cwd-only.** A session started below the repository root silently loses
   every rule. Start at the root (§5 R1).

## 4. Incompatibilities — all conditional

Each activates only when the named surface is used. Direct, foreground work with manual
approvals touches none of them.

| # | Incompatibility | Activates when | Evidence | Mitigation that changes no contract |
| --- | --- | --- | --- | --- |
| I1 | **Background delegation is turn-bounded.** A child's result re-enters only as a new turn, so a coordinator cannot observe it inside the same turn. | background `delegate_task` | [DOC] | Foreground delegation only. If background is later wanted, add a clause here, not to `orchestrate`. |
| I2 | **`delegate_task` is not durable.** | work must outlive the process | [DOC] process-local | Never use it for durable work. `cronjob`/`kanban` are durable but contradict the current "no background continuation" wording, so they stay disabled. |
| I3 | **Children cannot ask the user** (no `clarify`, `delegate_task`, `memory`, `cronjob`). | any delegated work | [DOC] tool contract | The work packet already carries stop conditions; the child returns the decision instead. |
| I4 | **No effective-model metadata per subagent.** | requested-versus-observed model evidence is required | [DOC] not exposed | Mark those eval cases **N/A for Hermes**, not failed. |
| I5 | **Approvals are semantic here, shell-shaped there.** Hermes gates shell commands and never prompts for file writes; the one-shot runtime bypasses approvals entirely. | any runner or merge path | [OBS] `run_oneshot` sets `HERMES_YOLO_MODE=1` unconditionally (`hermes_cli/oneshot.py:276`) | Keep `approvals.md` as the single semantic gate; never read a Hermes command approval as consent; never run with `--yolo`. |

## 5. Operational risks

| # | Risk | Mitigation |
| --- | --- | --- |
| R1 | `AGENTS.md` is cwd-only in Hermes; a session started in a subdirectory loses every rule. | Always start at the repository root (`--in <repo>`). |
| R2 | Editing `AGENTS.md` mid-session does not re-inject it. | Apply policy changes in a fresh session. |
| R3 | Project Skills pass the same injection scanner as hub installs; a `dangerous` verdict refuses to load by name. | [OBS] all 11 verdicts are `safe` (19 `persistence` findings, severity `low`, scanner `skills-guard-v10`). Quoted attack text stays in `evals/`, which is not scanned as a Skill. |
| R4 | `--yolo` / `approvals.mode: off` widen the blast radius beyond this methodology's gates. | Not used; `approvals.mode` unchanged; no allowlist edits. |
| R5 | Cron/kanban are durable and would contradict the "no background continuation" wording in `AGENTS.md` and `dynamic-agents.md`. | Out of scope; enabling them is a separate authorized step that needs canonical wording. |
| R6 | Trust is per checkout: a fresh clone of a derived project loads no Skills until trusted. | Documented once in the derived project's README, not in a Skill. |
| R7 | **Every chat turn runs in a host gateway, and the gateway reservation is pinned to the owning profile root.** A throwaway `HERMES_HOME` cannot start its own gateway while the host one runs: `Operation not permitted: '~/.hermes/gateway.lock'`, then `Gateway runtime already owns profile`. | [OBS] §6.2. For a session, use the user's own profile — the gateway already serves it. For an isolated runner, drive the one-shot runtime directly (`hermes_cli.oneshot.run_oneshot`, the function `-z` calls), which builds the agent without the gateway. |
| R8 | **The Skills index in a session is gated on the skills toolset, not only on trust.** With `-t vision` the index is empty (0 chars); with the `skills` tools present it renders 2,058 chars and 11 `[project]` rows. | [OBS] §6.3 P1a, [DOC] `agent/system_prompt.py:302-315`. Any run that must see project Skills has to include the `skills` toolset, which also brings `skill_manage` (a writer). Contain writes with the OS sandbox (§6.4), not by shrinking the toolset. |
| R9 | The launcher opens `~/.hermes/installs/<key>/pm-runtime/.prepare.lock` before any Python starts. A write jail that allows only the fixture aborts the launch: `install state is not writable by this user`. | [OBS] §6.2. Carve out that directory; it is launcher plumbing, not repository, config or credentials. |

## 6. Verification — three stages, all recorded

Every stage runs in a **disposable clone**; P0 and P1 additionally under a **throwaway
`HERMES_HOME`**. Client: Hermes Agent **v0.23.0** (2026.9.24), build `2bd378ed1b8d`, git
install, Python 3.14.9, macOS 15.5 arm64.

```sh
FIX=$(mktemp -d)/agent-project-template
git clone --no-hardlinks . "$FIX"
export HERMES_HOME=$(mktemp -d)/hermes-home
```

### 6.1 P0 — discovery, no model: **PASS 18/18**

Probe: [`evals/results/2026-11-10-hermes-p0-probe.sh`](../evals/results/2026-11-10-hermes-p0-probe.sh).
Two identical runs, zero model calls.

| Observation | Result |
| --- | --- |
| Canonical Skills found under `.agents/skills` | 11 |
| Loaded after trust | 11, one unique `load_name` each |
| Quarantined | 0 (all verdicts `safe`) |
| Scanner findings | 19, all `persistence`, severity `low` |
| Rendered Level-0 index | 2,072 chars, 11 `[project]` rows |
| `.claude/skills` scanned | no |
| Collision with 43 installed profile Skills | none |
| Trust stored in the throwaway home only | yes; real profile keeps `trusted_project_dirs: []` |
| Origin repository | HEAD and 14 file hashes identical before/after |

Evidence: [`summary`](../evals/results/2026-11-10-hermes-p0-summary.json),
[`discovery log`](../evals/results/2026-11-10-hermes-p0-discovery.log),
[`rendered index`](../evals/results/2026-11-10-hermes-p0-index.txt).

### 6.2 P-ISO — isolation proof, no model: **PASS**

Two probes, two roles. The one that runs from now on aims **every** write at a disposable
decoy and uses a **synthetic** config; the first run is kept unchanged because it was actually
executed, and its write attempts did point at the real checkout and the real profile (all
denied, both untouched afterwards).

| Probe | Result | Write attempts at real paths |
| --- | --- | --- |
| `2026-11-10-hermes-piso-probe.sh` — historical, unchanged | 26/26, 2 identical runs | 2 (real checkout, real profile): both denied, verified unchanged |
| [`-piso-probe-v2.sh`](../evals/results/2026-11-10-hermes-piso-probe-v2.sh) — current | 27/27, 2 identical runs | 0: decoy checkout, decoy profile home, synthetic config |

Both are model-free and network-free. Evidence: historical
[`log`](../evals/results/2026-11-10-hermes-piso.log) and
[`summary`](../evals/results/2026-11-10-hermes-piso-summary.json); current
[`log`](../evals/results/2026-11-10-hermes-piso-v2.log) and
[`summary`](../evals/results/2026-11-10-hermes-piso-v2-summary.json).

| Group | What was proven |
| --- | --- |
| A (14 checks in v2) | `sandbox-exec` denies writes to a checkout-shaped decoy, a profile-home-shaped decoy, `/tmp` and through a symlink pointing outside the fixture; the same path is writable with no profile and with a profile that allows it (A/B controls); a sandboxed `hermes config set` leaves the synthetic config byte-identical while the unsandboxed control changes it; reads stay allowed; and A11 asserts statically that neither the real checkout nor the real profile is covered by any allow rule, and that both are writable without the jail — so a write there would be denied by the rule, without aiming one at it |
| B (4 checks) | `file` toolset = `read_file`, `write_file`, `patch`, `search_files`; the `vision` surface composed by the runtime is exactly `vision_analyze`; no mutating tool in it |
| C (6 checks) | the pre/post manifest is stable on a clean tree, catches one appended byte (exactly one changed path), is restored by revert, catches an untracked file, and catches a same-size byte flip whose mtime was restored — a timestamp check does not |
| D (3 checks) | origin hashes identical before/after, real profile config and trust unchanged, fixture clean |

Evidence: [`log`](../evals/results/2026-11-10-hermes-piso.log),
[`summary`](../evals/results/2026-11-10-hermes-piso-summary.json).

### 6.3 P1 — one live session, one model call: **PASS 8/8**

Probe: [`evals/results/2026-11-10-hermes-p1-probe.sh`](../evals/results/2026-11-10-hermes-p1-probe.sh).
Model `deepseek/deepseek-v4.1-flash`, provider `commandcode`, chosen before the run. One API
call, 8,096 total tokens, `completed: true`.

| Check | Result |
| --- | --- |
| P1a1 — skills index with `-t vision` only | 0 chars: the index is gated on the skills toolset |
| P1a2 — skills index with the skills toolset | 2,058 chars, 11 `[project]` rows |
| P1b1 — live session names the project Skills | all 11 present in the response |
| P1b2 — workflow classification | `Quick` for "fix a typo in README.md" |
| P1b3 — cost accounting | `api_calls=1` |
| D1–D3 | origin hashes identical, real profile unchanged (`trusted_project_dirs: []`), fixture clean |

The run used `toolsets=["vision","skills"]` and `skills=["orchestrate"]` under the write jail.
It bypassed only the gateway dispatch layer (R7); the session itself was built by
`hermes_cli.oneshot.run_oneshot`.

**Corrections this stage forced on earlier drafts of this document**, applied in place:

1. **A write jail must carve out the launcher's install state** (R9). Denying it does not
   isolate more; it aborts the launch.
2. **`-t vision` cannot show project Skills** (R8). The earlier P1 criterion — "the session
   reports 11 project Skills" with `-t vision` — was unreachable. The toolset is now
   `vision,skills`, and write containment rests on the sandbox and the manifest.
3. **`--run-budget` is rejected for chat turns**: `Unsupported gateway CLI options:
   --run-budget ... use agent.run_budget_seconds in config.yaml`. [OBS] Use a wall-clock
   timeout around the process instead.
4. **`-t/--toolsets` sets the session tool surface** (`hermes_cli/main.py:1756` passes
   `args.toolsets` into the CLI session) **and** narrows which MCP servers spawn
   (`main.py:2888-2895`). An earlier draft read only the second half.
5. **The one-shot runtime bypasses approvals unconditionally**, so an eval run never carries
   approval semantics (I5).

### 6.4 Manifest, not flags

Absence of action is proven by the fixture, not by flags. The isolation stack, each layer
observable:

1. disposable clone, never the real checkout;
2. `toolsets=["vision","skills"]` — the smallest set that can still show the Skills index (R8),
   accepting that `skill_manage` is a writer;
3. OS write jail (`sandbox-exec`) denying every write outside the fixture, the run directory
   and the launcher's install state (R9);
4. pre/post manifest: `git status --porcelain` plus a `sha256` of every file and the HEAD;
5. post-hoc assertion over the response and the usage report;
6. a wall-clock timeout, as a ceiling, never as a safety control.

The manifest is the pass/fail signal; layers 2, 3 and 5 only reduce the chance a mutation is
attempted. The jail does **not** restrict network access — a model call needs it — and reads
stay unrestricted (P-ISO A10); both are deliberate.

### 6.5 Not proven

Still **UNRUN**: that a foreground `delegate_task` returns in the same turn (P2); that a
background dispatch produces no artifact (P2b); that the scorer accepts Hermes responses end
to end (P4); that cron, kanban and background continuation behave under this methodology;
variance — one run per stage cannot establish it; and behavior under a model other than the
one pinned above. P1 proves one session, not a suite.

## 7. Optional changes (not applied)

| # | Change | Benefit | What would justify it |
| --- | --- | --- | --- |
| O1 | Repo-root-relative links inside Skills (currently `../../../specs/...`) | Removes path-resolution ambiguity | A probe showing a session resolving `../../../` against the skill directory instead of the repo root. No repro today. |
| O2 | Descriptions ≤60 chars, `metadata.hermes.tags` | Smaller always-on index | A measurement showing the current index (2,058 chars) costs real context. It does not today. |
| O3 | Fold `tweak`/`task` into `orchestrate` | Fewer entry points | Only if the operator finds 11 slash commands confusing. |
| O4 | `.hermes.md` at repository root | Inherits rules into subdirectories | Only if sessions start below the root (R1). |
| O5 | Hermes-only eval scenarios (`hermes-01..06`: background dispatch, cron without opt-in, child needing a decision, closing a task with an UNRUN check, "dale" before a merge, a decision written to memory) | Covers surfaces no other client has | After P2 and P4 pass; none exists today. |
| O6 | Scorer `target` normalization (case, articles, backticks, declared synonyms) | Strict comparison scores paraphrases as failures | Independent of Hermes; report decision / target / criteria separately before adding a client. |

## 8. Decision status

Authorized and executed: discovery, isolation proof and one live session, each with its probe
and log committed. Published for review; **not merged**.

Still requires separate authorization: any edit to another canonical file, P2 (delegation), P4
(eval smoke), enabling cron/kanban, and any deletion. Merges and deployments are never covered
by this adapter.

## Delegation routes (effective-model check)

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

The generic requested-versus-observed rule is in [orchestrate](../.agents/skills/orchestrate/SKILL.md#procedure) (step 7); this section is the Hermes-specific way to read the observed route.

## Issue work identity

When Hermes runs `work-issue`, it passes `--agent hermes` to `scripts/work-issue` and works the
Issues without an agent label plus those labelled `agent:hermes`; see the
[work-issue Skill](../.agents/skills/work-issue/SKILL.md). It never reserves under another agent's name.
