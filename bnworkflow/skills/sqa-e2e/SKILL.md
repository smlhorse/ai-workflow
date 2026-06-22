---
name: bnworkflow:sqa-e2e
description: E2E 驗測（UI/UX + SRE 視角）。實地操作，不得只靠源碼推斷。只輸出 PASS/FAIL，FAIL 附 DEF ID 與觀察描述。
---

# bnworkflow:sqa-e2e

**角色視角**：UI/UX（操作流程順暢、介面回饋）+ SRE（環境一致性、可觀測性）。

## 執行規則

- 每個 TC 必須實地執行（Playwright 或 API 呼叫），禁止以「看源碼應該會過」標 PASS
- 驗證範圍：E2E 功能流程 + DB 實地查詢（若適用）
- 只在 DEV 環境執行，不得對 UAT／PROD 操作
- 統計數字必須與明細一致

## 測試計畫來源

依序查找，找到即用：
1. `tmp/sqa-plan.md`
2. CLAUDE.md 指定的測試計畫位置
3. 找不到 → 根據 `tmp/anchor.md` 範圍自建最小測試集（happy path + 主要例外情境）

## 輸出

```
## E2E：PASS / FAIL

統計：Pass X / Fail X / Skip X / 總計 X

FAIL 明細：
- DEF-001 {TC 描述}
  觀察：{實際結果}
  預期：{應有結果}

Skip 明細：
- {TC 描述}：{原因}
```
