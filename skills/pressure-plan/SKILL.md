---
name: pressure-plan
description: >-
  Stress-test a plan for completeness against reality. Use when the user says
  "pressure", "pressure-plan", "pressure the plan", "is the plan complete",
  "audit the plan", "what did we miss", or wants to verify a plan covers
  everything before execution.
---

# Pressure Plan

Take a plan and find where it's incomplete, wrong, or assumes things that aren't true. The plan might be a migration, refactor, feature spec, deployment checklist, API change, schema migration, deprecation, or anything else where someone wrote "here's what we'll do."

Unlike critique (which challenges whether an idea is *good*), pressure-plan assumes the direction is decided and checks whether the plan *actually covers everything it needs to*.

## Steps

1. **Understand the plan** — read the plan document, PR description, task list, or conversation context. Extract every concrete claim the plan makes:
   - Files, symbols, types, routes, configs it says it will touch
   - Assumptions about current state ("X only has 3 callers")
   - Behavioral claims ("this won't change anything")
   - Ordering/dependency claims ("we can do A before B")

2. **Verify against reality** — for each claim, check whether it's actually true. Search exhaustively:
   - Every symbol being changed — find ALL references, not just the ones the plan lists
   - Every assumption about current behavior — read the actual code
   - Every "this is the complete list" — prove it's complete or find what's missing
   - Config files, CI pipelines, deployment scripts, environment variables, documentation
   - Test fixtures and mocks that mirror production structure
   - String references in comments, docs, error messages, analytics, logging
   - Cross-system boundaries (API clients in other codebases, external consumers, database state)

3. **Check for implicit dependencies** — things the plan doesn't mention because the author didn't think of them:
   - Default values that callers rely on silently
   - Ordering assumptions (what if step 3 fails after step 2 succeeds?)
   - Rollback path (can this be partially applied and still work?)
   - Feature flags, environment-specific behavior, conditional logic
   - Cache invalidation, stale data, concurrent access
   - Downstream effects on things outside the plan's stated scope

4. **Report findings** — for each issue, cite the specific evidence:

   | Category | Meaning |
   |----------|---------|
   | **Gap** | Something the plan needs to cover but doesn't mention |
   | **Wrong assumption** | A claim the plan makes that isn't true |
   | **Safety risk** | The plan could cause breakage or data loss it doesn't account for |
   | **Ambiguity** | The plan is unclear about how to handle a specific case |
   | **Ordering issue** | Steps depend on each other in ways the plan doesn't acknowledge |

5. **Recommend** — suggest specific additions or corrections to the plan. Don't implement — the output is an improved plan, not code.

## Rules

- Verify claims, don't take them on faith. "There are 10 callsites" → search and count.
- Every finding must cite specific evidence. No "you might have missed something."
- Search broadly. Plans most often miss: documentation, test mocks, config files, string references, and cross-system consumers.
- Don't argue about whether the plan *should* do something — check whether it *covers* everything it needs to given what it's trying to do.
- If the plan is for a non-code change (process, infrastructure, deployment), pressure-test it against the same rigor — what does it assume about current state, what could go wrong, what's the rollback.
- When the plan involves any kind of rename or move, search for the old name in ALL file types including markdown, yaml, json, shell scripts, and env files.
