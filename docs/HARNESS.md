# Portable agent harness — first increment

**Status:** repository-level, offline guardrails and Claude Code discovery adapters. Not a standalone agent runtime, and not proof of deployment or completed behavioral evaluation.

## One canonical methodology, two clients

- Codex: `AGENTS.md` + `.agents/skills/*/SKILL.md` + optional local hooks.
- Claude Code: `CLAUDE.md` + thin `.claude/skills/*/SKILL.md` adapters to the *same* canonical sources + Claude project settings.
- Shared deterministic core: `scripts/harness.py`; tests: `evals/harness-cases.json`; GitHub Actions invokes both validators.

Source contracts remain `specs/methodology/workflows.md`, `specs/methodology/approvals.md` and the existing role/work-packet references. **Do not duplicate full skill instructions** in the Claude folder.

## Run offline

```sh
python3 scripts/harness.py validate
python3 scripts/harness.py eval
./scripts/validate-template
./scripts/test-validator
```

These commands are read-only. CI runs both harness commands alongside existing tests and Mermaid validation. No additional Python packages, accounts or persistent services are needed.

## Hooks: exact guarantees and gaps

The two hook configurations use `PreToolUse` on direct `Bash` calls. The shared Python guard **blocks only obvious direct command patterns**, currently `gh pr merge`, direct force/protected-branch push, and `rm -rf`-style deletion. It exits 2 to reject a matching call. It does **not** parse a shell, monitor the filesystem, cover every git invocation, MCP tool, nested script, alias, remote service or another process. It can produce false positives and may be skipped if a client doesn't load/trust project hooks.

The guard **does not and cannot authenticate chat approvals**. Approval remains an explicit human decision bound to a specific PR/operation, per `specs/methodology/approvals.md`. For independently enforceable protection, configure GitHub branch protection/rulesets (required checks and human review) separately after approving those settings; project files alone do not enable branch protection. Production permissions belong to the hosting provider and restricted credentials, not agent text.

Claude project hook: `.claude/settings.json`. Codex project hook: `.codex/hooks.json` as supported by the Codex client/configuration and user trust. Do not assert either hook ran until a real execution reports it. Review hook scripts before trusting them; do not bypass client safeguards merely to make a test pass.

For an authorized merge when the local guard blocks `gh pr merge`, use the independently reviewed GitHub action/UI after checking the explicit approval and required checks; **do not weaken the guard**.

## Behavioral evaluations pending

`evals/harness-cases.json` is a **deterministic fixture**, not a model eval or proof of faithful approval interpretation. Run the existing manual acceptance cases in `specs/methodology/acceptance-scenarios.md` in **both Codex and Claude Code**, including:
- `dale`/generic assent must NOT approve protected actions;
- explicit approval for one PR, HEAD revision checked before merge;
- blocked production operation despite green CI;
- Quick/Standard/Full routing without unnecessary documentation;
- subagent fallback when delegation/isolation unavailable;
- role instructions preserved on a new session.

Record client/version, inputs, actual trace, checks and outcome before claiming Claude/Codex behavior validated. No automatic grading of LLM behavior is implemented in this first increment.

## Adoption into existing projects

Do **not** overwrite pre-existing `AGENTS.md`, CI, skills, secrets policy or runbooks. Use `$adopt-project` with a file-by-file plan and approval. Choose applicable shared components and adapt all hooks/guard rules to project risk. Especially for real infrastructure, avoid treating this demo guard as permission to access/alter a VPS.

Template origin/version and forked local changes should be recorded during adoption. Upstream updates do not automatically propagate to derived projects.
