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
- **介面互動架構**（UI/UX 協同程式架構師）：長相已在 spec 定案，這裡定義互動流程/畫面狀態如何映射到模組切分，非重畫 spec
- **API 合約 / DB schema**：欄位、型別、權限、錯誤碼（spec 指向這裡）；有 DB schema 變更 → SRE 一併評估容量/查詢負載，業務流程架構師確認是否觸發資料治理 facet（PII/敏感欄位）
- **威脅模型（STRIDE，做前）**（資安官 主、系統架構師 協）：攻擊面/信任邊界、逐點 STRIDE 威脅清單、緩解對策；有外部輸入/權限邊界/敏感資料/對外整合才產。與下方 DFD 共用同一張。預設 `docs/security/threat-model/<feature>.md`
- **資料治理（資料字典/分類/PII 存取/保留政策/SBOM 授權）**（系統架構師＋業務流程架構師）：補 SDD schema 缺的分類/血緣/PII 遮罩/保留法規/開源授權；涉個資/敏感資料/合規才產。預設 `docs/data-governance/<feature>.md`
- **對外 API 文件（OpenAPI/整合指南）**（程式架構師/資深 SA 主）：端點、認證、錯誤碼、範例、限流、版本策略；有對外開放 API 才產。欄位/錯誤碼指向 SDD 合約不重抄。預設 `docs/api/<service>/api.md`
- **維運（runbook/事故處理/DR 備份還原/rollback/容量規劃/環境建置/監控告警設定/壓測規劃）**（SRE）：非原作者也能照做的處置程序；涉上線部署才產，推 UAT/上線前須齊，verify-deploy 驗就緒。預設 `docs/ops/<feature>/runbook.md`
- **圖（強制，不得只有文字）**：架構總覽圖（system context）＋系統架構圖＋關鍵流程圖＋資料流 DFD（建議 Mermaid，內嵌 SDD）。DFD 一張到底，威脅模型 facet 共用不重畫

## 路徑

預設 `docs/SDD/`，檔名 `{編號}_{名稱}[_{子模組}].md`（編號前綴決定排序、同一功能群共用編號前綴；例 `001_訂單.md`、`001_訂單_結帳.md`）；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不寫實作步驟（plan）、不寫 code
- 不重抄 spec 內容，只做技術設計
- 不在無架構決策的小任務硬產 SDD（過度設計）
- 不只設計 happy path：失敗、降級、容量上限都要涵蓋
- 無圖（架構總覽＋DFD 缺席）→ 打回
- 有 WBS（`docs/wbs/`）時本關完成必更新對應 WBS 節點狀態（make-design 完＝待審，等 review 判定；SDD 各 facet 各自標對應節點）；不更新＝不算完成
- 無 WBS/Issue 時不腦補，先查 anchor，缺資訊回報

## 自主決策邊界

**自己決定**：模組切分、技術選型、SDD 結構。

**停下來問**：跨系統整合策略不明、非功能需求（容量/SLA）未定、技術選型有重大成本/鎖定風險（費用前置同意）。

## 角色

系統架構師、程式架構師、SRE、UI/UX 共同產出；交棒 `bnworkflow:make-plan`。
