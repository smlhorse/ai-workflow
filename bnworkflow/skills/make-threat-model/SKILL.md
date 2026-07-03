---
name: bnworkflow:make-threat-model
description: 做前威脅建模。設計前以 STRIDE 推演攻擊面，產出威脅清單＋緩解對策。（可選，涉及外部輸入/權限邊界/敏感資料才走）
---

# bnworkflow:make-threat-model

## 核心心法

**洞在設計就埋下，做後才擋要返工** — 資安官的弱掃/SAST/紅軍是做後找已留下的洞；威脅模型是做前在設計階段先堵。前者省後者的返工。

**攻擊者視角推演，不是列規則** — 針對系統的資產與信任邊界，逐點問「誰、從哪、用什麼手法攻」，而非套一份通用檢查表。

**產出是資安官的對照基準** — 同一份威脅清單成為做後 SAST/紅軍演練的攻擊向量來源；緩解對策成為實作的安全需求。

## 涵蓋面向（按需，不全要）

- **資產與信任邊界**：值錢的資料/功能有哪些；資料從「不可信」跨進「可信」的邊界在哪
- **資料流 DFD**：與 make-design 共用
- **逐點 STRIDE**：每個進出點列 Spoofing/Tampering/Repudiation/Info Disclosure/DoS/Elevation
- **每威脅**：風險評估＋緩解對策（緩解/接受/轉移）

## 觸發判斷

- 有外部輸入、權限邊界、敏感資料、對外整合 → 走
- 純內部、無外部攻擊面的小改動 → 略過
- 判斷不出 → 停下問

## 路徑

預設 `docs/security/threat-model/<feature>.md`（與 findings/false-positives 同住 `docs/security`，便於資安官串接）；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不做修補（緩解對策交 SD/PG/SRE 實作）
- 不只列 happy path 的威脅 → 每個信任邊界都要過 STRIDE 六類
- 不重畫 DFD → 與 make-design 共用
- 無證據的風險評級（循環論證）不算威脅
- 不越權下架構決策 → 緩解對策有重大架構/成本影響時，回 make-design 協商

## 自主決策邊界

**自己決定**：STRIDE 列舉、風險評級方法、緩解對策草案。

**停下來問**：緩解對策牽動重大架構或費用（費用前置同意）、資產邊界界定不清、非功能安全需求未定。

## 角色

資安官主寫（攻擊面推演），系統架構師協同（架構邊界）。review 掛 `review-security` + `review-system`。交棒 `bnworkflow:make-design`。
