--VIEW — риск-сегментация по клиенту (для карточек/фильтров в дашборде)
CREATE OR REPLACE VIEW v_loan_risk_segments AS
SELECT
    loan_id,
    customer_id,
    loan_status,
    current_loan_amount,
    purpose,
    home_ownership,
    credit_score,
    annual_income,
    monthly_debt,
    CASE
        WHEN credit_score >= 750 THEN 'Low Risk'
        WHEN credit_score >= 650 THEN 'Medium Risk'
        WHEN credit_score IS NULL THEN 'Unknown Risk'
        ELSE 'High Risk'
    END AS risk_segment,
    CASE
        WHEN annual_income IS NULL OR annual_income = 0 THEN NULL
        WHEN (monthly_debt * 12) / annual_income < 0.1 THEN '< 10%'
        WHEN (monthly_debt * 12) / annual_income BETWEEN 0.1 AND 0.2 THEN '10-20%'
        WHEN (monthly_debt * 12) / annual_income BETWEEN 0.2 AND 0.35 THEN '20-35%'
        ELSE '> 35%'
    END AS dti_range,
    CASE 
        WHEN annual_income IS NOT NULL 
        THEN NTILE(4) OVER (PARTITION BY (annual_income IS NOT NULL) ORDER BY annual_income) 
        ELSE NULL 
    END AS income_quartile
FROM loans_clean;
--VIEW — сводка портфеля по статусам (для карточек KPI)
CREATE OR REPLACE VIEW v_portfolio_summary AS
SELECT
    loan_status,
    COUNT(*) AS total_loans,
    ROUND(SUM(current_loan_amount), 2) AS total_amount,
    ROUND(AVG(current_loan_amount), 2) AS avg_amount,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    ROUND(AVG(annual_income), 2) AS avg_income
FROM loans_clean
GROUP BY loan_status;
--VIEW — дефолт по сегменту риска (готовый для главного графика)
CREATE OR REPLACE VIEW v_default_by_risk_segment AS
SELECT
    risk_segment,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE loan_status = 'Charged Off') AS defaults,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM v_loan_risk_segments
GROUP BY risk_segment
ORDER BY default_rate_pct DESC;
--VIEW — дефолт по цели кредита и типу жилья (для heatmap/матрицы)
CREATE OR REPLACE VIEW v_default_by_purpose_ownership AS
SELECT
    purpose,
    home_ownership,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
GROUP BY purpose, home_ownership
HAVING COUNT(*) >= 30
ORDER BY default_rate_pct DESC;
--VIEW — дефолт по квартилям дохода
CREATE OR REPLACE VIEW v_default_by_income_quartile AS
SELECT
    income_quartile,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM v_loan_risk_segments
GROUP BY income_quartile
ORDER BY income_quartile;

--Проверка создания представлений
SELECT * FROM v_loan_risk_segments LIMIT 5;
SELECT * FROM v_portfolio_summary;
SELECT * FROM v_default_by_risk_segment;
SELECT * FROM v_default_by_purpose_ownership LIMIT 10;
SELECT * FROM v_default_by_income_quartile;