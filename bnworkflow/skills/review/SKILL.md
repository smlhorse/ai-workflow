---
name: bnworkflow:review
description: 審查總控。按對象（spec / design / plan / 程式）派對應審查角色，前一關 FAIL 停止後續。
---

# bnworkflow:review

## 核心心法

**多角色把關** — 產物必須通過對應角色 review 才可進入下一階段。任一 FAIL 停下修正後重跑。

**按對象派工** — review 不只審規格；spec / design SDD / plan / 程式碼 各召集不同審查角色。

**前段優先** — 業務/架構層 FAIL 時不跑後段細節 review。

**高風險二次質疑** — 子 skill 判 PASS 且屬高風險項（資安、資料、不可逆操作）時，追加一次「這個 PASS 有沒有可能誤判」的自我質疑，不照單全收。

## 審查對象 → 角色

| 對象 | 派哪些審查角色 |
|---|---|
| spec（lite / business） | review-business / -system / -program / -sa / -uiux |
| design（SDD，含架構圖/DFD；SDD 內含威脅模型/資料治理/對外 API/維運 facet 一併審） | review-system / -program / -infra |
| plan | review-program / -sa（技術可行性、步驟完整性） |
| 程式（diff，做後） | review-code / -security / -infra（涉部署配置/session/容量的改動才派 -infra） |

## 不做的事

- 不自行解釋 FAIL 原因（由各子 skill 回報）
- 不放水：任一子 skill FAIL 即整體 FAIL
- 多份內容矛盾 → 以較新 mtime 為基準陳述衝突，要求 user 確認；未回應不推進
- 對象沒有的面向 → N/A，不硬套

## 自主決策邊界

**自己決定**：依對象決定派哪些角色、呼叫順序、FAIL 停下後續、依檔案存在性決定對象。

**停下來問**：對應角色全 PASS 後彙總交 user；多份衝突時。

## 執行

用 `Agent` tool 依「審查對象 → 角色」表啟動對應子 skill，帶入審查對象，前一關 FAIL 停止。各子 skill 可單獨執行。

審查角色（8）：
- `review-business` 業務流程架構師
- `review-system` 系統架構師
- `review-program` 程式架構師
- `review-sa` 資深 SA
- `review-uiux` UI/UX
- `review-code` SD（程式碼對規格）
- `review-security` 資安官（靜態資安）
- `review-infra` SRE（基礎設施/部署架構）

## 最終輸出

```
## Review：PASS / FAIL
審查對象：spec / design / plan / 程式

- {角色}（{對象}）：PASS / FAIL / N/A
  …（只列本次對象召集的角色）

FAIL 清單：
- {角色} {對象} {面向} {具體問題}

衝突清單（如有）：
- {項目} {較新檔} 較新 → 待 user 決定
```
