# Universal AI development template
A reusable Codex and Claude Code agent development methodology for any project stack. This repository contains
no application and makes no language, database, framework or hosting choice for you.

## Codex / Claude Code portability (v2.4 candidate)

The same canonical `AGENTS.md`, Skills, approval policy and role contracts are
reused on both platforms. Codex uses `$orchestrate`; Claude Code loads
`CLAUDE.md` and offers `/orchestrate` through thin wrappers in
`.claude/skills/`. Optional Claude agent profiles are under `.claude/agents/`.
See the [Claude setup and smoke test](docs/CLAUDE_ADAPTER.md).

[Behavioral evals](docs/AGENT_EVALS.md) provide portable decision scenarios
and a scorer. CI runs scorer **self-tests only**; it does not call Claude or
Codex or certify model compliance.

## Start here

- **New project:** [copy the new-project prompt](NEW_PROJECT_PROMPT.md) and create an independent repository with GitHub **Use this template**.
- **Existing project:** [copy the adoption prompt](ADOPT_EXISTING_PROJECT_PROMPT.md) into Codex or Claude Code while the old repository is open. Because the `$adopt-project` Skill is **not yet installed** in that repository, the prompt reads it from a local checkout or from a pinned template commit, treats it as untrusted data, and waits for your explicit confirmation before following it.

Both paths require approval of important decisions before file changes.

## Adaptive agentic workflow (v2)

Start by describing the work, optionally in your client's planning mode, or invoke orchestrate explicitly (`$orchestrate` in Codex, `/orchestrate` in Claude Code). A planning mode does not itself invoke a Skill. The coordinator inspects repository context, proposes Quick / Standard / Full, and confirms Standard / Full unless already explicitly authorized. Clearly requested, reversible, low-risk Quick changes without protected or stricter project gates may proceed after a one-line plan. Analysis-only requests and read-only planning mode never authorize edits.

- Quick: `$tweak` for small low-risk modifications, without mandatory spec files.
- Standard: `$task` for bounded features, brief plan and acceptance checks.
- Full: existing `$init-project`, `$bootstrap`, `$roadmap`, `$spec`, `$dev`, using only necessary phases.

[Workflow, approval and delegation rules](specs/methodology/workflows.md). Multiagent delegation is optional and environment-dependent; scripts and CI remain the portable enforcement layer. [Manual behavioral acceptance scenarios](specs/methodology/acceptance-scenarios.md) cover Quick, Standard, Full, escalation and resume. Lifecycle hooks are not installed by this revision pending verified client support and safe deployment.

## Adaptive model selection (v2.2)

`$orchestrate` optionally suggests a **model capability tier and reasoning effort** alongside workflow classification when useful, normally Standard / Full. See [model-selection guidelines](specs/methodology/model-selection.md). Default preference is **balanced**; the user can prioritize **efficiency** or **quality**. Exact names/effort settings depend on the available client and model, and Skills do **not** change models automatically. Keep the current model when adequate and verify actual behavior through tests regardless of model.

## Epic orchestration (v2.3)

For multiple epics, [epic orchestration](specs/methodology/epic-orchestration.md) adds a dependency-aware scheduler, [epic board template](templates/epic-board.md) and [specialist role contracts](.agents/roles/README.md) for functional, implementation and QA tasks. Roles are task instructions, not guaranteed registered subagents.

While E1.6 awaits a financial decision, the functional lane can draft independent E1.7 requirements and QA can prepare provisional tests. E1.6 implementation remains blocked until explicit approval. After approval, `$orchestrate` can route to `$dev` and QA inside the active run without asking you to invoke those Skills manually. Merges and consequential decisions always need your approval. No background continuation after the session closes.

## Dynamic agent management (v2.3.1)

**Start with the [visual orchestration guide](docs/GUIA_VISUAL_ORQUESTACION.md)** (Spanish): eight editable Mermaid diagrams illustrate agent roles, dynamic pool selection, parallel epics, worker lifecycle, approval gates, branch isolation, migration from two chats and model selection.

The coordinator follows [dynamic agent management](specs/methodology/dynamic-agents.md) to **find independent ready work first, then choose agent count**. [Functional, Developer, QA and Infrastructure profiles](.agents/roles/README.md) are reusable role instructions, not permanent agents. Multiple distinct tasks can use the same role. Default to one executor; add specialists only when a supported runtime and independently useful work justify the overhead, preserving required independent QA. Use [agent work packets](templates/agent-work-packet.md) for scope, ownership and verifiable outcomes.

The template documents orchestration; it **does not itself register or launch workers**. Check the actual subagent tools and isolation of your client. Otherwise execute the same ready queue sequentially. Existing unrelated chats contribute checkpoints and Git artifacts; the coordinator cannot control them automatically.

## Explicit session shutdown and handoff

Use [`$handoff`](.agents/skills/handoff/SKILL.md) in Codex (or `/handoff` in Claude Code) when you want to **consolidate and stop**, rather than continue development. It freezes new work, requests stop of controllable workers, protects WIP, and writes a minimal checkpoint to existing progress/board files (or `specs/session-handoff.md` as a fallback). It never merges, deploys or creates a PR from a generic stop request.

If the client ran out of quota, interrupt any visibly running task using the client controls first. Once quota is available, invoke handoff before orchestrate; no Skill can save unseen state while it cannot execute. A new session may inspect the checkpoint but **must not resume automatically** or presume that other chats were stopped.

## Adopt an existing project

`$adopt-project` lives in [the Skill source](.agents/skills/adopt-project/SKILL.md). The old project initially cannot discover it by name. Use [ADOPT_EXISTING_PROJECT_PROMPT.md](ADOPT_EXISTING_PROJECT_PROMPT.md) once; it tells the agent to read the Skill (from a local copy or a pinned commit), analyze the existing code and propose a safe plan before installing project-local Skills. If remote access is unavailable, supply a local copy of the Skill.

Adoption preserves existing AGENTS.md, architecture, roadmap, specs, code and CI. It does not run a new-project bootstrap or assume the project is uninitialized. After successful adoption, `$orchestrate` is available in that project's Skills.

## Interactive initialization
Type `$init-project` in Codex or `/init-project` in Claude Code. It reads existing context, asks short rounds of questions
and saves state in `specs/setup-progress.md`. The seven stages are identity → technology
→ architecture → working bootstrap → guidelines → roadmap → development handoff.
It recommends options but waits for material decisions. Approved architecture belongs
in guidelines, while progress links to it. Existing decisions/files are preserved.
To resume: open the derived repository and say “$init-project, resume from saved progress.”
No previous chat history is required. Do not initialize an application in this template.

## Skills and eight-step methodology
| Step | Process | Entry point / result |
| --- | --- | --- |
| 1 | Smallest tested end-to-end bootstrap | `$bootstrap` after decisions approved |
| 2 | Document implemented context | Thin AGENTS and four guidelines |
| 3 | Enforce checkable rules | Tests, linters, scripts and CI; positive/negative proofs |
| 4 | Plan independently useful MVP epics | `$roadmap`; as many epics as justified and approved |
| 5 | Brainstorm and approve one specification | Append-only questions and acceptance checks |
| 6 | Reuse the specification process | `$spec 01` or `$spec feature name` |
| 7 | Build verified increments | Progress, test plan and working commits |
| 8 | Reuse implementation and verification | `$dev 01` for an approved specification |

To specify an epic, send `$spec 01`. Answer the proposed options; visual projects include
ASCII wireframes for feedback. It commits approved documents and stops before code.
Then send `$dev 01`. It maps acceptance checks to tests, builds small increments and
verifies actual behavior. Web features use Playwright plus inspected 390px/1440px
screenshots and a justified visual improvement review. Non-visual projects use relevant
API/CLI/integration checks. Failed or unrun acceptance checks block completion.
See [document ownership](specs/README.md) and [Skills invocation](NEW_PROJECT_PROMPT.md).

## Repository map
```text
AGENTS.md                         concise agent entry point
NEW_PROJECT_PROMPT.md              new-project prompt
ADOPT_EXISTING_PROJECT_PROMPT.md   copyable existing-project adoption prompt
.agents/skills/{adopt-project,orchestrate,handoff,task,tweak,init-project,bootstrap,roadmap,spec,dev}/SKILL.md
.github/workflows/validate.yml     template validation on push/PR
specs/README.md                    document ownership and naming
specs/methodology/model-selection.md advisory model and reasoning recommendations
specs/methodology/epic-orchestration.md dependency-aware epic scheduler
specs/methodology/dynamic-agents.md dynamic specialist lifecycle
docs/GUIA_VISUAL_ORQUESTACION.md   eight editable Mermaid diagrams
templates/agent-work-packet.md    delegate work packet contract
templates/epic-board.md          optional epic coordination board
.agents/roles/                   functional, implementation and QA roles
specs/guidelines/{architecture,ui,quality,security}.md
templates/{brainstorming,specification,roadmap,progress,testplan}.md
scripts/validate-template          standard-library checks
scripts/test-validator            positive/negative regression fixtures
docs/archive/                      history: prompt backups, v2.4.2 audit/benchmark (not methodology)
.claude/settings.json              ask-before-run rules and the read-only SessionStart hook
```
Project-specific files are created by the Skills in a derived repository, not prefilled
with fictional approved decisions. UNDECIDED placeholders are intentional initialization
instructions. Projects may retain this methodology and add their own code and tooling.

## Verify and commit
Optional local token accounting: [Codex usage reports](docs/USAGE_REPORTS.md).
Reports can be generated on demand or through reviewed local Codex lifecycle hooks,
outside the repository and without model calls. Hook activation requires client trust.

Python 3.10+ is needed only for template tooling; no package manager/install is needed.
From the repository root:
```sh
./scripts/validate-template
./scripts/test-validator
python3 scripts/test-agent-usage
python3 scripts/test-auto-agent-usage
git diff --check
git status --short
```
Review the diff, stage explicit files, inspect the staged diff and commit working changes.
Do not include unrelated user changes or credentials. Derived projects additionally run
the real commands recorded in their quality guidelines. See [quality](specs/guidelines/quality.md)
for check coverage and limitations. GitHub Actions runs the same template checks.

## Create a project on GitHub
Use **Use this template → Create a new repository**, choose owner/name and private visibility
by default, then open its independent checkout in Codex or Claude Code. CLI alternative and a complete
prompt are in [NEW_PROJECT_PROMPT.md](NEW_PROJECT_PROMPT.md). Changes here do not propagate
to existing projects; selectively port reviewed methodology changes yourself.

## Maintain and publish this template
Edit reusable methodology only, keep history in `docs/archive/` and avoid adding a demo application.
Run both checks and review Skills manually, especially approval and resume behavior.
Codex conventions: [AGENTS](https://developers.openai.com/codex/guides/agents-md) and
[Skills](https://developers.openai.com/codex/skills). Claude Code adds one read-only `SessionStart` hook that loads the orchestrate contract; see [Claude adapter](docs/CLAUDE_ADAPTER.md).
The local environment reports Codex CLI 0.163.0; the official Skills page was inaccessible
(HTTP 403) during creation. Recheck client discovery on your installed version; explicit
file-reading instructions remain available. No unsupported slash commands are required.

Before publication inspect Git status, verify GitHub access, confirm intended owner,
visibility (private by default) and repository name. The existing origin is
`josemartin2000/agent-project-template`; do not create over it, reset it or change visibility.
After explicit authorization, push the reviewed branch normally, enable **Template
repository** in repository settings (or `gh repo edit OWNER/REPO --template` with API access),
and verify accessibility. Create a disposable private repository from the template only
with authorization; verify required files and run both checks there. Delete it only with
permission. Update the prompt URL if the actual published location changes.
Git read access does not prove API or push permission. CLI token failure does not mean a
new token must be supplied in chat. Use supported authentication/settings securely.
Local validation cannot prove GitHub template mode or successful remote creation.
