#!/bin/bash
# PreToolUse hook (matcher: Bash) — flags commands that likely create/modify billable cloud
# resources, forcing a permission "ask" instead of silent execution.
#
# Scope: this is one layer of defense, not a complete guardrail. It only catches Bash-driven
# CLI calls matching known cloud-provisioning tools; it cannot catch console clicks, SDK calls
# embedded in application code, or CLI tools/subcommands not listed below.

cmd=$(jq -r '.tool_input.command // empty')

if [ -z "$cmd" ]; then
  exit 0
fi

if echo "$cmd" | grep -qiE '\b(gcloud|aws|az|terraform|pulumi)\b.*\b(create|apply|up|provision|deploy)\b'; then
  reason='此指令疑似建立/變更會持續計費的雲端資源。依 make-code 規則：動手前需先列出具體方案、查證計費方式、取得對該方案的明確同意，原則性回答不算授權。請確認已完成上述步驟再執行。'
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
fi

exit 0
