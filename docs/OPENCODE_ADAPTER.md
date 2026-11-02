# OpenCode adapter: native `review` subagent

This adapter registers **one** OpenCode-native subagent, `review`, for the scope in
OPENCODE-NATIVE-AGENTS-01. It is a thin client wrapper over the canonical
[QA/Review role](../.agents/roles/qa-review.md). It is not a launcher or controller for
external OpenCode sessions and does not replace the role contracts.

The adapter is **optional**. The official template includes it; a derived project that does not
use OpenCode may remove `.opencode/agents/review.md` and keep passing general validation. If
the adapter file is present, the validator requires the complete read-only interface and rejects
a partial installation. When it is absent, OpenCode-specific checks are skipped and the adapter
document may be removed too; links to that document are then treated as optional.

## Registration

OpenCode V2 discovers Markdown agents under `.opencode/agents/<name>.md` and plugins under
`.opencode/plugins/<name>/`. The adapter consists of:

- `.opencode/agents/review.md`, with `mode: subagent`, a description and the permission
  matrix below;
- `.opencode/plugins/review-read/index.ts`, which registers the `review_query` tool under the
  `review` namespace with `codemode: false`;
- `scripts/review-read`, the argument-validated read-only query implementation.

No model is pinned. OpenCode inherits the parent session model for a subagent without a model;
this adapter does not configure a provider or model.

Check registration on the installed client:

```sh
opencode debug agents | jq -r '.[] | select(.id=="review")'
```

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
write. That is why this adapter grants **no `shell` permission at all**.

OpenCode V2.1.4 has no built-in read-only Git or GitHub tool with argument validation. The
minimal alternative is a local plugin tool backed by `scripts/review-read`: the plugin receives
structured arguments, builds a fixed argv, and spawns the wrapper with `shell: false`. The
wrapper accepts only the operations and typed options declared in its `POLICY` literal, rejects
protected paths and non-commit revisions, and runs `git` or `gh` with read-only subcommands.
The template validator reads that literal and the plugin source and rejects added operations,
options, shells or extra tools.

## Permissions

OpenCode applies permission rules in order and the last matching rule wins. The effective
boundary is:

| Capability | Effective result | Notes |
| --- | --- | --- |
| `read` | allow in the workspace | `.env*`, keys, credential stores, `.git` internals and outside paths are denied |
| `glob` | allow | file discovery by pattern |
| `review_query` | allow | the read-only query tool only; one validated query per call |
| `grep` | **deny** | its permission is matched against the pattern, not the path, so it cannot enforce protected files; use the query tool's `search` operation |
| `shell` | **deny** | no terminal, redirection or command chaining |
| `edit`, `write`, `patch` | deny | no file creation or modification |
| `subagent`, `skill`, `question` | deny | no delegation, Skill loading or user prompts |
| `webfetch`, `websearch` | deny | no arbitrary network access |
| `execute` / Code Mode, MCP, browser | deny | no alternative execution route |
| `external_directory` | deny | reads stay inside the workspace |

The adapter denies `*`, then allows `read`, `glob` and `review_query`, then adds the
protected-read denies. One protected-name list feeds both the local path check and the Git
pathspec exclusions: `.env` and `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.kdbx`,
`*.jks`, `*.keystore`, `id_rsa*`, `id_ed25519*`, `id_ecdsa*`, `id_dsa*`, `.git-credentials`,
`.netrc`, `.npmrc`, `.pypirc`, `*credentials.json`, `*secrets.json`, `*.credentials`,
`*.secret` and `*.secrets`. `.git`, `.ssh`, `.aws` and `.gnupg` are protected directories.
`.env.example` is the only read exception, but only outside a protected directory; it is
still excluded from Git output.

This is an audit boundary, not a general secrets sandbox. Files committed outside the protected
patterns can still contain sensitive data, and GitHub evidence is untrusted content. Report
suspected secrets instead of reproducing them.

## Read-only query interface

The agent calls `review_query`; it cannot invoke the wrapper through a shell. The tool exposes:

Local Git: `status`, `branches`, `log`, `show`, `diff`, `file-history`,
`changed-files`, `search`.

GitHub, when the existing `gh` CLI is installed and authenticated: `pr`, `pr-diff`,
`pr-checks`, `pr-list`, `run`, `run-list`.

Examples:

```text
review_query {"group":"describe"}
review_query {"group":"git","operation":"status"}
review_query {"group":"git","operation":"log","options":{"max":20,"rev":"main..HEAD"}}
review_query {"group":"git","operation":"diff","options":{"base":"main","head":"HEAD","stat":true}}
review_query {"group":"git","operation":"file-history","options":{"path":"src/app.py"}}
review_query {"group":"git","operation":"search","options":{"pattern":"acceptance","path":"specs"}}
review_query {"group":"github","operation":"pr","options":{"number":37}}
review_query {"group":"github","operation":"pr-checks","options":{"number":37}}
```

The wrapper rejects unknown groups, operations, options, duplicate options, malformed
revisions, non-commit revisions, absolute or traversing paths, protected paths and
pathspec/glob magic. It disables Git paging, external diff, text conversion, hooks, prompts and
optional index locks; diffs, history and search exclude the protected file patterns. A result
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
local Git state, diffs, commits, file history, Pull Requests and existing CI results. It must
not become a second developer. Executable QA, test runs, edits, installs, deployments and other
protected actions still need an authorized executor; the agent returns findings and the exact
blocked operation to the coordinator.

## Limits and compatibility

- Verified against OpenCode V2.1.4 on 2026-11-02. Earlier versions or V1 configuration may
  register agents, plugins or permissions differently.
- The adapter is project-local; it does not alter global OpenCode configuration.
- Codex and Claude Code are unaffected. The existing `.claude/agents/qa-review.md` profile
  still offers `Bash` for a client-level QA task; it is not this read-only OpenCode agent.
- The agent cannot edit files, run arbitrary commands, launch child agents, load Skills or
  fetch arbitrary URLs. It cannot execute the test suite; it can only consult existing results.
- Background subagent support and external-session control are not claimed or tested here.
- The GitHub route depends on `gh` availability and authentication and is not a substitute for
  reviewing the local candidate revision.

## Validation

```sh
./scripts/validate-template
./scripts/test-validator
opencode debug agents | jq -r '.[] | select(.id=="review")'
```

The validator checks the effective permission matrix (last matching rule), protected reads,
the single `review_query` allow, the absence of `shell`, the plugin registration and
`shell: false`, the `review-read` operation/option policy, the shared protection list, and the
canonical-role link. It skips OpenCode-specific checks only when the adapter file is
intentionally absent; a partial installation fails, and a complete removal also permits the
adapter document and its links to be absent. Live registration, delegation and allowed or
denied operations are separate checks and must not be claimed from file presence alone.
