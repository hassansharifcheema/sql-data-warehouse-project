-- crate procedure to load and UPDATE data from csv files into bronze tables
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @batch_start_time DATETIME = GETDATE(), @batch_end_time DATETIME;
	BEGIN TRY
		PRINT'==========================================================================';
		PRINT 'Loading data into bronze tables...';
		PRINT'==========================================================================';

		--====================================================================================
		-- INSERTING DATA IN CRM TABLES
		--===================================================================================
		print('_________________________________________________________________________________');
		PRINT 'Loading data into bronze CRM tables...';
		print('_________________________________________________________________________________');
	
		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		from 'D:\sql-data-warehouse-project-1\datasets\source_crm\cust_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			tablock
		);
		--====================================================================================
		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		from 'D:\sql-data-warehouse-project-1\datasets\source_crm\prd_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			tablock
		);
		--======================================================================================
		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		from 'D:\sql-data-warehouse-project-1\datasets\source_crm\sales_details.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			tablock
		);
		--===================================================================================
		-- inserting data in ERP tables
		--===================================================================================
		print('_________________________________________________________________________________');
		PRINT 'Loading data into bronze ERP tables...';
		print('_________________________________________________________________________________');
		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		from 'D:\sql-data-warehouse-project-1\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			tablock
		);
		--===================================================================================
		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		from 'D:\sql-data-warehouse-project-1\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			tablock
		);
		--====================================================================================
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		from 'D:\sql-data-warehouse-project-1\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			tablock
		);
			set @batch_end_time = GETDATE();
			PRINT '>> Batch Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(50)) + ' seconds';
			PRINT '>> -----------------------------------';

	END TRY
	BEGIN CATCH
		PRINT 'Error occurred while loading data into bronze tables.';
		PRINT ERROR_MESSAGE();
		PRINT ERROR_SEVERITY();
		PRINT CAST(ERROR_STATE() AS VARCHAR(50));
		PRINT CAST(ERROR_NUMBER() AS VARCHAR(50));
	END CATCH
END
