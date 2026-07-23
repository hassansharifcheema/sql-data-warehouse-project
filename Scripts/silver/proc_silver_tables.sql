/*
====================================================================================================
This scipt as a whole creates a stored procedure to load data in silver tables from bronze tables 
every time you will run it it will updates 
----------------------------------------------------------------------------------------------------
prcedure: 
	1. truncate the silver tables 
	2. load fresh data after cleaning and standerdizing it according to need and quality of data 
Parameters:
		NONE
Usage :
		exec silver.load_silver
====================================================================================================
*/
create or alter procedure silver.load_silver AS
	BEGIN
		declare @starttime datetime, @endtime datetime,@batch_start_time datetime,@batch_end_time datetime
	begin try
	set @batch_start_time = GETDATE()
			set @starttime = GETDATE()
			/* 
			============================================================================
			Clean and transform the data from bronze.crm_cust_info to silver.crm_cust_info
			=============================================================================
			Purpose: This script is designed to clean and transform the data from the bronze.crm_cust_info
			table and insert it into the silver.crm_cust_info table.
			--------------------------------------------------------------------------------------------
			Warning :
					This script is designed to be run in a SQL Server environment.
			It assumes that the source table bronze.crm_cust_info exists and contains the necessary data. 
			The script will create the target table silver.crm_cust_info if it does not already exist,
			and then insert cleaned and transformed data into it.
			--------------------------------------------------------------------------------------------
			*/
			print'>-----------------------------------------------------------------------------------------------------'
			PRINT'>> TRUNCATE TABLE: silver.crm_cust_info'
			print'>-----------------------------------------------------------------------------------------------------'
			truncate table silver.crm_cust_info
			print'>-----------------------------------------------------------------------------------------------------'
			print'>> INSERTING INTO TABLE: silver.crm_cust_info'
			print'>-----------------------------------------------------------------------------------------------------'
			INSERT INTO silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date
			)
	

			select
			cst_id,
			cst_key,
			TRIM(cst_firstname) as cst_firstname,
			TRIM(cst_lastname) as cst_lastname,
			CASE
				WHEN upper(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN upper(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'N/A'
			END as cst_marital_status,
			CASE
				WHEN upper(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN upper(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'N/A'
			END as cst_gndr,
			cst_create_date

			from (
			select 
			* ,
			ROW_NUMBER () over (PARTITION BY cst_id ORDER BY cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			  WHERE cst_id IS NOT NULL 
			)t 
			where flag_last = 1 
		set @endtime = GETDATE()
		print '>>-----------------------'
		PRINT'>> Loead Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS VARCHAR(10)) + ' seconds'
			print'============================================================================================================='
			PRINT'>> Data has been successfully cleaned and transformed from bronze.crm_cust_info to silver.crm_cust_info'
			print'============================================================================================================='

			/*=============================================================================================
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
	set @starttime = GETDATE()
		print'>-----------------------------------------------------------------------------------------------------'
		PRINT'>> TRUNCATE TABLE: silver.crm_prd_info'
		print'>-----------------------------------------------------------------------------------------------------'
			truncate table silver.crm_prd_info
		print'>-----------------------------------------------------------------------------------------------------'
		print'>> INSERTING INTO TABLE: silver.crm_prd_info'
		print'>-----------------------------------------------------------------------------------------------------'
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
	set @endtime = GETDATE()
	print '>>-----------------------'
		PRINT'>> Loead Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS VARCHAR(10)) + ' seconds'
		print'============================================================================================================='
		PRINT'>> Data has been successfully transformed and loaded from bronze.crm_prd_info to silver.crm_prd_info'
		print'============================================================================================================='

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

	set @starttime = GETDATE()
		print'>-----------------------------------------------------------------------------------------------------'
		PRINT'>> TRUNCATE TABLE: silver.crm_sales_details'
		print'>-----------------------------------------------------------------------------------------------------'
			truncate table silver.crm_sales_details
		print'>-----------------------------------------------------------------------------------------------------'
		print'>> INSERTING INTO TABLE: silver.crm_sales_details'
		print'>-----------------------------------------------------------------------------------------------------'
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
		set @endtime = GETDATE()
		print '>>-----------------------'
		PRINT'>> Loead Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS VARCHAR(10)) + ' seconds'
		 print'============================================================================================================='
		 PRINT'>> Data has been successfully transformed and loaded from bronze.crm_sales_details to silver.crm_sales_details'
		 print'============================================================================================================='

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
		set @starttime = GETDATE()
		print'>-----------------------------------------------------------------------------------------------------'
		PRINT'>> TRUNCATE TABLE: silver.erp_cust_az12'
		print'>-----------------------------------------------------------------------------------------------------'
			truncate table silver.erp_cust_az12
		print'>-----------------------------------------------------------------------------------------------------'
		print'>> INSERTING INTO TABLE: silver.erp_cust_az12'
		print'>-----------------------------------------------------------------------------------------------------'
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
	set @endtime = GETDATE()
	print '>>-----------------------'
		PRINT'>> Loead Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS VARCHAR(10)) + ' seconds'
		print'============================================================================================================='
		PRINT '>> Data has been successfully transformed and loaded from bronze.erp_cust_az12 to silver.erp_cust_az12'
		print'============================================================================================================='

		/*
		=========================================================================
		this script is used to load data from bronze.erp_loc_a101 to silver.erp_loc_a101
		=========================================================================
		Purpose:
			it handle invalid values and empty strings
			then we have performed standerdication and removed emptry strings and invalid values
		*/
	set @starttime = GETDATE()
		print'>-----------------------------------------------------------------------------------------------------'
		PRINT'>> TRUNCATE TABLE: silver.erp_loc_a101'
		print'>-----------------------------------------------------------------------------------------------------'
			truncate table silver.erp_loc_a101
		print'>-----------------------------------------------------------------------------------------------------'
		print'>> INSERTING INTO TABLE: silver.erp_loc_a101'
		print'>-----------------------------------------------------------------------------------------------------'
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
	set @endtime = GETDATE()
	print '>>-----------------------'
		PRINT'>> Loead Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS VARCHAR(10)) + ' seconds'
		print'============================================================================================================='
		PRINT '>> Data has been successfully transformed and loaded from bronze.erp_loc_a101 to silver.erp_loc_a101'
		print'============================================================================================================='


		/*
		===================================================================================================
		this script is used to load data from bronze layer to silver layer for the table erp_px_cat_g1v2
		====================================================================================================

		*/
	set @starttime = GETDATE()
		print'>-----------------------------------------------------------------------------------------------------'
		PRINT'>> TRUNCATE TABLE: silver.erp_px_cat_g1v2'
		print'>-----------------------------------------------------------------------------------------------------'
			truncate table silver.erp_px_cat_g1v2
		print'>-----------------------------------------------------------------------------------------------------'
		print'>> INSERTING INTO TABLE: silver.erp_px_cat_g1v2'
		print'>-----------------------------------------------------------------------------------------------------'
		INSERT INTO 
		silver.erp_px_cat_g1v2
		(id,cat,subcat,maintanace)
		Select
		id,
		cat,
		subcat,
		maintanace
		from bronze.erp_px_cat_g1v2
		print'============================================================================================================='
		PRINT '>> Data has been successfully transformed and loaded from bronze.erp_px_cat_g1v2 to silver.erp_px_cat_g1v2'
		print'============================================================================================================='
	set @endtime = GETDATE()
	print '>>-----------------------'
		PRINT'>> Loead Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS VARCHAR(10)) + ' seconds'
	SET @batch_end_time = GETDATE()
	print '>>-----------------------'
		PRINT'>> Batch End Time: ' + CAST(@batch_end_time AS VARCHAR(30))
	end try
	begin catch
		print'============================================================================================================='
		PRINT '>> Error occurred while loading data:' 
		print '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10))
		print '>> Error message: ' + CAST(ERROR_MESSAGE() AS VARCHAR(255))
		print '>> Error State: ' + CAST(ERROR_State() AS VARCHAR(10))
		print'============================================================================================================='
	end catch
END;
