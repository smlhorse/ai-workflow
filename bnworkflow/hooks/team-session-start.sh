#!/bin/bash
# SessionStart hook — only acts when the project opted into team memory (a .team/ directory exists).
# Logs the session start and hands the model its own session id: the model has no other way to learn
# it, and team join needs it to register the member in org.md.
#
# SessionStart is one of the few events where plain stdout is added to Claude's context, so the id
# goes out as plain text. Kept light (session hooks run on a tight budget): no summarising, and no
# rewrite of org.md — concurrent windows would clobber each other, so org.md is the skill's to update.

input=$(cat)
dir="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.cwd // "."')}"
team="$dir/.team"

[ -d "$team" ] || exit 0

sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
printf '%s\tstart\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$sid" >> "$team/.sessions.log" 2>/dev/null

printf '[bnworkflow] 本專案有團隊記憶 .team/。本 session id：%s（登記組織表要用）。\n' "$sid"
exit 0
