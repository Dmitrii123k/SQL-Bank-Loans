-- ============================================
-- ИТОГОВЫЕ АНАЛИТИЧЕСКИЕ ЗАПРОСЫ ПРОЕКТА
-- ============================================

-- 1. Обзор кредитного портфеля
SELECT loan_status, COUNT(*) AS total_loans, 
       ROUND(SUM(current_loan_amount),2) AS total_amount,
       ROUND(AVG(credit_score),0) AS avg_credit_score
FROM loans_clean GROUP BY loan_status;

-- 2. Топ фактор риска: Credit Score vs Default Rate
SELECT * FROM v_default_by_risk_segment ORDER BY default_rate_pct DESC;

-- 3. Риск по комбинации цели кредита и типа жилья (топ-5 самых рискованных)
SELECT * FROM v_default_by_purpose_ownership ORDER BY default_rate_pct DESC LIMIT 5;

-- 4. Риск по квартилям дохода
SELECT * FROM v_default_by_income_quartile ORDER BY income_quartile;

-- 5. Сводка портфеля по статусам
SELECT * FROM v_portfolio_summary;