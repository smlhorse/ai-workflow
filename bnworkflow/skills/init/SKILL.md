---
name: init
description: 初始化新專案，產生 CLAUDE.md 與設定檔。
---

# bnworkflow:init

初始化專案 AI 工作流。產生專案 `CLAUDE.md`、`.claude/CLAUDE.md`、`.claude/roles.md`、設定檔與團隊記憶 `.team/`。

前置條件：bnworkflow plugin 已安裝（`/plugin install bnworkflow@smlhorse-ai-workflow`）。

## 執行

**Step 1 — 確認**
檢查專案根目錄是否已有 `CLAUDE.md`：
- 已存在 → 這是已初始化的專案，告知並建議改用 `bnworkflow:update` 補落差（只補缺的、不覆寫既有內容）；user 明確要重建才覆寫
- 不存在 → 繼續

**Step 2 — 收集資訊（一次問完）**
1. 專案名稱與一句話描述
2. 環境清單及各自連線方式（dev / uat / prod 或自訂）
3. Ground Truth 規格文件位置
4. 啟動命令
5. 架構摘要（技術棧、關鍵路徑）
6. 本機 Issue 位置（選填，預設 `docs/issues/` 版控；不強迫 user 填）
7. 團隊（選填）：組織 ID、團隊 ID，以及每個角色需要幾位成員；不設定＝不建 `.team/`。成員 ID 預設採 `{角色小寫}-{兩位流水號}`（如 `pg-01`、`pg-02`），姓名與主管關係由 user 確認；PG 預設全端，前後端是工作分組而非成員身分。

**Step 3 — 產生檔案**

`CLAUDE.md`（專案根目錄）：套用 `templates/CLAUDE.md`，填入收集的資訊。

`.claude/CLAUDE.md`（不存在則建立；已存在則告知衝突，由 user 決定是否覆寫）：
從 `templates/rules.md` 複製內容。

`.claude/roles.md`（不存在則建立；已存在則告知衝突，由 user 決定是否覆寫）：
從 `templates/roles.md` 複製內容。

`.claude/settings.json`（不存在則建立）：
```json
{
  "$comment": "入版控。規範此專案的 Claude Code 行為。"
}
```

`.team/`（有設定團隊才建；不進版控）：
- `defaults.md` — 套用 `../team/templates/defaults.md`，填入專案預設組織／團隊
- `organizations/{組織}/teams/{團隊}/org.md` — 套用 `../team/templates/org.md`；同角色可有多人，每位使用穩定成員 ID，主管欄填實際成員 ID
- `organizations/{組織}/teams/{團隊}/capabilities.md` — 套用 `../team/templates/capabilities.md`；join／refresh 只讀該成員角色的一列
- `organizations/{組織}/teams/{團隊}/work.md` — 套用 `../team/templates/work.md`，初始無工作
- `organizations/{組織}/teams/{團隊}/members/{成員 ID}.md` — 套用對應角色的 `../team/templates/members/{角色代號}.md`；將卡內路徑與指派語句填成實際組織／團隊／成員 ID。姓名與個人色彩給草案讓 user 改，不代 user 拍板
- `organizations/{組織}/teams/{團隊}/handoff/{成員 ID}.md` — 套用 `../team/templates/handoff.md`，狀態填「未開始」
- `sessions/` — 建空目錄；join 後依 `../team/templates/session.md` 建立 session 綁定
- `.sessions.log` 由掛勾第一次開 session 時自動產生，init 不建

日常使用見 `bnworkflow:team`。

`.gitignore` 補充（附加，不覆寫；逐行檢查避免重複）：
```
.claude/settings.local.json
tmp/
.team/
```

**Step 4 — 回報**
列出產生與修改的檔案，標出仍需人工填寫的 `{佔位符}`，以及成員卡裡標「⚠️ 待確認」的條目。
有建 `.team/` 時提醒：本次 session 開始時還沒有團隊記憶，拿不到 session 編號時不得編造；從下一個 session 起用 `/bnworkflow:team join [{組織}/{團隊}] {成員 ID}` 完成綁定與「未收尾」安全網。
