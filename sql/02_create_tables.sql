DROP TABLE IF EXISTS loans;
CREATE TABLE loans (
    loan_id TEXT,
    customer_id TEXT,
    loan_status TEXT,
    current_loan_amount NUMERIC,
    term TEXT,
    credit_score NUMERIC,
    annual_income NUMERIC,
    years_in_job TEXT,
    home_ownership TEXT,
    purpose TEXT,
    monthly_debt NUMERIC,
    years_credit_history NUMERIC,
    months_since_last_delinquent NUMERIC,
    number_open_accounts NUMERIC,
    number_credit_problems NUMERIC,
    current_credit_balance NUMERIC,
    max_open_credit NUMERIC,
    bankruptcies NUMERIC,
    tax_liens NUMERIC
);