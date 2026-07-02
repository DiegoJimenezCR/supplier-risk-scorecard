# Scoring Methodology

## Why a weighted scorecard model

Raw operational metrics (defect count, complaint count, audit findings) live on different scales and can't be compared or combined directly. A **weighted scorecard** — the same core approach used in credit risk and counterparty risk scoring — solves this by:

1. **Normalizing** every metric to a common 0–100 scale, where 100 always means "lowest risk" and 0 always means "highest risk"
2. **Weighting** each normalized metric by its business importance
3. **Aggregating** into a single composite score
4. **Binning** the composite score into risk tiers for fast decision-making

This makes the model transparent (every input to the score is traceable) and defensible (weights are business decisions, not a black box).

## Step-by-step logic

### 1. Defect Rate Score (25% weight)
```
defect_rate_pct = (defective_units / total_units_shipped) * 100
defect_score    = 100 - (defect_rate_pct / 5.0 * 100), clamped to [0, 100]
```
A 0% defect rate scores 100. A 5%+ defect rate scores 0. The 5% ceiling was chosen as a reasonable upper bound for component-level manufacturing defect rates — in a production setting this threshold would be calibrated against historical distribution and industry benchmarks.

### 2. Complaint & Severity Score (20% weight)
```
complaint_score = 100
                 - (complaint_count * 4)
                 - (avg_severity_score * 8)
                 - (recurrence_flag * 15)
```
Penalizes suppliers for complaint *volume*, complaint *severity* (1–5 scale), and *recurrence* of the same issue — a recurring issue is a stronger risk signal than an isolated one, so it carries an explicit penalty on top of the raw complaint count.

### 3. Delivery Reliability Score (15% weight)
```
delivery_score = (on_time_delivery_rate - 40) / 60 * 100, clamped to [0, 100]
```
Linear scale where 100% on-time delivery scores 100, and 40% or below scores 0.

### 4. Audit / Quality System Health Score (25% weight)
```
audit_health_score = audit_score - (critical_findings_last_audit * 10)
```
Starts from the raw audit score, then subtracts a fixed penalty per critical finding in the most recent audit — critical findings are a forward-looking risk indicator, so they're weighted more heavily than the base audit score alone would suggest.

### 5. Financial Stability Score (15% weight)
```
financial_score = financial_stability_score
```
Passed through directly (already 0–100 scaled in source data). Represents counterparty risk — the likelihood a supplier can't fulfill its obligations due to financial distress, independent of quality performance.

### Composite score
```
composite_risk_score = defect_score * 0.25
                      + complaint_score * 0.20
                      + delivery_score * 0.15
                      + audit_health_score * 0.25
                      + financial_score * 0.15
```

## Design choices worth noting

- **Weights are illustrative, not universal.** In a real deployment, weights should be validated against historical outcomes (e.g., which risk drivers actually predicted supply disruptions or quality escapes) rather than assigned by intuition alone.
- **Linear normalization was chosen for interpretability.** A production model might use logistic or percentile-based normalization if the underlying metric distributions are heavily skewed.
- **Tier boundaries (85/70/50) are round-number defaults** for this proof-of-concept. In practice, tier cutoffs should be set so that each tier reflects a materially different action (monitor vs. corrective action vs. requalification).

## Limitations

This is a portfolio project built on synthetic data, intended to demonstrate scoring methodology and SQL/BI execution — not a validated production risk model. A real implementation would require: historical outcome data to validate weights, stakeholder sign-off on thresholds, and a governance process for score overrides.
