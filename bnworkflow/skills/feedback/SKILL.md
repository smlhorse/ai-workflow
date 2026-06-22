---
name: bnworkflow:feedback
description: 提交 bnworkflow 框架本身的改善回饋（不是專案 bug）。在 skill 卡關、走錯路、有改善構想時呼叫。輸出至 tmp/bnworkflow-feedback/，回到 framework repo 時批量消化。
---

# bnworkflow:feedback

**目的**：累積框架使用回饋，回到 framework repo 時批量消化、修 skill、commit + push。

**不是**：自己專案的 bug report。本 skill 只收 bnworkflow 框架自身的問題與改善建議。

## 觸發時機

- skill 執行中卡關 / 結果不對 / 缺少某情境處理
- roles.md 衝突處理有漏洞或邊界不清
- 想到更好的設計（流程順序、輸出格式、防護規則、新 skill）
- 框架文件（README / CLAUDE.md）描述與實際行為不符
- 任何讓 user 想吐槽框架的瞬間

## 收集欄位（缺一不可）

1. **目標物**：哪個 skill 名 / `roles.md` / 框架 `CLAUDE.md` / `plugin.json` / `marketplace.json`
2. **觸發情境**：當時的任務、輸入、上下文
3. **預期 vs 實際**：以為會怎樣 vs 實際發生
4. **建議改法**：user 的想法；不知道可寫「需討論」
5. **嚴重度**：blocker（擋住工作）/ friction（能繞但難用）/ suggestion（改善建議）

## 輸出位置與格式

寫入 `tmp/bnworkflow-feedback/{YYYYMMDD-HHmm}-{slug}.md`（自動建立目錄）。

`tmp/` 通常已在專案 `.gitignore`，不會誤入 user 專案版控。

```markdown
---
date: YYYY-MM-DD HH:mm
project: {專案目錄名}
target: {skill 名 / roles.md / CLAUDE.md / plugin.json / marketplace.json}
severity: blocker / friction / suggestion
---

## 觸發情境

{當時要做什麼、用什麼輸入}

## 預期

{以為會怎樣}

## 實際

{實際發生}

## 建議改法

{user 想法，或「需討論」}
```

## 回饋消化路徑

User 累積一批後，回到 framework repo（`20260506_workflow`），開新 Claude Code 對話，告知檔案 path 清單（或直接貼內容）。Framework Claude 消化、修 skill、commit + push（需切 smlhorse 帳號）。

## 自主決策邊界

**自己決定**：從對話脈絡推斷欄位 1-4 草案；填好後給 user 確認再寫檔。

**停下來等確認**：嚴重度（user 才知道對工作影響多大）、建議改法（若 user 沒明說不得腦補）。

## 不做的事

- 不在框架 repo 外寫入框架本身的檔案（path restriction）
- 不擅自決定改框架，只記錄；等回 framework repo 處理
- 不混入「我這專案的 bug」（與框架無關的 issue 不收）
- 不為 user 想完整解法；寫 user 真實的想法或「需討論」

## 輸出

```
## bnworkflow:feedback：已記錄

檔案：tmp/bnworkflow-feedback/{filename}.md
目標物：{target}
嚴重度：{severity}

下一步：累積一批後回到 framework repo（20260506_workflow）批量消化。
```
