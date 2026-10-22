# Claude Code adapter (v2.4 candidate)

The methodology is **model-neutral**. Codex and Claude Code can use the same
`AGENTS.md`, Skills, financial/functional gates, acceptance checks and
documentation. Claude-specific files only map commands and optional profiles;
they do not replace canonical rules.

## Entry points

- `CLAUDE.md` uses `@AGENTS.md` to load the canonical project instructions,
  including on older Claude Code versions that lack direct AGENTS.md support.
  Do not maintain separate, conflicting policies in these files.
- `.claude/skills/NAME/SKILL.md` enables `/orchestrate`, `/spec`, `/dev`,
  `/task`, `/tweak`, `/init-project`, `/bootstrap`, `/roadmap`, and
  `/adopt-project`, and `/handoff`. Each wrapper **reads the corresponding canonical** file
  under `.agents/skills/NAME/SKILL.md`; none automatically copies its contents.
- `.claude/agents/` exposes optional task-limited profiles for
  functional, implementation, QA/review and infrastructure work. A profile
  file is not a running worker or a license to delegate without checks.
- Call `/orchestrate` with a concrete task and let it choose Quick, Standard,
  or Full according to the already agreed scope. Native Claude Plan mode is
  separate from a Skill. Command names do not give approval or change models.

## Manual smoke test (required before claiming live Claude compatibility)

1. Open an authorized checkout in Claude Code and check `/skills` discovers
   `/orchestrate` and `/spec`. Run `/context` to confirm AGENTS instructions.
2. Run `/orchestrate` with a **planning-only** example, confirm it reads the
   canonical Skill and reports the approval gates; do not grant new scope.
3. Ask the coordinator to list available specialist profiles without launching
   them; check real delegation capability, optional workers and isolation.
4. Try evaluation scenarios with Claude or Codex and score the resulting
   structured decisions as described in [behavioral evals](AGENT_EVALS.md).
5. Report actual model, client version, date, results, resource usage, and
   checks not executed. Do not claim native subagents, hooks or model evals have
   been tested just because files exist.

No hooks, auto-merge, cloud automations, or model API credentials are installed.
A hook cannot independently prove approval without a trusted external record;
the [approval policy](../specs/methodology/approvals.md) remains instructional.
The repository's existing Codex workflow remains unchanged.

For official mechanics see:
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Claude Code subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code project instructions](https://code.claude.com/docs/en/memory)

## Permission audit for v2.4.2

The repository supplies no `.claude/settings.json` permission rules. Existing wrappers
and profiles remain intact. The QA profile offers `Read, Glob, Grep, Bash`: its
read-only instruction is a role contract, while Bash remains able to write. Text
controls and Bash command filters are not independent security boundaries.

Do not install blanket deny rules from a reference archive: Claude deny rules can
block even an explicitly approved action, and matching a command does not cover
other Git/API execution paths. Inspect effective permissions in the actual Claude
client (for example `/permissions` where supported), including user/managed settings
and tool access; none were observed in a live Claude session for this change.
If an approved action is blocked, report the restriction and resolve it through the
authorized client configuration; do not silently bypass it or claim approval overrides
a deny. Keep project-specific restrictions and the canonical approval policy.
