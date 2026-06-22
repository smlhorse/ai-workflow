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
- `.claude/roles.md` — 10 角色定位與衝突處理
- `.claude/settings.json`

## 更新

```
/plugin marketplace update smlhorse-ai-workflow
```
或在 `/plugin` UI Marketplaces 分頁啟用 auto-update。

新增 skill 後重新跑一次 init 可選擇是否同步 `.claude/CLAUDE.md` 與 `.claude/roles.md`（plugin 升級不會自動覆蓋既有專案的規則檔，避免破壞用戶 local 修改）。

## 日常使用

```
# 直接描述任務（自動判規模走對應路徑）
我要做...

# 涉及 UI 時，先產元件級規格（A-E 5 表）
/bnworkflow:spec

# 只規畫不執行
/bnworkflow:plan

# 規畫 + 執行 + 驗收摘要
/bnworkflow:do

# 只執行（已有明確做法，跳過 plan）
/bnworkflow:exec

# 全套驗收（新對話執行）
/bnworkflow:sqa

# 單項驗收
/bnworkflow:sqa-review
/bnworkflow:sqa-security
/bnworkflow:sqa-e2e
/bnworkflow:sqa-deploy
/bnworkflow:sqa-security-officer
```

## Skill 說明

| Skill | 用途 |
|---|---|
| `bnworkflow:init` | 初始化新專案，產生 CLAUDE.md 與設定檔 |
| `bnworkflow:do` | plan + 執行，完成後提示走 /bnworkflow:sqa |
| `bnworkflow:spec` | 涉及 UI 時產出元件級規格（A-E 5 表），對齊業務目標 |
| `bnworkflow:plan` | Anchor → Plan → 等 ack，不執行 |
| `bnworkflow:exec` | 純執行，跳過 plan |
| `bnworkflow:sqa` | 全套驗收（必須新對話） |
| `bnworkflow:sqa-review` | Code review：規格對照 + 自行填充偵測 |
| `bnworkflow:sqa-security` | Security：OWASP + hardcode + 輸入驗證（系統架構師 + SD 視角） |
| `bnworkflow:sqa-e2e` | E2E：實地操作，不靠源碼推斷 |
| `bnworkflow:sqa-deploy` | 部署準備：環境變數、migration、rollback |
| `bnworkflow:sqa-security-officer` | 資安官 Sprint 末關卡：弱掃 + SAST + 紅軍；推 UAT 前必跑 |
| `bnworkflow:sqa-pm` | PM 按規格需求最終驗收 |
| `bnworkflow:sprint` | Sprint 與 Issue 管理（GitHub Milestone / 本機模式） |
| `bnworkflow:review` | 規格 review 總控（業務／系統／程式架構師＋SA＋UI/UX 多角色） |
| `bnworkflow:review-business` | 業務流程架構師審查規格 |
| `bnworkflow:review-system` | 系統架構師審查規格 |
| `bnworkflow:review-program` | 程式架構師審查規格 |
| `bnworkflow:review-sa` | 資深 SA 審查規格完整性 |
| `bnworkflow:review-uiux` | UI/UX 審查介面與操作流程 |
| `bnworkflow:feedback` | 框架使用回饋蒐集，寫入 `tmp/bnworkflow-feedback/`，回 framework repo 批量消化 |

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
│       └── ... (共 20 個 skill)
├── .claude/                          ← 框架自身的 AI 規範（維護者用）
│   ├── CLAUDE.md
│   └── roles.md
├── CLAUDE.md                         ← 框架維護說明（不進 plugin）
└── README.md
```
