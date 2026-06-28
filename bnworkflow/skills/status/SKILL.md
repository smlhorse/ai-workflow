---
name: bnworkflow:status
description: 讀現有 WBS/Issue/Sprint 彙整專案進度與時程（雙軌進度% + 逾期/即將到期 + stale 旗）。只讀不寫，不預測工期。PM 主責。
---

# bnworkflow:status

## 核心心法

**只讀不寫** — 純彙整現有資料給 PM 看進度與時程，不寫任何檔案、不改 Issue、不記工時。

**不預測工期** — 只用現有數字（估時點、建立日、due）算趨勢與剩餘，不臆測「還要幾天」。落後與否由現有數字推導，不腦補進度。

**WBS 生命週期原則**（起手套用）：
- 無 WBS/Issue → 不硬產空殼。先查 `tmp/anchor.md` 有無指示；缺資訊 → 明列「缺 X」回報 user，不腦補。
- 已有資料 → 純讀彙整，呈現當下狀態。

## 用法

view-driven，看當下要看什麼：

```
/bnworkflow:status              ← 全局進度 + 時程
/bnworkflow:status {sprint}     ← 單一 Sprint
/bnworkflow:status overdue      ← 只看逾期
```

## 讀取來源

- **WBS 樹**：`docs/wbs/{sprint}.md`（make-plan 於 L+ 規模產出）
- **Issue**：GitHub Issues（有 remote）或 `docs/issues/`（本機模式）
- **Sprint**：GitHub Milestone（due_on）或 `docs/sprints/`（起訖日）

## 輸出視角

**進度（雙軌 %）** — scale 加權點數（XS=1 / S=2 / M=3 / L=5），done 點 / 總點：
- 「已拆解進度」：只算已拆成 task/Issue 的節點
- 「含未規劃」：未規劃／想像 bucket 用粗估點進分母，標不確定
- 標註「**未拆解 L+ 不在分母，% 可能虛高**」與「未估項標『未估』，不進有效分母」

**時程**：
- Sprint 剩餘天數（以**今天**算）
- **逾期清單**（due < 今天且未完成）
- **即將到期**（3 天內）
- **stale 旗**：Issue open 超過「估時×2」對應天數，或 N 天無更新 → `⚠ 疑似 stale，請確認狀態`

**落後警示**：剩餘估時點 vs 剩餘天數 → 紅 / 黃 / 綠

計時一律**日曆天**（建立日 → 完成日），**明確標註「非實際工時」**。

## 不做的事

- 不寫任何資料（純讀，不碰 Issue／WBS／檔案）
- 不預測工期
- 不腦補未估項 → 標「未估」列待確認
- 不做 effort log（不記工時）

## 自主決策邊界

**自己決定**：view 呈現方式、紅黃綠門檻、stale 判定的 N 天值（就現有資料合理取值並標註）。

**停下來問**：無 WBS 且 anchor 無指示時（缺 X，回報，不產空殼）。
