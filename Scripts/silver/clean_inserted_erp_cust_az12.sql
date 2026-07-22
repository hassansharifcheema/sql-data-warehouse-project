/*
=============================================================================================
This script is used to load data from the bronze layer to the silver layer in the data warehouse
in the erp. table.
---------------------------------------------------------------------------------------------
Purpose:
	1. first with the id we have handeld invalid values 
	2. then we have handled invalid date values
	3. we have performed gender standardization to Male,
	female and n/a for invalid values.
	==============================================================================================
*/
insert into silver.erp_cust_az12
(cid, b_date, gendr)
select 
CASE 
	when cid LIKE 'nas%' then SUBSTRING(cid,4,len(cid))
	else cid
END as cid,
CASE WHEN b_date > GETDATE() THEN NULL
	ELSE b_date
END as b_date,
case when  UPPER (TRIM(gendr)) IN ('M','MALE') THEN 'Male'
	WHEN UPPER (TRIM(gendr)) IN ('F','FEMALE') THEN 'Female'
	ELSE 'n/a'
END as gendr
from bronze.erp_cust_az12
