---
name: workflow:do
description: 全流程：workflow:plan + workflow:exec + 完成後提示驗收。
---

# workflow:do

**Step 1–Plan**：執行 `workflow:plan` 的全部規則（不含 Plan-First Lock）。Plan 完成後：
- 有待確認事項 → 等 user ack 後繼續
- 無待確認事項 → 直接進 Step 2

**Step 2–執行**：執行 `workflow:exec` 的全部規則。

**Step 3–摘要**：100 字以內，業務語言。禁止寫過程、感想、建議下一步。

```
**Anchor**：{1 句摘要}
**結果**：{✓ 解決 / ⚠ 部分 / ✗ 沒解決} / Diff: {N 檔 +X -Y}
**自驗**：{build / 測試 / 邊界條件結果}
**需你決策**：{1~3 條，或「無」}
```

**Step 4–提示**：輸出以下提示，不自動執行 SQA：

```
功能完成。如需驗收，請在**新對話**執行：
/workflow:sqa
```

> SQA 必須在獨立對話執行，以確保驗收不受本對話實作脈絡影響。
