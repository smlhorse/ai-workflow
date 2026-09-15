#!/bin/bash
# SessionStart hook — only acts when the project opted into team memory (a .team/ directory exists).
# Records the session once and hands the model its own session id. When the session is already
# bound, also returns its organization/team/member identity from sessions/{id}.md.
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
if [ -f "$log" ]; then
  lines=$(wc -l < "$log")
else
  lines=0
fi
if [ "${lines:-0}" -gt 400 ]; then
  tail -200 "$log" > "$log.tmp" 2>/dev/null && mv "$log.tmp" "$log" 2>/dev/null || rm -f "$log.tmp" 2>/dev/null
fi

grep -qF "	start	$sid" "$log" 2>/dev/null || \
  printf '%s\tstart\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$sid" >> "$log" 2>/dev/null

printf '[bnworkflow] 本專案有團隊記憶 .team/。本 session id：%s（team join 綁定身分要用）。\n' "$sid"
binding="$team/sessions/$sid.md"
if [ -f "$binding" ]; then
  org=$(sed -n 's/^組織: //p' "$binding" | head -1)
  group=$(sed -n 's/^團隊: //p' "$binding" | head -1)
  member=$(sed -n 's/^成員 ID: //p' "$binding" | head -1)
  role=$(sed -n 's/^角色: //p' "$binding" | head -1)
  bound_version=$(sed -n 's/^能力版本: //p' "$binding" | head -1)
  current_version=$(jq -r '.version // "unknown"' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" 2>/dev/null)
  printf '[bnworkflow] 已綁定：%s/%s %s（%s）；不得因帳號改變而另建身分。\n' "$org" "$group" "$member" "$role"
  if [ -n "$current_version" ] && [ "$current_version" != "unknown" ] && [ "$bound_version" != "$current_version" ]; then
    printf '[bnworkflow] 能力版本 %s 落後於 plugin %s：先執行 team refresh；若本版新增 skill/hook/tool，handoff 後重開 session。\n' "${bound_version:-未記錄}" "$current_version"
  fi
fi
exit 0
