#!/bin/bash
# SessionEnd hook — mechanical close-out only. A session hook has ~1.5s shared budget and cannot
# call the model, so it cannot write a summary. What it can do: log the end, and if this session's
# handoff file was never updated during the session, mark it 未收尾 and record the transcript path
# so the next session can recover the state itself. Handoff files may be nested by organization/team.
#
# Kept cheap on purpose: one recursive lookup picks out this session's handoff file rather than
# running one model call or one batch per member.
# Never rewrites org.md (concurrent windows) and never fails the shutdown.

input=$(cat)
dir="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.cwd // "."')}"
team="$dir/.team"

[ -d "$team" ] || exit 0

sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
reason=$(printf '%s' "$input" | jq -r '.reason // "other"')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')

printf '%s\tend\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$sid" "$reason" >> "$team/.sessions.log" 2>/dev/null

# 本 session 的開始時間＝第一筆 start（compact/resume 會再觸發 SessionStart，取最後一筆會誤判成剛開機）
started=$(grep -F "	start	$sid" "$team/.sessions.log" 2>/dev/null | head -1 | cut -f1)
[ -n "$started" ] || exit 0

find "$team/organizations" -type f -path '*/handoff/*.md' -exec grep -l "^最後 session id: $sid$" {} + 2>/dev/null | while IFS= read -r f; do
  updated=$(sed -n 's/^更新時間: //p' "$f" | head -1)
  # 佔位符等非日期值一律當「沒更新過」，否則字串比大小會反向判成已收尾
  case "$updated" in
    [0-9][0-9][0-9][0-9]-*) [ ! "$updated" \< "$started" ] && continue ;;
  esac
  tmp="$f.tmp.$$"
  awk -v t="$transcript" '
    NR==1 && /^---$/ { fm=1; print; next }
    fm && !ds && /^狀態: / { print "狀態: 未收尾"; ds=1; next }
    fm && !dt && /^逐字稿: / { print "逐字稿: " t; dt=1; next }
    fm && /^---$/ {
      if (!ds) print "狀態: 未收尾"
      if (!dt) print "逐字稿: " t
      fm=0; print; next
    }
    { print }
  ' "$f" > "$tmp" 2>/dev/null && mv "$tmp" "$f" 2>/dev/null || rm -f "$tmp" 2>/dev/null
done

exit 0
