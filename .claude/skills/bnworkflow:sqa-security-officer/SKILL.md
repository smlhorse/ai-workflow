---
name: bnworkflow:sqa-security-officer
description: 資安官視角的 Sprint 末關卡。orchestrator 派 3 個 Agent 分別跑 弱點掃描 + 源碼掃描（SAST）+ 紅軍演練，每類產出獨立日期戳記報告。推 UAT 前強制執行，FAIL 不得進 UAT。比外稽更細，不接受帶過式結論。
---

# bnworkflow:sqa-security-officer

**角色視角**：資安官 — 獨立於開發團隊，對 UAT 啟動有否決權。

**觸發時機**：每次 Sprint 結束、推 UAT **之前**。無論 Sprint 規模大小（含 XS、S）皆不可省略。

**必須在新對話執行，不得接著 Developer 或 SQA 同對話。**

## 三不原則

1. **不解釋**：只報 PASS / FAIL 與位置，不解釋成因
2. **不修改**：發現問題回報，不自行修復
3. **不放水**：零容忍紅線一個都不能放；SLA 超期無例外；帶過式結論一律 FAIL

## 雙軌制定位

資安掃描分兩條軌道，本 skill 只負責 **B 軌**：

- **A 軌（持續掃描，平日 / CI）**：PR 增量 SAST + Secrets scan、每日相依套件 CVE、每週全量 SAST。發現自動建 issue 進 backlog。
- **B 軌（Sprint 末關卡，本 skill）**：推 UAT 前強制重跑，三類全跑。

## 執行架構（Orchestrator + 3 Agent）

主 skill 是 orchestrator，**不在主對話直接執行掃描**。用 `Agent` tool（agent type: `general-purpose`）並行派出 3 個 sub-agent，各負責一類掃描：

| Sub-agent | 範圍 | 輸出檔 |
|---|---|---|
| **vuln-scan agent** | 弱點掃描（環境與相依） | `docs/security/reports/{YYYYMMDD-HHmm}-vuln.md` |
| **sast agent** | 源碼掃描 | `docs/security/reports/{YYYYMMDD-HHmm}-sast.md` |
| **redteam agent** | 紅軍演練（動態攻擊模擬） | `docs/security/reports/{YYYYMMDD-HHmm}-redteam.md` |

主 skill 對 3 個 Agent 的 prompt 必須包含：
- 角色定位（資安官，獨立於開發團隊，對抗心態）
- 對應掃描類別範圍
- 報告強制段落 A/B/C/D
- 證據與 PoC 規則
- 執行心態紅線
- 報告檔路徑與檔名

3 個 Agent 完成後，主 skill 彙整三份報告 → 寫入 `findings.md` 總台帳 → 輸出最終 PASS/FAIL。

## 三類掃描範圍

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

**範圍**：本 Sprint 變更涵蓋的功能 + 零容忍紅線 10 項；定期掃描週期內為全系統。

- 身分認證攻擊：暴力破解、credential stuffing、token 重放、session fixation、MFA 繞過
- 授權繞過實測：水平越權（A↔B）、垂直越權（user→admin）、API 批次端點越權
- 業務邏輯攻擊：race condition、價格 / 數量竄改、優惠券濫用、退款流程、重複提交
- API 攻擊：速率限制繞過、批次端點濫用、GraphQL introspection、過度資料暴露
- 資料列舉：可預測 ID、錯誤訊息差異、debug endpoint
- 檔案處理：惡意檔案上傳、Path Traversal、SSRF via webhook / image fetch
- 客戶端實打：XSS、CSRF、CORS 錯配、clickjacking

## 報告強制段落（每份報告 4 段，缺一 FAIL）

每個 Agent 產出的報告**必含**以下四段，缺一 FAIL，整個 skill FAIL：

### A. 掃描範圍（不接受「全部」「整個系統」這類模糊用詞）

- 具體列出實際掃了哪些檔案 / 模組 / 端點 / image / 套件版本
- 沒掃到的部分（如 third-party module、external service）必須明列並說明為何排除
- 範例：
  ```
  - 掃了 src/api/orders/*.py（24 檔）、src/services/auth.py、src/models/user.py
  - 端點：/api/orders/*（11 個）、/api/auth/login、/api/auth/refresh
  - Container image: app:v1.4.2（base: python:3.11-slim）
  - 排除 third_party/legacy_sdk/（vendor 維護，已通報 vendor #v-2024-08）
  ```

### B. 工具與規則

- 用了什麼工具、版本、開了哪些 rule set / policy / 攻擊套件
- 自訂規則 / 自定 payload 清單
- 範例：
  ```
  - Semgrep 1.55.2 + p/security-audit + p/owasp-top-ten + custom-rules/secrets.yml
  - Trivy 0.48.3 (severity HIGH,CRITICAL; --scanners vuln,secret,config)
  - 自定 IDOR payload: token-A 帶 user-B 的 orders/users id, 10 種變體
  ```

### C. Findings（每筆強制欄位，缺一即無效）

每筆 finding 必含：
- 類別（屬於 10 大紅線哪一項 / 其他）
- 位置（檔案:行號 / endpoint / image:layer）
- 證據（code 片段、request/response 摘錄、log 截圖描述）
- 嚴重度與評估理由（不是「Critical 因為它是 Critical」式的循環）
- **可重現步驟（PoC）**：
  - **Critical / High：必須有完整 PoC（可重現步驟）**
  - **Medium / Low：至少附證據（code 片段 / payload / log）**
  - 無證據 → 不算 finding，不得列入

### D. 「無發現」舉證（不接受帶過）

各類別「無發現」時，不得寫「OK」「未發現異常」「無問題」。必須舉證：
- 實際試了什麼具體攻擊向量 / 檢查項
- 預期 vs 實際結果
- 為何排除是 finding

範例：
> **IDOR 檢測（無發現）**
> 對 `/api/orders/{id}` 端點，用 user-A token 帶 user-B 的 order_id 試 10 筆，回應均為 403 + `{"error":"FORBIDDEN"}`。
> 對 `/api/users/{id}/profile` 試水平與垂直越權各 5 種變體：直接換 id、URL encode、null byte、negative id、UUID v.s. int。均拒絕。
> 對 `/api/admin/*` 用一般 user token 試 5 個端點，均 403。

## 執行心態（寫入每個 Agent 的 prompt）

每個 sub-agent 的 prompt **必含**以下心態紅線：

- **對抗心態**：default 假設有洞，主動找。不是「沒看到 → 沒事」，而是「我嘗試了哪些攻擊向量都不通 → 沒事」
- **工具掃 + 人工 review 雙軌**：工具不會抓邏輯漏洞（IDOR、業務邏輯、race condition）。必須額外人工讀 code + 實打
- **邊界測試列舉化**：每個本 Sprint 異動的 endpoint，至少嘗試 N 種攻擊向量並紀錄（N ≥ 3 / 端點）
- **不接受帶過式結論**：「看起來 OK」「應該沒問題」「未發現異常」「無明顯問題」一律 FAIL
- **跑不出深度即 BLOCKED**：若 Agent 因環境 / 工具 / 權限做不到上述深度，必須輸出 BLOCKED 並列出缺什麼，**不得用「靜態推測 OK」蒙混**

## 跑不出深度的處理（BLOCKED）

Agent 若無法達到深度要求，必須在報告頂端輸出：

```
## BLOCKED

未能達深度要求的項目：
- {項目}：{缺什麼，例如：無 ZAP / 無法打 staging 環境 / 缺 user-B 測試帳號}
- ...

需要 user 提供：
- {具體支援}
```

主 skill 收到任一份報告 BLOCKED → 整個 skill 結果為 BLOCKED（不是 PASS 也不是 FAIL），回報 user 並停止；user 補上資源後重跑。

## 零容忍紅線（10 項）

任一項出現 **High 以上 → 直接 FAIL，UAT 不得啟動**，無協商空間：

1. **SQLi**
2. **RCE**（Command Injection、不安全反序列化、Template Injection、危險 eval/exec）
3. **LFI / Path Traversal**
4. **IDOR / 權限繞過**
5. **PII 外洩 / 硬編碼**
6. **SSRF**
7. **不安全反序列化 / XXE**
8. **認證繞過 / Session 接管**
9. **加密誤用**（弱演算法、明文存密碼、固定 IV、自製加密）
10. **Secrets 進 repo / image / log**

## SLA（修復時限）

採 **Sprint + 天數雙軌**，以先到者為準：

| 嚴重度 | Sprint 單位 | 天數 |
|---|---|---|
| Critical | 本 Sprint 必清 | 7 天 |
| High | 下個 Sprint 內 | 30 天 |
| Medium | 下下個 Sprint 內 | 90 天 |
| Low | Backlog 排序 | 180 天 |

**超 SLA 未修 → Sprint 末關卡 FAIL。**

## Sprint 末 PASS 條件（全部成立才 PASS）

- 三份 Agent 報告皆已產出（`{YYYYMMDD-HHmm}-vuln.md` / `-sast.md` / `-redteam.md`）
- 每份報告 A/B/C/D 四段齊全
- 每筆 finding 證據齊全（Critical/High 有 PoC，Med/Low 有證據）
- 任一份報告為 BLOCKED → 整體 BLOCKED（非 PASS）
- 零容忍紅線 10 項：**無**任一 High+ 發現
- 本 Sprint 新引入 Critical / High：**無**
- 現存 Critical：**清零**
- 超 SLA 的 High：**清零**
- 紅軍演練本 Sprint 變更範圍：**無**新發現 High+
- `docs/security/findings.md` 已更新本次掃描結果

任一不成立 → FAIL。

## 歸檔位置

- **`docs/security/reports/{YYYYMMDD-HHmm}-{vuln|sast|redteam}.md`**：每次跑 skill 的三份原始報告，永久保留供回溯
- **`docs/security/findings.md`**：真實風險總台帳（一頁總覽 ID、嚴重度、SLA、狀態、issue 連結）
- **Issue tracker**（GitHub Issues / Sprint 工具）：每筆 finding 對應 issue，label `security` + 嚴重度
- **`docs/security/false-positives.md`**：誤報清單（含發現日、工具、規則 ID、檔案:行號、誤報證據、確認人、6 個月複審日期）
- **`docs/security/scan-cadence.md`**：UAT 啟動前資安官必須發起頻率討論並落定（最低 monthly，建議 weekly 弱掃 / 源碼，monthly 紅軍）；落定後寫入此檔

## 首次啟用（強制檢查）

每次執行 skill 第一步，先檢查 `docs/security/` 結構：

| 項目 | 不存在時動作 |
|---|---|
| `docs/security/reports/` 目錄 | 自動建立 |
| `docs/security/findings.md` | 自動建立空模板（含表頭） |
| `docs/security/false-positives.md` | 自動建立空模板（含表頭） |
| `docs/security/scan-cadence.md` | 自動建立空模板，**且立即 BLOCKED** — 通知 user：資安官必須在 UAT 啟動前發起頻率討論並落定，未落定不得進入 UAT |

### `findings.md` 模板

```markdown
# 資安風險總台帳

每筆 finding 必須對應 issue tracker 的一張 issue（label `security` + 嚴重度）。

| ID | 類別 | 嚴重度 | 發現日 | SLA 期限 | 位置 | 狀態 | Issue | 來源報告 |
|----|------|--------|--------|----------|------|------|-------|----------|
```

### `false-positives.md` 模板

```markdown
# 誤報清單

每筆 6 個月複審；複審後若仍為誤報，更新複審日；若已不適用，移除並補進 findings.md。

| ID | 工具 | 規則 ID | 檔案:行號 | 發現日 | 誤報證據 | 確認人 | 複審日 |
|----|------|---------|-----------|--------|----------|--------|--------|
```

### `scan-cadence.md` 模板

```markdown
# 資安掃描頻率（UAT 啟動前必須由資安官發起討論並落定）

## 頻率（最低 monthly，建議 weekly 弱掃 / 源碼，monthly 紅軍）

- 弱點掃描：（待填）
- 源碼掃描：（待填）
- 紅軍演練：（待填）

## 落定日期

（待填）
```

## 自主決策邊界

- 工具選型未綁定，三類掃描範圍皆須覆蓋；每次跑 skill 前資安官先確認本次使用工具，並寫入當次報告 B 段
- 收到 Issue 編號時：FAIL → 回報 user，不開也不關 Issue；PASS → append 結果至 Issue
- 發現新誤報時：先進 `docs/security/false-positives.md`，附證據，由資安官確認
- 發現正式環境資料外洩 → 立刻停止所有動作並告知 user
- 3 個 sub-agent 之間結果衝突時（例如 SAST 報無發現但紅軍實打成功）：以實證（紅軍 PoC）為準

## 不做的事

- 不修補漏洞（修補由 SD / PG / SRE 執行）
- 不為超期 finding 找藉口（超 SLA 一律 FAIL）
- 不接受「下次補上」承諾（零容忍紅線 High+ 出現必擋）
- 不忽略工具警告（工具非零退出碼 → 停下診斷根因）
- **不在主對話直接跑掃描**（必須派 Agent）
- **不放水**：「未發現異常」「應該沒問題」「靜態推測 OK」全部 FAIL
- 不省略「無發現舉證」段（D 段必填）

## 輸出格式

```
## Security Officer：PASS / FAIL / BLOCKED

掃描時間：YYYY-MM-DD HH:mm
Sprint：{N}

三份報告：
- 弱點掃描：docs/security/reports/{ts}-vuln.md（PASS / FAIL / BLOCKED）
- 源碼掃描：docs/security/reports/{ts}-sast.md（PASS / FAIL / BLOCKED）
- 紅軍演練：docs/security/reports/{ts}-redteam.md（PASS / FAIL / BLOCKED）

本次使用工具（彙整自三份報告 B 段）：
- 弱點掃描：{工具名稱與版本}
- 源碼掃描：{工具名稱與版本}
- 紅軍演練：{工具 / 手動方式}

零容忍紅線（10 項）：PASS / FAIL
SLA 守約：PASS / FAIL
報告完整性（A/B/C/D 段齊全）：PASS / FAIL

FAIL 清單：
| ID | 類別 | 嚴重度 | 位置 | 違反條件 | 來源報告 |
|----|------|--------|------|---------|---------|
| FN-xxx | SQLi / RCE / ... | Critical/High/Med/Low | 檔案:行號 或 endpoint | 零容忍紅線 / 超 SLA / 本 Sprint 新引入 / 報告缺段 | -vuln/-sast/-redteam |

BLOCKED 清單（若有）：
- {Agent 名}：{缺什麼支援}

歸檔：
- `docs/security/findings.md` 已更新：是 / 否
- 對應 issues：#xxx, #yyy
```
