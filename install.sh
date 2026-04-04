#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
RULES_DIR="$REPO_DIR/rules"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()  { printf "\033[0;34m→\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m✓\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m!\033[0m %s\n" "$1"; }
err()   { printf "\033[0;31m✗\033[0m %s\n" "$1" >&2; }

link_dir() {
  local target="$1" link="$2" label="$3"
  local parent
  parent="$(dirname "$link")"

  mkdir -p "$parent"

  if [ -L "$link" ]; then
    local existing
    existing="$(readlink "$link")"
    if [ "$existing" = "$target" ]; then
      ok "$label already linked"
      return
    fi
    warn "$label symlink exists → $existing (replacing)"
    rm "$link"
  elif [ -d "$link" ]; then
    warn "Backing up $link → ${link}.bak"
    mv "$link" "${link}.bak"
  fi

  ln -s "$target" "$link"
  ok "$label → $target"
}

link_file() {
  local target="$1" link="$2" label="$3"
  local parent
  parent="$(dirname "$link")"

  mkdir -p "$parent"

  if [ -L "$link" ]; then
    local existing
    existing="$(readlink "$link")"
    if [ "$existing" = "$target" ]; then
      ok "$label already linked"
      return
    fi
    warn "$label symlink exists → $existing (replacing)"
    rm "$link"
  elif [ -f "$link" ]; then
    warn "Backing up $link → ${link}.bak"
    mv "$link" "${link}.bak"
  fi

  ln -s "$target" "$link"
  ok "$label → $target"
}

# ---------------------------------------------------------------------------
# Agent installers
# ---------------------------------------------------------------------------

install_cursor() {
  info "Installing for Cursor"
  link_dir "$SKILLS_DIR" "$HOME/.cursor/skills" "skills"
  link_file "$RULES_DIR/global-preferences.mdc" "$HOME/.cursor/rules/global-preferences.mdc" "rules/global-preferences.mdc"
}

install_claude_code() {
  info "Installing for Claude Code"
  # Claude Code discovers skills from ~/.claude/skills/<name>/SKILL.md
  link_dir "$SKILLS_DIR" "$HOME/.claude/skills" "skills"

  # Sync global preferences to ~/.claude/CLAUDE.md (plain text, no MDC frontmatter)
  local claude_md="$HOME/.claude/CLAUDE.md"
  if [ -f "$claude_md" ] && ! grep -q "jkvc-skills" "$claude_md" 2>/dev/null; then
    warn "$claude_md exists — run 'sync-ai-preferences' skill to update it from the repo"
  elif [ ! -f "$claude_md" ]; then
    # Generate a clean version without MDC frontmatter
    sed '1,/^---$/{ /^---$/d; /^[a-zA-Z]/d; }' "$RULES_DIR/global-preferences.mdc" \
      | sed 's/\*\*\([^*]*\)\*\*/\1/g' \
      | sed 's/^# Global Rules/# Global Preferences/' \
      > "$claude_md"
    ok "Generated $claude_md from global-preferences.mdc"
  fi
}

install_codex() {
  info "Installing for Codex CLI"
  # Codex discovers skills from ~/.codex/skills/<name>/SKILL.md
  link_dir "$SKILLS_DIR" "$HOME/.codex/skills" "skills"
}

install_opencode() {
  info "Installing for OpenCode"
  link_dir "$SKILLS_DIR" "$HOME/.config/opencode/skills" "skills"
}

install_windsurf() {
  info "Installing for Windsurf"
  link_dir "$SKILLS_DIR" "$HOME/.windsurf/skills" "skills"
}

# ---------------------------------------------------------------------------
# Auto-detect which agents are installed
# ---------------------------------------------------------------------------

detect_agents() {
  local agents=()
  [ -d "$HOME/.cursor" ]              && agents+=("cursor")
  [ -d "$HOME/.claude" ]              && agents+=("claude-code")
  command -v codex &>/dev/null         && agents+=("codex")
  [ -d "$HOME/.config/opencode" ]     && agents+=("opencode")
  [ -d "$HOME/.windsurf" ]            && agents+=("windsurf")
  echo "${agents[@]}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Install jkvc-skills for AI coding agents.

Options:
  --agent <name>    Install for a specific agent only.
                    Supported: cursor, claude-code, codex, opencode, windsurf
  --all             Install for all detected agents (default)
  --list            List detected agents and exit
  --uninstall       Remove symlinks (restores .bak if available)
  -h, --help        Show this help

Examples:
  ./install.sh                    # Auto-detect and install for all agents
  ./install.sh --agent cursor     # Install for Cursor only
  ./install.sh --agent claude-code --agent codex  # Multiple agents
EOF
}

uninstall() {
  info "Uninstalling jkvc-skills symlinks"
  local paths=(
    "$HOME/.cursor/skills"
    "$HOME/.cursor/rules/global-preferences.mdc"
    "$HOME/.claude/skills"
    "$HOME/.codex/skills"
    "$HOME/.config/opencode/skills"
    "$HOME/.windsurf/skills"
  )
  for p in "${paths[@]}"; do
    if [ -L "$p" ]; then
      local target
      target="$(readlink "$p")"
      if [[ "$target" == *jkvc-skills* ]]; then
        rm "$p"
        if [ -e "${p}.bak" ]; then
          mv "${p}.bak" "$p"
          ok "Restored ${p} from backup"
        else
          ok "Removed ${p}"
        fi
      fi
    fi
  done
}

main() {
  local agents=()
  local do_uninstall=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)    agents+=("$2"); shift 2 ;;
      --all)      shift ;;
      --list)     echo "Detected agents: $(detect_agents)"; exit 0 ;;
      --uninstall) do_uninstall=true; shift ;;
      -h|--help)  usage; exit 0 ;;
      *)          err "Unknown option: $1"; usage; exit 1 ;;
    esac
  done

  if $do_uninstall; then
    uninstall
    exit 0
  fi

  # Default: auto-detect
  if [ ${#agents[@]} -eq 0 ]; then
    read -ra agents <<< "$(detect_agents)"
  fi

  if [ ${#agents[@]} -eq 0 ]; then
    err "No supported AI agents detected. Use --agent <name> to install manually."
    exit 1
  fi

  echo ""
  info "jkvc-skills — installing from $REPO_DIR"
  info "Skills: $(ls "$SKILLS_DIR" | tr '\n' ' ')"
  echo ""

  for agent in "${agents[@]}"; do
    case "$agent" in
      cursor)      install_cursor ;;
      claude-code) install_claude_code ;;
      codex)       install_codex ;;
      opencode)    install_opencode ;;
      windsurf)    install_windsurf ;;
      *)           warn "Unknown agent: $agent (skipping)" ;;
    esac
    echo ""
  done

  ok "Done. Skills are now shared across: ${agents[*]}"
  echo ""
  echo "  To add a new skill:  mkdir $SKILLS_DIR/<name> && edit SKILL.md"
  echo "  To sync changes:     git -C $REPO_DIR pull"
  echo "  To uninstall:        $REPO_DIR/install.sh --uninstall"
  echo ""
}

main "$@"
