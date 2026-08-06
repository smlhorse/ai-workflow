#!/bin/bash
# PreToolUse hook (matcher: Bash) — flags destructive/irreversible git operations and pushes,
# forcing a permission "ask" instead of silent execution.
#
# Scope: catches literal `git reset --hard` / `git clean -f*` / `git push` invocations via Bash.
# It cannot catch equivalent effects reached through other tools or scripts.

cmd=$(jq -r '.tool_input.command // empty')

if [ -z "$cmd" ]; then
  exit 0
fi

if echo "$cmd" | grep -qiE '\bgit\s+reset\s+.*--hard\b'; then
  reason='此指令會永久丟棄未提交的變更（reset --hard）。依規則：破壞性/不可還原操作先告知並取得明確同意，請確認後再執行。'
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
fi

if echo "$cmd" | grep -qiE '\bgit\s+clean\s+.*-[a-zA-Z]*f'; then
  reason='此指令會永久刪除未追蹤的檔案（git clean -f）。依規則：破壞性/不可還原操作先告知並取得明確同意，請確認後再執行。'
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
fi

if echo "$cmd" | grep -qiE '\bgit\s+push\b'; then
  reason='push 需要當次明確下令，「OK」「去做」不構成 push 授權。請確認 user 已明確同意 push 才執行。'
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
fi

exit 0
