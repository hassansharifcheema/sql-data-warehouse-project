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
	
