---
name: bnworkflow:verify
description: 全套品質驗收。必須在新對話執行，不得與 Developer 同一對話。只輸出 PASS/FAIL，不給修復建議。
---

# bnworkflow:verify

**必須在新對話執行。不得接著 Developer 繼續。**

## 三不原則

1. **不解釋**：只說符合／不符合，不解釋為什麼
2. **不修改**：發現問題回報，不自行修復
3. **不放水**：「差一點」也是 FAIL；不用「應該 OK」蓋章

## 讀取

1. `tmp/anchor.md` + 本次 diff
2. CLAUDE.md 指定的 Ground Truth 規格文件
3. `SPEC_CONTRACT.md`（若存在）
4. make-testplan 產出的測試計畫（主路徑；位置見「QA 文件結構」。找不到才 fallback 臨時推導）

## QA 文件結構

預設（專案 CLAUDE.md 可覆寫路徑、檔名、時間戳格式、入版策略）：

```
docs/qa/
  {sprint}_測試計畫_v{N}.md          ← make-testplan 產出（版本化；spec 變更 → v+1）
  reports/
    {sprint}_測試紀錄_v{N}_{時戳}.md  ← verify 產出；v{N} 對應所驗的計畫版本，時戳為執行時間
    assets/
```

測試紀錄的 `v{N}` 必須對應所驗的測試計畫版本，`{時戳}` 為執行時間（精確到分鐘以上）；同版計畫重跑保留多份紀錄。

啟動時（主路徑）：讀 make-testplan 產出的現成 `{sprint}_測試計畫_v{N}.md` 執行。
Fallback（找不到計畫才走）：從規格（lite / business / plan）臨時推導 case。
跑完 case → 寫 reports/，FAIL 案附 {case id} {期望} {實際} {附件路徑}。

## 執行

做後驗收＝先審程式、再驗成品。用 `Agent` tool 依序啟動，前一關 FAIL 則停止後續：

1. 呼叫 `bnworkflow:review`（程式對象 → review-code + review-security）　← 程式審查（屬 review，做後跑）
2. `bnworkflow:verify-e2e`（UI/UX + SRE，實地操作）
3. `bnworkflow:verify-deploy`（SRE，部署就緒）
4. `bnworkflow:verify-security-officer`（資安官，推 UAT 前必跑，FAIL 對 UAT 啟動有否決權）
5. `bnworkflow:verify-pm`（PM + PO 業務驗收）

各子 skill 可單獨執行：`/bnworkflow:verify-e2e`、`/bnworkflow:verify-deploy`、`/bnworkflow:verify-security-officer`、`/bnworkflow:verify-pm`；程式審查走 `/bnworkflow:review`。

## 不做的事

- 有 WBS（`docs/wbs/`）時，PASS 必更新對應節點為「已執行」並戳完成日（今天）；不更新＝不算完成
- 無 WBS/Issue 時不腦補，先查 anchor，缺資訊回報

## 自主決策邊界

收到 Issue 編號時（Issue 位置依設定：GitHub 模式走 GitHub Issues；本機模式讀專案 CLAUDE.md「本機 Issue 位置」欄位，預設 `docs/issues/#N.md`）：
- PASS → 戳完成日（今天）、更新對應 WBS 節點為「已執行」；append 結果至 Issue；owner 是 AI 自動關閉，owner 是 user 等 user 關閉
- FAIL → 回報 user，不開也不關 Issue

## 最終輸出

```
## Verify：PASS / FAIL

- 程式審查（review-code + review-security）：PASS / FAIL
- E2E：PASS / FAIL
- Deploy：PASS / FAIL
- Security Officer：PASS / FAIL
- PM：PASS / FAIL

FAIL 清單：
- {項目} {具體位置或描述}
```
