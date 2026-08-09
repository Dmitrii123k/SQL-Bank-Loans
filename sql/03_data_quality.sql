--Общее количество записей
SELECT COUNT(*) AS total_rows FROM loans;
--Проверка пропусков (NULL) по ключевым колонкам
SELECT
    COUNT(*) FILTER (WHERE loan_id IS NULL) AS missing_loan_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE loan_status IS NULL) AS missing_loan_status,
    COUNT(*) FILTER (WHERE credit_score IS NULL) AS missing_credit_score,
    COUNT(*) FILTER (WHERE annual_income IS NULL) AS missing_annual_income
FROM loans;
--Проверка дубликатов по Loan ID
SELECT loan_id, COUNT(*) AS duplicate_count
FROM loans
GROUP BY loan_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
--Проверка аномалий в Credit Score
SELECT MIN(credit_score) AS min_score, MAX(credit_score) AS max_score, AVG(credit_score) AS avg_score
FROM loans;
--Проверка уникальных значений категориальных полей
SELECT DISTINCT loan_status FROM loans;
SELECT DISTINCT home_ownership FROM loans;
SELECT DISTINCT purpose FROM loans;
--точно ли пропуски credit_score и annual_income совпадают в одних строках
SELECT COUNT(*) 
FROM loans 
WHERE credit_score IS NULL AND annual_income IS NULL;
--что из себя представляют дубли по loan_id
SELECT *
FROM loans
WHERE loan_id = '0ced4c4f-a459-4e69-8c92-fe3de8ac08ec';