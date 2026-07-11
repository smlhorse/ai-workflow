---
name: bnworkflow:make-spec
description: 規格產出（lite＋business）。產出規格＝系統長什麼樣（畫面/行為/規則）。不是要解決什麼(需求)、不是怎麼建(設計)。
---

# bnworkflow:make-spec

## 核心心法

**規格是描述不是步驟** — spec 回答「系統長什麼樣」。實作步驟是 plan，技術細節是 SDD。

**兩層**：
- **lite**：業務語言、整個 feature 都涵蓋、不深入元件層
- **business**：結構化、含元件 ID，作為 spec ↔ SDD ↔ code 的 binding key

**指向 SDD 不複製** — business 提到 API call / DB 變更時只填 path / 表名，schema / 權限 / 錯誤碼寫在 SDD。

## 觸發判斷

- 任務會改變使用者可見的輸出或互動 → 走 spec
- 純後端 / 純資料處理 / 純內部重構 → 不走 spec
- 判斷不出來 → 停下問

跳級：anchor 標示「規格已 align」或 business 已存在 → 跳 lite。

## 兩層內容（涵蓋面向，不規定段數欄數）

**lite 至少涵蓋**：畫面長相、操作劇本、業務規則、影響範圍（業務語言）、待確認

**business 至少涵蓋（建議用 A-E 5 表）**，每元件能回答：
- **A. VISUAL**：在哪、視覺類型、預設狀態
- **B. DATA**：來源、撈取時機、條件、顯示欄位
- **C. INTERACTION**：觸發事件、前置條件、回饋
- **D. FLOW**：系統做什麼、API path（指向 SDD）、DB 變更（指向 SDD）、影響範圍、失敗處理
- **E. STATUS**：是否凍結、未決事項

每元件配唯一元件 ID 橫貫 A-E。

## 路徑

**lite 格式 / 位置由 user 決定**（業務同仁用什麼工具看就用什麼）。

business 預設 `docs/specs/<feature>/business.md`；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不寫實作步驟、技術選型、檔案結構
- business D 群不抄 SDD 內容，只填指向字串
- lite 不寫元件 ID / API / DB
- 不只寫 happy path：失敗、空值、權限、網路失敗每項都要對應處理
- 同一元件 ID 在 A-E 描述不一致 → 整份打回
- 有 WBS（`docs/wbs/`）時本關完成必更新對應 WBS 節點狀態（make-spec 完＝待審，等 review 判定）；不更新＝不算完成
- 無 WBS/Issue 時不腦補，先查 anchor，缺資訊回報

## 角色分工（建議）

| 階段 | 主寫者 | review |
|---|---|---|
| lite | 貼近 user 的角色（PM / UI/UX / 業務 owner） | 業務同仁、PM |
| business | 貼近需求結構的角色（SA / UI/UX） | 三大架構師、SA |

小團隊一人兼多角；AI 代寫時 AI 主寫、user review。E.STATUS 更新機制（git log / 手動 / CI hook）擇一。

## 自主決策邊界

**自己決定**：元件 ID 命名、欄位寫法、面向如何分段、是否拆子表。

**停下來問**：觸發判斷模糊、業務目標不明確、未決項已影響規格收斂。

## 工作流

確認分支 → lite 或 business（依跳級規則）→ 涵蓋面向 → 自檢 → 呼叫 `bnworkflow:review` → 等 ack → 交棒 `bnworkflow:make-design`（M/L+ 或跨模組）或 `bnworkflow:make-plan`

**完成自檢（強制，缺一不打回）**：
1. 失敗情境完整（失敗、空值、權限、網路失敗各有對應處理）
2. 元件 ID 在 A-E 描述一致
3. **文字來源核對** — 列出本次所有欄位名 + 提醒/錯誤/提示文字，逐一標出規格來源位置；無來源者列待確認，不自填、不自創
