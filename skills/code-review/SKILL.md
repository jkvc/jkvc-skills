---
name: code-review
description: >-
  Systematically review a PR or branch, categorize concerns by severity and
  system area, then work through each with the user — discussing, patching,
  and checking off. Use when the user says "review this PR", "review this
  branch", "help me review", "what's wrong with this diff", or wants to
  improve code before merging.
---

# Code Review

Review a PR or branch systematically: categorize every concern, discuss each with the user, patch what's agreed, and track progress until done.

## Steps

### 1. Understand the change

- Get the PR metadata (title, body, commits) and full diff.
- Read the changed files in their current state, not just the diff — understand the surrounding code.
- Cross-reference with project architecture docs (CLAUDE.md, docs/, notes/) to understand conventions and boundaries the changes might violate.

### 2. Categorize concerns

Group findings by **system area**, not by file. Examples: schema/types, agent tools, API routes, UI components, tests, docs. Within each category, flag:

- **What changed** — be specific (new parameters, changed logic, new types).
- **Whether additive or modifying** — additive is safe, modifying existing behavior is risky.
- **Severity** — bugs, architectural violations, behavior changes, code quality, cosmetic.
- **Cross-cutting concerns** — does a change in one file have implications in others (e.g., a schema change that affects tools, rendering, and tests)?

Present the full categorized review as a table with severity and a recommended order. Let the user decide what to tackle.

### 3. Work through each concern

For each item the user wants to address:

- **Elaborate** — explain the concern in full context. Show the relevant code. Explain what happens now vs what should happen. If it's a judgment call, present both sides.
- **Discuss** — let the user decide. Don't implement until they agree. Ask clarifying questions if the right fix is ambiguous.
- **Verify against real data** — when the concern involves data (DB schema, existing records, event flows), query the actual database or inspect real books/logs to confirm assumptions before changing anything.
- **Patch** — implement the agreed fix. Run type-check and tests after each change.
- **Check off** — mark the item done and move to the next.

### 4. Commit discipline

- Commit in logical groups — one commit per category or concern, not one giant commit.
- Write commit messages with three sections: **What** (what changed), **Why** (motivation and what was wrong), **Implications** (what downstream effects this has).
- Never commit without the user's explicit go-ahead.
- Run the full verification pipeline before pushing (type-check, lint, tests, build).

### 5. Track progress

Maintain a running checklist showing every concern, its status (done, pending, left, deferred), and what was decided. Present it when asked "what have we checked off" or "what's left."

## Rules

- **Examine, don't assume.** Read the actual code on the branch, query the DB, inspect event logs. Don't reason about what the code "probably does."
- **Understand the project's architecture boundaries.** If the project has layered conventions (e.g., tools vs rules vs skills vs hats), flag violations. These boundaries exist for reasons.
- **Real data over theory.** When debating whether a change is safe (e.g., removing a field, changing a data path), verify with the actual database before proceeding. Check row counts, data consistency, whether the old path is actually used.
- **Revert over patch when the design is wrong.** If a feature's approach is fundamentally flawed (e.g., breaks a system invariant, creates unmaintainable prop drilling), advocate for reverting it and redesigning rather than band-aiding.
- **Don't fix what isn't broken.** If a concern is theoretical (no real perf issue, no actual bug, pattern is unconventional but correct), say so and recommend leaving it. Not every finding needs a fix.
- **Track tech debt explicitly.** If something is left unfixed intentionally, add it to the project's tech debt tracker with full context — what, why left, how to fix.
- **Backfill existing data.** When changing how data is stored or derived, verify existing data is consistent with the new approach and migrate if needed — with the user's approval.
- **One concern at a time.** Don't batch-fix multiple unrelated issues in one pass. Each concern gets its own discussion → decision → implementation → verification cycle.
