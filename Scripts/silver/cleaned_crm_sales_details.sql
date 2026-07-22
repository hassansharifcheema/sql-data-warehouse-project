/*
===================================================================================================
this script is used to load data from the bronze layer to the silver layer in a data warehouse. 
It performs data transformations and quality checks before inserting the data into the silver layer tables.
----------------------------------------------------------------------------------------------------------
Purpose:
    1. Load data from the bronze layer to the silver layer.
    2. Perform data transformations and quality checks on the data.
    3. Insert the transformed data into the silver layer tables.
    4. Ensure data integrity and consistency between the bronze and silver layers.
    5. applies business rules to the data before loading it into the silver layer.
    =======================================================================================================
*/
INSERT INTO silver.crm_sales_details(
sls_ord_num ,
	sls_prd_key ,
	sls_cust_id	,
	sls_order_dt ,
	sls_ship_dt ,
	sls_due_dt ,
	sls_sales ,
	sls_quantity ,
	sls_price 
)
SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id],
      
      CASE WHEN [sls_order_dt] =0 OR LEN([sls_order_dt]) != 8 THEN NULL
           ELSE cast(cast(sls_order_dt AS varchar) AS date)
      END AS [sls_order_dt],
       CASE WHEN [sls_ship_dt] =0 OR LEN([sls_ship_dt]) != 8 THEN NULL
           ELSE cast(cast(sls_ship_dt AS varchar) AS date)
      END AS [sls_ship_dt],
       CASE WHEN [sls_due_dt] =0 OR LEN([sls_due_dt]) != 8 THEN NULL
           ELSE cast(cast(sls_due_dt AS varchar) AS date)
      END AS [sls_due_dt],
      case 
	when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	else sls_sales
    END as sls_sales,
       [sls_quantity],
    CASE 
	    when sls_price is null or sls_price <=0 
		    THEN sls_sales / NULLIF(sls_quantity, 0)
	    else sls_price
    END as sls_price
 FROM [bronze].[crm_sales_details]
