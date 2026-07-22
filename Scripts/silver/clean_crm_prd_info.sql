/*
=============================================================================================
this script is used to load the silver layer of the data warehouse for the crm_prd_info table.
=============================================================================================
purpose:
	purpose of this script is to transform and load the data
	from the bronze layer to the silver layer for the crm_prd_info table.
	The transformation includes:
	1. Extracting the category id from the product key.
	2. Extracting the prd_key as saperation from the product key.
	3. Handling null values for prd_cost by replacing them with 0.
	4. Mapping the prd_line values to their corresponding full names.
	5. Calculating the prd_end_dt based on the next prd_start_dt for the same prd_key.
	-----------------------------------------------------------------------------------
	warning: 
		this script assumes that the data in the bronze layer is clean and does not contain
		any duplicates or invalid values. If there are any issues with the data,
		it may cause errors or unexpected results in the silver layer.
=============================================================================================
*/

INSERT INTO silver.crm_prd_info(
prd_id ,
cat_id,
prd_key ,
prd_nm ,
prd_cost ,
prd_line ,
prd_start_dt,
prd_end_dt 
)

SELECT  
prd_id,
prd_key,
REPLACE(substring(prd_key,1,5), '-', '_') as cat_id,
SUBSTRING (prd_key,7,LEN(prd_key)) as prd_key,
ISNULL( prd_cost, 0) as prd_cost,
CASE UPPER(TRIM(prd_line))
	WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'T' THEN 'Touriing'
	WHEN 'S' THEN 'Other sales'
	ELSE 'N/A'
END as prd_line,
CAST(prd_start_dt AS DATE) as prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (partition by prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM data_warehouse.bronze.crm_prd_info
