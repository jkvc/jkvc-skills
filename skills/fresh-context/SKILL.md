---
name: fresh-context
description: >-
  Only use when the user explicitly says "fresh-context",
  "fresh context", "fresh agent", or "on a fresh agent".
disable-model-invocation: true
---

# Fresh Context

Run the current task in a fresh subagent that has zero prior conversation context. This eliminates confirmation bias, anchoring to earlier conclusions, and context pollution from a long session.

Use alongside another skill for an unbiased second opinion, or standalone when you've been deep in a problem and need fresh eyes.

## Steps

1. **Build a self-contained handoff** — the subagent has zero conversation history, so the prompt must include everything it needs:
   - The task or question to answer
   - Relevant file paths and directories to examine
   - Scope boundaries (what to focus on, what to ignore)
   - If a companion skill was invoked, include its full instructions
   - If there's a plan document, spec, or PR to review, include its path

   Critical: pass *facts and locations*, not your conclusions. Don't say "I refactored X and I think it's correct, please verify" — say "X was refactored, verify the migration is complete and behaviorally correct." The subagent must form its own opinions.

2. **Choose the right subagent** — pick based on what the task needs:
   - Read-only analysis (audit, review, search) → `code_search` with `readonly: true`
   - Needs to run commands (tests, type-check, build) → `shell`
   - Needs to modify files → `generalPurpose`
   - Multiple independent areas to check → launch multiple subagents in parallel

3. **Present results unfiltered** — when the subagent returns:
   - Present its findings directly without softening or filtering
   - If it found issues you missed, say so explicitly
   - If it contradicts your earlier analysis, flag the contradiction — don't quietly resolve it
   - If it found nothing, that's a valid and useful signal too

## Rules

- Never leak your conclusions into the subagent prompt. Give it the task, not your answer.
- Prefer read-only subagents unless the task specifically requires writes or command execution.
- If combining with another skill, paste that skill's full instructions into the subagent prompt.
- The value of this skill is the absence of prior context. Don't undermine it by summarizing your session for the subagent.
- When the user invokes this standalone (not with a companion skill), ask what they want fresh eyes on if it's not obvious from context.
