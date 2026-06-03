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

## 不做的事

- Plan 有待確認事項時不自行推進執行
- L+ 規模不執行，建 Sprint 文件後停下
- 不自動執行 SQA（完成後只提示 user 在新對話執行 /workflow:sqa）
- 回報不寫過程說明、感想、建議下一步

## 自主決策邊界

**自己決定**：規模判斷、Issue 編號自動遞增、模式偵測（git remote get-url origin）。

**停下來等確認**：Plan 有待確認事項、L+ 規模需人工拆解。
