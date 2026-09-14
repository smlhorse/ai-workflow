#!/bin/bash
# UserPromptSubmit hook — re-injects a one-line, constant-size pointer to rules.md's
# communication standard on every user message, so it stays fresh instead of fading as
# the conversation grows. Deliberately kept to one line: the full rules already live in
# rules.md; repeating them verbatim every turn would itself become the clutter this exists
# to prevent.

jq -n '{"hookSpecificOutput":{"additionalContext":"[bnworkflow] 本輪若涉及執行/決策，套用 rules.md 標準（第一行給動作／重述進度／工作量給單位／指涉不明就問不猜／業務語言／位置明示／送出前先刪再送）；非閒聊不強制。"}}'
