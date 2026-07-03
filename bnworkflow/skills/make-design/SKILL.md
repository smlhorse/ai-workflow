---
name: bnworkflow:make-design
description: 架構設計。產出 SDD＝系統怎麼建（模組/API/schema/部署）。不是長什麼樣(規格)。
---

# bnworkflow:make-design

## 核心心法

**spec 說「長什麼樣」，design 說「怎麼建」** — SDD 是 spec→實作之間的技術橋：系統怎麼切、模組怎麼分、資料怎麼流、怎麼部署。

**架構師畫、不只審** — 系統/程式架構師、SRE 在此**產出**設計，再由 review 審。修掉「架構師只審不畫」。

**SDD 是 binding key** — spec 指向 SDD，code 依 SDD，三者可追溯。

## 觸發判斷

- M / L+，或跨模組 / 新介面 / DB schema 變更 → 走 design
- XS / S 單模組、無架構決策 → 跳過，直接 plan
- 判斷不出 → 停下問

## SDD 至少涵蓋（按需，不全要）

- **系統架構**（系統架構師）：服務切分、整合方式、資料一致性、容錯、容量/SLA
- **軟體架構**（程式架構師）：模組邊界與分層、設計模式、技術選型、介面契約、錯誤處理
- **基礎設施架構**（SRE）：部署拓樸、IaC、環境、監控
- **API 合約 / DB schema**：欄位、型別、權限、錯誤碼（spec 指向這裡）
- **圖（強制，不得只有文字）**：架構總覽圖（system context）＋系統架構圖＋關鍵流程圖＋資料流 DFD（建議 Mermaid，內嵌 SDD）。DFD 與 `make-threat-model` 共用同一張，不重畫

## 路徑

預設 `docs/design/<feature>/SDD.md`；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不寫實作步驟（plan）、不寫 code
- 不重抄 spec 內容，只做技術設計
- 不在無架構決策的小任務硬產 SDD（過度設計）
- 不只設計 happy path：失敗、降級、容量上限都要涵蓋
- 無圖（架構總覽＋DFD 缺席）→ 打回

## 自主決策邊界

**自己決定**：模組切分、技術選型、SDD 結構。

**停下來問**：跨系統整合策略不明、非功能需求（容量/SLA）未定、技術選型有重大成本/鎖定風險（費用前置同意）。

## 角色

系統架構師、程式架構師、SRE 共同產出；交棒 `bnworkflow:make-plan`。
