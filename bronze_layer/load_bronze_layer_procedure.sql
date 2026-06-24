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
				TRUNCATE TABLE cust_info;  -- empty table first, otherwise each time we run, it will be loaded again 
				
				PRINT '>> Inserting data into: cust_info';
				BULK INSERT cust_info FROM "/Users/mohanwang/Documents/Summer2026/data_engineer/sql-data-warehouse-project/datasets/source_crm/cust_info.csv" -- insert table from local csv file 
				WITH (
				
				FIRSTROW = 2, -- skip the first row (header) 
				
				FIELDTERMINATOR = ',', -- specify the deliminator type 
				
				TABLOCK -- lock the entire table while loading data 
				
				);
				SET @end_time = GETDATE();
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				
				SET @batch_start_time = GETDATE();
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