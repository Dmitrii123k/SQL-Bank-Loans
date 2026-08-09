--Простой CTE — сегментация клиентов по риску в один проход
WITH risk_segments AS (
    SELECT
        loan_id,
        customer_id,
        credit_score,
        annual_income,
        monthly_debt,
        loan_status,
        CASE
            WHEN credit_score >= 750 THEN 'Low Risk'
            WHEN credit_score >= 650 THEN 'Medium Risk'
            WHEN credit_score IS NULL THEN 'Unknown Risk'
            ELSE 'High Risk'
        END AS risk_segment
    FROM loans_clean
)
SELECT
    risk_segment,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM risk_segments
GROUP BY risk_segment
ORDER BY default_rate_pct DESC;
--CTE с несколькими шагами (цепочка)
WITH avg_income AS (
    SELECT AVG(annual_income) AS overall_avg_income
    FROM loans_clean
    WHERE annual_income IS NOT NULL
),
income_comparison AS (
    SELECT
        l.loan_id,
        l.loan_status,
        CASE
            WHEN l.annual_income > a.overall_avg_income THEN 'Above Average'
            ELSE 'Below Average'
        END AS income_group
    FROM loans_clean l
    CROSS JOIN avg_income a
    WHERE l.annual_income IS NOT NULL
)
SELECT
    income_group,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM income_comparison
GROUP BY income_group;
--CTE для многошаговой агрегации — риск по комбинации факторов
WITH scored_loans AS (
    SELECT
        loan_id,
        loan_status,
        home_ownership,
        CASE
            WHEN credit_score >= 700 THEN 'High Score'
            ELSE 'Low Score'
        END AS score_group
    FROM loans_clean
    WHERE credit_score IS NOT NULL
),
grouped_risk AS (
    SELECT
        home_ownership,
        score_group,
        COUNT(*) AS total_loans,
        COUNT(*) FILTER (WHERE loan_status = 'Charged Off') AS defaults
    FROM scored_loans
    GROUP BY home_ownership, score_group
)
SELECT
    home_ownership,
    score_group,
    total_loans,
    defaults,
    ROUND(100.0 * defaults / total_loans, 2) AS default_rate_pct
FROM grouped_risk
ORDER BY home_ownership, score_group;
