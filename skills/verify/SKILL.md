---
name: verify
description: >-
  Run verification checks not already covered by the project's pre-push hook.
  Use when the user says "verify", "run checks", "check everything", "any test
  needed", or wants confirmation that recent changes are clean.
---

# Verify

Run checks the project defines that the pre-push hook does **not** already run. Fix issues introduced by recent changes and report results.

## 1. Discover what the project can verify

Inspect the repo for how it runs checks. Use whatever the project already documents or wires up — do not invent a standard pipeline.

Sources (use what exists; skip what doesn't):

- **Pre-push hook** — `.husky/pre-push`, `.githooks/pre-push`, or `core.hooksPath` target
- **Package scripts** — `package.json`, `pyproject.toml` `[project.scripts]`, `Cargo.toml`, `Makefile`, `justfile`, etc.
- **CI** — `.github/workflows/`, other CI configs (often the canonical check list)
- **Repo docs** — `CLAUDE.md`, `README.md`, `CONTRIBUTING.md` for project-specific conventions (e.g. separate build dirs)

Each discovered command is one **check**. Name it from the script/target label or its role (e.g. `lint`, `test`, `build`, `make check`).

## 2. Determine what pre-push already covers

Read the pre-push hook. Any command or script it invokes is **hook-covered** — skip it during verify; it will run on `git push`.

Match by the actual invocations in the hook (script names, `make` targets, direct binaries), not by guessing tool families. If the hook calls `npm run validate`, defer `validate` — whatever that script does.

If there is no pre-push hook, nothing is hook-covered.

## 3. Run uncovered checks only

`uncovered = discovered checks − hook-covered checks`

- Run each uncovered check with the project's own command.
- Run independent checks in parallel when practical.
- If every discovered check is hook-covered, skip execution and note that push will validate.
- If the project defines no checks at all, say so and stop.

## 4. Report

List every discovered check and its outcome:

```
| Check        | Result              |
|--------------|---------------------|
| typecheck    | ↷ pre-push          |
| lint         | ✓ 0 errors          |
| test         | ↷ pre-push          |
| build        | ✓ compiled          |
```

- `↷ pre-push` — deferred; hook will run it on push
- `✓ …` — passed (brief detail: clean, N/N pass, compiled, etc.)
- `✗ …` — failed (brief detail; fix if you introduced it)
- `—` — not defined in this project

## Rules

- **Discover, don't prescribe** — use the repo's commands and conventions, not a fixed toolchain.
- **Only fix issues you introduced.** Don't fix pre-existing failures unless they block the pipeline.
- **On push**, do not re-run hook-covered checks — commit, push, let the hook validate them.
