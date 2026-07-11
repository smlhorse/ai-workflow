# AI 工作流框架

全公司通用的 Claude Code 工作流規範，解決 AI 執行常見缺陷。以 Claude Code plugin 形式發布。

## 安裝

**Step 1**：加入 marketplace（一次性）：
```
/plugin marketplace add smlhorse/ai-workflow
```
（或本機路徑：`/plugin marketplace add /path/to/20260506_workflow`）

**Step 2**：安裝 plugin：
```
/plugin install bnworkflow@smlhorse-ai-workflow
```

**Step 3**：在目標專案執行：
```
/bnworkflow:init
```
init 會互動式收集專案資訊，產生：
- `CLAUDE.md`（專案根目錄）— 專案名稱、環境、規格文件位置、啟動命令
- `.claude/CLAUDE.md` — AI 行為規範（從 plugin 複製，獨立於 plugin 更新）
- `.claude/roles.md` — 12 角色定位與衝突處理
- `.claude/settings.json`

## 更新

```
/plugin marketplace update smlhorse-ai-workflow
```
或在 `/plugin` UI Marketplaces 分頁啟用 auto-update。

新增 skill 後重新跑一次 init 可選擇是否同步 `.claude/CLAUDE.md` 與 `.claude/roles.md`（plugin 升級不會自動覆蓋既有專案的規則檔，避免破壞用戶 local 修改）。

## 執行流程（什麼時候用誰）

**日常你只打 2 個**：`do`（做事）、`verify`（驗收，開新對話）。其餘由 do / review / verify 按規則自動派，你不用選。

```
你描述任務
   ▼
do ──讀 anchor、判規模、逐關判斷需不需要
   ├─ 需求講不清？─是→ make-req(PO 訪談逼出需求)
   ▼
   ├─ 改使用者可見？─是→ make-spec ──→ review(審規格)
   ▼
   規格定案後 fan-out 兩軌並行：
   ├─────────────────────┬─────────────────────────────┐
   │ 工程軌                │ QA 軌                        │
   │ make-design(SDD)      │ make-testplan(SQA 從規格寫    │
   │   ──→ review(審設計)  │   測試案例，涵蓋失敗/邊界)   │
   │ make-plan ──→ review  │                              │
   │   →等 ack             │                              │
   │ make-code ──→ 做後    │                              │
   │   review(code+sec)    │                              │
   └─────────────────────┴─────────────────────────────┘
   ▼ 兩軌匯流(barrier，完成，開新對話)
verify ── 讀 make-testplan 的測試計畫執行：程式審查 + e2e + deploy + 紅軍 + PM驗收
```

每產出一個產物（spec / design / plan / 程式）就 `review` 審那個對象，FAIL 停下修。

- **review** ＝ 審查（讀產物判對錯）：每完成一個產物就跑，按對象派對應角色。
- **verify** ＝ 驗測（把成品跑起來驗）：做後一次、開新對話保持獨立。
- `init` ＝ 開新專案用一次；`feedback` ＝ 吐槽框架時用。

### 產物遞進

```
make-req(需求) → make-spec(規格) → make-design(SDD) → make-plan(計畫) → make-code(程式碼)
```

一句話分清差別：**要解決什麼**（需求）→ **長什麼樣**（規格）→ **怎麼建**（設計）→ **怎麼一步步做**（計畫）→ **寫出來**（程式碼）。

主線之外，`make-design` 的 SDD 按需涵蓋可選 facet：威脅模型（規格後、設計前的 STRIDE 安全建模）、資料治理、對外 API 文件、維運（runbook/DR/rollback/容量規劃/環境建置/監控告警/壓測規劃）；不需要的略過。發布時由 `verify` 彙整 Release Notes/CHANGELOG。

### 各產物的家

**skill 產出物**（skill 名與下方「Skill 說明」一致）：

| Skill | 產出位置 |
|---|---|
| `bnworkflow:make-req` | `docs/requirements/` |
| `bnworkflow:make-spec` | `docs/specs/` |
| `bnworkflow:make-design` | `docs/SDD/{編號}_{名稱}.md`（編號前綴排序、統一命名；SDD facet 按需：威脅模型 `docs/security/threat-model/`、資料治理 `docs/data-governance/`、對外 API `docs/api/<service>/api.md`、維運 `docs/ops/<feature>/`） |
| `bnworkflow:make-testplan` | `docs/qa/{sprint}_測試計畫_v{N}.md` |
| `bnworkflow:make-plan` | 小任務＝Issue 內步驟；L+＝WBS（`docs/wbs/`） |
| `bnworkflow:make-code` | repo（程式碼） |
| `bnworkflow:verify` | `docs/qa/reports/{sprint}_測試紀錄_v{N}_{時戳}.md`；發布時彙整 repo 根 `CHANGELOG.md` |

**任務追蹤／變更去處**（非 skill 產物）：

| 類別 | 去處 |
|---|---|
| Issue（任務追蹤，已排程） | GitHub Issues / 本機 `docs/issues/`（版控，預設）/ `tmp/issues/`（scratch，依設定） |
| backlog（未排程前置池） | `docs/backlog/{bugs.md, 改善.md, questions.md}`（只列未完成、做完即刪、恆短） |
| 變更＋決策日誌 | `docs/decisions.md`（🔵動到範圍的變更/決策，一條一行） |
| 改字級小改 | git log（🟢沒動範圍、直接 commit，不進任何清單） |

### 專案管理（WBS + status）

L+ 規模時 `make-plan` 產出 **WBS 樹**（`docs/wbs/{sprint}.md`，層級 milestone → epic → story → task，葉子＝一張 Issue）。執行各關（do / make-code / verify）**必更新對應節點狀態**，不更新不算完成。`status` 只讀 WBS 樹＋Issue＋Sprint，給**雙軌進度%**（已拆解 vs 含未規劃）＋**時程**（剩餘天數、逾期、即將到期、stale 旗），計時用**日曆天、非實際工時**。

### 想手動單獨呼叫時

| 你要 | 打 |
|---|---|
| 整件事（訪談 → 規格 → 設計 → 規畫 → 執行 → 驗收） | `/bnworkflow:do` |
| 釐清需求 | `/bnworkflow:make-req` |
| 只產規格 | `/bnworkflow:make-spec` |
| 只做架構設計（SDD，含威脅模型/資料治理/對外 API/維運 facet 按需） | `/bnworkflow:make-design` |
| 寫測試計畫 | `/bnworkflow:make-testplan` |
| 只規畫不執行 | `/bnworkflow:make-plan` |
| 已有明確做法、跳過規畫 | `/bnworkflow:make-code` |
| 審查某產物（spec/SDD/plan/程式） | `/bnworkflow:review` |
| 全套驗收（新對話；發布時彙整 Release Notes/CHANGELOG） | `/bnworkflow:verify` |
| 開新專案初始化 | `/bnworkflow:init` |
| Sprint／Issue 管理 | `/bnworkflow:sprint` |
| 回饋框架本身 | `/bnworkflow:feedback` |
| 看進度／時程 | `/bnworkflow:status` |

## 角色與能力（12 位資深成員，皆 10+ 年、負責過大型系統）

| # | 角色 | 核心能力 |
|---|---|---|
| 1 | **PM**（產品經理） | 商業模式、市場/競品、需求優先序與 ROI、roadmap、stakeholder 管理、跨域裁定、驗收 sign-off |
| 2 | **PO**（需求擁有者） | 需求訪談、把模糊願望翻成可執行需求、代位不成熟 user 做系統化決策、**按需動態補齊能力** |
| 3 | **業務流程架構師** | 跨領域流程設計與重構、產業合規、維運成本、業務層權限/稽核、流量/批次/時效 |
| 4 | **系統架構師** | 高併發/分散式設計、容錯/災難恢復、整合架構、系統層安全、容量/SLA、**產系統架構 SDD** |
| 5 | **程式架構師** | 模組化（SRP/DDD/分層）、設計模式與技術選型、可測試性、介面契約、技術債/重構、**產軟體架構 SDD** |
| 6 | **資深 SA** | 需求釐清、隱性需求挖掘、無歧義規格、邊界條件、資料流/狀態機、規格↔實作追溯 |
| 7 | **資深工程師（SD＝Tech Lead）** | clean code/重構、程式層安全、效能優化、code review；**軟體工程實務總負責**：工程流程/測試策略/CI/分支/相依/工具鏈/規範 |
| 8 | **PG**（程式設計師） | 按規格/設計快速實作、CRUD/API、單元測試、bug 修復、規範遵循 |
| 9 | **UI/UX** | 介面/互動設計與 design system、心智模型、操作流程、切版/響應式、user research、無障礙 |
| 10 | **SRE** | 部署/CI-CD/IaC、監控/可觀測性、容量/災難恢復、基礎設施層安全、事故/SLO、**產 infra SDD＋審 infra** |
| 11 | **SQA**（資深 QA） | 缺陷模式、邊界/回歸測試、測試計畫、PASS/FAIL 把關（三不原則） |
| 12 | **資安官** | 弱掃/SAST/DAST、紅軍演練、OWASP/CVE、零容忍紅線與 SLA 強制（三不原則） |

完整定位、經驗背景、判斷依據、衝突裁定見 `.claude/roles.md`。

## Skill 說明

25 個 skill 按「做哪種工作」分四類。**日常只需打 `do` 與 `verify`**，其餘自動派。

### 調度（派工，自己不做事）

| # | Skill | 參與角色 | 用途 |
|---|---|---|---|
| 1 | `bnworkflow:do` | （流程驅動） | 任務全流程驅動，自動串管線 |
| 2 | `bnworkflow:review` | 召集對應審查角色 | 審查總控，按對象派審查角色 |
| 3 | `bnworkflow:verify` | SQA 主導 | 驗測總控（必須新對話），派驗測角色 |

### 產出執行（管線：把產物做出來，do 自動串、亦可單獨打）

| # | Skill | 參與角色 | 用途 |
|---|---|---|---|
| 4 | `bnworkflow:make-req` | PO、PM、業務流程架構師 | 需求訪談，逼出 user 講不清的真需求 |
| 5 | `bnworkflow:make-spec` | 資深 SA、UI/UX（PM、業務架構師協同） | 兩層規格（lite 業務版 + business 結構版） |
| 6 | `bnworkflow:make-design` | 系統架構師、程式架構師、SRE、UI/UX（威脅模型→資安官、資料治理→業務流程架構師 協） | 架構設計 SDD（系統＋軟體＋基礎設施＋介面互動＋強制圖；按需含威脅模型/資料治理/對外 API/維運 facet） |
| 7 | `bnworkflow:make-testplan` | SQA、UI/UX | 規格定案後與工程軌並行寫測試計畫（含失敗/邊界/非功能） |
| 8 | `bnworkflow:make-plan` | 程式架構師、SD | Anchor → Plan → 等 ack，不執行；步驟標並行分組並註明執行角色 |
| 9 | `bnworkflow:make-code` | PG（依 plan 並行分組可拆前端/後端等多角色，SD 督） | 純執行，跳過 plan |

### 把關執行（callee，由 review / verify 自動派，通常不手動）

| # | Skill | 參與角色 | 派工者 | 用途 |
|---|---|---|---|---|
| 10 | `bnworkflow:review-business` | 業務流程架構師 | review | 審業務流程合理性 |
| 11 | `bnworkflow:review-system` | 系統架構師 | review | 審系統架構面 |
| 12 | `bnworkflow:review-program` | 程式架構師 | review | 審軟體架構面 |
| 13 | `bnworkflow:review-sa` | 資深 SA | review | 審規格完整性/品質 |
| 14 | `bnworkflow:review-uiux` | UI/UX | review | 審介面與操作流程 |
| 15 | `bnworkflow:review-code` | SD | review | 審程式碼對規格＋執行驗證（build/測試） |
| 16 | `bnworkflow:review-security` | 資安官 | review | 資安審查（OWASP/hardcode）＋輸入驗證實際送測 |
| 17 | `bnworkflow:review-infra` | SRE | review | 審基礎設施/部署架構 |
| 18 | `bnworkflow:verify-e2e` | UI/UX、SRE | verify | 實地操作 E2E |
| 19 | `bnworkflow:verify-deploy` | SRE | verify | 部署就緒檢查＋對照 anchor 確認環境建置/監控告警/壓測是否需要 |
| 20 | `bnworkflow:verify-security-officer` | 資安官 | verify | 動態關卡：弱掃 + SAST + 紅軍 |
| 21 | `bnworkflow:verify-pm` | PM、PO | verify | 業務最終驗收 |

### 工具

| # | Skill | 參與角色 | 用途 |
|---|---|---|---|
| 22 | `bnworkflow:init` | （工具） | 初始化新專案，產生 CLAUDE.md 與設定檔 |
| 23 | `bnworkflow:sprint` | （PM 視角） | Sprint 與 Issue 管理（GitHub Milestone / 本機模式） |
| 24 | `bnworkflow:feedback` | （工具） | 框架使用回饋蒐集，回 framework repo 批量消化 |
| 25 | `bnworkflow:status` | PM、SD | 讀 WBS+Issue 給雙軌進度% + 時程 + stale 旗（只讀，非工時） |

## 解決的問題

| 問題 | 解法 |
|---|---|
| 確認一點就腦補整體 | Anchor-First：逐字存 anchor，No-Drift 防護 |
| 沒完成說做好了 | Done Definition：完成 = 自驗通過，非語法通過 |
| 不查就問 user | 規格文件是 ground truth；codebase 是現況。先確認現況、對照規格，查不到才問 |
| 不會自己拆任務 | 規模判斷矩陣 + L+ 強制人工拆解 |
| 規格寫死 | 規格文件衛生：禁止暫時性資訊進規格 |
| 可併行卻不併行 | Plan 步驟標並行分組（parallel group） |
| 跳過錯誤繼續跑 | 非零退出碼 / 工具警告 → 停下診斷，不繼續 |
| 驗收停在語法層 | Done Definition：業務邏輯 + 邊界條件列入 |
| 決策漂移不自知 | No-Drift：後段想改前段決策 → 停下告知 |
| 狀態假設不嚴謹 | 每步驗產物存在才繼續，不假設上步成功 |
| 模糊範圍往少靠 | BLOCKED：業務規則不確定 → 停下問清楚 |
| 改動溢出邊界 | Diff 必須能對照 anchor；無法對應的改動若涉及架構或系統邏輯，需取得 anchor 確認才動手 |
| Plan 後段模糊 | 每步驗收方式必須具體，不得用「實作 X」帶過 |
| 重複讀同一份文件 | 同對話內讀過的內容不重讀；先查已有上下文，再查 codebase |
| 輸出混過程說明 | 輸出格式規範：只寫事實與決策 |
| 重複提醒已知限制 | 已知限制不重複提醒，只報告新資訊 |
| review 只讀 diff 沒執行，錯誤穿透未被抓到 | `review-code`/`review-security` 加執行驗證（build/測試/實際送測），不得只憑讀碼判 PASS |
| 並行分組定義了沒人消費，實作永遠單一 agent 全包 | `make-code` 依 plan 並行分組拆前端/後端等多角色平行執行 |
| 設計期角色不全（UI/UX、SRE 容量規劃缺席） | `make-design` 補 UI/UX 介面互動架構、DB schema 變更連動 SRE 容量規劃 |
| 派工前沒查是否已有文件就直接實作 | `do` 加派工前盤點：查 SDD/API文件/威脅模型/測試計畫是否已存在 |
| 上線設施項目（環境建置/監控/壓測）事後才想起 | `verify-deploy` 上線前對照 anchor 逐項確認是否需要，不擅自省略或全做 |

## 使用後的專案目錄結構

跑過 `init` 與各 skill 後，**你的專案**長這樣（與下方 plugin repo 本身結構不同，勿混淆）：

```
你的專案/
├── CLAUDE.md                    ← init 產（必有，專案設定）
├── .claude/{CLAUDE.md, roles.md, settings.json}  ← init 產/複製（必有）
├── CHANGELOG.md                 ← verify 發布時彙整（選用）
├── docs/                        ← skills 按需產生
│   ├── requirements/            ← make-req
│   ├── specs/                   ← make-spec
│   ├── SDD/{編號}_{名稱}.md     ← make-design（含強制架構圖/DFD）
│   ├── api/<service>/api.md     ← make-design 對外 API facet（選用）
│   ├── data-governance/         ← make-design 資料治理 facet（選用）
│   ├── ops/<feature>/           ← make-design 維運 facet（選用）
│   ├── qa/{sprint}_測試計畫_v{N}.md + reports/  ← make-testplan / verify
│   ├── wbs/{sprint}.md          ← make-plan（L+）
│   ├── issues/#N.md             ← 本機 Issue（本機模式預設；專案可設 tmp/issues）
│   ├── backlog/{bugs,改善,questions}.md ← 🟡未排程前置池（做完即刪、恆短）
│   ├── decisions.md             ← 🔵變更＋決策日誌（動到範圍才記，一條一行）
│   ├── adr/                     ← 重要決策記錄（選用）
│   ├── sprints/                 ← sprint（本機模式）
│   └── security/                ← verify-security-officer + make-design 威脅模型 facet（threat-model/）
└── tmp/                         ← gitignore（scratch：anchor.md、report.md；專案設 tmp/issues 時 Issue 也在此）
```

- **必有**＝init 一開始就建：`CLAUDE.md`、`.claude/*`。
- **按需**＝skill 用到才建：`docs/*` 子目錄、`tmp/*`。
- GitHub 模式下 Issue/Milestone 走 GitHub，不產 `docs/issues`、`docs/sprints`。
- **Issue ＝任務追蹤，不是萬用桶**：產出物（需求/spec/設計/測試計畫/WBS）住 `docs/*` 恆版控、Issue 只引用；討論走 Issue 留言、重要決策落 `docs/adr/`。Issue 位置才「視情況」（GitHub / `docs/issues/` 版控 / `tmp/issues/` scratch，依設定）。
- **變更依「規模×是否排程」分家**（根治大小不分）：`backlog`＝未排程前置池（🟡未做、做完即刪、恆短）；`sprint`/`issue`＝已排程（功能級才進，多一項使用者能力）；`decisions.md`＝🔵動到已定案範圍的變更/決策（等 user 拍板）；git log＝🟢改字級小改（不進任何清單）。sprint 規劃從 backlog **選**進、非清空。

## 目錄結構（plugin 包裝）

```
20260506_workflow/                    ← repo / marketplace 根目錄
├── .claude-plugin/
│   └── marketplace.json              ← 列出此 marketplace 包含的 plugins
├── bnworkflow/                       ← plugin 本體
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/
│       ├── init/SKILL.md
│       │   └── templates/{CLAUDE.md, rules.md, roles.md}
│       ├── do/SKILL.md
│       └── ... (共 25 個 skill)
├── .claude/                          ← 框架自身的 AI 規範（維護者用）
│   ├── CLAUDE.md
│   └── roles.md
├── CLAUDE.md                         ← 框架維護說明（不進 plugin）
└── README.md
```
