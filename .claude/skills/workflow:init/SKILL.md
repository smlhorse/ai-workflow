---
name: workflow:init
description: 初始化新專案，建立 symlink 並產生 CLAUDE.md 與設定檔。
---

# workflow:init

初始化專案 AI 工作流。建立框架 symlink，產生專案 `CLAUDE.md` 與設定檔。

## 執行

**Step 1 — 確認**
檢查專案根目錄是否已有 `CLAUDE.md`：
- 已存在 → 告知，詢問是否覆寫，等指示
- 不存在 → 繼續

**Step 2 — 收集資訊（一次問完）**
1. 框架 repo 的本機路徑（e.g. `/Users/xxx/projects/ai-workflow`）
2. 專案名稱與一句話描述
3. 環境清單及各自連線方式（dev / uat / prod 或自訂）
4. Ground Truth 規格文件位置
5. 啟動命令
6. 架構摘要（技術棧、關鍵路徑）

**Step 3 — 建立 symlink**

確認框架路徑存在後，在專案建立以下 symlink：

`.claude/rules/workflow.md` → `{框架路徑}/.claude/CLAUDE.md`
```bash
mkdir -p .claude/rules
ln -sf {框架路徑}/.claude/CLAUDE.md .claude/rules/workflow.md
```

`.claude/skills/workflow:*` → 框架每個 skill 目錄：
```bash
mkdir -p .claude/skills
for skill in {框架路徑}/.claude/skills/workflow:*/; do
  ln -sf "$skill" .claude/skills/
done
```

symlink 建立失敗 → 告知原因，停止，不繼續。

**Step 4 — 產生檔案**

`CLAUDE.md`（專案根目錄）：套用 `templates/CLAUDE.md`，填入收集的資訊。

`.claude/settings.json`（不存在則建立）：
```json
{
  "$comment": "入版控。規範此專案的 Claude Code 行為。"
}
```

`.gitignore` 補充（附加，不覆寫）：
```
.claude/settings.local.json
.claude/rules/
.claude/skills/workflow:*
tmp/
```

**Step 5 — 回報**
列出建立的 symlink 與產生的檔案，標出仍需人工填寫的 `{佔位符}`。
