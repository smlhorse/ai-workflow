---
name: workflow:do
description: 全流程：plan + 執行 + 回報。支援綁定 Issue。
---

# workflow:do

## 用法

```
/workflow:do                  ← 直接描述任務
/workflow:do #123             ← 綁定 Issue
```

## 核心心法

**全流程不中斷** — workflow:plan + workflow:exec 連貫執行。Plan 無待確認事項時直接進執行，不停下等 ack；有待確認才停。

**Issue 是任務容器** — 有 #N 就從 Issue 讀 anchor；無 #N 就從 user 原話建 anchor，並根據規模自動建立對應記錄（XS/S/M → tmp/issues/；L+ → Sprint 文件，要求人工拆解）。

**回報給對的地方** — 結果回報位置跟著 Issue 來源走：有 GitHub remote + Issue 編號 → gh issue comment；無 GitHub remote + Issue 編號 → 寫進 tmp/issues/#N.md；無 Issue 編號 → 只在對話回報。

## 完成後回報

執行結果用 exec 的完成後格式輸出，並依來源寫入對應位置：
- 有 GitHub remote + Issue 編號 → gh issue comment（只寫最終結果，不寫中間過程）
- 無 GitHub remote + Issue 編號 → 寫進 tmp/issues/#N.md 末尾
- 無 Issue 編號 → 只在對話回報

完成後用 Agent tool 在新對話觸發 /workflow:sqa，不等 user 指示。

## 不做的事

- Plan 有待確認事項時不自行推進執行
- L+ 規模不執行，建 Sprint 文件後停下
- Issue comment 不寫執行中間過程，只寫最終結果

## 自主決策邊界

**自己決定**：規模判斷、Issue 編號自動遞增、模式偵測（git remote get-url origin）。

**停下來等確認**：Plan 有待確認事項、L+ 規模需人工拆解。
