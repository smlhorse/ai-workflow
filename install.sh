#!/bin/bash
# 用法：bash install.sh /path/to/target-project

set -e

FRAMEWORK_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
  echo "用法：bash install.sh /path/to/target-project"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "錯誤：目標專案目錄不存在：$TARGET_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR/.claude/skills"

# bnworkflow:* skill
for skill in "$FRAMEWORK_DIR"/.claude/skills/bnworkflow:*/; do
  skill_name="$(basename "$skill")"
  ln -sf "$skill" "$TARGET_DIR/.claude/skills/$skill_name"
  echo "✓ .claude/skills/$skill_name"
done

echo "$FRAMEWORK_DIR" > "$TARGET_DIR/.claude/workflow-framework-path"
echo "✓ .claude/workflow-framework-path"

echo ""
echo "安裝完成。請在 $TARGET_DIR 開啟 Claude Code 並執行 /bnworkflow:init"
