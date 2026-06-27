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
4. 對應的測試計畫（位置見「QA 文件結構」）

## QA 文件結構

預設（專案 CLAUDE.md 可覆寫路徑、檔名、時間戳格式、入版策略）：

```
docs/qa/
  SQA測試計畫_範本.md
  {sprint}_SQA測試計畫_{YYYYMMDD}.md
  reports/
    {計畫檔名去 .md}_執行紀錄_v{YYYYMMDDHHmm}.md
    assets/
```

執行紀錄檔名須能回溯對應計畫並含執行時間（精確到分鐘以上）；多次執行保留多份。

啟動時：對應計畫不存在 → 從規格（lite / business / plan）推導 case 寫入計畫檔；跑完 case → 寫 reports/，FAIL 案附 {case id} {期望} {實際} {附件路徑}。

## 執行

做後驗收＝先審程式、再驗成品。用 `Agent` tool 依序啟動，前一關 FAIL 則停止後續：

1. 呼叫 `bnworkflow:review`（程式對象 → review-code + review-security）　← 程式審查（屬 review，做後跑）
2. `bnworkflow:verify-e2e`（UI/UX + SRE，實地操作）
3. `bnworkflow:verify-deploy`（SRE，部署就緒）
4. `bnworkflow:verify-security-officer`（資安官，推 UAT 前必跑，FAIL 對 UAT 啟動有否決權）
5. `bnworkflow:verify-pm`（PM + PO 業務驗收）

各子 skill 可單獨執行：`/bnworkflow:verify-e2e`、`/bnworkflow:verify-deploy`、`/bnworkflow:verify-security-officer`、`/bnworkflow:verify-pm`；程式審查走 `/bnworkflow:review`。

## 自主決策邊界

收到 Issue 編號時：
- PASS → append 結果至 Issue；owner 是 AI 自動關閉，owner 是 user 等 user 關閉
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
