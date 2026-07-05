#!/usr/bin/env bash
# 框架文件一致性自檢（維護用；不進 plugin、不進用戶專案）
# 用法：bash tools/check-readme.sh
# 掛 pre-commit：cp tools/check-readme.sh .git/hooks/pre-commit-checker 或見 README 維護段
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" 2>/dev/null || exit 2
fail=0
ok(){ printf '✓ %s\n' "$*"; }
bad(){ printf '✗ %s\n' "$*"; fail=1; }

# 1) skill 數：資料夾 == README == 維護 CLAUDE.md
folders=$(find bnworkflow/skills -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
for f in README.md CLAUDE.md; do
  for n in $(grep -oE '[0-9]+ 個 skill' "$f" | grep -oE '^[0-9]+'); do
    [ "$n" = "$folders" ] || bad "$f 寫「$n 個 skill」但資料夾實有 $folders"
  done
done
[ "$fail" = 0 ] && ok "skill 數一致：$folders"

# 2) 三表 make-* 順序一致（以 Skill 說明為 master）
region(){ awk "/$1/,/$2/" README.md | grep -oE 'make-(req|spec|threat-model|design|data-governance|apidoc|testplan|plan|code|ops)' | paste -sd' ' -; }
a=$(region 'skill 產出物' '任務追蹤')       # 各產物的家（skill）
b=$(region '### 想手動' '## 角色與能力')     # 想手動
c=$(region '### 產出執行' '### 把關執行')     # Skill 說明（master）
if [ "$a" = "$b" ] && [ "$b" = "$c" ] && [ -n "$c" ]; then
  ok "三表 make-* 順序一致"
else
  bad "三表順序不一致：產出位置[$a] / 想手動[$b] / master[$c]"
fi

# 3) README skill 命名一致（無裸名 make-，一律 bnworkflow: 前綴）
if grep -qE '\| `make-' README.md; then bad "README 有裸名 make-（缺 bnworkflow: 前綴）"; else ok "命名一致（bnworkflow: 前綴）"; fi

# 4) SDD 目錄無殘留（design 已改 SDD）
if grep -rqE 'docs/design' bnworkflow README.md 2>/dev/null; then bad "仍有 docs/design 殘留（應為 docs/SDD）"; else ok "SDD 目錄無殘留"; fi

# 5) 專案化洩漏：框架 skill 內容不該有特定專案詞
if grep -rlE '入庫|工作台|WMS|900 堆' bnworkflow/skills/*/SKILL.md 2>/dev/null | grep -q .; then
  bad "框架 skill 有專案化洩漏（WMS/入庫/工作台/900 堆）：$(grep -rlE '入庫|工作台|WMS|900 堆' bnworkflow/skills/*/SKILL.md | tr '\n' ' ')"
else ok "框架 skill 無專案化洩漏"; fi

# 6) .claude 用 @import 單一真相（非又手抄一份會漂的副本）
grep -q '@../bnworkflow/skills/init/templates/rules.md' .claude/CLAUDE.md && ok ".claude/CLAUDE.md=@import 單一真相" || bad ".claude/CLAUDE.md 非 @import（可能又手抄了規則）"

# 7) 版本存在
grep -qE '"version": "[0-9]+\.[0-9]+\.[0-9]+"' bnworkflow/.claude-plugin/plugin.json && ok "plugin.json 版本格式正常" || bad "plugin.json 版本缺失/格式錯"

[ "$fail" = 0 ] && echo "== 全部通過 ==" || echo "== 有不一致，請修再 commit =="
exit $fail
