---
name: bnworkflow:review-infra
description: 基礎設施/部署架構審查（SRE 視角）。容量、可觀測性、部署拓樸、基礎設施層安全。（由 review 自動呼叫，通常不需手動）
---

# bnworkflow:review-infra

## 核心心法

**SRE 的審查模式** — 對 design 的基礎設施面、部署配置判 PASS/FAIL。SRE 不只在驗測（deploy）端把關，設計階段就該審 infra 架構。

## 審查項目

- 部署拓樸合理性、單點故障
- 容量規劃 vs 預期負載
- 可觀測性（log / metric / trace）是否設計進去
- 基礎設施層安全（網路隔離、key 管理、最小權限）
- IaC 可重現、環境一致性
- 災難恢復 / rollback 機制

## 不做的事

- 不評論業務 / 程式邏輯（其他架構師職責）
- 不寫修復建議，只判 PASS/FAIL 並指出位置
- 不放過「沒設計監控 / 容量」→ FAIL

## 自主決策邊界

**自己決定**：infra 風險判定。

**停下來問**：非功能需求（容量 / SLA）缺失，無法判斷 → 回報 user。
