--Общая картина портфеля
SELECT
    COUNT(*) AS total_loans,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(current_loan_amount), 2) AS avg_loan_amount,
    ROUND(SUM(current_loan_amount), 2) AS total_portfolio_amount
FROM loans_clean;
--Распределение по статусу кредита
SELECT
    loan_status,
    COUNT(*) AS loans_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM loans_clean
GROUP BY loan_status
ORDER BY loans_count DESC;
--Топ целей кредита
SELECT
    purpose,
    COUNT(*) AS loans_count,
    ROUND(AVG(current_loan_amount), 2) AS avg_amount
FROM loans_clean
GROUP BY purpose
ORDER BY loans_count DESC;
--Распределение по типу жилья
SELECT
    home_ownership,
    COUNT(*) AS loans_count,
    ROUND(AVG(annual_income), 2) AS avg_income
FROM loans_clean
GROUP BY home_ownership
ORDER BY loans_count DESC;
--Средние показатели по статусу — первый взгляд на риск
SELECT
    loan_status,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    ROUND(AVG(annual_income), 2) AS avg_income,
    ROUND(AVG(monthly_debt), 2) AS avg_monthly_debt
FROM loans_clean
GROUP BY loan_status; 
