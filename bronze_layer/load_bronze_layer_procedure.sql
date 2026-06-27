/* =================================
Procedure to Load Bronze Layer (Source -> Bronze)
==================================== 
Purpose: 
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
		-- declare variables to helps to identity bottlenecks, optimize performance, monitor trends, detect issues 
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
		
		-- Ensures error handling, data integrity, and issue logging for easier debugging 
		BEGIN TRY
				SET @batch_start_time = GETDATE();
				-- Add Prints to track execution, debug issues, and understand its flow 
				PRINT '=======================================';
				PRINT 'Loading Bronze Layer';
				PRINT '=======================================';
				
				PRINT '---------------------------------------';
				PRINT 'Loading crm cust_info Tables';
				PRINT '---------------------------------------';
				
				SET @start_time = GETDATE();
				PRINT '>> Truncating table: cust_info';
				TRUNCATE TABLE bronze.crm_cust_info;  -- empty table first, otherwise each time we run, it will be loaded again 
				
				PRINT '>> Inserting data into: cust_info';
				BULK INSERT bronze.crm_cust_info FROM "/var/opt/mssql/datasets/source_crm/cust_info.csv" -- insert table from local csv file 
				WITH (
				
				FIRSTROW = 2, -- skip the first row (header) 
				
				FIELDTERMINATOR = ',', -- specify the deliminator type 
				
				TABLOCK -- lock the entire table while loading data 
				
				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

				PRINT '---------------------------------------';
				PRINT 'Loading crm prd_info Tables';
				PRINT '---------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating table: prd_info';
				TRUNCATE TABLE bronze.crm_prd_info;

				PRINT '>> Inserting data into: prd_info';
				BULK INSERT bronze.crm_prd_info FROM "/var/opt/mssql/datasets/source_crm/prd_info.csv"
				WITH (

				FIRSTROW = 2,

				FIELDTERMINATOR = ',',

				TABLOCK

				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

				PRINT '---------------------------------------';
				PRINT 'Loading crm sales_details Tables';
				PRINT '---------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating table: sales_details';
				TRUNCATE TABLE bronze.crm_sales_details;

				PRINT '>> Inserting data into: sales_details';
				BULK INSERT bronze.crm_sales_details FROM "/var/opt/mssql/datasets/source_crm/sales_details.csv"
				WITH (

				FIRSTROW = 2,

				FIELDTERMINATOR = ',',

				TABLOCK

				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

				PRINT '---------------------------------------';
				PRINT 'Loading erp CUST_AZ12 Tables';
				PRINT '---------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating table: erp_cust_az12';
				TRUNCATE TABLE bronze.erp_cust_az12;

				PRINT '>> Inserting data into: erp_cust_az12';
				BULK INSERT bronze.erp_cust_az12 FROM "/var/opt/mssql/datasets/source_erp/CUST_AZ12.csv"
				WITH (

				FIRSTROW = 2,

				FIELDTERMINATOR = ',',

				TABLOCK

				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

				PRINT '---------------------------------------';
				PRINT 'Loading erp LOC_A101 Tables';
				PRINT '---------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating table: erp_loc_a101';
				TRUNCATE TABLE bronze.erp_loc_a101;

				PRINT '>> Inserting data into: erp_loc_a101';
				BULK INSERT bronze.erp_loc_a101 FROM "/var/opt/mssql/datasets/source_erp/LOC_A101.csv"
				WITH (

				FIRSTROW = 2,

				FIELDTERMINATOR = ',',

				TABLOCK

				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

				PRINT '---------------------------------------';
				PRINT 'Loading erp PX_CAT_G1V2 Tables';
				PRINT '---------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating table: erp_px_cat_g1v2';
				TRUNCATE TABLE bronze.erp_px_cat_g1v2;

				PRINT '>> Inserting data into: erp_px_cat_g1v2';
				BULK INSERT bronze.erp_px_cat_g1v2 FROM "/var/opt/mssql/datasets/source_erp/PX_CAT_G1V2.csv"
				WITH (

				FIRSTROW = 2,

				FIELDTERMINATOR = ',',

				TABLOCK

				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

				PRINT '=======================================';
				PRINT 'Loading Bronze Layer is Completed';
				PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
				PRINT '=======================================';
		END TRY
		
		-- Ensures error handling, data integrity, and issue logging for easier debugging 
		BEGIN CATCH 
				PRINT '=======================================';
				PRINT 'ERRO OCCURED DURING LOADING BRONZE LAYER';
				PRINT 'Error Message' + ERROR_MESSAGE();
				PRINT 'ERROR Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT 'ERROR Message' + CAST(ERROR_STATE() AS NVARCHAR);
				PRINT '=======================================';
		END CATCH
END

EXEC bronze.load_bronze;