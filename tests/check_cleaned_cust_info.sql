-- check for the primary key duplicates 
SELECT 
cst_id,
count(*) as id_count
FROM silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null
-- Check for the unwanted spaces
-- exception : No Results
select 
cst_firstname

from silver.crm_cust_info
 where cst_firstname != TRIM (cst_firstname)

 -- Data Consistency & standerdization
 SELECT DISTINCT cst_gndr 
 from silver.crm_cust_info
 select * from silver.crm_cust_info
