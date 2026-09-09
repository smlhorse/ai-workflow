#!/bin/bash
# SessionEnd hook — mechanical close-out only. A session hook has ~1.5s and cannot call the model,
# so it cannot write a summary. What it can do: log the end, and if this session's handoff file was
# never updated during the session, mark it 未收尾 and record the transcript path so the next
# session can recover the state itself.
#
# Never rewrites org.md (concurrent windows) and never fails the shutdown.

input=$(cat)
dir="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.cwd // "."')}"
team="$dir/.team"

[ -d "$team" ] || exit 0

sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
reason=$(printf '%s' "$input" | jq -r '.reason // "other"')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')
now=$(date '+%Y-%m-%d %H:%M')

printf '%s\tend\t%s\t%s\n' "$now" "$sid" "$reason" >> "$team/.sessions.log" 2>/dev/null

started=$(tail -500 "$team/.sessions.log" 2>/dev/null | grep -F "	start	$sid" | tail -1 | cut -f1)
[ -n "$started" ] || exit 0

for f in "$team"/handoff/*.md; do
  [ -f "$f" ] || continue
  grep -q "^最後 session id: $sid$" "$f" || continue
  updated=$(sed -n 's/^更新時間: //p' "$f" | head -1)
  # 佔位符等非日期值一律當「沒更新過」，否則字串比大小會反向判成已收尾
  case "$updated" in
    [0-9][0-9][0-9][0-9]-*) [ ! "$updated" \< "$started" ] && continue ;;
  esac
  tmp="$f.tmp.$$"
  awk -v t="$transcript" '
    NR==1 && /^---$/ { fm=1; print; next }
    fm && !done_s && /^狀態: / { print "狀態: 未收尾"; done_s=1; next }
    fm && !done_t && /^逐字稿: / { print "逐字稿: " t; done_t=1; next }
    fm && /^---$/ { if (!done_t) print "逐字稿: " t; fm=0; print; next }
    { print }
  ' "$f" > "$tmp" 2>/dev/null && mv "$tmp" "$f" 2>/dev/null || rm -f "$tmp" 2>/dev/null
done

exit 0
