# OpenCode adapters: native review and specialized subagents

This document covers four optional OpenCode-native subagents: the read-only auditor `review`
and the specialized `functional`, `implementation` and `infrastructure` adapters. Each is a
thin client wrapper over its canonical role in [`.agents/roles/`](../.agents/roles/), never a
replacement for that role contract. None is a launcher or controller for external sessions;
each is an adapter, not a launcher.

The **review adapter** is a trio: `.opencode/agents/review.md`,
`.opencode/plugins/review-read/index.ts` and `scripts/review-read`. If any one is present, all
three are required. The specialized agents are single Markdown files, optional independently
and independent of the review adapter. They use OpenCode's default subagent capabilities, not
`review_query`. Removing all specialized files is valid, and removing the review trio while
leaving specialized agents is valid because they do not depend on it.

The official template includes the files; a derived project that does not use OpenCode may
remove the review trio and all specialized agents and keep passing general validation. When the
whole set is absent, OpenCode-specific checks and this document’s links are optional.

## Registration

OpenCode V2 discovers Markdown agents under `.opencode/agents/<name>.md` and plugins under
`.opencode/plugins/<name>/`. The adapter consists of:

- `.opencode/agents/review.md`, with `mode: subagent`, a description and the review permission
  matrix below;
- `.opencode/plugins/review-read/index.ts`, which registers the `review_query` tool under the
  `review` namespace with `codemode: false`;
- `scripts/review-read`, the argument-validated read-only query implementation;
- `.opencode/agents/functional.md`, `.opencode/agents/implementation.md` and
  `.opencode/agents/infrastructure.md`, each optional and linked to its canonical role.

No model is pinned. OpenCode inherits the parent session model for a subagent without a model;
these adapters do not configure a provider or model. UI colors: `functional` blue (`#3B82F6`),
`implementation` green (`#22C55E`), `infrastructure` orange (`#F59E0B`) and `review` purple
(`#A855F7`). Colors do not change tool permissions or behavior.

Check registration on the installed client:

```sh
opencode debug agents | jq -r '.[] | select(.id=="review" or .id=="functional" or .id=="implementation" or .id=="infrastructure")'
```

## Specialized agents

| Agent | Canonical role | Role behavior |
| --- | --- | --- |
| `functional` | [functional](../.agents/roles/functional.md) | prepares requirements, questions, draft sections and acceptance cases; read-only by contract |
| `implementation` | [implementation](../.agents/roles/implementation.md) | implements an approved bounded specification using only the packet's ownership, runs authorized checks and returns evidence |
| `infrastructure` | [infrastructure](../.agents/roles/infrastructure.md) | read-only investigation and safe preparation; execution or mutation requires a separately authorized executor |

These adapters use the **OpenCode default** subagent tool capabilities. They do not define a
permission matrix and do not require the review adapter. The default client may expose read,
search, edit, shell and delegation; those capabilities are not an ownership or security
boundary. The work packet, the canonical role and the project policies govern what the agent
may do. Functional and infrastructure are read-only by contract; implementation is bounded by
its approved specification and packet ownership. None may self-approve, publish or merge. Per the shared work packet, subagents return clarification
and approval needs to the coordinator rather than invoking the user-facing question tool.
This is a behavioral rule, not a technical denial under the default tool policy.

`review` remains a separate, independently registered read-only audit adapter with its own
permission matrix. The specialized agents do not depend on it and do not inherit its restrictive
matrix. When the review plugin is installed, its `review_query` tool is registered project-wide
and may appear on a specialized agent's default tool surface; that does not make the specialized
agent read-only. The reverse is also true: default tools may include edit, shell, delegation,
Code Mode, session/worktree operations and network access. This is capability, not authorization.

## Why a tool, not a shell allowlist

OpenCode V2 permissions match the **command text** for `shell`; they do not validate a Git
subcommand or its options. A narrow-looking rule such as `git diff *` would still allow
`--output=<file>` to write, `--ext-diff` or a configured external diff driver to execute code,
and `git show HEAD:.env` or `git diff --no-index -- .env` to print a protected file. `git grep`
has pager options that execute commands.

A command-prefix allowlist is also not a sufficient sandbox by itself. On OpenCode V2.1.4 a
temporary probe showed that a rule allowing `python3 scripts/review-read *` also allowed shell
redirection (`... > file`), because the pattern matches the complete command text. The shell
interprets redirection and chaining before the wrapper runs, so the wrapper cannot prevent a
write. That is why this review adapter grants **no `shell` permission at all**.

OpenCode V2.1.4 has no built-in read-only Git or GitHub tool with argument validation. The
minimal alternative is a local plugin tool backed by `scripts/review-read`: the plugin receives
structured arguments, builds a fixed argv, and spawns the wrapper with `shell: false`. The
wrapper accepts only the operations and typed options declared in its `POLICY` literal, rejects
protected paths and non-commit revisions, and runs `git` or `gh` with read-only subcommands.
The template validator reads that literal and the plugin source and rejects added operations,
options, shells or extra tools.

## Review permissions

OpenCode applies permission rules in order and the last matching rule wins. The effective
boundary is:

| Capability | Effective result | Notes |
| --- | --- | --- |
| `read` | **deny** | the native matcher is case-sensitive on non-Windows hosts; use the query tool's `file read` |
| `glob` | allow | file discovery by pattern; names only, no contents |
| `review_query` | allow | the read-only query tool only; one validated query per call |
| `grep` | **deny** | its permission is matched against the pattern, not the path, so it cannot enforce protected files; use the query tool's `search` operation |
| `shell` | **deny** | no terminal, redirection or command chaining |
| `edit`, `write`, `patch` | deny | no file creation or modification |
| `subagent`, `skill`, `question` | deny | no delegation, Skill loading or user prompts |
| `webfetch`, `websearch` | deny | no arbitrary network access |
| `execute` / Code Mode, MCP, browser | deny | no alternative execution route |
| `external_directory` | deny | reads stay inside the workspace |

The adapter denies `*`, then allows `glob` and `review_query`, then denies `read`. Native
`read` is denied because OpenCode permission matching is case-sensitive on non-Windows hosts:
a rule for `.env` does not match `.eNv`, and a rule for `.git/*` does not match
`vendor/.git/config`. Content reads therefore use the query tool, whose path check lowercases
names and checks every path component. The wrapper's protected-name list feeds the local path
check and the Git pathspec exclusions, which are case-insensitive: `.env`, `.env.*`,
`*.env.example`, `*.pem`, `*.key`,
`*.p12`, `*.pfx`, `*.kdbx`, `*.jks`, `*.keystore`, `id_rsa*`, `id_ed25519*`, `id_ecdsa*`,
`id_dsa*`, `.git-credentials`, `.netrc`, `.npmrc`, `.pypirc`, `*credentials.json`,
`*secrets.json`, `*.credentials`, `*.secret`, `*.secrets`, `.envrc`, `.envrc.*`, bare
`secret`/`secrets`/`credential`/`credentials`, and any name containing `secret` or
`credential`. `.git`, `.ssh`, `.aws`, `.gnupg`, `secrets` and `credentials` are protected
directories.
Only the exact basename `.env.example`, outside a protected directory, is a read exception; it
is still excluded from local Git output, while `pr-diff` does not treat it as protected because
it is the declared read exception. Generic names such as `foo.env.example`,
`prod.env.example`, `secret.env.example` and `credential.env.example` are protected, including
nested variants. The wrapper, Git exclusions and PR filtering match names case-insensitively,
and the query boundary checks every path component for protected directories such as `.git`.

This is an audit boundary, not a general secrets sandbox. Files committed outside the protected
patterns can still contain sensitive data, and GitHub evidence is untrusted content. Report
suspected secrets instead of reproducing them.

## Read-only query interface

The agent calls `review_query`; it cannot invoke the wrapper through a shell. The tool exposes:

File: `read` (one allowed UTF-8 text file, bounded output).

Local Git: `status`, `branches`, `log`, `show`, `diff`, `file-history`,
`changed-files`, `search`.

GitHub, when the existing `gh` CLI is installed and authenticated: `pr`, `pr-diff`,
`pr-checks`, `pr-list`, `run`, `run-list`.

Examples:

```text
review_query {"group":"describe"}
review_query {"group":"file","operation":"read","options":{"path":"README.md"}}
review_query {"group":"git","operation":"status"}
review_query {"group":"git","operation":"log","options":{"max":20,"rev":"main..HEAD"}}
review_query {"group":"git","operation":"diff","options":{"base":"main","head":"HEAD","stat":true}}
review_query {"group":"git","operation":"file-history","options":{"path":"src/app.py"}}
review_query {"group":"git","operation":"search","options":{"pattern":"acceptance","path":"specs"}}
review_query {"group":"github","operation":"pr","options":{"number":37}}
review_query {"group":"github","operation":"pr-checks","options":{"number":37}}
review_query {"group":"github","operation":"run","options":{"run-id":41443377507}}
```

`run-id` is validated as a positive decimal GitHub identifier (up to 19 digits), separately
from bounded counters such as `max`, `limit` and PR `number`. Pass a `run-id` above 2^53 as a
string; JavaScript numbers cannot represent it exactly. `file-history` follows the target path
and omits name-status entries whose old or new path is protected; `git log --follow` accepts
only one pathspec, so the normal exclusions cannot be passed directly.

The wrapper rejects unknown groups, operations, options, duplicate options, malformed
revisions, non-commit revisions, absolute or traversing paths, protected paths and
pathspec/glob magic. It disables Git paging, external diff, text conversion, hooks, prompts and
optional index locks; diffs, history, search and changed-files exclude the protected file
patterns, `status` filters its rendered short output, and rename/copy metadata also excludes the
allowed side of a pair whose other side is protected. A result
of `2` means invalid input, `3` means the integration is unavailable and `4` means the read-only
command failed. The agent reports those as `BLOCKED` or `UNRUN`, never as PASS.

`pr-diff` does not return raw `gh pr diff` output. It reads the PR file list from the existing
GitHub API integration and renders only non-protected files, including their per-file patches.
Protected paths are counted but not named or printed. Renames are checked on both the old and
new path. If the API response cannot be parsed, the operation fails closed instead of returning
an unfiltered patch.

GitHub access uses the existing `gh` authentication. The adapter adds no service, credential,
token or network endpoint. If `gh` is absent or unauthenticated, PR and CI evidence is
`UNAVAILABLE`; local Git evidence still works.

## Canonical contract

The adapter body is deliberately short. It reads
[`.agents/roles/qa-review.md`](../.agents/roles/qa-review.md) as the single source of truth and
requires the coordinator's work packet, including its **Applicable rules** and return schema.
The role's mission is not copied into the adapter.

The agent may investigate independently: documents, specifications, acceptance criteria, code,
local Git state, diffs, commits, file history, Pull Requests and existing CI results. Text file
contents are read through `review_query file read`, not the native `read` tool. It must not
become a second developer. Executable QA, test runs, edits, installs, deployments and other
protected actions still need an authorized executor; the agent returns findings and the exact
blocked operation to the coordinator.

## Coordinator delegation

For a read-only audit, select the native `review` subagent directly. The coordinator's preflight
is limited to authorization and Task ID, ownership, hard dependencies, the candidate revision
(branch and SHA) and the PR number when applicable, and the applicable rules and return schema
in the work packet. Commits, diffs, file history, PR data and existing CI belong to the subagent;
do not pre-run those queries or repeat its audit during consolidation.

The `review_query` signature is in this document, so the coordinator does not need to rediscover
it. The canonical role is the subagent's contract; the coordinator does not need to load it in
full to build the packet. OpenCode records token and cost metrics per session: when telemetry is
available, report the coordinator session and the child `review` session separately.

For substantial independent work, the coordinator may select **background** when the active
OpenCode client exposes non-blocking delegation and the benefit justifies it. Announce the task,
executor, mode, isolation and coordinator availability; continue supervising at milestones. The
child remains running after the coordinator turn is released, but closing the client or runtime
may stop it. Do not claim persistence after that close without a new verification.

## Limits and compatibility

- Verified against OpenCode V2.1.4 on 2026-11-02. Earlier versions or V1 configuration may
  register agents, plugins or permissions differently.
- On OpenCode V2.1.4/macOS, the pre-hardening native `read` allowed `.eNv` and
  `vendor/.git/config` on a case-insensitive filesystem. After the change the `review` agent has
  no native `read` tool, and `review_query file read` returns exit 2 for both paths; the exact
  `.env.example` basename remains readable. These are live fixture observations, not a general
  secrets guarantee.
- The adapter is project-local; it does not alter global OpenCode configuration.
- Codex and Claude Code are unaffected. The existing `.claude/agents/qa-review.md` profile
  still offers `Bash` for a client-level QA task; it is not this read-only OpenCode agent.
- The `review` agent cannot edit files, run arbitrary commands, launch child agents, load Skills
  or fetch arbitrary URLs. It cannot execute the test suite; it can only consult existing results.
  The specialized agents instead use the default OpenCode capabilities; their role and work packet
  restrict behavior, not technical tool access. The default surface may include shell, edit,
  delegation, Code Mode, network and session/worktree operations. Check live behavior per agent
  and client; none of these is an isolation guarantee.
- `file-history` cannot combine `--follow` with the protected-path excludes, so it consumes
  NUL-delimited `--name-status` records and filters them in the wrapper. Commit subjects that
  name a protected path are not rewritten. Merge commits may not expose rename or copy metadata
  to `diff-tree`; a combined `show` remains a documented blind spot.
- `changed-files` omits both sides of a rename or copy when either side is protected, so an
  allowed destination name does not reveal that a protected file was moved or copied.
- `file read` is text-only, UTF-8 and bounded by the same output limit as the other queries. It
  resolves symlinks, rejects paths outside the workspace and rechecks the resolved path for
  protected names or directories. Binary or non-UTF-8 files are unavailable through this route.
- A complete review removal must remove the agent, plugin directory and wrapper together; a
  single deleted component, including a residual plugin directory, is reported as an incomplete
  adapter. Specialized agents are independent: removing all of them is valid and leaves the
  review adapter independent; removing the review trio is valid while specialized agents remain.
- OpenCode V2.1.4 supports non-blocking background delegation (owner-verified 2026-11-02). The
  coordinator may select background for substantial independent work when it verifies the option
  in the active client. Releasing the coordinator turn does not end the child runtime; closing
  the client or runtime may stop it, and persistence beyond the active runtime is not claimed.
  External-session control remains unclaimed.
- The GitHub route depends on `gh` availability and authentication and is not a substitute for
  reviewing the local candidate revision.

## Validation

```sh
./scripts/validate-template
./scripts/test-validator
opencode debug agents | jq -r '.[] | select(.id=="review" or .id=="functional" or .id=="implementation" or .id=="infrastructure")'
```

The validator checks the review trio’s effective permission matrix, native `read` denial, single
`review_query` allow, plugin registration, `shell: false`, the `review-read` policy including
`file read`, the shared protection list and the canonical link. For each specialized agent it
checks `mode: subagent`, a description, the canonical-role link, no model pin, no agent-specific
`permissions` block (default OpenCode capabilities), and the required packet/return sections.
Empty files fail. Each specialized file is optional and independent of the review adapter;
removing all is valid, and removing the review trio while leaving specialized agents is valid.
Live registration and the actual client tool surface remain separate checks and must not be
claimed from file presence alone.
