---
name: bnworkflow:make-ops
description: 維運手冊。產出 runbook/事故處理/DR 備份還原/rollback/容量規劃。（可選，涉及上線部署才走；與 verify 並行）
---

# bnworkflow:make-ops

## 核心心法

**上線後事故不能靠現場臨時應變** — 系統部署後，告警、當機、回滾都需事前寫好的程序。維運手冊把 SRE 腦中的處置流程落成文件，非原作者也能照做。

**產文件、不驗證** — 本 skill 產出維運程序；`verify-deploy` 只檢查部署就緒。兩者分工，不重疊。

**與工程軌並行** — make-code 完成後、與 verify 並行的維運軌；不阻塞驗收，但推 UAT/上線前須齊。

## 涵蓋面向（按需，不全要）

- **runbook**：告警響應程序、常見故障排除
- **incident-playbook**：事故分級、處置流程、升級路徑、事後檢討
- **dr-backup**：災難恢復、備份策略與還原程序（含還原演練）
- **rollback**：回滾程序（與 verify-deploy 檢查的 rollback 就緒對應）
- **capacity**：容量規劃、擴縮策略、SLO

## 觸發判斷

- 涉及上線部署、有正式環境 → 走
- 純文件/純內部工具、無部署 → 略過
- 判斷不出 → 停下問

## 路徑

預設 `docs/ops/<feature>/`（runbook.md / incident-playbook.md / dr-backup.md / rollback.md / capacity.md 按需）；專案 CLAUDE.md 可覆寫。

## 不做的事

- 不改程式、不自行部署（維運手冊是文件，不是執行）
- 不只寫 happy path → 故障、降級、還原失敗、容量上限都要有程序
- 備份策略不附還原演練 → 等於沒備份
- 不與 verify-deploy 重工 → 本 skill 產程序、verify-deploy 驗就緒

## 自主決策邊界

**自己決定**：手冊結構、程序拆分、SLO 建議值草案。

**停下來問**：DR/rollback 牽涉正式環境操作或費用、SLO 目標未定、備份保留政策不明（與 make-data-governance 對齊）。

## 角色

SRE 主寫，資深工程師（SD）協同。review 掛 `review-infra`。完成後匯流進 `bnworkflow:verify`。
