# CLAUDE.md — 框架維護說明

此 repo 是 Claude Code plugin 來源。對外以 marketplace 形式發布（`.claude-plugin/marketplace.json`），實際 plugin 在 `bnworkflow/`。以下規範適用於維護、新增、修改任何 skill。

## 任務開始前（強制）

1. 讀所有現有 skill（`bnworkflow/skills/*/SKILL.md`）
2. 讀完再動手。不確定的事先查文件，查不到才問 user。一次問完，不分批。

## Skill 撰寫原則

**寫防護，不寫流程。** 每條規則動筆前先問：這對應哪個已知失敗模式？沒有具體來源的規則不寫。

**寫原則，避免禁令清單，簡潔。** 簡潔、寫原則、說明為什麼，讓執行者能從原則判斷邊界，保留彈性。

## 產出物 vs 任務追蹤 vs 討論（三分原則）

三種東西、三個家，撰寫任何涉及 issue/plan/產出物的 skill 都依此：
- **產出物**（需求/spec/設計 SDD/測試計畫/WBS）＝跨任務的文件 → 一律 `docs/*`，恆版控（無「視情況」）。Issue 只引用，不裝。
- **任務追蹤 Issue**（目標/狀態/估時/日期/驗收結果）＝一件要做的事 → 位置才「視情況」：GitHub 模式走 GitHub Issues；本機模式預設 `docs/issues/`（版控），專案可設 `tmp/issues/`（scratch、不版控）。這是唯一的「視情況」變數。
- **討論/決策** → Issue 留言；架構決策（為什麼這樣設計）落 `docs/adr/`；🔵已定案範圍的變更日誌（改了什麼規格/範圍，一行一條）落 `docs/decisions.md`。兩者不同家、不互換，都不是 Issue 本體。

plan 不是一律進 Issue：小任務的計畫＝Issue 內幾行步驟；L+＝WBS（`docs/wbs/`）。沒有獨立 plan 暫存檔。

**任務追蹤再依「規模×是否排程」分家**（根治 issue 堆積、大小不分、混一桶）：
- **已排程**（sprint/issue）＝功能級（多一項使用者能力）才進；規劃時從 backlog **選**進、非清空。
- **未排程**（`docs/backlog/{bugs.md, 改善.md, questions.md}`）＝🟡前置池，只列未完成、做完即刪（git 留歷史），故恆短。
- **改字級**（🟢沒動範圍的小改）＝直接 commit、只留 git log，不進任何清單。
撰寫涉及變更分流的 skill 依此三線，並遵守 `.claude/CLAUDE.md`「變更分流與 Sprint 防波堤」核心原則（兩份規則檔須同步）。

## Skill 分類（四類，新增 skill 必須歸類）

30 個 skill 按「做哪種工作」分四類：

**調度** — 派工/把關，自己不做事：`do`、`review`（審查總控）、`verify`（驗測總控）

**產出執行** — 把產物做出來（管線，`do` 自動串、亦可單獨打）：
`make-req → make-spec →〔工程軌 make-design → make-plan → make-code ＋ QA 軌 make-testplan〕`
（make-spec 後 fan-out 兩軌並行；make-testplan 是並行軌、非線性串，兩軌匯流才進 verify）
四個可選關按需插入：`make-threat-model`（設計前，做前安全建模）、`make-data-governance`（設計後，資料治理）、`make-apidoc`（設計後，對外 API 文件）、`make-ops`（實作後、與 verify 並行，維運手冊）

**把關執行** — 角色執行一次審查/驗測（由 review/verify 派，一般不手動）：
- review 派（8）：`review-business / -system / -program / -sa / -uiux / -code / -security / -infra`
- verify 派（4）：`verify-e2e / -deploy / -security-officer / -pm`

**工具** — 一次性雜務：`init`、`sprint`、`feedback`、`status`、`changelog`（發布記錄）

慣例：
- 把關執行一律 `review-` / `verify-` 前綴；description 標「（由 {parent} 自動呼叫，通常不需手動）」，讓 `/plugin` 清單與 autocomplete 自我說明
- 新增 skill 必須歸入某類；歸不進 → 先檢討是否真需要

## Skill 結構規範

每個 skill 必須有：
- `name` + `description` frontmatter；`name` 寫完整 `bnworkflow:<folder>`，slash command autocomplete 才會顯示 `/bnworkflow:<folder>` 而不是裸名 `/<folder>`
- **核心心法**：說明這個 skill 存在的原因（解決什麼問題）
- **不做的事**：針對已知失敗模式的明確禁止清單
- **自主決策邊界**（如適用）：哪些自己決定、哪些停下來問

不需要有：執行步驟說明、輸出格式教學（除非格式本身是防護的一部分）。

## 新增 Skill 流程

1. 確認對應的失敗模式（來源：實際執行紀錄、用戶回饋）
2. 每條規則對應一個失敗模式，無來源不寫
3. 歸入分類（調度 / 產出執行 / 把關執行 / 工具）；把關執行用 `review-` / `verify-` 前綴 + description 標 callee
4. 在 `bnworkflow/skills/<name>/SKILL.md` 建立檔案，frontmatter `name: bnworkflow:<name>`
5. 在 README.md Skill 說明表對應分類區塊新增一行
6. push 到 `smlhorse/ai-workflow`；user 端透過 `/plugin marketplace update` 取得新版

## 規則檔同步注意

`.claude/CLAUDE.md` + `.claude/roles.md`（框架自身運行時用）與 `bnworkflow/skills/init/templates/rules.md` + `templates/roles.md`（init 複製給用戶專案）內容應保持一致。修改規則時兩處同步更新。

## 目錄結構

```
20260506_workflow/                    ← repo / marketplace 根目錄
├── .claude-plugin/
│   └── marketplace.json
├── bnworkflow/                       ← plugin 本體
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/
│       ├── init/
│       │   ├── SKILL.md
│       │   └── templates/
│       │       ├── CLAUDE.md         ← 新專案根 CLAUDE.md 模板
│       │       ├── rules.md          ← 複製到用戶 .claude/CLAUDE.md
│       │       └── roles.md          ← 複製到用戶 .claude/roles.md
│       ├── do/SKILL.md
│       ├── make-spec/SKILL.md
│       ├── verify-security-officer/
│       │   ├── SKILL.md
│       │   └── templates/         ← findings / false-positives / scan-cadence
│       └── ...（共 30 個 skill；部分 skill 含 templates/）
├── .claude/                          ← 框架自身運行規則（維護者用）
│   ├── CLAUDE.md
│   ├── roles.md
│   └── settings.json
├── CLAUDE.md                         ← 本檔，維護說明（不進 plugin）
├── README.md
└── .gitignore
```
