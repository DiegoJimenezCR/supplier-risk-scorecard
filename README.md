# Supplier Risk Scorecard

A weighted risk-scoring model that converts raw supplier quality data into a single, actionable risk score and tier classification — built with **SQL** and **Power BI**, using a methodology inspired by credit-risk scorecards (normalize → weight → aggregate → classify).

> **Note on data:** the dataset is synthetic, generated to statistically resemble real medical-device supply chain quality metrics (defect rates, complaint volume, audit outcomes, delivery reliability). No proprietary or employer data is used.

---

## 1. Business Context

Organizations that manage large supplier networks — manufacturers, medical device companies, and risk data providers alike — need a consistent, defensible way to answer one question: **which suppliers pose the greatest operational risk, and why?**

Traditional quality reporting (raw defect counts, complaint logs) tells you *what happened*. A scorecard model tells you *how risky each supplier is relative to the others*, in a single number stakeholders can act on — the same logic that underpins credit rating and counterparty risk models used across financial risk analytics.

## 2. Objective

Build a reproducible pipeline that:
1. Ingests raw supplier quality data (shipments, defects, complaints, audits, delivery, financial stability)
2. Normalizes each risk driver to a common 0–100 scale
3. Applies business-weighted aggregation into one **Composite Risk Score**
4. Classifies suppliers into **Risk Tiers** (Tier 1–4) for fast triage
5. Visualizes results in an interactive Power BI dashboard

## 3. Dataset

`data/supplier_quality_data.csv` — 120 simulated suppliers across 8 categories and 10 countries, with 16 fields including:

| Field | Description |
|---|---|
| `defective_units` / `total_units_shipped` | Used to calculate defect rate |
| `complaint_count`, `avg_severity_score`, `recurrence_flag` | Complaint profile |
| `on_time_delivery_rate` | Delivery reliability |
| `audit_score`, `critical_findings_last_audit` | Quality system health |
| `financial_stability_score` | Counterparty financial risk proxy |

## 4. Methodology

The **Composite Risk Score** (0 = highest risk, 100 = lowest risk) is a weighted sum of five normalized components:

| Risk Driver | Weight | Rationale |
|---|---|---|
| Defect Rate Performance | 25% | Direct measure of product quality failure |
| Complaint & Severity Profile | 20% | Captures frequency, severity, and recurrence of issues |
| Delivery Reliability | 15% | Operational dependability |
| Audit / Quality System Health | 25% | Forward-looking indicator of systemic risk |
| Financial Stability | 15% | Counterparty risk — a financially unstable supplier is a supply continuity risk |

Suppliers are then classified into tiers, mirroring how a rating agency bands issuers into risk categories:

| Tier | Score Range | Action |
|---|---|---|
| **Tier 1 — Low Risk** | 85–100 | Preferred supplier, standard monitoring |
| **Tier 2 — Moderate Risk** | 70–84 | Routine monitoring |
| **Tier 3 — Elevated Risk** | 50–69 | Corrective action plan required |
| **Tier 4 — High Risk** | < 50 | Critical review / requalification |

See [`docs/methodology.md`](docs/methodology.md) for the full scoring logic and normalization formulas.

## 5. Key Findings

Based on the current dataset run (120 suppliers):

- **3 suppliers (2.5%)** fall into **Tier 4 — High Risk**, requiring immediate requalification review.
- **46 suppliers (38%)** sit in **Tier 3 — Elevated Risk**, the largest actionable segment — this is where corrective action plans have the most portfolio-wide impact.
- Only **4 suppliers (3%)** achieve **Tier 1 — Low Risk**, suggesting the overall supplier base has room to improve against the scoring thresholds.
- **Electronic Components** suppliers score highest on average (lowest risk), while **Precision Optics** suppliers score lowest — a signal for category-level sourcing review.
- Risk is not concentrated in a single country — the lowest and highest-risk suppliers in the dataset span multiple regions, reinforcing that **supplier-level scoring catches risk that country-level heuristics would miss**.

## 6. Repository Structure

```
supplier-risk-scorecard/
├── data/
│   └── supplier_quality_data.csv       # Source dataset (synthetic)
├── sql/
│   ├── 01_data_exploration.sql         # Profiling & sanity checks
│   ├── 02_risk_score_calculation.sql   # Core scoring logic
│   └── 03_risk_tier_classification.sql # Tier assignment & summary
├── docs/
│   ├── methodology.md                  # Full scoring methodology
│   └── dax_measures.md                 # Power BI DAX measures
├── dashboard/
│   └── dashboard_overview.md           # Dashboard structure & screenshots
└── README.md
```

## 7. Tech Stack

- **SQL** — data profiling, scoring logic, tier classification (portable across PostgreSQL / SQL Server / SQLite)
- **Power BI** — interactive scorecard dashboard, DAX measures for dynamic scoring
- **Python** (data generation only) — pandas/numpy, used solely to produce the synthetic dataset

## 8. About

Built by **Diego Jiménez** — Industrial Engineer with experience in medical device quality and process analytics (Genpact / Edwards Lifesciences), currently expanding into data analytics with a focus on **risk scoring and operational data**.

[LinkedIn](#) · [Portfolio](#)
