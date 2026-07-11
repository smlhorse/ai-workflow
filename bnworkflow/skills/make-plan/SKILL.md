---
name: bnworkflow:make-plan
description: 執行規劃。產出計畫＝怎麼一步步做（步驟＋每步驗收）。不是怎麼設計(設計)。
---

# bnworkflow:make-plan

## 核心心法

**No-Drift** — 看到模糊地帶 → 列待確認，不擅自詮釋。任何想做但 anchor 沒說的事，列在 Won't do。後段執行若想改前段決策 → 停下告知，不靜悄悄調整。

**Plan-First Lock** — 輸出 Plan 後強制等待 user ack，不得自動推進。

## 不做的事

- 不在 Plan 加 anchor 沒說的功能
- 不猜 Open question 的答案（先問自己：grep／讀檔／規格文件能回答嗎？能就自己決定並說明理由，不問 user）
- 不漫無目的探索 codebase
- 不異動工作目錄以外的 repo
- anchor 太模糊無法寫 Plan → 直接問，不瞎寫
- 不分批發問，完整思考後一次列完所有待確認
- Plan 後段步驟不得用「實作 X」帶過，每步都要有具體驗收方式
- 寫或修改規格文件時，只描述業務意圖與約束，涵蓋成功與失敗情境；不只寫 happy path
- 有疑問前先查對話上下文與規格文件；同一對話中 user 已回答的問題不重問
- 若 `business.md` 存在（預設 `docs/specs/<feature>/business.md`，路徑以專案 CLAUDE.md 為準），plan 涉及 UI 元件的步驟必須引用 business 中的元件 ID；非 UI 步驟不強制引用
- 執行中若發現需修改 spec（如元件邊界調整、欄位變動）→ 停下回報，不靜悄悄改 plan 繞過 spec
- 有 WBS（`docs/wbs/`）時執行或修改必同步更新對應節點狀態；不更新不算完成
- 無 WBS/Issue 時不腦補 — 先查 anchor 有無拆解指示，缺資訊回報，不硬產空殼樹

## WBS 樹（僅 L+ 規模產出）

L+ 規模時，make-plan 的產物之一是 WBS 樹 `docs/wbs/{sprint}.md`（S/M 不需要，Issue 清單已足）：

- 層級 milestone → epic → story → 葉節點；非葉子是分組節點
- **葉節點＝一個可獨立驗收的產出單位**，兩種型態：
  - **task**：實作任務，標 Issue 編號
  - **產出物 checkpoint**：文件/設計類交付，標對應 skill（需求文件／規格文件／SDD／SDD facet／測試計畫）與產出路徑
- 須含兩種 bucket：**未規劃**（知道要做、還沒拆，粗估點或標未估）、**想像中**（還不確定要不要做，標不估、查 anchor）
- 每節點標狀態：`未執行 / 執行中 / 待審 / 待驗 / 已產出 / 已執行 / 未規劃 / 想像中`（待審＝等 review 判定；待驗＝等 verify 執行；已產出＝文件類無後續把關關卡，產出即完成）
- 估時：scale 帶（XS=1 / S=2 / M=3 / L=5 點），**不強制**；查 anchor 有無指示，沒指示 → 標「未估」列待確認

## 規模判斷

| 規模 | 條件 | 路徑 |
|---|---|---|
| XS | 單一文件、範圍明確、不涉及介面變更 | 直接執行，不走本 skill |
| S | 單模組、介面已凍結 | Plan → ack → 執行 |
| M | 跨 2 模組或需新定義介面 | Plan → ack → 執行 |
| L+ | 跨 3+ 模組或 DB schema 變更 | 停止，要求人工分解，不寫 Plan |

## 工作流

讀現況（相關規格、現有設計）→ 判規模 → 產出 Plan → 呼叫 `bnworkflow:review` 多角色審查 → **等 ack**

Plan 不另寫獨立 plan 暫存檔，依規模分流：
- **小任務（S/M）**：計畫＝任務 Issue 內的幾行步驟。GitHub 模式寫進 Issue body；本機模式寫進專案設定的 Issue 位置（預設 `docs/issues/`）`#N.md`。
- **L+**：計畫＝WBS（`docs/wbs/`，版控），見下節。Issue 只引用 WBS 節點，不裝計畫本體。

Plan 包含：
- **規模**：XS / S / M / L+
- **步驟**：標並行分組（parallel group，需註明可由哪些角色/agent 平行執行，如前端/後端/整合；有依賴的步驟標明等哪個分組完成才能開始）；每步附具體驗收方式
- **Won't do**：刻意排除的事才列，無則省略
- **待確認**：模糊地帶，查不到答案的才列
