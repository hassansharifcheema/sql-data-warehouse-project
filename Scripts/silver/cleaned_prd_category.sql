/*
===================================================================================================
this script is used to load data from bronze layer to silver layer for the table erp_px_cat_g1v2
====================================================================================================

*/
INSERT INTO 
silver.erp_px_cat_g1v2
(id,cat,subcat,maintanace)
Select
id,
cat,
subcat,
maintanace
from bronze.erp_px_cat_g1v2


-- check for unwanted spaces 
select * from bronze.erp_px_cat_g1v2
where maintanace != trim(maintanace)
--data standerdization and consistency check
Select distinct 
maintanace
from bronze.erp_px_cat_g1v2

