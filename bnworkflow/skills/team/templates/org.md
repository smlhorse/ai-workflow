# 組織表

> 誰是誰、主管是誰、現在在哪個 session。只由 `bnworkflow:team` 更新，掛勾不改此檔（避免多視窗互相覆蓋）。

| 代號 | 姓名 | 角色 | 主管 | 現用 session 名稱 | session id | 最後更新 |
|---|---|---|---|---|---|---|
| {代號} | {姓名} | {角色} | {主管代號／無} | {session 名稱／未命名} | {session id／—} | {YYYY-MM-DD HH:MM} |

- 主管欄為「無」＝直接回報 user。
- session 欄只是上次報到時的登記，可能過期：要找人先查對方在不在，找不到往上一級。
- 角色層級與衝突裁定依 `.claude/roles.md`「衝突處理」，本表不另定規則。

## 代號與預設主管（init 建表時套用，user 可改）

各代號的職能底稿在 `../members/{代號}.md`，建成員卡時套用。預設主管照 `.claude/roles.md` 的角色層級推導：CTO 為全隊總管、PM 向 CTO 回報；三大架構師同層、皆對 CTO；UI/UX 與程式架構師是協商關係不是上下級，故歸 PM。

| 代號 | 角色（對應 `.claude/roles.md`） | 預設主管 |
|---|---|---|
| CTO | CTO（技術主管） | 無（直接對 user） |
| PM | PM（產品經理） | CTO |
| PO | PO（Product Owner，需求擁有者） | PM |
| BIZ-ARCH | 業務流程架構師 | CTO |
| SYS-ARCH | 系統架構師 | CTO |
| PROG-ARCH | 程式架構師 | CTO |
| SA | 資深 SA（System Analyst） | SYS-ARCH |
| SD | 資深工程師（SD，兼 Tech Lead） | PROG-ARCH |
| UIUX | UI/UX | PM |
| PG | PG（程式設計師） | SD |
| SRE | SRE（Site Reliability Engineer） | SD |
| SQA | SQA（Senior QA） | 無（獨立，只判 PASS/FAIL） |
| SEC | 資安官（Security Officer） | 無（獨立，只判 PASS/FAIL） |
