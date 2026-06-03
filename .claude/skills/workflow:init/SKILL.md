---
name: workflow:init
description: 初始化新專案，產生 CLAUDE.md 與設定檔。
---

# workflow:init

初始化專案 AI 工作流。產生專案 `CLAUDE.md` 與設定檔。

前置條件：`install.sh` 已執行（skill symlink 已建立）。

## 執行

**Step 1 — 確認**
檢查專案根目錄是否已有 `CLAUDE.md`：
- 已存在 → 告知，詢問是否覆寫，等指示
- 不存在 → 繼續

**Step 2 — 收集資訊（一次問完）**
1. 專案名稱與一句話描述
2. 環境清單及各自連線方式（dev / uat / prod 或自訂）
3. Ground Truth 規格文件位置
4. Sprint 文件位置（預設 `docs/sprints/`）
5. 啟動命令
6. 架構摘要（技術棧、關鍵路徑）

**Step 3 — 產生檔案**

`CLAUDE.md`（專案根目錄）：套用 `templates/CLAUDE.md`，填入收集的資訊。

`.claude/CLAUDE.md`（不存在則建立，已存在則在最上面插入）：
讀取 `.claude/workflow-framework-path` 取得框架路徑，在第一行插入：
```
@{框架路徑}/.claude/CLAUDE.md
```
不覆蓋原有內容。

`.claude/settings.json`（不存在則建立）：
```json
{
  "$comment": "入版控。規範此專案的 Claude Code 行為。"
}
```

建立目錄（不存在則建立）：
- `{Sprint 文件位置}/`（e.g. `docs/sprints/`）
- `tmp/issues/`

`.gitignore` 補充（附加，不覆寫）：
```
.claude/settings.local.json
.claude/skills/workflow:*
.claude/workflow-framework-path
tmp/
```

**Step 4 — 回報**
列出產生與修改的檔案，標出仍需人工填寫的 `{佔位符}`。
