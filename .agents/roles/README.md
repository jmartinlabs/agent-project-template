# Epic orchestration specialist role contracts

These files are **instructions for logical delegate roles**, not an assumption that this Codex client automatically registers three custom agents. Read them when constructing bounded subagent tasks. If delegation is unavailable, the coordinator performs the same roles sequentially.

- [Functional](functional.md): discovery, brainstorming and specs without self-approval
- [Implementation](implementation.md): approved-spec-only development
- [QA / Review](qa-review.md): independent acceptance and regression checks

The coordinator owns dependency scheduling and `specs/epic-board.md`. Parallel read-only preparation is safe; parallel writes need non-overlapping ownership and authorized isolation.
