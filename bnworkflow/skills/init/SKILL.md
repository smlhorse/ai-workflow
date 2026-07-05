---
name: bnworkflow:init
description: 初始化新專案，產生 CLAUDE.md 與設定檔。
---

# bnworkflow:init

初始化專案 AI 工作流。產生專案 `CLAUDE.md`、`.claude/CLAUDE.md`、`.claude/roles.md` 與設定檔。

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

**Step 3 — 產生檔案**

`CLAUDE.md`（專案根目錄）：套用 `templates/CLAUDE.md`，填入收集的資訊。

`.claude/CLAUDE.md`（不存在則建立；已存在則告知衝突，由 user 決定是否覆寫）：
從 `templates/rules.md` 複製內容。

`.claude/roles.md`（不存在則建立；已存在則告知衝突，由 user 決定是否覆寫）：
從 `templates/roles.md` 複製內容。

`docs/專案管理.md`（不存在則建立）：從 `templates/專案管理.md` 複製——每個專案的可讀操作總覽（變更分流三堆／Sprint 防波堤／digest）。規則見 `.claude/CLAUDE.md`，地圖見根 `CLAUDE.md`。

`.claude/settings.json`（不存在則建立）：
```json
{
  "$comment": "入版控。規範此專案的 Claude Code 行為。"
}
```

`.gitignore` 補充（附加，不覆寫；逐行檢查避免重複）：
```
.claude/settings.local.json
tmp/
```

**Step 4 — 回報**
列出產生與修改的檔案，標出仍需人工填寫的 `{佔位符}`；並指向 CLAUDE.md「目錄結構」地圖，說明 `docs/*` 由對應 skill 首次用到時才建、init 不預建。
