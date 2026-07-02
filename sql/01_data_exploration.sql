-- ============================================================
-- 01_data_exploration.sql
-- Supplier Risk Scorecard | Exploratory queries
-- ============================================================
-- Purpose: initial profiling of the supplier quality dataset
-- before building the risk scoring model.
-- ============================================================

-- 1. Row count and basic sanity check
SELECT COUNT(*) AS total_suppliers
FROM supplier_quality_data;

-- 2. Suppliers by country
SELECT
    country,
    COUNT(*) AS supplier_count,
    ROUND(AVG(defective_units * 1.0 / NULLIF(total_units_shipped, 0)) * 100, 2) AS avg_defect_rate_pct
FROM supplier_quality_data
GROUP BY country
ORDER BY avg_defect_rate_pct DESC;

-- 3. Suppliers by category, with average complaint volume
SELECT
    category,
    COUNT(*) AS supplier_count,
    ROUND(AVG(complaint_count), 2) AS avg_complaints,
    ROUND(AVG(audit_score), 1) AS avg_audit_score
FROM supplier_quality_data
GROUP BY category
ORDER BY avg_complaints DESC;

-- 4. Suppliers with recurring issues and low audit scores
--    (early warning candidates before formal scoring)
SELECT
    supplier_id,
    supplier_name,
    country,
    complaint_count,
    recurrence_flag,
    audit_score,
    critical_findings_last_audit
FROM supplier_quality_data
WHERE recurrence_flag = 1
  AND audit_score < 70
ORDER BY audit_score ASC;

-- 5. Distribution check: defect rate percentiles (for normalization thresholds)
SELECT
    ROUND(defective_units * 1.0 / NULLIF(total_units_shipped, 0) * 100, 3) AS defect_rate_pct
FROM supplier_quality_data
ORDER BY defect_rate_pct;
-- (Used offline to inspect percentile cut points before setting
--  normalization bounds in 02_risk_score_calculation.sql)
