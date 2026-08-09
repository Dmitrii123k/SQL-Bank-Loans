--Ранжирование клиентов по сумме кредита внутри каждой цели (Purpose)
SELECT
    loan_id,
    purpose,
    current_loan_amount,
    RANK() OVER (PARTITION BY purpose ORDER BY current_loan_amount DESC) AS rank_within_purpose
FROM loans_clean
ORDER BY purpose, rank_within_purpose
LIMIT 30;
--NTILE — разбивка клиентов на 4 квартиля по доходу
SELECT
    loan_id,
    annual_income,
    loan_status,
    NTILE(4) OVER (ORDER BY annual_income) AS income_quartile
FROM loans_clean
WHERE annual_income IS NOT NULL
ORDER BY annual_income
LIMIT 20;
--Дефолт по квартилям дохода (используем NTILE через подзапрос)
SELECT
    income_quartile,
    COUNT(*) AS total_loans,
    ROUND(100.0 * COUNT(*) FILTER (WHERE loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate_pct
FROM (
    SELECT
        loan_status,
        NTILE(4) OVER (ORDER BY annual_income) AS income_quartile
    FROM loans_clean
    WHERE annual_income IS NOT NULL
) sub
GROUP BY income_quartile
ORDER BY income_quartile;
--Накопительная сумма портфеля по датам (если понадобится динамика) — альтернатива: по сумме кредита
SELECT
    loan_id,
    current_loan_amount,
    SUM(current_loan_amount) OVER (ORDER BY current_loan_amount DESC) AS running_total,
    ROUND(100.0 * SUM(current_loan_amount) OVER (ORDER BY current_loan_amount DESC) / SUM(current_loan_amount) OVER (), 2) AS running_pct_of_portfolio
FROM loans_clean
ORDER BY current_loan_amount DESC
LIMIT 20;
--Сравнение каждого клиента со средним по его сегменту риска (оконная функция без агрегации GROUP BY)
SELECT
    loan_id,
    credit_score,
    current_loan_amount,
    CASE
        WHEN credit_score >= 750 THEN 'Low Risk'
        WHEN credit_score >= 650 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_segment,
    ROUND(AVG(current_loan_amount) OVER (
        PARTITION BY 
            CASE
                WHEN credit_score >= 750 THEN 'Low Risk'
                WHEN credit_score >= 650 THEN 'Medium Risk'
                ELSE 'High Risk'
            END
    ), 2) AS avg_amount_in_segment,
    ROUND(current_loan_amount - AVG(current_loan_amount) OVER (
        PARTITION BY 
            CASE
                WHEN credit_score >= 750 THEN 'Low Risk'
                WHEN credit_score >= 650 THEN 'Medium Risk'
                ELSE 'High Risk'
            END
    ), 2) AS diff_from_segment_avg
FROM loans_clean
WHERE credit_score IS NOT NULL
ORDER BY diff_from_segment_avg DESC
LIMIT 20;