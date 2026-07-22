/*
=========================================================================
this script is used to load data from bronze.erp_loc_a101 to silver.erp_loc_a101
=========================================================================
Purpose:
	it handle invalid values and empty strings
	then we have performed standerdication and removed emptry strings and invalid values
*/
INSERT INTO silver.erp_loc_a101 
(cid, cntry)
select 
REPLACE(cid, '-', '') as cid,
case when TRIM(cntry) = 'DE' THEN 'Germany'
	 when TRIM(cntry) IN ('US' , 'USA') THEN 'United States'
	 when TRIM(cntry)= '' OR cntry IS NULL THEN 'N/A'
	 else TRIM(cntry)
end as cntry
from bronze.erp_loc_a101
