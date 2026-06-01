---
name: workflow:sqa-security
description: Security 審查。OWASP Top 10、hardcode 掃描、敏感資料流、輸入驗證。只輸出 PASS/FAIL，FAIL 附風險等級與具體位置。
---

# workflow:sqa-security

## 檢查項目

**Hardcode**：grep 掃描所有被修改的檔案，找帳密、金鑰、URL。確認所有帳密來源在 SPEC_CONTRACT 資料來源清冊中（若存在）。

**OWASP（只查與本次改動相關的）**：
- A01 存取控制：權限是否有繞過風險
- A02 加密失敗：敏感資料是否加密儲存與傳輸
- A03 注入：SQL、Command 注入風險
- A07 身份驗證：Token 存放、Session 管理
- A09 記錄失敗：敏感資料是否進 log

**輸入驗證**：所有外部輸入是否有驗證。SQL 必須 parameterized query。HTML 輸出必須 escape。

**敏感資料流**：PII 禁止明文出現在 log、response、git。

## 輸出

```
## Security：PASS / FAIL

FAIL 清單：
| 項目 | 位置 | 風險等級 |
|------|------|---------|
| {說明} | {檔案:行號} | HIGH／MED／LOW |
```
