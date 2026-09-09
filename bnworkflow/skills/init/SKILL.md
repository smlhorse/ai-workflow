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
- 已存在 → 告知，詢問是否覆寫，等指示
- 不存在 → 繼續

**Step 2 — 收集資訊（一次問完）**
1. 專案名稱與一句話描述
2. 環境清單及各自連線方式（dev / uat / prod 或自訂）
3. Ground Truth 規格文件位置
4. 啟動命令
5. 架構摘要（技術棧、關鍵路徑）
6. 本機 Issue 位置（選填，預設 `docs/issues/` 版控；不強迫 user 填）
7. 團隊成員（選填）：列 `templates/roles.md` 的 12 個角色讓 user 勾選這個專案要哪幾位；不勾＝不建 `.team/`

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

`.team/`（有勾選成員才建；不進版控）：
- `org.md` — 套用 `../team/templates/org.md`，被勾選的成員各一列；代號與預設主管照該模板的對照表填，由 user 確認
- `members/{代號}.md` — 每位一張自我介紹卡，套用 `../team/templates/member.md`；姓名與人設（經驗/工具/寫作習性/溝通方式/個性）先給草案讓 user 改，不代 user 拍板
- `handoff/{代號}.md` — 每位一份空的工作管理檔，套用 `../team/templates/handoff.md`，狀態填「進行中」
- `.sessions.log` 由掛勾在第一次開 session 時自動產生，init 不建

日常使用見 `bnworkflow:team`。

`.gitignore` 補充（附加，不覆寫；逐行檢查避免重複）：
```
.claude/settings.local.json
tmp/
.team/
```

**Step 4 — 回報**
列出產生與修改的檔案，標出仍需人工填寫的 `{佔位符}`。
