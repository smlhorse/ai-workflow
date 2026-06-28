---
name: bnworkflow:do
description: 全流程：plan + 執行 + 回報。支援綁定 Issue。
---

# bnworkflow:do

## 用法

```
/bnworkflow:do                  ← 直接描述任務
/bnworkflow:do #123             ← 綁定 Issue
```

## 核心心法

**全流程不中斷** — 管線 make-discovery → make-spec → make-design → make-plan → make-code 連貫執行（依分支判斷略過不需要的關）。Plan 無待確認事項時直接進執行，不停下等 ack；有待確認才停。

**Issue 是任務容器** — 有 #N 就從 Issue 讀 anchor；無 #N 就從 user 原話建 anchor，並根據規模自動建立對應記錄（XS/S/M → tmp/issues/；L+ → 呼叫 bnworkflow:sprint new，將拆解建議記進 Sprint 文件）。

**回報給對的地方** — SQA 結果由 bnworkflow:verify 寫回 Issue（有 GitHub remote → gh issue comment；無 → tmp/issues/#N.md）。

## 管線分支（讀 anchor 後依需要逐關判斷）

每關只在「需要」時跑，否則略過：

- **make-discovery**（需求訪談）：anchor 模糊、user 講不清要什麼 → 先 `bnworkflow:make-discovery` 逼出可執行需求；需求已清楚 → 略過
- **make-spec**（規格）：任務改變使用者可見輸出/互動 → `bnworkflow:make-spec`；純後端/純資料/純內部重構 → 略過
- **make-design**（SDD）：M/L+ 或跨模組/新介面/DB schema 變更 → `bnworkflow:make-design`；XS/S 單模組無架構決策 → 略過
- **make-plan**（計畫）：除 XS 外都跑 `bnworkflow:make-plan`
- **make-code**（實作）：`bnworkflow:make-code`

跳級：anchor 標「規格已 align」或既有 spec/SDD 已存在 → 跳對應關。判斷不出來 → 停下問，不自行定奪。

每產出一個產物（spec / design / plan）即呼叫 `bnworkflow:review` 審該對象，FAIL 停下修正。

## 完成後

執行結果用 make-code 的完成後格式在對話輸出。
有「需你決策」項目 → 等 user 回覆；無 → 用 Agent tool 在新對話觸發 /bnworkflow:verify，帶入 Issue 編號。

## 不做的事

- Plan 有待確認事項時不自行推進執行
- L+ 規模，呼叫 bnworkflow:sprint new 後停下
- Issue comment 不寫執行中間過程，只寫最終結果

## 自主決策邊界

**自己決定**：規模判斷、Issue 編號自動遞增、模式偵測（git remote get-url origin）。

**停下來等確認**：Plan 有待確認事項、L+ 規模需人工拆解。
