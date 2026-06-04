---
name: bnworkflow:review
description: 規格 review 總控。依序呼叫 5 個角色子 skill，前一關 FAIL 則停止後續。
---

# bnworkflow:review

## 核心心法

**多角色把關** — 規格必須通過所有角色 review 才可進入實作。任一 FAIL 停下，回到 plan 修正後重跑。

**前段優先** — 業務流程 FAIL 時不應再跑後段技術 review，避免浪費資源。

## 不做的事

- 不自行解釋 FAIL 原因（由各角色 skill 回報）
- 不放水：任一子 skill FAIL 即整體 FAIL
- 子 skill 全 PASS 之前不得宣告 review 通過

## 自主決策邊界

**自己決定**：依序呼叫順序（business → system → program → sa → uiux）、FAIL 時停下後續。

**停下來等確認**：所有子 skill PASS 後，將彙總結果交給 user，不自行推進到實作階段。

## 執行

用 `Agent` tool 依序啟動 5 個子 skill，每個帶入 plan 內容與規格文件，前一關 FAIL 則停止：

1. `bnworkflow:review-business`
2. `bnworkflow:review-system`
3. `bnworkflow:review-program`
4. `bnworkflow:review-sa`
5. `bnworkflow:review-uiux`

各子 skill 可單獨執行：`/bnworkflow:review-business`、`/bnworkflow:review-system`、`/bnworkflow:review-program`、`/bnworkflow:review-sa`、`/bnworkflow:review-uiux`

## 最終輸出

```
## Review：PASS / FAIL

- Business：PASS / FAIL
- System：PASS / FAIL
- Program：PASS / FAIL
- SA：PASS / FAIL
- UI/UX：PASS / FAIL

FAIL 清單：
- {角色} {項目} {具體問題}
```
