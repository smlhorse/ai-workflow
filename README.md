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
   ├─ 需求講不清？─是→ discovery(PO 訪談逼出需求)
   ▼
   ├─ 改使用者可見？─是→ spec ──→ review(審 spec)
   ▼
   ├─ M/L+ 或跨模組？─是→ design(SDD) ──→ review(審 design)
   ▼
   plan ──→ review(審 plan) → 等 ack
   ▼
   exec(寫 code) ──→ 做後 review(審程式 code+security)
   ▼ (完成，開新對話)
verify ── 程式審查 + e2e + deploy + 紅軍 + PM驗收
```

每產出一個產物（spec / design / plan / 程式）就 `review` 審那個對象，FAIL 停下修。

- **review** ＝ 審查（讀產物判對錯）：每完成一個產物就跑，按對象派對應角色。
- **verify** ＝ 驗測（把成品跑起來驗）：做後一次、開新對話保持獨立。
- `init` ＝ 開新專案用一次；`feedback` ＝ 吐槽框架時用。

### 想手動單獨呼叫時

| 你要 | 打 |
|---|---|
| 整件事（訪談 → 規格 → 設計 → 規畫 → 執行 → 驗收） | `/bnworkflow:do` |
| 釐清需求 | `/bnworkflow:discovery` |
| 只產規格 | `/bnworkflow:spec` |
| 只做架構設計（SDD） | `/bnworkflow:design` |
| 只規畫不執行 | `/bnworkflow:plan` |
| 已有明確做法、跳過規畫 | `/bnworkflow:exec` |
| 審查某產物（spec/design/plan/程式） | `/bnworkflow:review` |
| 全套驗收（新對話） | `/bnworkflow:verify` |

## Skill 說明

23 個 skill 按「做哪種工作」分四類。**日常只需打 `do` 與 `verify`**，其餘自動派。

### 調度（派工，自己不做事）

| Skill | 用途 |
|---|---|
| `bnworkflow:do` | 任務全流程驅動，自動串管線 |
| `bnworkflow:review` | 審查總控，按對象派審查角色 |
| `bnworkflow:verify` | 驗測總控（必須新對話），派驗測角色 |

### 產出執行（管線：把產物做出來，do 自動串、亦可單獨打）

| Skill | 用途 |
|---|---|
| `bnworkflow:discovery` | 需求訪談，逼出 user 講不清的真需求 |
| `bnworkflow:spec` | 兩層規格（lite 業務版 + business 結構版） |
| `bnworkflow:design` | 架構設計 SDD（系統＋軟體＋基礎設施） |
| `bnworkflow:plan` | Anchor → Plan → 等 ack，不執行 |
| `bnworkflow:exec` | 純執行，跳過 plan |

### 把關執行（callee，由 review / verify 自動派，通常不手動）

| Skill | 派工者 | 用途 |
|---|---|---|
| `bnworkflow:review-business` | review | 業務流程架構師審業務流程合理性 |
| `bnworkflow:review-system` | review | 系統架構師審系統架構面 |
| `bnworkflow:review-program` | review | 程式架構師審軟體架構面 |
| `bnworkflow:review-sa` | review | 資深 SA 審規格完整性/品質 |
| `bnworkflow:review-uiux` | review | UI/UX 審介面與操作流程 |
| `bnworkflow:review-code` | review | SD 審程式碼對規格 |
| `bnworkflow:review-security` | review | 資安官靜態資安審查（OWASP/hardcode） |
| `bnworkflow:review-infra` | review | SRE 審基礎設施/部署架構 |
| `bnworkflow:verify-e2e` | verify | UI/UX+SRE 實地操作 E2E |
| `bnworkflow:verify-deploy` | verify | SRE 部署就緒檢查 |
| `bnworkflow:verify-security-officer` | verify | 資安官動態關卡：弱掃 + SAST + 紅軍 |
| `bnworkflow:verify-pm` | verify | PM+PO 業務最終驗收 |

### 工具

| Skill | 用途 |
|---|---|
| `bnworkflow:init` | 初始化新專案，產生 CLAUDE.md 與設定檔 |
| `bnworkflow:sprint` | Sprint 與 Issue 管理（GitHub Milestone / 本機模式） |
| `bnworkflow:feedback` | 框架使用回饋蒐集，回 framework repo 批量消化 |

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
│       └── ... (共 23 個 skill)
├── .claude/                          ← 框架自身的 AI 規範（維護者用）
│   ├── CLAUDE.md
│   └── roles.md
├── CLAUDE.md                         ← 框架維護說明（不進 plugin）
└── README.md
```
