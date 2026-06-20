---
name: bnworkflow:review
description: 規格 review 總控。對 spec.md 或 plan.md 依差異化視角呼叫 5 個子 skill，前一關 FAIL 停止後續。
---

# bnworkflow:review

## 核心心法

**多角色把關** — 規格必須通過所有角色 review 才可進入實作。任一 FAIL 停下，回到 plan / spec 修正後重跑。

**前段優先** — 業務流程 FAIL 時不應再跑後段技術 review，避免浪費資源。

**對象明確** — review 對象為 `tmp/spec.md` 與 `tmp/plan.md`，存在哪份就 review 哪份。兩份同時存在 → 都 review。

## 不做的事

- 不自行解釋 FAIL 原因（由各角色 skill 回報）
- 不放水：任一子 skill FAIL 即整體 FAIL
- 子 skill 全 PASS 之前不得宣告 review 通過
- 子 skill 啟動時不得省略「審查對象」與「視角範圍」兩項輸入

## 對象判定

啟動時依檔案存在性決定呼叫範圍：

| 檔案狀態 | review 對象 | 處理 |
|---|---|---|
| 只有 `tmp/plan.md` | plan | 5 個子 skill 以「plan 視角」呼叫 |
| 只有 `tmp/spec.md` | spec | 5 個子 skill 以「spec 視角」呼叫 |
| 兩份都存在 | spec + plan | 每個子 skill 先審 spec、後審 plan，**FAIL 任一即整體 FAIL** |

## 衝突處理

兩份都存在且內容矛盾時（如 plan 步驟提及的元件 ID 不在 spec、欄位描述不一致）：

1. 比對 `tmp/spec.md` 與 `tmp/plan.md` 的 mtime
2. 以**較新**者為基準陳述衝突
3. 回報 user：「衝突項目 X，spec 較新／plan 較新，是否更新另一份對齊？」
4. user 未回應前不繼續推進

## 差異化視角對照表

各子 skill 依對象不同採不同視角，總控在呼叫時帶入下列範圍：

| 子 skill | review spec 時主審 | review plan 時主審 |
|---|---|---|
| review-business | 開頭業務目標段是否對齊 anchor | 步驟是否服務業務目標、Won't do 是否合理 |
| review-system | B.DATA（資料來源/條件）、D.FLOW（API/DB） | 步驟對系統整合的影響、跨服務一致性 |
| review-program | D.FLOW（API/DB 設計）、模組邊界 | 步驟拆解 SRP、可測試性 |
| review-sa | A-D 所有表的邊界條件覆蓋、E 是否有未確認項 | 每步驟驗收方式是否明確、邊界是否覆蓋 |
| review-uiux | A.VISUAL、C.INTERACTION 完整性與一致性 | 步驟是否覆蓋 UI 操作流程 |

## 自主決策邊界

**自己決定**：依序呼叫順序（business → system → program → sa → uiux）、FAIL 時停下後續、依檔案存在性決定 spec/plan/兩者。

**停下來等確認**：所有子 skill PASS 後將彙總交 user，不自行推進實作；spec 與 plan 衝突時停下確認，不自行擇一。

## 執行

用 `Agent` tool 依序啟動 5 個子 skill，每個帶入「審查對象（spec/plan/兩者）」與「視角範圍」（見上表），前一關 FAIL 則停止：

1. `bnworkflow:review-business`
2. `bnworkflow:review-system`
3. `bnworkflow:review-program`
4. `bnworkflow:review-sa`
5. `bnworkflow:review-uiux`

各子 skill 可單獨執行：`/bnworkflow:review-business`、`/bnworkflow:review-system`、`/bnworkflow:review-program`、`/bnworkflow:review-sa`、`/bnworkflow:review-uiux`

## 最終輸出

```
## Review：PASS / FAIL
審查對象：spec / plan / 兩者

- Business（{對象}）：PASS / FAIL
- System（{對象}）：PASS / FAIL
- Program（{對象}）：PASS / FAIL
- SA（{對象}）：PASS / FAIL
- UI/UX（{對象}）：PASS / FAIL

FAIL 清單：
- {角色} {對象} {表/段} {具體問題}

衝突清單（如有）：
- {項目} spec 較新 / plan 較新 → 待 user 決定更新方向
```
