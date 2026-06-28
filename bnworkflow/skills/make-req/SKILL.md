---
name: bnworkflow:make-req
description: 需求釐清（訪談）。產出需求＝要解決什麼、user 真正要什麼。落 docs/requirements/。
---

# bnworkflow:make-req

## 核心心法

**user 常講不清自己要什麼** — make-req 用 PO（成熟版 user）視角，把模糊願望逼成明確、可驗證的需求，再交給 spec。

**訪談不是記錄** — 主動追問隱性需求、邊界、例外、「為什麼」，不照單全收。

**輸出是需求，不是方案** — make-req 回答「要解決什麼」，不回答「長什麼樣」（spec）或「怎麼建」（design）。

## 產出

精煉後的需求（寫入 `docs/requirements/`；專案 CLAUDE.md 可覆寫路徑）：目標、使用情境、邊界/例外、成功標準、未決項。

## 不做的事

- 不幫 user 腦補沒講的需求 → 列待確認問清楚
- 不寫系統長相（spec）、不寫怎麼建（design）
- 不放過「我要一個系統」這種模糊願望 → 逼到可執行
- happy path 之外的例外、權限、極端情境都要問到

## 自主決策邊界

**自己決定**：訪談問題設計、需求結構化方式、從脈絡推斷的需求草案（給 user 確認）。

**停下來問**：業務目標不明、user 真實意圖不確定、需求互相矛盾。

## 角色

PO 主導（代位 user），PM（業務優先序）、業務流程架構師（流程合理性）協同。交棒 `bnworkflow:make-spec`。
