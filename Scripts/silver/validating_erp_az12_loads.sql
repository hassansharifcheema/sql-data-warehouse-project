-- identify Out of range dates 
SELECT DISTINCT 
b_date from silver.erp_cust_az12
where b_date < '1924-01-01' or b_date > GETDATE()
--Data standerdization and consistency
SELECT DISTINCT 
gendr 
FROM silver.erp_cust_az12

select * from silver.erp_cust_az12
