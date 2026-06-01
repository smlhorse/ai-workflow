# AI 工作流框架

全公司通用的 Claude Code 工作流規範，解決 AI 執行常見缺陷。

## 安裝

**Step 1**：將本 repo 的 `.claude/` 目錄複製到目標專案根目錄。

**Step 2**：在目標專案開啟 Claude Code，執行：
```
/workflow:init
```
init 會互動式收集專案資訊，產生專案專屬的 `CLAUDE.md` 與 `.claude/settings.json`。

**兩個 CLAUDE.md 的差異：**
| 檔案 | 角色 | 內容 |
|---|---|---|
| `.claude/CLAUDE.md` | 框架行為規範，隨 `.claude/` 一起複製過去 | AI 的通用執行原則，不改動 |
| `CLAUDE.md`（專案根目錄） | 專案設定，由 `workflow:init` 產生 | 專案名稱、環境、規格文件位置、啟動命令 |

## 日常使用

```
# 直接描述任務（自動判規模走對應路徑）
我要做...

# 只規畫不執行
/workflow:plan

# 規畫 + 執行 + 驗收摘要
/workflow:do

# 只執行（已有明確做法，跳過 plan）
/workflow:exec

# 全套驗收（新對話執行）
/workflow:sqa

# 單項驗收
/workflow:sqa-review
/workflow:sqa-security
/workflow:sqa-e2e
/workflow:sqa-deploy
```

## Skill 說明

| Skill | 用途 |
|---|---|
| `workflow:init` | 初始化新專案，產生 CLAUDE.md 與設定檔 |
| `workflow:do` | plan + 執行，完成後提示走 /workflow:sqa |
| `workflow:plan` | Anchor → Plan → 等 ack，不執行 |
| `workflow:exec` | 純執行，跳過 plan |
| `workflow:sqa` | 全套驗收（必須新對話） |
| `workflow:sqa-review` | Code review：規格對照 + 自行填充偵測 |
| `workflow:sqa-security` | Security：OWASP + hardcode + 輸入驗證 |
| `workflow:sqa-e2e` | E2E：實地操作，不靠源碼推斷 |
| `workflow:sqa-deploy` | 部署準備：環境變數、migration、rollback |

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
  settings.json
  skills/
    workflow:init/
      SKILL.md
      templates/CLAUDE.md        ← 新專案的 CLAUDE.md 模板
    workflow:plan/SKILL.md
    workflow:do/SKILL.md
    workflow:exec/SKILL.md
    workflow:sqa/SKILL.md
    workflow:sqa-review/SKILL.md
    workflow:sqa-security/SKILL.md
    workflow:sqa-e2e/SKILL.md
    workflow:sqa-deploy/SKILL.md
CLAUDE.md                        ← 框架維護說明（不進 plugin）
README.md
.gitignore
```
