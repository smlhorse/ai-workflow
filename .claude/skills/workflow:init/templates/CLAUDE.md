# {專案名稱}
# e.g. WMS、會員系統

{專案一句話描述}
# e.g. 跨境倉庫管理系統，處理進出口訂單與物流追蹤

---

## 環境

| 環境 | 說明 | 連線方式 |
|---|---|---|
| dev | 日常開發 | {e.g. localhost:5432 / Neon free tier} |
| uat | 驗收測試 | {e.g. Cloud SQL，需 proxy 連線} |
| prod | 正式環境 | {e.g. Cloud SQL，需 proxy + 明確授權} |

## 操作授權規則

- **dev**：可直接操作，執行前告知動作
- **uat**：需 user 當次明確說「可以」才執行
- **prod**：每次都需 user 明確下指令確認，絕不主動連線或寫入

不構成授權的情況：討論中曾提到、之前對話說過「可以」、自行判斷上下文應該可以。

## Ground Truth

規格文件位置：`{路徑}`
# e.g. docs/功能清單.md
# 這是 AI 判斷「做對了沒」的唯一依據，必須填

Sprint 文件位置：`{路徑}`
# e.g. docs/sprints/

實作必須完全符合規格定義。發現實作與規格不符 → 以規格為準，先問清楚再改，不擅自詮釋。

## 啟動命令

```bash
# {服務名稱與 port}
{啟動指令}
# e.g. cd src/api && uvicorn main:app --port 8003 --reload
```

## 架構摘要

{技術棧、關鍵路徑、重要約束}
# e.g. React + FastAPI + PostgreSQL；全域狀態用 Zustand；DB 操作只能透過 src/api/lib/db/

## 禁止事項（永不破例）

- credentials / PII 禁止進 log 和 git
- 禁止讀寫工作目錄以外的檔案
- 禁止未告知就執行會永久丟失資料的操作
- 禁止未授權對 uat / prod 寫入
