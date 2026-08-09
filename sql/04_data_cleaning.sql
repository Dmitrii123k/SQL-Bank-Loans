CREATE OR REPLACE VIEW loans_clean AS
SELECT DISTINCT ON (loan_id)
    loan_id,
    customer_id,
    TRIM(loan_status) AS loan_status,
    current_loan_amount,
    term,
    -- Исправляем аномалию: значения credit_score > 850 записаны с лишним нулём
    CASE
        WHEN credit_score > 850 THEN ROUND(credit_score / 10)
        ELSE credit_score
    END AS credit_score,
    annual_income,
    years_in_job,
    TRIM(home_ownership) AS home_ownership,
    TRIM(purpose) AS purpose,
    monthly_debt,
    years_credit_history,
    months_since_last_delinquent,
    number_open_accounts,
    number_credit_problems,
    current_credit_balance,
    max_open_credit,
    bankruptcies,
    tax_liens
FROM loans
WHERE loan_id IS NOT NULL
  AND loan_id <> ''
  AND customer_id IS NOT NULL
ORDER BY loan_id, credit_score DESC NULLS LAST;


