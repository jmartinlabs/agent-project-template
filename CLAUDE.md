# Claude Code · Agent project template

Use [AGENTS.md](AGENTS.md) as the canonical project instructions and [explicit approvals](specs/methodology/approvals.md) for protected decisions. Do **not** infer approval from generic agreement such as "dale", "ok", or "continue".

In Claude Code, project skills under `.claude/skills/` are small discovery adapters. They refer to the *same* canonical workflows at `.agents/skills/` used by Codex. To coordinate, use `/orchestrate` if discovered; otherwise read `.agents/skills/orchestrate/SKILL.md` explicitly.

No skill grants access, deployment or merge permissions; the user approves protected actions, and the repository may require stronger branch/ruleset policies. The local shell guard is defense in depth and **cannot authenticate a user approval**. See [harness limitations](docs/HARNESS.md).

This is the reusable **template**, not a running application. Derived repositories must adapt these rules and only install suitable skills/hooks after review. Preserve their existing AGENTS.md and CI.
