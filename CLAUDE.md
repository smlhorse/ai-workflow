# CLAUDE.md — 框架維護說明

此目錄是 AI 工作流框架的 plugin 本體。以下規範適用於維護、新增、修改任何 skill。

## 任務開始前（強制）

1. 讀所有現有 skill（`.claude/skills/*/SKILL.md`）
2. 讀完再動手。不確定的事先查文件，查不到才問 user。一次問完，不分批。

## Skill 撰寫原則

**寫防護，不寫流程。** 每條規則動筆前先問：這對應哪個已知失敗模式？沒有具體來源的規則不寫。

**寫原則，避免禁令清單。** 原則說明為什麼，讓執行者能從原則判斷邊界。

## Skill 結構規範

每個 skill 必須有：
- `name` + `description` frontmatter
- **核心心法**：說明這個 skill 存在的原因（解決什麼問題）
- **不做的事**：針對已知失敗模式的明確禁止清單
- **自主決策邊界**（如適用）：哪些自己決定、哪些停下來問

不需要有：執行步驟說明、輸出格式教學（除非格式本身是防護的一部分）。

## 新增 Skill 流程

1. 確認對應的失敗模式（來源：實際執行紀錄、用戶回饋）
2. 每條規則對應一個失敗模式，無來源不寫
3. 在 README.md Skill 說明表新增一行

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
CLAUDE.md                        ← 本檔，維護說明（不進 plugin）
README.md
.gitignore
```
