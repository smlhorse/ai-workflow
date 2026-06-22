---
name: review
description: 規格 review 總控。對 lite / business / plan 呼叫 5 個子 skill，前一關 FAIL 停止後續。
---

# bnworkflow:review

## 核心心法

**多角色把關** — 規格必須通過所有角色 review 才可進入實作。任一 FAIL 停下修正後重跑。

**前段優先** — 業務流程 FAIL 時不跑後段技術 review。

**對象明確** — 對 `lite.md` / `business.md` / `plan.md` 中存在的份做 review；多份並存都要看，先 lite → business → plan。

## 不做的事

- 不自行解釋 FAIL 原因（由各子 skill 回報）
- 不放水：任一子 skill FAIL 即整體 FAIL
- 多份內容矛盾 → 以較新 mtime 為基準陳述衝突，要求 user 確認是否更新另一份；未回應前不推進

## 視角原則

各子 skill 主審自己關注的面向，視對象有什麼自然調整：
- 對象有的面向 → 主審
- 對象沒的面向（如 lite 不寫元件 ID，review-program 無切入點）→ N/A

詳細面向定義在各子 skill 的「spec 視角」段。

## 自主決策邊界

**自己決定**：呼叫順序（business → system → program → sa → uiux）、FAIL 時停下後續、依檔案存在性決定對象。

**停下來問**：所有子 skill PASS 後彙總交 user；多份衝突時。

## 執行

用 `Agent` tool 依序啟動 5 個子 skill，帶入「審查對象」，前一關 FAIL 停止：

1. `bnworkflow:review-business`
2. `bnworkflow:review-system`
3. `bnworkflow:review-program`
4. `bnworkflow:review-sa`
5. `bnworkflow:review-uiux`

各子 skill 可單獨執行。

## 最終輸出

```
## Review：PASS / FAIL
審查對象：lite / business / plan / 多份

- Business（{對象}）：PASS / FAIL
- System（{對象}）：PASS / FAIL
- Program（{對象}）：PASS / FAIL / N/A
- SA（{對象}）：PASS / FAIL
- UI/UX（{對象}）：PASS / FAIL

FAIL 清單：
- {角色} {對象} {面向} {具體問題}

衝突清單（如有）：
- {項目} {較新檔} 較新 → 待 user 決定
```
