# Adaptive workflow contract

The entry point is a natural-language request, optionally in Codex Plan mode (/plan where supported). AGENTS.md recommends orchestrate; /plan does not invoke any Skill automatically. The user can explicitly invoke $orchestrate. Start with inspection and a **proposed classification**, then **ask the user to confirm Quick / Standard / Full before implementation**.

| Workflow | Typical scope | Required preparation | Verification |
| --- | --- | --- | --- |
| Quick | Low-risk bounded bug/tweak | Short plan and observable expected result | Focused tests, diff review, relevant regressions |
| Standard | Bounded feature | Short plan, edge cases, concise acceptance checks | Implementation, tests, code review |
| Full | New project, cross-cutting feature, major architectural work | Discovery, approved decisions, applicable roadmap, approved feature spec | Incremental dev, QA, spec compliance and code review |

Risk matters more than code size. Auth, payments, production configuration, migrations, data deletion, security and incompatible contracts may require Full or elevated approval even for tiny edits.

## Full workflow routing
- New project: init-project discovery + project brainstorming if needed, architecture decision, bootstrap walking skeleton, roadmap approval, feature spec approval, dev and verification. Roadmap can be drafted provisionally earlier to select a useful vertical slice.
- Existing project, one complex feature: reuse context; run spec and dev. No redundant project init or roadmap.
- Multiple new epics: propose/update roadmap, confirm it, then spec and dev one epic at a time.
- Brainstorming is for unresolved requirements; preserve decisions and open questions. Do not force it for straightforward changes.
- Walking skeleton is a real minimal end-to-end executable slice, not a planning interview. Use bootstrap only when initializing a project or validating a meaningful new architectural path.

## Approval gates
Require user confirmation for initial classification, material product/architecture choices, a new or materially revised roadmap, Full specifications and significant escalation of risk/scope. Ordinary code changes and tests inside the authorized scope do not need approval. Existing approved specs remain authoritative.

## Delegation and portability
Skills are workflow descriptions, not separate agents. Prefer sequential execution when agent delegation is unavailable; multiagent is optional optimization. Scope each independent delegate with file ownership, expected checks and review requirements. No concurrent writes to the same files. Preserve implementation results in a way that supports Desktop and Web. Do not assume availability of local tools, hooks or credentials in cloud tasks.

## Evidence
Do not equate a successful build with user acceptance. State checks passed, failed, blocked and unrun separately. Review diffs before local commits. CI is the portable enforcement layer; any client lifecycle hooks are optional enhancements, not a substitute for tests or approval.
