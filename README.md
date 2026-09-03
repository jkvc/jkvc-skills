# jkvc-skills

You're probably here because you found my github or I sent you a link to this. I promise I'm not trying to give you a virus. 

Proudly tested extensively thru claude code, cursor, and the goldfish brain of Junshen K Chen. 

---

Shared AI agent skills and rules. One repo, synced across machines, picked up by any agent that supports SKILL.md discovery.

## What's in here

```
skills/                         # SKILL.md files — each skill is a directory
├── architecture-review/        # Deep codebase exploration and assessment
├── brainstorm/                 # Generate creative ideas for a goal
├── code-review/                # Systematically review a PR or branch
├── critique/                   # Stress-test a specific idea or proposal
├── document/                   # Audit and update project documentation
├── eli5/                       # Explain a topic tailored to a specific audience
├── fresh-context/              # Run a task on a fresh subagent (no session bias)
├── interview/                  # Gather requirements through structured questions
├── pressure-plan/              # Stress-test a plan for completeness against codebase
├── retrospective/              # Fresh-eyes review of recent implementation
├── sync-ai-preferences/        # Sync global prefs from Cursor rules → Claude Code
├── tech-debt/                  # Record tech debt entries
└── verify/                     # Run full verification pipeline (type-check, lint, test, build)

rules/
└── global-preferences.mdc     # Global agent behavior rules (always applied)
```

## Install

```bash
git clone git@github.com:<you>/jkvc-skills.git ~/jkvc-skills
cd ~/jkvc-skills
./install.sh
```

The install script auto-detects which AI agents you have and symlinks skills into the right location for each.

### Supported agents

| Agent | Skills path | Rules path |
|-------|------------|------------|
| **Cursor** | `~/.cursor/skills/` | `~/.cursor/rules/global-preferences.mdc` |
| **Claude Code** | `~/.claude/skills/` | `~/.claude/CLAUDE.md` (generated) |
| **Codex CLI** | `~/.codex/skills/` | — |
| **OpenCode** | `~/.config/opencode/skills/` | — |
| **Windsurf** | `~/.windsurf/skills/` | — |

### Install for a specific agent

```bash
./install.sh --agent cursor
./install.sh --agent claude-code --agent codex
```

### List detected agents

```bash
./install.sh --list
```

### Uninstall

```bash
./install.sh --uninstall
```

Removes symlinks and restores `.bak` backups if they exist.

## How it works

The install script symlinks the `skills/` directory into each agent's skill discovery path. No files are copied — all agents read from the same source. When you add, edit, or remove a skill, every agent sees the change immediately.

```
~/jkvc-skills/skills/  ←  ~/.cursor/skills (symlink)
                       ←  ~/.claude/skills  (symlink)
                       ←  ~/.codex/skills   (symlink)
```

## Adding a new skill

```bash
mkdir skills/my-new-skill
cat > skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: >-
  Brief description of what it does and when the agent should use it.
---

# My New Skill

Instructions for the agent.

## Steps

1. ...
2. ...

## Rules

- ...
EOF
```

Every agent picks it up immediately (no reinstall needed).

## SKILL.md format

Each skill is a directory containing a `SKILL.md` file. The file has:

1. **YAML frontmatter** — `name`, `description`, and optionally `disable-model-invocation: true` (prevents auto-triggering)
2. **Markdown body** — instructions the agent follows when the skill is activated

The `description` field is what agents use to decide when to activate the skill. Write it as a trigger list: "Use when the user says X, Y, or Z."

## Editing rules

`rules/global-preferences.mdc` is the source of truth for global agent behavior. It uses Cursor's MDC format (YAML frontmatter with `alwaysApply: true`).

After editing, run the `sync-ai-preferences` skill to propagate changes to Claude Code's `~/.claude/CLAUDE.md`.

## On a new machine

```bash
git clone git@github.com:<you>/jkvc-skills.git ~/jkvc-skills
cd ~/jkvc-skills && ./install.sh
```

## Per-project skills

This repo is for **personal global skills** that apply everywhere. For project-specific skills, put them in the project's `.cursor/skills/` or `.agents/skills/` directory and commit them to that repo.
