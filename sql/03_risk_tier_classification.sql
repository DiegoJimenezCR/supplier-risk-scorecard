-- ============================================================
-- 03_risk_tier_classification.sql
-- Supplier Risk Scorecard | Risk Tier Assignment
-- ============================================================
-- Converts the composite_risk_score (from 02_risk_score_calculation.sql)
-- into a categorical risk tier, similar in spirit to a credit
-- rating band -- easier for stakeholders to act on than a raw number.
-- ============================================================

WITH scored AS (
    -- In production this would reference a view/table built from
    -- 02_risk_score_calculation.sql. Inlined here for portability.
    SELECT
        supplier_id,
        supplier_name,
        country,
        category,
        composite_risk_score
    FROM supplier_risk_scores  -- materialized view of query 02
),

tiered AS (
    SELECT
        *,
        CASE
            WHEN composite_risk_score >= 85 THEN 'Tier 1 - Low Risk (Preferred)'
            WHEN composite_risk_score >= 70 THEN 'Tier 2 - Moderate Risk (Monitor)'
            WHEN composite_risk_score >= 50 THEN 'Tier 3 - Elevated Risk (Corrective Action Required)'
            ELSE 'Tier 4 - High Risk (Critical Review / Requalification)'
        END AS risk_tier
    FROM scored
)

SELECT
    risk_tier,
    COUNT(*) AS supplier_count,
    ROUND(AVG(composite_risk_score), 1) AS avg_score_in_tier
FROM tiered
GROUP BY risk_tier
ORDER BY avg_score_in_tier DESC;

-- Drill-down: full supplier list with assigned tier
-- SELECT * FROM tiered ORDER BY composite_risk_score ASC;
