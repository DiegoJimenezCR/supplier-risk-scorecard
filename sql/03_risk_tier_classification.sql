-- ============================================================
-- 03_risk_tier_classification.sql
-- Supplier Risk Scorecard | Risk Tier Assignment
-- ============================================================
-- Converts the composite_risk_score (from 02_risk_score_calculation.sql)
-- into a categorical risk tier, similar in spirit to a credit
-- rating band -- easier for stakeholders to act on than a raw number.
--
-- Tested against SQL Server (T-SQL syntax).
-- ============================================================

DROP VIEW IF EXISTS vw_supplier_risk_tiers;
GO

CREATE VIEW vw_supplier_risk_tiers AS
SELECT
    supplier_id,
    supplier_name,
    country,
    category,
    composite_risk_score,
    CASE
        WHEN composite_risk_score >= 85 THEN 'Tier 1 - Low Risk'
        WHEN composite_risk_score >= 70 THEN 'Tier 2 - Moderate Risk'
        WHEN composite_risk_score >= 50 THEN 'Tier 3 - Elevated Risk'
        ELSE 'Tier 4 - High Risk'
    END AS risk_tier
FROM supplier_risk_scores;
GO

-- Summary: supplier count and average score per tier
SELECT
    risk_tier,
    COUNT(*) AS supplier_count,
    ROUND(AVG(composite_risk_score), 1) AS avg_score_in_tier
FROM vw_supplier_risk_tiers
GROUP BY risk_tier
ORDER BY avg_score_in_tier DESC;

-- Drill-down: full supplier list with assigned tier
-- SELECT * FROM vw_supplier_risk_tiers ORDER BY composite_risk_score ASC;
