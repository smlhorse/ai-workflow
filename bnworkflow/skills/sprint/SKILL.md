---
name: bnworkflow:sprint
description: Sprint 與 Issue 清單管理。支援 GitHub Milestone 與本機模式。
---

# bnworkflow:sprint

## 用法

```
/bnworkflow:sprint              ← 列出所有 Sprint 與待辦
/bnworkflow:sprint {N}          ← 列出 Sprint N 的 Issues
/bnworkflow:sprint new          ← 建立新 Sprint
/bnworkflow:sprint close {N}    ← 關閉 Sprint N
```

## 核心心法

**單一來源** — 有 GitHub remote 用 Milestone + Issues，沒有用 `docs/sprints/` + `docs/issues/`。禁止混用。

**Sprint 文件住在專案** — 位置從專案 `CLAUDE.md` 的 `Sprint 文件位置：` 欄位讀取，預設 `docs/sprints/`。

**規模決定歸屬** — Issue 歸 Sprint（Milestone）。bnworkflow:do 建立 Issue 時加上對應 Label（`scale:XS/S/M/L`）。L+ 不建 Issue，改建 Sprint 文件要求人工拆解。

**起訖日記錄** — `new` 時記 Sprint 起訖日（user 填）；GitHub 模式設 Milestone `due_on`，本機模式寫進 Sprint 文件。列表顯示起訖日（供 status 算剩餘天數／逾期）。

## 不做的事

- 不在目標不清楚的情況下建立 Sprint
- 不自行決定未完成 Issue 的去向（列出後等 user 決定）
- 不混用 GitHub 與本機模式資料
- 建立或關閉 Milestone 前必須告知並等 user ack（影響 GitHub 共享狀態）
- Sprint 文件的原始目標內容未經 user 同意不得修改

## 自主決策邊界

**自己決定**：Sprint 編號（現有最大值 + 1）、模式偵測（git remote get-url origin）。

**停下來等確認**：Sprint 目標不清楚、Sprint 起訖日須 user 提供（不自定）、關閉 Sprint 時有未完成 Issue、CLAUDE.md 沒有 `Sprint 文件位置：` 欄位、建立或關閉 Milestone。
