-- ============================================================
-- 02_risk_score_calculation.sql
-- Supplier Risk Scorecard | Composite Risk Score
-- ============================================================
-- Methodology: weighted scorecard model, inspired by credit-risk
-- scoring frameworks (normalize each risk driver to a 0-100 scale,
-- weight by business impact, aggregate into one composite score).
--
-- Composite Score = 100 (lowest risk) ... 0 (highest risk)
--
-- Weights:
--   Defect Rate Performance        25%
--   Complaint & Severity Profile   20%
--   Delivery Reliability           15%
--   Audit / Quality System Health  25%
--   Financial Stability            15%
-- ============================================================

WITH base AS (
    SELECT
        supplier_id,
        supplier_name,
        country,
        category,
        total_shipments,
        total_units_shipped,
        defective_units,
        complaint_count,
        avg_resolution_days,
        avg_severity_score,
        on_time_delivery_rate,
        audit_score,
        critical_findings_last_audit,
        recurrence_flag,
        financial_stability_score,
        (defective_units * 1.0 / NULLIF(total_units_shipped, 0)) * 100 AS defect_rate_pct
    FROM supplier_quality_data
),

normalized AS (
    SELECT
        *,
        -- Defect rate: 0% = 100 pts, 5%+ = 0 pts (linear, capped)
        GREATEST(0, LEAST(100, 100 - (defect_rate_pct / 5.0 * 100))) AS defect_score,

        -- Complaint & severity: fewer complaints + lower severity + no recurrence = higher score
        GREATEST(0, LEAST(100,
            100
            - (complaint_count * 4)
            - (avg_severity_score * 8)
            - (recurrence_flag * 15)
        )) AS complaint_score,

        -- Delivery reliability: on-time delivery rate maps directly (floor at 40%)
        GREATEST(0, LEAST(100, (on_time_delivery_rate - 40) / 60.0 * 100)) AS delivery_score,

        -- Audit health: audit score minus penalty per critical finding
        GREATEST(0, LEAST(100, audit_score - (critical_findings_last_audit * 10))) AS audit_health_score,

        -- Financial stability maps directly
        GREATEST(0, LEAST(100, financial_stability_score)) AS financial_score
    FROM base
),

scored AS (
    SELECT
        supplier_id,
        supplier_name,
        country,
        category,
        ROUND(defect_rate_pct, 2)          AS defect_rate_pct,
        ROUND(defect_score, 1)             AS defect_score,
        ROUND(complaint_score, 1)          AS complaint_score,
        ROUND(delivery_score, 1)           AS delivery_score,
        ROUND(audit_health_score, 1)       AS audit_health_score,
        ROUND(financial_score, 1)          AS financial_score,
        ROUND(
            defect_score          * 0.25 +
            complaint_score       * 0.20 +
            delivery_score        * 0.15 +
            audit_health_score    * 0.25 +
            financial_score       * 0.15
        , 1) AS composite_risk_score
    FROM normalized
)

SELECT *
FROM scored
ORDER BY composite_risk_score ASC;  -- lowest score = highest risk, surfaced first
