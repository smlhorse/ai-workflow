---
name: bnworkflow:sqa
description: 全套品質驗收。必須在新對話執行，不得與 Developer 同一對話。只輸出 PASS/FAIL，不給修復建議。
---

# bnworkflow:sqa

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

用 `Agent` tool 依序啟動五個子 skill，前一關 FAIL 則停止後續：

1. `bnworkflow:sqa-review`（SD 視角）
2. `bnworkflow:sqa-security`（系統架構師 + SD 視角）
3. `bnworkflow:sqa-e2e`（UI/UX + SRE 視角）
4. `bnworkflow:sqa-deploy`（SRE 視角）
5. `bnworkflow:sqa-pm`（PM 按規格最終驗收）

各子 skill 可單獨執行：`/bnworkflow:sqa-review`、`/bnworkflow:sqa-security`、`/bnworkflow:sqa-e2e`、`/bnworkflow:sqa-deploy`、`/bnworkflow:sqa-pm`

## 自主決策邊界

收到 Issue 編號時：
- PASS → append 結果至 Issue；owner 是 AI 自動關閉，owner 是 user 等 user 關閉
- FAIL → 回報 user，不開也不關 Issue

## 最終輸出

```
## SQA：PASS / FAIL

- Review：PASS / FAIL
- Security：PASS / FAIL
- E2E：PASS / FAIL
- Deploy：PASS / FAIL
- PM：PASS / FAIL

FAIL 清單：
- {項目} {具體位置或描述}
```
