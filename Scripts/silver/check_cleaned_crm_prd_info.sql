/*
==========================================================================
this script is used to perform data quality checks on
the silver.crm_prd_info table in the data_warehouse database. 
The checks include:
-------------------------------------------------------------------------
*/
-- check for the primary key duplicates 
SELECT 
prd_id,
count(*) as id_count
FROM silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null
-- Check for the unwanted spaces
-- exception : No Results
select prd_cost
from silver.crm_prd_info
 where prd_cost < 0 OR prd_cost IS NULL

 -- Data Consistency & standerdization
 SELECT DISTINCT prd_line
 from silver.crm_prd_info
 select * from silver.crm_prd_info
 -- check for invalid dates orders
 select 
 * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

-- understanding the date validities
SELECT [prd_id]
      ,[prd_key]
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt],
      LEAD(prd_start_dt) OVER (partition by prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
   
  FROM [data_warehouse].[bronze].[crm_prd_info]
  where prd_key in ('AC-HE-HL-U509-R','AC-HE-HL-U509')
