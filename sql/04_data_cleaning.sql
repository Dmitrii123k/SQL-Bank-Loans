CREATE OR REPLACE VIEW loans_clean AS
SELECT DISTINCT ON (loan_id)
    loan_id,
    customer_id,
    TRIM(loan_status) AS loan_status,
    current_loan_amount,
    term,
    CASE
        WHEN credit_score > 850 THEN ROUND(credit_score / 10)
        ELSE credit_score
    END AS credit_score,
    annual_income,
    years_in_job,
    CASE 
        WHEN TRIM(home_ownership) = 'HaveMortgage' THEN 'Home Mortgage'
        ELSE INITCAP(TRIM(home_ownership))
    END AS home_ownership,
    INITCAP(TRIM(purpose)) AS purpose,
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
  AND (current_loan_amount IS NULL OR current_loan_amount < 99999999)
ORDER BY loan_id, credit_score DESC NULLS LAST;