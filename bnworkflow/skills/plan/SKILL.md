---
name: bnworkflow:plan
description: 把 user 原話存為 Anchor，拆計畫，等 ack 後才能繼續。
---

# bnworkflow:plan

## 核心心法

**No-Drift** — 看到模糊地帶 → 列待確認，不擅自詮釋。任何想做但 anchor 沒說的事，列在 Won't do。後段執行若想改前段決策 → 停下告知，不靜悄悄調整。

**Plan-First Lock** — 輸出 Plan 後強制等待 user ack，不得自動推進。

## 不做的事

- 不在 Plan 加 anchor 沒說的功能
- 不猜 Open question 的答案（先問自己：grep／讀檔／規格文件能回答嗎？能就自己決定並說明理由，不問 user）
- 不漫無目的探索 codebase
- 不讀工作目錄以外的 repo
- anchor 太模糊無法寫 Plan → 直接問，不瞎寫
- 不分批發問，完整思考後一次列完所有待確認
- Plan 後段步驟不得用「實作 X」帶過，每步都要有具體驗收方式
- 寫或修改規格文件時，只描述業務意圖與約束，涵蓋成功與失敗情境；不只寫 happy path
- 有疑問前先查對話上下文與規格文件；同一對話中 user 已回答的問題不重問
- 若 `business.md` 存在（預設 `docs/specs/<feature>/business.md`，路徑以專案 CLAUDE.md 為準），plan 涉及 UI 元件的步驟必須引用 business 中的元件 ID；非 UI 步驟不強制引用
- 執行中若發現需修改 spec（如元件邊界調整、欄位變動）→ 停下回報，不靜悄悄改 plan 繞過 spec

## 規模判斷

| 規模 | 條件 | 路徑 |
|---|---|---|
| XS | 單一文件、範圍明確、不涉及介面變更 | 直接執行，不走本 skill |
| S | 單模組、介面已凍結 | Plan → ack → 執行 |
| M | 跨 2 模組或需新定義介面 | Plan → ack → 執行 |
| L+ | 跨 3+ 模組或 DB schema 變更 | 停止，要求人工分解，不寫 Plan |

## 工作流

讀現況（相關規格、現有設計）→ 判規模 → 產出 Plan → 呼叫 `bnworkflow:review` 多角色審查 → **等 ack**

Plan 包含：
- **規模**：XS / S / M / L+
- **步驟**：標並行分組（parallel group）；每步附具體驗收方式
- **Won't do**：刻意排除的事才列，無則省略
- **待確認**：模糊地帶，查不到答案的才列
