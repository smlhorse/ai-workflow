---
name: bnworkflow:sqa-security-officer
description: 資安官視角的 Sprint 末關卡。orchestrator 派 3 個 Agent 分別跑 弱點掃描 + 源碼掃描（SAST）+ 紅軍演練，每類產出獨立日期戳記報告。推 UAT 前強制執行，FAIL 不得進 UAT。比外稽更細，不接受帶過式結論。
---

# bnworkflow:sqa-security-officer

**角色視角**：資安官 — 獨立於開發團隊，對 UAT 啟動有否決權。
**觸發時機**：每次 Sprint 結束、推 UAT **之前**。無論規模（含 XS、S）皆不可省略。
**必須在新對話執行**，不得接著 Developer 或 SQA 同對話。

## 核心心法

**推 UAT 前最後一道獨立資安關卡。** 與開發團隊隔離、對抗心態找洞，零容忍紅線有否決權。

- **對抗心態**：default 假設有洞、主動攻。「沒看到」不等於「沒事」；要「試了哪些向量都不通」才算沒事。
- **工具 + 人工雙軌**：工具抓不到邏輯洞（IDOR、業務邏輯、race condition），必須人工讀 code + 實打。
- **深度不足即 BLOCKED**：做不到要求深度就輸出 BLOCKED，不得用「靜態推測 OK」蒙混。

## 三不原則

1. **不解釋**：只報 PASS / FAIL 與位置，不解釋成因
2. **不修改**：發現問題回報，不自行修復
3. **不放水**：零容忍紅線一個都不能放；SLA 超期無例外；帶過式結論一律 FAIL

## 雙軌定位

本 skill 只負責 **B 軌**。
- **A 軌（平日 / CI，非本 skill）**：PR 增量 SAST + Secrets、每日相依 CVE、每週全量 SAST，發現自動建 issue。
- **B 軌（本 skill）**：推 UAT 前強制重跑，三類全跑。

## 執行架構（Orchestrator + 3 Agent）

主 skill 是 orchestrator，**不在主對話直接掃描**。用 `Agent` tool（type `general-purpose`）並行派 3 個 sub-agent：

| Sub-agent | 範圍 | 輸出檔 |
|---|---|---|
| vuln-scan | 弱點掃描（環境與相依） | `docs/security/reports/{YYYYMMDD-HHmm}-vuln.md` |
| sast | 源碼掃描 | `docs/security/reports/{YYYYMMDD-HHmm}-sast.md` |
| redteam | 紅軍演練（動態攻擊模擬） | `docs/security/reports/{YYYYMMDD-HHmm}-redteam.md` |

每個 Agent 的 prompt 必含：角色定位（資安官、對抗心態）、對應掃描範圍、A/B/C/D 報告段、PoC 規則、深度紅線、報告檔路徑。
3 Agent 完成 → 主 skill 彙整三份報告 → 寫入 `findings.md` 總台帳 → 輸出最終 PASS / FAIL。

## 三類必掃範圍

### 1. 弱點掃描（環境與相依）

- 相依套件 CVE（npm / pip / maven / cargo audit；對照 OSV / NVD）
- Container image 漏洞（Trivy / Grype 掃 base image 與最終 image）
- IaC 配置（Terraform / K8s manifest / Dockerfile：Checkov、tfsec、kube-linter）
- 對外服務：開放端口、TLS 版本與套件、憑證效期、HTTP security headers
- Secrets 外洩（repo / image / log 內是否有 API key、token、密碼）

### 2. 源碼掃描（SAST）

- 注入類：SQLi、NoSQLi、Command Injection、SSRF、XXE、Template Injection
- XSS（反射 / 儲存 / DOM）、CSRF、Open Redirect
- 認證授權邏輯：IDOR、權限繞過、JWT 演算法/簽章/過期、Session 管理
- 敏感資料硬編碼：API key、密碼、token、PII、內部 IP / endpoint
- 加密誤用：MD5/SHA1 用於密碼、ECB 模式、固定 IV、自製加密、隨機數來源
- 反序列化、Path Traversal、檔案上傳
- Log 洩漏：PII、credentials、token 進 log
- 錯誤處理：stack trace、debug 訊息外露

### 3. 紅軍演練（動態攻擊模擬）

範圍：本 Sprint 變更涵蓋的功能 + 零容忍紅線 10 項；定期掃描週期內為全系統。

- 身分認證攻擊：暴力破解、credential stuffing、token 重放、session fixation、MFA 繞過
- 授權繞過實測：水平越權（A↔B）、垂直越權（user→admin）、API 批次端點越權
- 業務邏輯攻擊：race condition、價格 / 數量竄改、優惠券濫用、退款流程、重複提交
- API 攻擊：速率限制繞過、批次端點濫用、GraphQL introspection、過度資料暴露
- 資料列舉：可預測 ID、錯誤訊息差異、debug endpoint
- 檔案處理：惡意檔案上傳、Path Traversal、SSRF via webhook / image fetch
- 客戶端實打：XSS、CSRF、CORS 錯配、clickjacking

## 報告強制段落（每份 4 段，缺一 FAIL）

- **A. 掃描範圍**：具體列實際掃了哪些檔案 / 模組 / 端點 / image / 套件版本；排除項（third-party、external service）須明列並說明為何排除。不接受「全部」「整個系統」。
- **B. 工具與規則**：工具、版本、rule set / policy / 攻擊套件、自訂規則與 payload。
- **C. Findings**（每筆缺一即無效）：類別（屬 10 紅線哪項 / 其他）、位置（檔案:行號 / endpoint / image:layer）、證據、嚴重度與評估理由（非循環論證）、PoC——Critical/High 必須完整 PoC，Medium/Low 至少附證據；**無證據不算 finding**。
- **D.「無發現」舉證**：不得寫「OK / 未發現異常 / 無問題」。須列實際試了哪些攻擊向量、預期 vs 實際、為何排除是 finding。

## BLOCKED（深度不足）

Agent 無法達深度要求 → 報告頂端輸出 `## BLOCKED` + 未達項目（缺什麼，如無 ZAP / 無法打 staging / 缺測試帳號）+ 需 user 提供的支援。
主 skill 收到任一份 BLOCKED → 整體 **BLOCKED**（非 PASS 非 FAIL），回報 user 並停止；補上資源後重跑。

## 零容忍紅線（10 項）

任一項出現 **High 以上 → 直接 FAIL，UAT 不得啟動**，無協商空間：

1. SQLi
2. RCE（Command Injection、不安全反序列化、Template Injection、危險 eval/exec）
3. LFI / Path Traversal
4. IDOR / 權限繞過
5. PII 外洩 / 硬編碼
6. SSRF
7. 不安全反序列化 / XXE
8. 認證繞過 / Session 接管
9. 加密誤用（弱演算法、明文存密碼、固定 IV、自製加密）
10. Secrets 進 repo / image / log

## SLA（修復時限）

採 Sprint + 天數雙軌，以先到者為準。**超 SLA 未修 → Sprint 末關卡 FAIL。**

| 嚴重度 | Sprint 單位 | 天數 |
|---|---|---|
| Critical | 本 Sprint 必清 | 7 天 |
| High | 下個 Sprint 內 | 30 天 |
| Medium | 下下個 Sprint 內 | 90 天 |
| Low | Backlog 排序 | 180 天 |

## PASS 條件（全部成立才 PASS，任一不成立即 FAIL）

- 三份報告皆產出，且 A/B/C/D 四段齊全、每筆 finding 證據齊全（Critical/High 有 PoC）
- 零容忍紅線 10 項：無任一 High+
- 本 Sprint 新引入 Critical / High：無；現存 Critical：清零；超 SLA 的 High：清零
- 紅軍演練本 Sprint 變更範圍：無新發現 High+
- 任一份報告 BLOCKED → 整體 BLOCKED（非 PASS）
- `docs/security/findings.md` 已更新本次結果

## 歸檔（路徑固定）

- `docs/security/reports/{YYYYMMDD-HHmm}-{vuln|sast|redteam}.md`：三份原始報告，永久保留供回溯
- `docs/security/findings.md`：真實風險總台帳（ID、嚴重度、SLA、狀態、issue 連結）
- `docs/security/false-positives.md`：誤報清單（含 6 個月複審日）
- `docs/security/scan-cadence.md`：掃描頻率（UAT 前必落定）
- Issue tracker：每筆 finding 對應 issue，label `security` + 嚴重度

## 首次啟用（檢查 `docs/security/` 結構）

第一步檢查，缺則從本 skill `templates/` 複製：

| 缺 | 動作 |
|---|---|
| `reports/` 目錄 | 建立 |
| `findings.md` | 從 `templates/findings.md` 複製 |
| `false-positives.md` | 從 `templates/false-positives.md` 複製 |
| `scan-cadence.md` | 從 `templates/scan-cadence.md` 複製，**且立即 BLOCKED**——頻率未落定不得進 UAT |

## 自主決策邊界

**自己決定**：工具選型（三類範圍須全覆蓋，當次工具寫入報告 B 段）；新誤報先進 `false-positives.md` 附證據。

**停下來等確認 / 處理**：收到 Issue 編號時 FAIL → 回報不開關 Issue、PASS → append 結果；3 個 Agent 結果衝突（如 SAST 無發現但紅軍實打成功）→ 以實證 PoC 為準；發現正式環境資料外洩 → 立刻停止並告知 user。

## 不做的事

- 不修補漏洞（修補由 SD / PG / SRE 執行）
- 不為超期 finding 找藉口（超 SLA 一律 FAIL）
- 不接受「下次補上」承諾（零容忍紅線 High+ 出現必擋）
- 不忽略工具警告（非零退出碼 → 停下診斷根因）
- 不在主對話直接跑掃描（必須派 Agent）
- 不放水：「未發現異常」「應該沒問題」「靜態推測 OK」全部 FAIL
- 不省略 D 段「無發現」舉證

## 輸出格式

```
## Security Officer：PASS / FAIL / BLOCKED

掃描時間：YYYY-MM-DD HH:mm ｜ Sprint：{N}

三份報告（各 PASS / FAIL / BLOCKED）：
- 弱點掃描：docs/security/reports/{ts}-vuln.md
- 源碼掃描：docs/security/reports/{ts}-sast.md
- 紅軍演練：docs/security/reports/{ts}-redteam.md

零容忍紅線：PASS / FAIL ｜ SLA：PASS / FAIL ｜ 報告完整性：PASS / FAIL

FAIL 清單：
| ID | 類別 | 嚴重度 | 位置 | 違反條件 | 來源報告 |
|----|------|--------|------|---------|---------|

BLOCKED 清單（若有）：{Agent 名}：{缺什麼支援}

歸檔：findings.md 已更新（是/否）｜ 對應 issues：#xxx
```
