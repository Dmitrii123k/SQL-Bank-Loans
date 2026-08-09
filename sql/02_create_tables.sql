DROP TABLE IF EXISTS loans_raw;

CREATE TABLE loans_raw (
    loan_id TEXT,
    customer_id TEXT,
    loan_status TEXT,
    current_loan_amount TEXT,
    term TEXT,
    credit_score TEXT,
    annual_income TEXT,
    years_in_job TEXT,
    home_ownership TEXT,
    purpose TEXT,
    monthly_debt TEXT,
    years_credit_history TEXT,
    months_since_last_delinquent TEXT,
    number_open_accounts TEXT,
    number_credit_problems TEXT,
    current_credit_balance TEXT,
    max_open_credit TEXT,
    bankruptcies TEXT,
    tax_liens TEXT
);

