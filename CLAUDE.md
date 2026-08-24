# CLAUDE.md — 框架維護說明

此 repo 是 Claude Code plugin 來源。對外以 marketplace 形式發布（`.claude-plugin/marketplace.json`），實際 plugin 在 `bnworkflow/`。以下規範適用於維護、新增、修改任何 skill。

## 任務開始前（強制）

1. 讀所有現有 skill（`bnworkflow/skills/*/SKILL.md`）
2. 讀完再動手。不確定的事先查文件，查不到才問 user。一次問完，不分批。

## Skill 撰寫原則

**寫防護，不寫流程。** 每條規則動筆前先問：這對應哪個已知失敗模式？沒有具體來源的規則不寫。

**寫原則，避免禁令清單，簡潔。** 簡潔、寫原則、說明為什麼，讓執行者能從原則判斷邊界，保留彈性，不擅自定義死板的禁令，避免過度強烈的禁止語氣。

## 產出物 vs 任務追蹤 vs 討論（三分原則）

三種東西、三個家，撰寫任何涉及 issue/plan/產出物的 skill 都依此：
- **產出物**（需求/spec/設計 SDD/測試計畫/WBS）＝跨任務的文件 → 一律 `docs/*`，恆版控（無「視情況」）。Issue 只引用，不裝。
- **任務追蹤 Issue**（目標/狀態/估時/日期/驗收結果）＝一件要做的事 → 位置才「視情況」：GitHub 模式走 GitHub Issues；本機模式預設 `docs/issues/`（版控），專案可設 `tmp/issues/`（scratch、不版控）。這是唯一的「視情況」變數。
- **討論/決策** → Issue 留言；架構決策（為什麼這樣設計）落 `docs/adr/`；🔵已定案範圍的變更日誌（改了什麼規格/範圍，一行一條）落 `docs/decisions.md`。兩者不同家、不互換，都不是 Issue 本體。

plan 不是一律進 Issue：小任務的計畫＝Issue 內幾行步驟；L+＝WBS（`docs/wbs/`）。沒有獨立 plan 暫存檔。

**任務追蹤再依「規模×是否排程」分三線**：🟢改字級＝git log／🔵動到範圍＝decisions.md 等拍板／🟡未排程＝backlog。定義、門檻、防波堤以 rules.md（即 `.claude/CLAUDE.md`）「變更分流與 Sprint 防波堤」為唯一權威，撰寫相關 skill 依它，此處不另抄。

## Skill 分類（四類，新增 skill 必須歸類）

25 個 skill 按「做哪種工作」分四類：

**調度** — 派工/把關，自己不做事：`do`、`review`（審查總控）、`verify`（驗測總控）

**產出執行** — 把產物做出來（管線，`do` 自動串、亦可單獨打）：
`make-req → make-spec →〔工程軌 make-design → make-plan → make-code ＋ QA 軌 make-testplan〕`
（make-spec 後 fan-out 兩軌並行；make-testplan 是並行軌、非線性串，兩軌匯流才進 verify）
make-design 的 SDD 按需涵蓋威脅模型（STRIDE，做前）、資料治理、對外 API 文件、維運等 facet；發布記錄由 verify 於推 UAT/發布時彙整。

**把關執行** — 角色執行一次審查/驗測（由 review/verify 派，一般不手動）：
- review 派（8）：`review-business / -system / -program / -sa / -uiux / -code / -security / -infra`
- verify 派（4）：`verify-e2e / -deploy / -security-officer / -pm`

**工具** — 一次性雜務：`init`、`sprint`、`feedback`、`status`

慣例：
- 把關執行一律 `review-` / `verify-` 前綴；description 標「（由 {parent} 自動呼叫，通常不需手動）」，讓 `/plugin` 清單與 autocomplete 自我說明
- 新增 skill 必須歸入某類；歸不進 → 先檢討是否真需要

## Skill 結構規範

每個 skill 必須有：
- `name` + `description` frontmatter；`name` 寫裸名 `<folder>`，不手寫 `bnworkflow:` 前綴——plugin 載入時會自動加上，手寫會變雙重前綴（`bnworkflow:bnworkflow:<folder>`）
- **核心心法**：說明這個 skill 存在的原因（解決什麼問題）
- **不做的事**：針對已知失敗模式的明確禁止清單
- **自主決策邊界**（如適用）：哪些自己決定、哪些停下來問

不需要有：執行步驟說明、輸出格式教學（除非格式本身是防護的一部分）。

## 新增 Skill 流程

1. 確認對應的失敗模式（來源：實際執行紀錄、用戶回饋）
2. 每條規則對應一個失敗模式，無來源不寫
3. 歸入分類（調度 / 產出執行 / 把關執行 / 工具）；把關執行用 `review-` / `verify-` 前綴 + description 標 callee
4. 在 `bnworkflow/skills/<name>/SKILL.md` 建立檔案，frontmatter `name: <name>`（裸名，不加 `bnworkflow:` 前綴）
5. 在 README.md Skill 說明表對應分類區塊新增一行
6. **完成前自檢**：動到的文件逐項對照本檔原則自審（skill 數／三表順序／命名／無專案化洩漏／版本）；**大改後派 general agent 審文件一致性與廢話**（段落重複、命名/順序一致、無廢話）——語意一致與廢話非 grep 能判，靠 AI 或人審。
7. push 到 `smlhorse/ai-workflow`；user 端透過 `/plugin marketplace update` 取得新版

## 規則檔（內容只一份，.claude 用 @import）

規則內容只有一份、住 `bnworkflow/skills/init/templates/rules.md`（＋`templates/roles.md`）——這點沒變。差別是：框架自身的 `.claude/CLAUDE.md` / `.claude/roles.md`（Claude Code 在本 repo 的**自動載入入口，仍必須存在**）現在**只 `@import` 那一份、不再各存一份手動同步**。改規則只改 templates。init 給用戶專案的是 templates 的**全文複本**（用戶端無 templates 可 import）。

## 目錄結構

```
20260506_workflow/                    ← repo / marketplace 根目錄
├── .claude-plugin/
│   └── marketplace.json
├── bnworkflow/                       ← plugin 本體
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── hooks/
│   │   ├── hooks.json                ← PreToolUse／Bash 攔付費資源/破壞性git/push；PostToolUse／Write|Edit 呼叫 review
│   │   ├── check-billable-command.sh
│   │   └── check-git-safety.sh
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
│       └── ...（共 25 個 skill；部分 skill 含 templates/）
├── .claude/                          ← 框架自身運行規則（維護者用）
│   ├── CLAUDE.md
│   ├── roles.md
│   └── settings.json
├── CLAUDE.md                         ← 本檔，維護說明（不進 plugin）
├── README.md
└── .gitignore
```
