---
name: bnworkflow:changelog
description: 產出 Release Notes / CHANGELOG。verify 通過、推 UAT/發布時彙整本次變更。
---

# bnworkflow:changelog

## 核心心法

**每次上線改了什麼要有記錄** — 沒有變更記錄，stakeholder 不知道這版動了什麼，回溯排查無據。CHANGELOG 把本次 spec/Issue 對應的變更彙整成人看得懂的發布記錄。

**記結果、不記過程** — 只寫「改了什麼、影響誰」，不寫實作過程、除錯細節。過程留在 Issue/report，發布記錄只留結論。

## 觸發時機

verify 全通過、推 UAT 或正式發布時；把本次 Sprint/Issue 範圍的變更歸整。

## 涵蓋面向

- 版本號（對齊專案/plugin 版本規則）
- 分類：Added / Changed / Fixed / Removed / Security
- 每條：改了什麼、影響對象；破壞性變更明確標示

## 路徑

repo 根 `CHANGELOG.md`（慣例位置）；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不記過程與除錯細節 → 只記變更結論
- 不含 credentials/PII/內部細節
- 破壞性變更不得埋在一般條目 → 明確標 breaking
- 不憑空編變更 → 每條對應實際 spec/Issue/commit，無對應不寫

## 自主決策邊界

**自己決定**：分類歸屬、條目措辭、版本號遞增（依既有規則）。

**停下來問**：版本號規則未定、是否公開某條變更涉及揭露決策。
