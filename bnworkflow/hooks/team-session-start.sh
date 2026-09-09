#!/bin/bash
# SessionStart hook — only acts when the project opted into team memory (a .team/ directory exists).
# Records the session once and hands the model its own session id: the model has no other way to
# learn it, and team join needs it to register the member in org.md.
#
# SessionStart is one of the few events where plain stdout is added to Claude's context, so the id
# goes out as plain text. Session hooks run on a tight shared budget, so this stays to a couple of
# cheap calls: no summarising, and no rewrite of org.md — concurrent windows would clobber each
# other, so org.md is the skill's to update.
#
# The event re-fires on compact/resume, hence the "log the session id once" guard: one start line
# per session keeps the log short and keeps SessionEnd's staleness comparison anchored to the real
# session start rather than to the latest compaction.

input=$(cat)
dir="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.cwd // "."')}"
team="$dir/.team"
log="$team/.sessions.log"

[ -d "$team" ] || exit 0

sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')

# 流水無上限會讓後面的查找失準，超量就留最近的部分
lines=$(wc -l < "$log" 2>/dev/null || echo 0)
if [ "${lines:-0}" -gt 400 ]; then
  tail -200 "$log" > "$log.tmp" 2>/dev/null && mv "$log.tmp" "$log" 2>/dev/null || rm -f "$log.tmp" 2>/dev/null
fi

grep -qF "	start	$sid" "$log" 2>/dev/null || \
  printf '%s\tstart\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$sid" >> "$log" 2>/dev/null

printf '[bnworkflow] 本專案有團隊記憶 .team/。本 session id：%s（登記組織表要用）。\n' "$sid"
exit 0
