---
name: retrospective
description: >-
  Audit recent implementation with fresh eyes before moving forward. Use when
  the user says "retrospective", "retro", or wants to examine recent work for
  issues before continuing.
---

# Retrospective

Fresh-eyes review of recent work. Catch issues that accumulate during heads-down building before they compound.

## Steps

1. **Gather context** — understand what was built and why.
   - Read project docs: README, planning docs, architecture docs, design philosophy, tech debt file — whatever exists.
   - Check recent git history to scope the review to what changed.
   - If the user specifies a scope ("review the auth work", "retro on last 3 commits"), focus there. Otherwise, review all recent uncommitted or recently committed work.

   ```bash
   git log --oneline -20
   git diff HEAD~N --stat   # N = commits in scope
   ```

2. **Cross-reference** — compare what was built against its own stated intent. Check for:
   - **Spec drift** — divergence from planning docs, design docs, or stated conventions
   - **Type safety** — loose types (`any`, `string` where a union fits), missing fields for planned features
   - **Data integrity** — missing constraints, indexes, transactions, or validation
   - **Security** — auth/authz gaps, input validation, data leakage
   - **Reliability** — swallowed errors, missing error handling, race conditions
   - **API contracts** — return types that will need to change, missing validation, inconsistent response shapes
   - **Portability from source** — if the codebase was extracted from or modeled after another repo, check that intended patterns carried over correctly

3. **Read the source** — verify against actual code, not summaries. Use subagents for parallel exploration on large codebases. Reference specific files and line numbers.

4. **Present findings** — organize by severity:

   | Severity | Meaning |
   |----------|---------|
   | Critical | Blocks correctness or security — fix before any new work |
   | High | Will cause pain in the next phase of work — fix now |
   | Medium | Worth fixing but won't block progress — fix alongside next work |
   | Low | Hygiene improvement — fix when convenient |

   For each issue: file/location, what's wrong, why it matters *concretely*, and a suggested fix.

5. **Propose a fix plan** — batch related fixes together. Separate "must fix now" from "can fix alongside next work."

6. **Get user approval** — present the plan and wait before implementing.

7. **Implement + verify** — fix approved issues, update or add tests for changed behavior, run the project's verification pipeline.

## Rules

- Audit, not rewrite. Fix what's wrong; don't refactor what's working.
- Every finding must cite specific code. No abstract concerns.
- Severity is based on concrete impact on upcoming work, not theoretical purity.
- Don't fix pre-existing issues unrelated to the work in scope unless they actively block progress.
- If the project has its own conventions, style guide, or architecture principles, evaluate against those — the code should match its own stated standards.
