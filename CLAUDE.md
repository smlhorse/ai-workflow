# CLAUDE.md — 框架維護說明

此 repo 是 Claude Code plugin 來源。對外以 marketplace 形式發布（`.claude-plugin/marketplace.json`），實際 plugin 在 `bnworkflow/`。以下規範適用於維護、新增、修改任何 skill。

## 任務開始前（強制）

1. 讀所有現有 skill（`bnworkflow/skills/*/SKILL.md`）
2. 讀完再動手。不確定的事先查文件，查不到才問 user。一次問完，不分批。

## Skill 撰寫原則

**寫防護，不寫流程。** 每條規則動筆前先問：這對應哪個已知失敗模式？沒有具體來源的規則不寫。

**寫原則，避免禁令清單，簡潔。** 簡潔、寫原則、說明為什麼，讓執行者能從原則判斷邊界，保留彈性。

## Skill 分類（四類，新增 skill 必須歸類）

23 個 skill 按「做哪種工作」分四類：

**調度** — 派工/把關，自己不做事：`do`、`review`（審查總控）、`verify`（驗測總控）

**產出執行** — 把產物做出來（管線，`do` 自動串、亦可單獨打）：
`make-discovery → make-spec → make-design → make-plan → make-code`

**把關執行** — 角色執行一次審查/驗測（由 review/verify 派，一般不手動）：
- review 派（8）：`review-business / -system / -program / -sa / -uiux / -code / -security / -infra`
- verify 派（4）：`verify-e2e / -deploy / -security-officer / -pm`

**工具** — 一次性雜務：`init`、`sprint`、`feedback`

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
│       ├── spec/SKILL.md
│       └── ...（共 23 個 skill）
├── .claude/                          ← 框架自身運行規則（維護者用）
│   ├── CLAUDE.md
│   ├── roles.md
│   └── settings.json
├── CLAUDE.md                         ← 本檔，維護說明（不進 plugin）
├── README.md
└── .gitignore
```
