# AI 工作流框架

全公司通用的 Claude Code 工作流規範，解決 AI 執行常見缺陷。

## 安裝

**Step 1**：clone 框架 repo 到本機：
```bash
git clone https://github.com/smlhorse/ai-workflow {框架路徑}
```

**Step 2**：執行安裝腳本，指定目標專案路徑：
```bash
bash {框架路徑}/install.sh /path/to/target-project
```

**Step 3**：在目標專案開啟 Claude Code，執行：
```
/bnworkflow:init
```
init 會互動式收集專案資訊，產生專案專屬的 `CLAUDE.md` 與 `.claude/settings.json`。

**檔案說明：**
| 檔案 | 角色 | 內容 |
|---|---|---|
| `{框架路徑}/.claude/CLAUDE.md` | 框架行為規範實體，不改動 | AI 的通用執行原則 |
| `.claude/CLAUDE.md`（專案） | 由 `bnworkflow:init` 附加一行 `@` 引用框架規範 | 專案原有內容不動 |
| `CLAUDE.md`（專案根目錄） | 專案設定，由 `bnworkflow:init` 產生 | 專案名稱、環境、規格文件位置、啟動命令 |

**框架更新：**
```bash
cd {框架路徑} && git pull
```
所有已安裝的專案透過 symlink 自動同步，不需重新執行任何指令。

## 日常使用

```
# 直接描述任務（自動判規模走對應路徑）
我要做...

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

## 目錄結構

```
.claude/
  CLAUDE.md                      ← 框架行為規範（跟著 plugin 走）
  roles.md                       ← 10 角色定位與衝突處理
  settings.json
  skills/
    bnworkflow:init/
      SKILL.md
      templates/CLAUDE.md        ← 新專案的 CLAUDE.md 模板
    bnworkflow:plan/SKILL.md
    bnworkflow:do/SKILL.md
    bnworkflow:exec/SKILL.md
    bnworkflow:sqa/SKILL.md
    bnworkflow:sqa-review/SKILL.md
    bnworkflow:sqa-security/SKILL.md
    bnworkflow:sqa-e2e/SKILL.md
    bnworkflow:sqa-deploy/SKILL.md
    bnworkflow:sqa-security-officer/SKILL.md
    bnworkflow:sqa-pm/SKILL.md
    bnworkflow:sprint/SKILL.md
    bnworkflow:review/SKILL.md
    bnworkflow:review-business/SKILL.md
    bnworkflow:review-system/SKILL.md
    bnworkflow:review-program/SKILL.md
    bnworkflow:review-sa/SKILL.md
    bnworkflow:review-uiux/SKILL.md
    bnworkflow:feedback/SKILL.md
CLAUDE.md                        ← 框架維護說明（不進 plugin）
README.md
.gitignore
```
