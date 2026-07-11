---
name: bnworkflow:review-security
description: Security 審查（系統架構師 + SD 視角）。OWASP Top 10、hardcode 掃描、敏感資料流、輸入驗證。只輸出 PASS/FAIL，FAIL 附風險等級與具體位置。（由 review 自動呼叫，通常不需手動）
---

# bnworkflow:review-security

**角色視角**：系統架構師（系統層 authn/authz、傳輸加密、敏感資料）+ SD（程式層輸入驗證、注入防護、log 衛生）。

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

**執行驗證**：涉輸入驗證／注入防護的改動，至少手動送一次邊界或惡意輸入，確認實際被擋下；不得只憑讀程式碼判斷「應該有擋」。

## 不做的事

- 只回報風險不修補，不給修復建議
- OWASP 判「無問題」須有依據，帶過式結論一律 FAIL
- 不只查 happy path，敏感資料流每條都要追到底
- 不得以「讀程式碼看起來有擋」代替實際送測結果

## 輸出

```
## Security：PASS / FAIL

FAIL 清單：
| 項目 | 位置 | 風險等級 |
|------|------|---------|
| {說明} | {檔案:行號} | HIGH／MED／LOW |
```
