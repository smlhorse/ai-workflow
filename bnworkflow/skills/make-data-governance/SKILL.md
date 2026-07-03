---
name: bnworkflow:make-data-governance
description: 資料治理。產出資料字典/分類/PII 存取/保留政策/SBOM 授權。（可選，涉及個資/敏感資料/合規才走）
---

# bnworkflow:make-data-governance

## 核心心法

**PII 無分類與規範＝合規稽核無據** — SDD 的 DB schema 只講欄位型別，不講「哪些是個資、誰能存取、留多久、第三方元件授權是否合規」。缺這層，稽核無據、留存無政策、授權踩雷。

**治理不是偵測** — 資安官「偵測」PII 外洩；本 skill「治理」——事前定義分類與存取規範。兩者互補。

## 涵蓋面向（按需，不全要）

- **data-dictionary**：完整資料字典（欄位語意、分類、血緣），補 SDD schema 缺的分類/血緣
- **classification**：資料分級（公開/內部/機密/個資）
- **pii-access**：PII 欄位標記、存取方式、遮罩/加密策略
- **retention**：保留政策、刪除/歸檔程序、法規對應
- **sbom-license**：第三方元件物料清單（SBOM）與開源授權合規

## 觸發判斷

- 涉及個資、敏感資料、合規需求 → 走
- 純無敏感資料的內部工具 → 略過
- 判斷不出 → 停下問

## 路徑

預設 `docs/data-governance/`（data-dictionary.md / classification.md / pii-access.md / retention.md / sbom-license.md 按需）；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不重抄 SDD 已有的欄位型別 → 只補分類/血緣/PII/保留/授權
- 不放過任何 PII 欄位未分類 → 逐欄標記
- 保留政策不含刪除/歸檔程序 → 不完整
- SBOM 缺授權欄位（只列版本不列 license）→ 無法判合規
- 不自行下法規結論 → 合規判定不確定時列待確認，回報 user

## 自主決策邊界

**自己決定**：字典結構、分類級距命名、SBOM 生成方式。

**停下來問**：法規適用範圍不明（GDPR/個資法等）、PII 存取政策牽動架構、保留年限與業務/法規未定。

## 角色

業務流程架構師主寫（分類/保留/合規），系統架構師協同（資料流/存取）。review 掛 `review-business` + `review-system` + `review-security`。交棒 `bnworkflow:make-plan`。
