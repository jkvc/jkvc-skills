---
name: in-session
description: >-
  Only use when the user explicitly says "in-session",
  "in session", "stay in session", "keep context",
  or "don't spawn a subagent".
disable-model-invocation: true
---

# In Session

Keep all work in the current session. Use your existing conversation history, accumulated context, and direct tool calls — no subagent delegation.

Use it when session continuity matters more than unbiased isolation.

**Scope:** This skill is only effective for the turn in which the user invokes it. It does not persist across future turns or alter default behavior.

## Rules

- Never launch a subagent (Task tool with any subagent_type) this turn unless the user overrides it for a specific subtask.
- If the task would benefit from a fresh perspective (e.g. audit, review, bias check), flag that trade-off but still proceed in-session unless told otherwise.
- Prefer direct, sequential exploration over isolated subagent queries — you can follow threads across files in ways a subagent can't.
