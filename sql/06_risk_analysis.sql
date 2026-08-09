--Дефолт по диапазонам кредитного скоринга
SELECT
    CASE
        WHEN credit_score < 600 THEN '< 600 (Poor)'
        WHEN credit_score BETWEEN 600 AND 649 THEN '600-649 (Fair)'
        WHEN credit_score BETWEEN 650 AND 699 THEN '650-699 (Good)'
        WHEN credit_score BETWEEN 700 AND 749 THEN '700-749 (Very Good)'
        WHEN credit_score >= 750 THEN '750+ (Excellent)'
        ELSE 'Unknown'
    END AS score_range,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE loan_status = 'Charged Off') AS defaults,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
GROUP BY score_range
ORDER BY MIN(credit_score);
--Дефолт по уровню долговой нагрузки (Debt-to-Income)
SELECT
    CASE
        WHEN (monthly_debt * 12) / NULLIF(annual_income, 0) < 0.1 THEN '< 10%'
        WHEN (monthly_debt * 12) / NULLIF(annual_income, 0) BETWEEN 0.1 AND 0.2 THEN '10-20%'
        WHEN (monthly_debt * 12) / NULLIF(annual_income, 0) BETWEEN 0.2 AND 0.35 THEN '20-35%'
        ELSE '> 35%'
    END AS dti_range,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
WHERE annual_income IS NOT NULL AND annual_income > 0
GROUP BY dti_range
ORDER BY dti_range;
--Влияние истории просрочек
SELECT
    CASE
        WHEN months_since_last_delinquent IS NULL THEN 'Never delinquent'
        ELSE 'Had delinquency before'
    END AS delinquency_history,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
GROUP BY delinquency_history;
--Влияние стажа работы
SELECT
    years_in_job,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
GROUP BY years_in_job
ORDER BY total_loans DESC;
--Влияние типа жилья на риск
SELECT
    home_ownership,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
GROUP BY home_ownership
ORDER BY default_rate_pct DESC;