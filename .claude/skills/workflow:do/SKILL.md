---
name: workflow:do
description: 全流程：plan + 執行 + 回報。支援綁定 Issue。
---

# workflow:do

## 用法

```
/workflow:do                  ← 直接描述任務
/workflow:do #123             ← 綁定 Issue
```

## Anchor 來源

**有 Issue 編號（`#123`）：**
1. 偵測是否有 GitHub remote：
   - 有 → `gh issue view 123` 讀取標題 + 內容
   - 無 → 讀 `tmp/issues/#123.md`
2. Issue 內容存為 anchor（`tmp/anchor.md`）
3. 讀 Label 判規模：有規模 Label 直接用；無則自行判斷，回報 Issue comment 標註「AI 判定規模：{規模}」

**無 Issue 編號：**
1. user 描述的任務存為 anchor
2. 執行 `workflow:plan` 判規模：
   - XS/S/M → 自動在 `tmp/issues/` 建新 Issue 檔（自動編號）
   - L+ → 在 CLAUDE.md 指定的 Sprint 文件位置建新 Sprint 檔，要求人工拆解

## 執行流程

**Step 1–Plan**：執行 `workflow:plan` 的全部規則（不含 Plan-First Lock）。Plan 完成後：
- 有待確認事項 → 等 user ack 後繼續
- 無待確認事項 → 直接進 Step 2

有 Issue 編號且有 GitHub remote → 在 Issue comment 留「開始執行」。

**Step 2–執行**：執行 `workflow:exec` 的全部規則。

**Step 3–摘要與回報**：100 字以內，業務語言。

```
**Anchor**：{1 句摘要}
**結果**：{✓ 解決 / ⚠ 部分 / ✗ 沒解決} / Diff: {N 檔 +X -Y}
**自驗**：{build / 測試 / 邊界條件結果}
**需你決策**：{1~3 條，或「無」}
```

回報位置：
- 有 GitHub remote + Issue 編號 → `gh issue comment` 回報
- 無 GitHub remote + Issue 編號 → 寫進 `tmp/issues/#123.md` 末尾
- 無 Issue 編號 → 只在對話回報

**Step 4–提示**：輸出以下提示，不自動執行 SQA：

```
功能完成。如需驗收，請在**新對話**執行：
/workflow:sqa
```

> SQA 必須在獨立對話執行，以確保驗收不受本對話實作脈絡影響。
