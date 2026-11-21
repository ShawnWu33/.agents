#!/usr/bin/env bash
# Wire ~/.agents (shared AGENTS.md + skills) into every coding agent found on this machine.
# Safe to re-run. Never overwrites a real file: conflicts are reported and skipped unless --force.
#
#   ./install.sh            install for detected agents
#   ./install.sh --dry-run  show what would change
#   ./install.sh --force    back up conflicting files to <file>.bak.<timestamp>, then link
#   ./install.sh --all      configure every supported agent, even ones not detected

set -euo pipefail

DRY=0 FORCE=0 ALL=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --force) FORCE=1 ;;
    --all) ALL=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

AGENTS="$HOME/.agents"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TS="$(date +%Y%m%d%H%M%S)"
CONFLICTS=0

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY" = 1 ]; then say "  would: $*"; else "$@"; fi; }

# The repo must be reachable at ~/.agents: Codex, OpenCode and Pi read ~/.agents/skills directly.
if [ "$SRC" != "$(cd "$AGENTS" 2>/dev/null && pwd -P)" ]; then
  if [ -e "$AGENTS" ] || [ -L "$AGENTS" ]; then
    say "error: $AGENTS already exists and is not this folder ($SRC)." >&2
    say "Move one of them so this folder lives at (or is linked from) $AGENTS." >&2
    exit 1
  fi
  say "linking $AGENTS -> $SRC"
  run ln -s "$SRC" "$AGENTS"
fi

# link <target> <link-path>: make <link-path> a symlink to <target>.
link() {
  local target="$1" dest="$2"
  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$target" ]; then say "  ok      $dest"; return; fi
    say "  relink  $dest (was -> $(readlink "$dest"))"
    run rm "$dest"
  elif [ -e "$dest" ]; then
    if [ "$FORCE" = 1 ]; then
      say "  backup  $dest -> $dest.bak.$TS"
      run mv "$dest" "$dest.bak.$TS"
    else
      say "  CONFLICT $dest exists. Merge it into $target, then re-run with --force."
      CONFLICTS=$((CONFLICTS + 1)); return
    fi
  else
    say "  link    $dest"
  fi
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$target" "$dest"
}

detected() { # detected <binary> <config-dir>
  [ "$ALL" = 1 ] || command -v "$1" >/dev/null 2>&1 || [ -d "$2" ]
}

# --- Claude Code: @import in CLAUDE.md, one symlink per skill and subagent ---
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
if detected claude "$CLAUDE_DIR"; then
  say "Claude Code ($CLAUDE_DIR)"
  md="$CLAUDE_DIR/CLAUDE.md" line="@~/.agents/AGENTS.md"
  if [ -f "$md" ] && grep -qxF "$line" "$md"; then
    say "  ok      $md imports AGENTS.md"
  else
    say "  import  $line >> $md"
    run mkdir -p "$CLAUDE_DIR"
    if [ "$DRY" = 0 ]; then
      if [ -s "$md" ]; then printf '\n%s\n' "$line" >> "$md"; else printf '%s\n' "$line" > "$md"; fi
    fi
  fi
  for skill in "$AGENTS"/skills/*/; do
    [ -f "$skill/SKILL.md" ] || continue
    name="$(basename "$skill")"
    link "$AGENTS/skills/$name" "$CLAUDE_DIR/skills/$name"
  done
  for agent in "$AGENTS"/agents/*.md; do
    [ -f "$agent" ] || continue
    link "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
  done
  # Drop links to skills and subagents that were removed from ~/.agents.
  for l in "$CLAUDE_DIR"/skills/* "$CLAUDE_DIR"/agents/*; do
    if [ -L "$l" ] && [ ! -e "$l" ] && [[ "$(readlink "$l")" == "$AGENTS/"* ]]; then
      say "  prune   $l"; run rm "$l"
    fi
  done
fi

# --- Codex: AGENTS.md symlink; reads ~/.agents/skills natively ---------------
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
if detected codex "$CODEX_DIR"; then
  say "Codex ($CODEX_DIR)"
  link "$AGENTS/AGENTS.md" "$CODEX_DIR/AGENTS.md"
fi

# --- OpenCode: AGENTS.md symlink; reads ~/.agents/skills natively ------------
OPENCODE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
if detected opencode "$OPENCODE_DIR"; then
  say "OpenCode ($OPENCODE_DIR)"
  link "$AGENTS/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
fi

# --- Pi: AGENTS.md symlink; reads ~/.agents/skills natively ------------------
PI_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
if detected pi "$PI_DIR"; then
  say "Pi ($PI_DIR)"
  link "$AGENTS/AGENTS.md" "$PI_DIR/AGENTS.md"
fi

if [ "$CONFLICTS" -gt 0 ]; then
  say "$CONFLICTS conflict(s) skipped; see CONFLICT lines above."
  exit 1
fi
if [ "$DRY" = 1 ]; then say "dry run: nothing changed"; else say "done"; fi
