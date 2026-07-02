# Power BI — DAX Measures

These measures replicate the SQL scoring logic (`sql/02_risk_score_calculation.sql`) natively in Power BI, so the composite score and tier can be calculated dynamically inside the dashboard (e.g., if a user adjusts a weight via a what-if parameter).

## Base measures

```dax
Defect Rate % =
DIVIDE(
    SUM(supplier_quality_data[defective_units]),
    SUM(supplier_quality_data[total_units_shipped]),
    0
) * 100
```

```dax
Defect Score =
VAR RawScore = 100 - (DIVIDE([Defect Rate %], 5, 0) * 100)
RETURN
MAX(0, MIN(100, RawScore))
```

```dax
Complaint Score =
VAR RawScore =
    100
    - (AVERAGE(supplier_quality_data[complaint_count]) * 4)
    - (AVERAGE(supplier_quality_data[avg_severity_score]) * 8)
    - (AVERAGE(supplier_quality_data[recurrence_flag]) * 15)
RETURN
MAX(0, MIN(100, RawScore))
```

```dax
Delivery Score =
VAR RawScore = DIVIDE(AVERAGE(supplier_quality_data[on_time_delivery_rate]) - 40, 60, 0) * 100
RETURN
MAX(0, MIN(100, RawScore))
```

```dax
Audit Health Score =
VAR RawScore =
    AVERAGE(supplier_quality_data[audit_score])
    - (AVERAGE(supplier_quality_data[critical_findings_last_audit]) * 10)
RETURN
MAX(0, MIN(100, RawScore))
```

```dax
Financial Score =
MAX(0, MIN(100, AVERAGE(supplier_quality_data[financial_stability_score])))
```

## Composite score

```dax
Composite Risk Score =
[Defect Score] * 0.25
+ [Complaint Score] * 0.20
+ [Delivery Score] * 0.15
+ [Audit Health Score] * 0.25
+ [Financial Score] * 0.15
```

## Risk tier (for slicers / conditional formatting)

```dax
Risk Tier =
VAR Score = [Composite Risk Score]
RETURN
SWITCH(
    TRUE(),
    Score >= 85, "Tier 1 - Low Risk",
    Score >= 70, "Tier 2 - Moderate Risk",
    Score >= 50, "Tier 3 - Elevated Risk",
    "Tier 4 - High Risk"
)
```

## Optional: What-if parameter for dynamic weighting

To let a dashboard viewer adjust weights interactively (e.g., a slider for "Audit Health weight"), create What-If Parameters in Power BI (`Modeling → New Parameter`) for each weight, then reference them in `Composite Risk Score` instead of the hardcoded 0.25 / 0.20 / etc. This is a strong "extra credit" feature to demonstrate in an interview — it shows you understand both the scoring logic and how to make it interactive for stakeholders.
