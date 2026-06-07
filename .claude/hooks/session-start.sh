#!/bin/bash
set -euo pipefail

# Only run in Claude Code remote environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

GSTACK_REPO="https://github.com/garrytan/gstack.git"
GSTACK_DIR="$HOME/.gstack/gstack"
SKILLS_DIR="$HOME/.claude/skills"

echo "Installing gstack skills..."

# Clone or update the gstack repository
if [ -d "$GSTACK_DIR/.git" ]; then
  git -C "$GSTACK_DIR" fetch origin --quiet
  git -C "$GSTACK_DIR" reset --hard origin/main --quiet
else
  mkdir -p "$(dirname "$GSTACK_DIR")"
  git clone --depth=1 --quiet "$GSTACK_REPO" "$GSTACK_DIR"
fi

# Install each skill directory that contains a SKILL.md
mkdir -p "$SKILLS_DIR"
linked=()

for skill_dir in "$GSTACK_DIR"/*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  dir_name="$(basename "$skill_dir")"
  [ "$dir_name" = "node_modules" ] && continue

  # Use directory name as the skill name (no prefix)
  skill_name="$dir_name"
  target="$SKILLS_DIR/$skill_name"

  mkdir -p "$target"

  # Copy SKILL.md
  cp -f "$skill_dir/SKILL.md" "$target/SKILL.md"

  # Copy sections/ subdirectory if present
  if [ -d "$skill_dir/sections" ]; then
    rm -rf "$target/sections"
    cp -r "$skill_dir/sections" "$target/sections"
  fi

  linked+=("$skill_name")
done

echo "Installed ${#linked[@]} gstack skills: ${linked[*]}"
