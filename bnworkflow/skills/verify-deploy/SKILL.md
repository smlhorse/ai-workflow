---
name: bnworkflow:verify-deploy
description: 部署準備檢查（SRE 視角）。環境變數、Migration、CI/CD、Rollback。只輸出 PASS/FAIL，FAIL 附具體缺漏。（由 verify 自動呼叫，通常不需手動）
---

# bnworkflow:verify-deploy

**角色視角**：SRE — 部署、監控、維運、基礎設施層安全與效能。

## 檢查項目

**環境變數**：新增的環境變數已加入 `.env.template` 並有說明。沒有實際值進入版控。帳密變數名稱與 SPEC_CONTRACT 清冊一致（若存在）。

**DB Migration**（有 DB 變更才適用）：腳本存在且 idempotent。不可逆操作（DROP、資料轉換）已明確標注並確認。

**CI/CD**：有新增服務或環境變數時，pipeline 配置已更新。

**Rollback**：有明確的 rollback 步驟。資料變更的 rollback 方案已確認。

**維運手冊**（涉上線部署才適用）：runbook/事故處理/DR 備份還原/容量規劃已隨設計（make-design SDD 維運 facet）產出並齊備，非原作者也能照做。缺 → FAIL。

**環境建置／監控告警設定／壓測**（涉上線部署才適用）：對照 anchor 逐項確認本次是否需要；anchor 未提及 → 停下問 user，不擅自省略或全做；anchor 已明確排除 → 免問直接跳過。

## 不做的事

- 只回報缺漏，不代為補設定
- 不接受「上線後再補」的 migration / rollback
- 不可逆操作未標注並確認 → FAIL，不放行

## 輸出

```
## Deploy：PASS / FAIL

FAIL 清單：
| 項目 | 缺漏說明 |
|------|---------|
```
