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
# e.g. docs/功能清單.md，或 docs/sprints/ 目錄
# 這是 AI 判斷「做對了沒」的唯一依據，必須填

實作必須完全符合規格定義。發現實作與規格不符 → 以規格為準，先問清楚再改，不擅自詮釋。

## 本機 Issue 位置

`docs/issues/`（版控，預設）。改 `tmp/issues/` 則不版控、團隊共享會掉。GitHub 模式下 Issue 走 GitHub Issues，不用此設定。

## 變更去哪：backlog / decisions / sprint / git log

冒出來的東西按規模與是否排程分家（詳規則見 `.claude/CLAUDE.md`「變更分流與 Sprint 防波堤」）：
- `docs/backlog/{bugs.md, 改善.md, questions.md}`＝**未排程前置池**：🟡現在不做的待辦，只列未完成、做完即刪（git 留歷史，故恆短）。
- `docs/decisions.md`＝**變更＋決策日誌**：🔵動到已定案範圍的變更/決策，一條一行，等 user 點頭。
- sprint / issue＝**已排程**：功能級（多一項使用者能力）才進；規劃時從 backlog 選進，非清空。
- git log＝**改字級**：🟢沒動範圍的小改，直接 commit，不進任何清單。

## 目錄結構

init 建 `CLAUDE.md`、`.claude/*` 與 `docs/專案管理.md`（操作總覽）；其餘 `docs/*` 由對應 skill 首次用到時才建。地圖如下：

```
專案根/
├── CLAUDE.md                             # 專案設定（init 建）
├── .claude/{CLAUDE.md,roles.md,settings.json}   # 行為規範/角色（init 建）
├── CHANGELOG.md                          # 發布記錄（changelog，選用）
└── docs/
    ├── 專案管理.md                       # 操作總覽：三堆/Sprint/digest（init 建）
    ├── requirements/                     # 需求（make-req）
    ├── specs/<feature>/                  # 規格（make-spec）
    ├── design/<feature>/                 # SDD：架構＋DB schema（make-design）
    ├── wbs/                              # WBS 功能全景樹（make-plan，L+）
    ├── sprints/                          # 已排程功能級任務＋驗收
    ├── issues/#N.md                      # 本機 Issue 任務追蹤（見「本機 Issue 位置」）
    ├── qa/                               # 測試計畫/紀錄（make-testplan / verify）
    ├── backlog/{bugs,改善,questions}.md  # 🟡未排程池，做完即刪
    ├── decisions.md                      # 🔵範圍變更＋決策日誌
    ├── adr/                              # 架構決策（選用）
    └── 可選關：security/threat-model/、data-governance/、api/、ops/  # 對應 make-* 可選 skill
（git log＝🟢改字級小改，不進任何檔）
```

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
- 禁止寫入工作目錄以外的檔案
- 禁止未告知就執行會永久丟失資料的操作
- 禁止未授權對 uat / prod 寫入
