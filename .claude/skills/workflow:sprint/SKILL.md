---
name: workflow:sprint
description: Sprint 與 Issue 清單管理。支援 GitHub Milestone 與本機模式。
---

# workflow:sprint

## 用法

```
/workflow:sprint              ← 列出所有 Sprint 與待辦
/workflow:sprint {N}          ← 列出 Sprint N 的 Issues
/workflow:sprint new          ← 建立新 Sprint
/workflow:sprint close {N}    ← 關閉 Sprint N
```

## 模式偵測

執行前先偵測：`git remote get-url origin`

- **有 GitHub remote** → GitHub 模式（Milestone + Issues）
- **無 GitHub remote** → 本機模式（`docs/sprints/` + `tmp/issues/`）

Sprint 文件位置從專案 `CLAUDE.md` 讀取 `Sprint 文件位置：` 欄位，預設 `docs/sprints/`。

---

## `/workflow:sprint`（列出所有）

**GitHub 模式**：
1. `gh milestone list --state open` — 列出進行中 Sprint
2. 每個 Milestone 下 `gh issue list --milestone {title} --state open` — 統計待辦數
3. 輸出格式：

```
Sprint {N}  {Milestone title}  [{open}/{total} Issues]  截止：{due_date}
  #123  {Issue title}  [{Labels}]
  #124  {Issue title}  [{Labels}]
```

**本機模式**：
1. 讀取 `{Sprint文件位置}/` 下所有 `sprint-*.md`
2. 讀取 `tmp/issues/` 下所有未關閉 Issue（無 `## 狀態：closed`）
3. 輸出格式與 GitHub 模式相同，Sprint 編號從檔名取得

---

## `/workflow:sprint {N}`（列出指定 Sprint）

**GitHub 模式**：
1. `gh milestone list` 找對應 Sprint N 的 Milestone
2. `gh issue list --milestone {title} --state all` — 列出全部 Issues
3. 輸出含狀態（open / closed）、Labels、Assignee

**本機模式**：
1. 讀取 `{Sprint文件位置}/sprint-{N}.md`
2. 列出檔案內所有 Issue 連結或任務項目

---

## `/workflow:sprint new`（建立新 Sprint）

**GitHub 模式**：
1. `gh milestone list` 找最大編號，新 Sprint = max + 1
2. 詢問：Sprint 目標（一句話）、截止日期
3. `gh api repos/{owner}/{repo}/milestones` 建立 Milestone
4. 回報 Sprint 編號與 URL

**本機模式**：
1. 讀取 `{Sprint文件位置}/` 找最大 `sprint-{N}.md` 編號
2. 詢問：Sprint 目標（一句話）、截止日期
3. 從 `.claude/skills/workflow:sprint/templates/sprint.md` 建立 `sprint-{N+1}.md`
4. 填入目標與截止日期

---

## `/workflow:sprint close {N}`（關閉 Sprint）

**GitHub 模式**：
1. 確認 Sprint N 下是否有 open Issues
2. 有 open Issues → 列出，詢問處理方式（移至下個 Sprint / 保留 / 關閉）
3. `gh api` 更新 Milestone state 為 `closed`

**本機模式**：
1. 讀取 `sprint-{N}.md`，確認未完成項目
2. 有未完成 → 列出，詢問處理方式
3. 在 `sprint-{N}.md` 末尾加入 `## 狀態：closed  關閉日：{date}`

---

## Issue 規模標準（Label）

| Label | 說明 |
|---|---|
| `scale:XS` | 單一文件，< 30 min |
| `scale:S` | 單模組，< 2 hr |
| `scale:M` | 跨模組，< 1 day |
| `scale:L` | 跨 Sprint，需拆解 |

workflow:do 建立 Issue 時自動加上對應 Label。
