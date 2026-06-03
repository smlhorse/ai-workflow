---
name: workflow:sqa
description: 全套品質驗收。必須在新對話執行，不得與 Developer 同一對話。只輸出 PASS/FAIL，不給修復建議。
---

# workflow:sqa

**必須在新對話執行。不得接著 Developer 繼續。**

## 三不原則

1. **不解釋**：只說符合／不符合，不解釋為什麼
2. **不修改**：發現問題回報，不自行修復
3. **不放水**：「差一點」也是 FAIL；不用「應該 OK」蓋章

## 讀取

1. `tmp/anchor.md` + 本次 diff
2. CLAUDE.md 指定的 Ground Truth 規格文件
3. `SPEC_CONTRACT.md`（若存在）

## 執行

用 `Agent` tool 依序啟動四個子 skill，前一關 FAIL 則停止後續：

1. `workflow:sqa-review`
2. `workflow:sqa-security`
3. `workflow:sqa-e2e`
4. `workflow:sqa-deploy`

各子 skill 可單獨執行：`/workflow:sqa-review`、`/workflow:sqa-security`、`/workflow:sqa-e2e`、`/workflow:sqa-deploy`

## 最終輸出

```
## SQA：PASS / FAIL

- Review：PASS / FAIL
- Security：PASS / FAIL
- E2E：PASS / FAIL
- Deploy：PASS / FAIL

FAIL 清單：
- {項目} {具體位置或描述}
```

## Issue 回寫

收到 Issue 編號時：
- PASS → append 結果至 Issue（有 GitHub remote → gh issue comment；無 → tmp/issues/#N.md）；owner 是 AI 自動關閉，owner 是 user 等 user 關閉
- FAIL → 回報 user，不開也不關 Issue
