---
name: team
description: 多組織、多團隊的成員身分與跨 session 交接。支援 onboard、join、handoff、who、use、refresh；換帳號或 session 不遺失角色、關係與工作現況。
---

# bnworkflow:team

## 用法

```text
/bnworkflow:team use {組織}/{團隊}
/bnworkflow:team onboard {組織}/{團隊} {成員 ID} {角色代號} [--manager {主管成員 ID}]
/bnworkflow:team join [{組織}/{團隊}] {成員 ID}
/bnworkflow:team handoff [--to {成員 ID}]
/bnworkflow:team who [{成員 ID}]
/bnworkflow:team refresh
/bnworkflow:team refresh-all [{組織}/{團隊}]
```

身分分四層：**組織 → 團隊 → 成員 → session**。帳號不決定團隊；同一專案換帳號時，只要使用相同專案目錄並 join 同一成員 ID，即接續同一份團隊資料。不同帳號仍須各自安裝相同版本的 plugin。

## 資料位置

```text
.team/                              # 不進版控
├── defaults.md                     # 專案預設組織／團隊
├── sessions/{session-id}.md        # session → 組織／團隊／成員綁定
└── organizations/{組織}/teams/{團隊}/
    ├── org.md                       # 成員、角色、主管
    ├── capabilities.md              # 角色應使用的 workflow skills
    ├── work.md                      # 目前有效派工
    ├── members/{成員-id}.md         # 成員卡
    └── handoff/{成員-id}.md         # 工作現況
```

組織／團隊 ID 只用英數、`-`、`_`，不得含 `/`；成員 ID 採 `{角色小寫}-{兩位流水號}`，例如 `pg-01`、`pg-02`、`sa-01`。流水號只供穩定識別，不代表職級、專長或目前分工；停用後不轉給新人。PG 預設為全端，前端／後端是當次工作的分組，不寫進 ID。

## 指令契約

**use**：寫入 `.team/defaults.md`。只設定本專案預設值，不綁定任何 session。

**onboard**：由 user 指定成員 ID、角色與主管；依角色底稿建立成員卡與空 handoff，更新 org.md。成員 ID 已存在、主管不存在或會形成循環時停止，不覆寫。onboard 是建立成員，join 是目前 session 報到，兩者不得混為一談。

**join**：組織／團隊的選擇順序為「指令明示 → 本 session 既有綁定 → defaults.md → 詢問 user」，不得猜。確認成員存在後：
1. 讀自己的成員卡、handoff、org.md、capabilities.md 中自己角色那列，以及 work.md 中指派給自己的項目。
2. 寫入 `sessions/{session-id}.md`，記錄 plugin 能力版本與 refresh 時間。
3. handoff 檔頭更新本 session 名稱與 id，但不動工作現況更新時間。
4. 只載入主管、直接同事與直屬下屬的名稱／角色／關係；需要協作時才讀對方完整成員卡，避免無效 token。

**handoff**：覆寫自己的 handoff，只保留下一棒能直接動手的目前狀態；未驗過的放下一步，不寫成完成。無 `--to` 時狀態為「交接待接手」；指定接手者時，確認對方同隊且存在，更新 work.md 負責人，接手者確認後才改為「進行中」。待 user 決策事項照原文搬，不代替決定。

**who**：交叉比對 session 綁定、org.md、work.md 與 handoff 更新時間，回報在線／忙碌／停滯／失聯。不得只靠 org.md 推測在線狀態。

**refresh**：重新讀最新成員卡、組織關係、角色能力表中自己那列、work.md 與 handoff，更新 session 的能力版本與 refresh 時間。角色規則與工作內容可在原 session refresh；plugin 新增 skill、hook 或工具時，先更新 plugin，再 handoff 並重開 session，舊 session 不得假裝已取得新能力。

**refresh-all**：通知同隊在線成員 refresh，記錄其能力版本；離線者下次 join 自動 refresh。只做版本同步，不逐員重問工作內容。

## 工作與能力原則

- 成員卡由角色底稿產生，但成員身分以成員 ID 為準；同角色可有多人。
- 每項派工在 work.md 留任務來源、負責人、產出、完成判準、停止條件與同步點；沒有 user 已提出／確認的來源或明確產出，不得派工。
- 全端成員可承接前端或後端；同一功能仍依設計與計畫拆前端、後端、整合工作軌。M／L+ 優先派不同成員平行執行，XS／S 可由同一成員依獨立工作項依序完成。
- 參與產出者不得擔任唯一審查者；換 session 或帳號不會解除此限制。
- 工作管理檔不是日誌，長到一頁看不完即須收斂；歷史看 Issue、WBS、逐字稿與 git。

## 舊版轉換

發現舊結構 `.team/org.md`、`.team/members/{角色}.md`、`.team/handoff/{角色}.md` 時，不直接混用。交由 `bnworkflow:update`：先讓 user 指定組織／團隊，再將每個舊角色映射為 `{角色小寫}-01`；保留姓名、人設與 handoff 內容，加入能力表，列出差異後取得確認才搬移。完成前舊版照舊可讀，不建立半套新結構。

## 自主決策邊界

**自己決定**：依既有資料讀取狀態、離線判定、handoff 內容取捨與排版。

**停下來問**：onboard 身分、角色、姓名、主管關係；預設組織／團隊；舊版轉換映射；跨團隊調動。

## 不做的事

- 不自封身分、不用帳號推測成員、不把 session 名稱當永久身分。
- 不把密碼或個資寫進 `.team/`。
- 不為認人讀完整團隊卡片，不為 refresh 重跑工作或重派 agent。
