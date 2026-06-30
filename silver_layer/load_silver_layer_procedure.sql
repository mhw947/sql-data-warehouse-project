/* =================================
Procedure to Load Silver Layer (Bronze -> Silver)
====================================
Purpose:
    This stored procedure loads cleansed and standardized data into the 'silver' schema
    from the 'bronze' schema. Each table is checked for NULLs in primary keys,
    duplicate primary keys, and unwanted spaces before loading.
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

        BEGIN TRY
                SET @batch_start_time = GETDATE();
                PRINT '=======================================';
                PRINT 'Loading Silver Layer';
                PRINT '=======================================';

                -- ============================================================
                -- CRM Tables
                -- ============================================================

                PRINT '---------------------------------------';
                PRINT 'Loading silver.crm_cust_info';
                PRINT '---------------------------------------';

                SET @start_time = GETDATE();

                /*
                PRINT '>> [Check] NULLs in primary key: cst_id';
                IF EXISTS (SELECT 1 FROM bronze.crm_cust_info WHERE cst_id IS NULL)
                        BEGIN
                        PRINT 'WARNING: NULL values found in cst_id';
                        SELECT TOP(10) * FROM bronze.crm_cust_info WHERE cst_id IS NULL;
                        END
                ELSE
                        PRINT 'PASSED: No NULLs in cst_id';

                PRINT '>> [Check] Duplicates in primary key: cst_id';
                IF EXISTS (
                        SELECT cst_id FROM bronze.crm_cust_info
                        GROUP BY cst_id HAVING COUNT(*) > 1
                )
                        BEGIN
                        PRINT 'WARNING: Duplicate values found in cst_id';
                        SELECT TOP(10) cst_id, COUNT(*) AS duplicate_count
                        FROM bronze.crm_cust_info
                        GROUP BY cst_id
                        HAVING COUNT(*) > 1;
                        END
                ELSE
                        PRINT 'PASSED: No duplicates in cst_id';

                PRINT '>> [Check] Unwanted spaces in string columns';
                IF EXISTS (
                        SELECT 1 FROM bronze.crm_cust_info
                        WHERE cst_key       != TRIM(cst_key)
                           OR cst_firstname != TRIM(cst_firstname)
                           OR cst_lastname  != TRIM(cst_lastname)
                )
                        BEGIN
                        PRINT 'WARNING: Unwanted spaces found in cst_key / cst_firstname / cst_lastname';
                        SELECT TOP(10) * FROM bronze.crm_cust_info
                        WHERE cst_key       != TRIM(cst_key)
                           OR cst_firstname != TRIM(cst_firstname)
                           OR cst_lastname  != TRIM(cst_lastname);
                        END
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';

                PRINT '>> [Check] Distinct values in cst_gndr (bronze)';
                SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info;
                PRINT '>> [Check] Distinct values in cst_marital_status (bronze)';
                SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info;
                */

                PRINT '>> Truncating table: silver.crm_cust_info';
                TRUNCATE TABLE silver.crm_cust_info;

                PRINT '>> Inserting data into: silver.crm_cust_info';
                INSERT INTO silver.crm_cust_info (
                        cst_id,
                        cst_key,
                        cst_firstname,
                        cst_lastname,
                        cst_marital_status,
                        cst_gndr,
                        cst_create_date
                )
                SELECT
                        cst_id,
                        TRIM(cst_key)                   AS cst_key,
                        TRIM(cst_firstname)             AS cst_firstname,
                        TRIM(cst_lastname)              AS cst_lastname,
                        CASE UPPER(TRIM(cst_marital_status))
                                WHEN 'M' THEN 'Married'
                                WHEN 'S' THEN 'Single'
                                ELSE 'n/a'
                        END                             AS cst_marital_status,
                        CASE UPPER(TRIM(cst_gndr))
                                WHEN 'M' THEN 'Male'
                                WHEN 'F' THEN 'Female'
                                ELSE 'n/a'
                        END                             AS cst_gndr,
                        cst_create_date
                FROM (
                        SELECT *,
                               ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
                        FROM bronze.crm_cust_info
                        WHERE cst_id IS NOT NULL
                ) t
                WHERE rn = 1;

                SET @end_time = GETDATE();
                PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

                /*
                PRINT '>> [Post-Load Check] silver.crm_cust_info';
                IF EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_id IS NULL)
                        PRINT 'ERROR: NULLs still exist in cst_id';
                ELSE
                        PRINT 'PASSED: No NULLs in cst_id';
                IF EXISTS (SELECT cst_id FROM silver.crm_cust_info GROUP BY cst_id HAVING COUNT(*) > 1)
                        PRINT 'ERROR: Duplicates still exist in cst_id';
                ELSE
                        PRINT 'PASSED: No duplicates in cst_id';
                IF EXISTS (
                        SELECT 1 FROM silver.crm_cust_info
                        WHERE cst_key       != TRIM(cst_key)
                           OR cst_firstname != TRIM(cst_firstname)
                           OR cst_lastname  != TRIM(cst_lastname)
                )
                        PRINT 'ERROR: Unwanted spaces still exist in string columns';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';

                PRINT '>> [Post-Load Check] Distinct values in cst_gndr (silver)';
                SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;
                PRINT '>> [Post-Load Check] Distinct values in cst_marital_status (silver)';
                SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
                */

                -- ------------------------------------------------------------

                PRINT '---------------------------------------';
                PRINT 'Loading silver.crm_prd_info';
                PRINT '---------------------------------------';

                SET @start_time = GETDATE();

                /*
                PRINT '>> [Check] NULLs in primary key: prd_id';
                IF EXISTS (SELECT 1 FROM bronze.crm_prd_info WHERE prd_id IS NULL)
                        BEGIN
                        PRINT 'WARNING: NULL values found in prd_id';
                        SELECT TOP(10) * FROM bronze.crm_prd_info WHERE prd_id IS NULL;
                        END
                ELSE
                        PRINT 'PASSED: No NULLs in prd_id';

                PRINT '>> [Check] Duplicates in primary key: prd_id';
                IF EXISTS (
                        SELECT prd_id FROM bronze.crm_prd_info
                        GROUP BY prd_id HAVING COUNT(*) > 1
                )
                        BEGIN
                        PRINT 'WARNING: Duplicate values found in prd_id';
                        SELECT TOP(10) prd_id, COUNT(*) AS duplicate_count
                        FROM bronze.crm_prd_info
                        GROUP BY prd_id
                        HAVING COUNT(*) > 1;
                        END
                ELSE
                        PRINT 'PASSED: No duplicates in prd_id';

                PRINT '>> [Check] Unwanted spaces in string columns';
                IF EXISTS (
                        SELECT 1 FROM bronze.crm_prd_info
                        WHERE prd_key  != TRIM(prd_key)
                           OR prd_nm   != TRIM(prd_nm)
                           OR prd_line != TRIM(prd_line)
                )
                        BEGIN
                        PRINT 'WARNING: Unwanted spaces found in prd_key / prd_nm / prd_line';
                        SELECT TOP(10) * FROM bronze.crm_prd_info
                        WHERE prd_key  != TRIM(prd_key)
                           OR prd_nm   != TRIM(prd_nm)
                           OR prd_line != TRIM(prd_line);
                        END
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';
                */

                PRINT '>> Truncating table: silver.crm_prd_info';
                TRUNCATE TABLE silver.crm_prd_info;

                PRINT '>> Inserting data into: silver.crm_prd_info';
                INSERT INTO silver.crm_prd_info (
                        prd_id,
                        cat_id,
                        prd_key,
                        prd_nm,
                        prd_cost,
                        prd_line,
                        prd_start_dt,
                        prd_end_dt
                )
                SELECT
                        prd_id,
                        -- extract category id from first 5 chars of prd_key (e.g. 'AC-HE-HL-...' -> 'AC_HE')
                        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')    AS cat_id,
                        SUBSTRING(prd_key, 7, LEN(prd_key))            AS prd_key,
                        TRIM(prd_nm)                                    AS prd_nm,
                        ISNULL(prd_cost, 0)                             AS prd_cost,
                        CASE UPPER(TRIM(prd_line))
                                WHEN 'R' THEN 'Road'
                                WHEN 'M' THEN 'Mountain'
                                WHEN 'T' THEN 'Touring'
                                WHEN 'S' THEN 'Other Sales'
                                ELSE 'n/a'
                        END                                             AS prd_line,
                        CAST(prd_start_dt AS DATE)                      AS prd_start_dt,
                        DATEADD(DAY, -1,
                            LEAD(prd_start_dt) OVER (
                                PARTITION BY prd_key
                                ORDER BY prd_start_dt
                        )) AS prd_end_dt
                FROM bronze.crm_prd_info
                WHERE prd_id IS NOT NULL;

                SET @end_time = GETDATE();
                PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

                /*
                PRINT '>> [Post-Load Check] silver.crm_prd_info';
                IF EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_id IS NULL)
                        PRINT 'ERROR: NULLs still exist in prd_id';
                ELSE
                        PRINT 'PASSED: No NULLs in prd_id';
                IF EXISTS (SELECT prd_id FROM silver.crm_prd_info GROUP BY prd_id HAVING COUNT(*) > 1)
                        PRINT 'ERROR: Duplicates still exist in prd_id';
                ELSE
                        PRINT 'PASSED: No duplicates in prd_id';
                IF EXISTS (
                        SELECT 1 FROM silver.crm_prd_info
                        WHERE prd_key  != TRIM(prd_key)
                           OR prd_nm   != TRIM(prd_nm)
                           OR prd_line != TRIM(prd_line)
                )
                        PRINT 'ERROR: Unwanted spaces still exist in string columns';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';
                */

                -- ------------------------------------------------------------

                PRINT '---------------------------------------';
                PRINT 'Loading silver.crm_sales_details';
                PRINT '---------------------------------------';

                SET @start_time = GETDATE();

                /*
                PRINT '>> [Check] NULLs in primary key: sls_ord_num';
                IF EXISTS (SELECT 1 FROM bronze.crm_sales_details WHERE sls_ord_num IS NULL)
                        BEGIN
                        PRINT 'WARNING: NULL values found in sls_ord_num';
                        SELECT TOP(10) * FROM bronze.crm_sales_details WHERE sls_ord_num IS NULL;
                        END
                ELSE
                        PRINT 'PASSED: No NULLs in sls_ord_num';

                PRINT '>> [Check] Duplicates in primary key: sls_ord_num';
                IF EXISTS (
                        SELECT sls_ord_num, sls_prd_key
                            FROM bronze.crm_sales_details
                            GROUP BY sls_ord_num, sls_prd_key
                            HAVING COUNT(*) > 1
                        )
                        BEGIN
                        PRINT 'WARNING: Duplicate values found in sls_ord_num';
                        SELECT *
                        FROM bronze.crm_sales_details
                        WHERE EXISTS (
                            SELECT 1
                            FROM (
                                SELECT sls_ord_num, sls_prd_key
                                FROM bronze.crm_sales_details
                                GROUP BY sls_ord_num, sls_prd_key
                                HAVING COUNT(*) > 1
                            ) AS duplicates
                            WHERE duplicates.sls_ord_num = bronze.crm_sales_details.sls_ord_num
                              AND duplicates.sls_prd_key = bronze.crm_sales_details.sls_prd_key
                        );
                        END
                ELSE
                        PRINT 'PASSED: No duplicates in sls_ord_num';

                PRINT '>> [Check] Invalid input values in sls_sales, sls_quantity, sls_price';
                IF EXISTS (
                        SELECT 1 FROM bronze.crm_sales_details
                        WHERE sls_sales != sls_quantity * sls_price
                                  OR sls_sales IS NULL OR sls_sales <= 0
                )
                        BEGIN
                        PRINT 'WARNING: Invalid values found in sls_sales / sls_quantity / sls_price';
                        SELECT TOP(10) * FROM bronze.crm_sales_details
                        WHERE sls_sales != sls_quantity * sls_price
                                  OR sls_sales IS NULL OR sls_sales <= 0;
                        END
                ELSE
                        PRINT 'PASSED: No invalid input values found in sls_sales, sls_quantity, sls_price';

                PRINT '>> [Check] Invalid sls_order_dt, sls_ship_dt, sls_due_dt values';
                IF EXISTS (
                        SELECT 1 FROM bronze.crm_sales_details
                        WHERE (LEN(CAST(sls_order_dt AS VARCHAR)) != 8 AND sls_order_dt IS NOT NULL)
                           OR (LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 AND sls_ship_dt IS NOT NULL)
                           OR (LEN(CAST(sls_due_dt AS VARCHAR)) != 8 AND sls_due_dt IS NOT NULL)
                )
                        BEGIN
                        PRINT 'WARNING: Invalid date values found in sls_order_dt / sls_ship_dt / sls_due_dt';
                        SELECT TOP(10) * FROM bronze.crm_sales_details
                        WHERE (LEN(CAST(sls_order_dt AS VARCHAR)) != 8 AND sls_order_dt IS NOT NULL)
                           OR (LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 AND sls_ship_dt IS NOT NULL)
                           OR (LEN(CAST(sls_due_dt AS VARCHAR)) != 8 AND sls_due_dt IS NOT NULL);
                        END
                ELSE
                        PRINT 'PASSED: No invalid date values found in sls_order_dt, sls_ship_dt, sls_due_dt';

                PRINT '>> [Check] Unwanted spaces in string columns';
                IF EXISTS (
                        SELECT 1 FROM bronze.crm_sales_details
                        WHERE sls_ord_num != TRIM(sls_ord_num)
                           OR sls_prd_key != TRIM(sls_prd_key)
                )
                        BEGIN
                        PRINT 'WARNING: Unwanted spaces found in sls_ord_num / sls_prd_key';
                        SELECT TOP(10) * FROM bronze.crm_sales_details
                        WHERE sls_ord_num != TRIM(sls_ord_num)
                           OR sls_prd_key != TRIM(sls_prd_key);
                        END
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';
                */

                PRINT '>> Truncating table: silver.crm_sales_details';
                TRUNCATE TABLE silver.crm_sales_details;

                PRINT '>> Inserting data into: silver.crm_sales_details';
                INSERT INTO silver.crm_sales_details (
                        sls_ord_num,
                        sls_prd_key,
                        sls_cust_id,
                        sls_order_dt,
                        sls_ship_dt,
                        sls_due_dt,
                        sls_sales,
                        sls_quantity,
                        sls_price
                )
                SELECT
                        TRIM(sls_ord_num)                               AS sls_ord_num,
                        TRIM(sls_prd_key)                               AS sls_prd_key,
                        sls_cust_id,
                        -- convert YYYYMMDD integer to DATE
                        CASE WHEN LEN(CAST(sls_order_dt AS VARCHAR)) = 8
                             THEN CONVERT(DATE, CAST(sls_order_dt AS VARCHAR), 112)
                             ELSE NULL END                              AS sls_order_dt,
                        CASE WHEN LEN(CAST(sls_ship_dt AS VARCHAR)) = 8
                             THEN CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR), 112)
                             ELSE NULL END                              AS sls_ship_dt,
                        CASE WHEN LEN(CAST(sls_due_dt AS VARCHAR)) = 8
                             THEN CONVERT(DATE, CAST(sls_due_dt AS VARCHAR), 112)
                             ELSE NULL END                              AS sls_due_dt,
                        -- derive sales if value is missing or inconsistent
                        CASE WHEN sls_sales != sls_quantity * sls_price
                                  OR sls_sales IS NULL OR sls_sales <= 0
                             THEN ABS(sls_quantity) * ABS(sls_price)
                             ELSE sls_sales
                        END                                             AS sls_sales,
                        sls_quantity,
                        CASE WHEN sls_price IS NULL OR sls_price <= 0
                             THEN sls_sales / NULLIF(sls_quantity, 0)
                             ELSE sls_price
                        END                                             AS sls_price
                FROM bronze.crm_sales_details
                WHERE sls_ord_num IS NOT NULL;

                SET @end_time = GETDATE();
                PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

                /*
                PRINT '>> [Post-Load Check] silver.crm_sales_details';
                IF EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_ord_num IS NULL)
                        PRINT 'ERROR: NULLs still exist in sls_ord_num';
                ELSE
                        PRINT 'PASSED: No NULLs in sls_ord_num';
                IF EXISTS (
                        SELECT sls_ord_num, sls_prd_key FROM silver.crm_sales_details
                        GROUP BY sls_ord_num, sls_prd_key HAVING COUNT(*) > 1
                )
                        PRINT 'ERROR: Duplicates still exist in sls_ord_num / sls_prd_key';
                ELSE
                        PRINT 'PASSED: No duplicates in sls_ord_num';
                IF EXISTS (
                        SELECT 1 FROM silver.crm_sales_details
                        WHERE sls_ord_num != TRIM(sls_ord_num)
                           OR sls_prd_key != TRIM(sls_prd_key)
                )
                        PRINT 'ERROR: Unwanted spaces still exist in string columns';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';
                IF EXISTS (
                        SELECT 1 FROM silver.crm_sales_details
                        WHERE sls_sales != sls_quantity * sls_price
                           OR sls_sales IS NULL OR sls_sales <= 0
                )
                        PRINT 'ERROR: Inconsistent or invalid values still exist in sls_sales / sls_quantity / sls_price';
                ELSE
                        PRINT 'PASSED: No invalid values in sls_sales / sls_quantity / sls_price';
                */

                -- ============================================================
                -- ERP Tables
                -- ============================================================

                PRINT '---------------------------------------';
                PRINT 'Loading silver.erp_cust_az12';
                PRINT '---------------------------------------';

                SET @start_time = GETDATE();

                /*
                PRINT '>> [Check] NULLs in primary key: cid';
                IF EXISTS (SELECT 1 FROM bronze.erp_cust_az12 WHERE cid IS NULL)
                        BEGIN
                        PRINT 'WARNING: NULL values found in cid';
                        SELECT TOP 10 * FROM bronze.erp_cust_az12 WHERE cid IS NULL;
                        END
                ELSE
                        PRINT 'PASSED: No NULLs in cid';

                PRINT '>> [Check] Duplicates in primary key: cid';
                IF EXISTS (
                        SELECT cid FROM bronze.erp_cust_az12
                        GROUP BY cid HAVING COUNT(*) > 1
                )
                        BEGIN
                        PRINT 'WARNING: Duplicate values found in cid';
                        SELECT TOP 10 cid, COUNT(*) AS duplicate_count
                        FROM bronze.erp_cust_az12
                        GROUP BY cid HAVING COUNT(*) > 1;
                        END
                ELSE
                        PRINT 'PASSED: No duplicates in cid';

                PRINT '>> [Check] Unwanted spaces in string columns';
                IF EXISTS (
                        SELECT 1 FROM bronze.erp_cust_az12
                        WHERE cid != TRIM(cid)
                           OR gen != TRIM(gen)
                )
                        BEGIN
                        PRINT 'WARNING: Unwanted spaces found in cid / gen';
                        SELECT TOP 10 * FROM bronze.erp_cust_az12
                        WHERE cid != TRIM(cid)
                           OR gen != TRIM(gen);
                        END
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';

                PRINT '>> [Check] Distinct values in gen (bronze)';
                SELECT DISTINCT gen FROM bronze.erp_cust_az12;
                */

                PRINT '>> Truncating table: silver.erp_cust_az12';
                TRUNCATE TABLE silver.erp_cust_az12;

                PRINT '>> Inserting data into: silver.erp_cust_az12';
                INSERT INTO silver.erp_cust_az12 (
                                cid,
                                bdate,
                                gen
                            )
                SELECT
                        -- strip leading 'NAS' prefix to align cid format with CRM customer keys
                        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid,
                        -- nullify future birthdates (data quality issue)
                        CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END                    AS bdate,
                        CASE UPPER(TRIM(REPLACE(gen, CHAR(13), '')))
                                WHEN 'M'      THEN 'Male'
                                WHEN 'F'      THEN 'Female'
                                WHEN 'MALE'   THEN 'Male'
                                WHEN 'FEMALE' THEN 'Female'
                                ELSE 'n/a'
                        END                                                                      AS gen
                FROM bronze.erp_cust_az12
                WHERE cid IS NOT NULL;

                SET @end_time = GETDATE();
                PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

                /*
                PRINT '>> [Post-Load Check] silver.erp_cust_az12';
                IF EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE cid IS NULL)
                        PRINT 'ERROR: NULLs still exist in cid';
                ELSE
                        PRINT 'PASSED: No NULLs in cid';
                IF EXISTS (SELECT cid FROM silver.erp_cust_az12 GROUP BY cid HAVING COUNT(*) > 1)
                        PRINT 'ERROR: Duplicates still exist in cid';
                ELSE
                        PRINT 'PASSED: No duplicates in cid';
                IF EXISTS (
                        SELECT 1 FROM silver.erp_cust_az12
                        WHERE cid != TRIM(cid)
                           OR gen != TRIM(gen)
                )
                        PRINT 'ERROR: Unwanted spaces still exist in string columns';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';

                PRINT '>> [Post-Load Check] Distinct values in gen (silver)';
                SELECT DISTINCT gen FROM silver.erp_cust_az12;
                */

                -- ------------------------------------------------------------

                PRINT '---------------------------------------';
                PRINT 'Loading silver.erp_loc_a101';
                PRINT '---------------------------------------';

                SET @start_time = GETDATE();

                /*
                PRINT '>> [Check] NULLs in primary key: cid';
                IF EXISTS (SELECT 1 FROM bronze.erp_loc_a101 WHERE cid IS NULL)
                        PRINT 'WARNING: NULL values found in cid';
                ELSE
                        PRINT 'PASSED: No NULLs in cid';

                PRINT '>> [Check] Duplicates in primary key: cid';
                IF EXISTS (
                        SELECT cid FROM bronze.erp_loc_a101
                        GROUP BY cid HAVING COUNT(*) > 1
                )
                        PRINT 'WARNING: Duplicate values found in cid';
                ELSE
                        PRINT 'PASSED: No duplicates in cid';

                PRINT '>> [Check] Unwanted spaces in string columns';
                IF EXISTS (
                        SELECT 1 FROM bronze.erp_loc_a101
                        WHERE cid   != TRIM(cid)
                           OR cntry != TRIM(cntry)
                )
                        PRINT 'WARNING: Unwanted spaces found in cid / cntry';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';

                PRINT '>> [Check] Distinct values in cntry (bronze)';
                SELECT DISTINCT cntry FROM bronze.erp_loc_a101;
                */

                PRINT '>> Truncating table: silver.erp_loc_a101';
                TRUNCATE TABLE silver.erp_loc_a101;

                PRINT '>> Inserting data into: silver.erp_loc_a101';
                INSERT INTO silver.erp_loc_a101 (
                                cid,
                                cntry
                            )
                SELECT
                        -- remove dashes from cid to align format with CRM keys
                        REPLACE(TRIM(cid), '-', '')     AS cid,
                        CASE TRIM(cntry)
                                WHEN 'DE'  THEN 'Germany'
                                WHEN 'US'  THEN 'United States'
                                WHEN 'USA' THEN 'United States'
                                WHEN 'FR'  THEN 'France'
                                WHEN 'GB'  THEN 'United Kingdom'
                                WHEN ''    THEN 'n/a'
                                ELSE TRIM(cntry)
                        END                             AS cntry
                FROM bronze.erp_loc_a101
                WHERE cid IS NOT NULL;

                SET @end_time = GETDATE();
                PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

                /*
                PRINT '>> [Post-Load Check] silver.erp_loc_a101';
                IF EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE cid IS NULL)
                        PRINT 'ERROR: NULLs still exist in cid';
                ELSE
                        PRINT 'PASSED: No NULLs in cid';
                IF EXISTS (SELECT cid FROM silver.erp_loc_a101 GROUP BY cid HAVING COUNT(*) > 1)
                        PRINT 'ERROR: Duplicates still exist in cid';
                ELSE
                        PRINT 'PASSED: No duplicates in cid';
                IF EXISTS (
                        SELECT 1 FROM silver.erp_loc_a101
                        WHERE cid   != TRIM(cid)
                           OR cntry != TRIM(cntry)
                )
                        PRINT 'ERROR: Unwanted spaces still exist in string columns';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';

                PRINT '>> [Post-Load Check] Distinct values in cntry (silver)';
                SELECT DISTINCT cntry FROM silver.erp_loc_a101;
                */

                -- ------------------------------------------------------------

                PRINT '---------------------------------------';
                PRINT 'Loading silver.erp_px_cat_g1v2';
                PRINT '---------------------------------------';

                SET @start_time = GETDATE();

                /*
                PRINT '>> [Check] NULLs in primary key: id';
                IF EXISTS (SELECT 1 FROM bronze.erp_px_cat_g1v2 WHERE id IS NULL)
                        PRINT 'WARNING: NULL values found in id';
                ELSE
                        PRINT 'PASSED: No NULLs in id';

                PRINT '>> [Check] Duplicates in primary key: id';
                IF EXISTS (
                        SELECT id FROM bronze.erp_px_cat_g1v2
                        GROUP BY id HAVING COUNT(*) > 1
                )
                        PRINT 'WARNING: Duplicate values found in id';
                ELSE
                        PRINT 'PASSED: No duplicates in id';

                PRINT '>> [Check] Unwanted spaces in string columns';
                IF EXISTS (
                        SELECT 1 FROM bronze.erp_px_cat_g1v2
                        WHERE id          != TRIM(id)
                           OR cat         != TRIM(cat)
                           OR subcat      != TRIM(subcat)
                           OR maintenance != TRIM(maintenance)
                )
                        PRINT 'WARNING: Unwanted spaces found in id / cat / subcat / maintenance';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';
                */

                PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
                TRUNCATE TABLE silver.erp_px_cat_g1v2;

                PRINT '>> Inserting data into: silver.erp_px_cat_g1v2';
                INSERT INTO silver.erp_px_cat_g1v2 (
                                id,
                                cat,
                                subcat,
                                maintenance
                            )
                SELECT
                        TRIM(id)            AS id,
                        TRIM(cat)           AS cat,
                        TRIM(subcat)        AS subcat,
                        TRIM(maintenance)   AS maintenance
                FROM bronze.erp_px_cat_g1v2
                WHERE id IS NOT NULL;

                SET @end_time = GETDATE();
                PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

                /*
                PRINT '>> [Post-Load Check] silver.erp_px_cat_g1v2';
                IF EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE id IS NULL)
                        PRINT 'ERROR: NULLs still exist in id';
                ELSE
                        PRINT 'PASSED: No NULLs in id';
                IF EXISTS (SELECT id FROM silver.erp_px_cat_g1v2 GROUP BY id HAVING COUNT(*) > 1)
                        PRINT 'ERROR: Duplicates still exist in id';
                ELSE
                        PRINT 'PASSED: No duplicates in id';
                IF EXISTS (
                        SELECT 1 FROM silver.erp_px_cat_g1v2
                        WHERE id          != TRIM(id)
                           OR cat         != TRIM(cat)
                           OR subcat      != TRIM(subcat)
                           OR maintenance != TRIM(maintenance)
                )
                        PRINT 'ERROR: Unwanted spaces still exist in string columns';
                ELSE
                        PRINT 'PASSED: No unwanted spaces found';
                */

                SET @batch_end_time = GETDATE();
                PRINT '=======================================';
                PRINT 'Loading Silver Layer is Completed';
                PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
                PRINT '=======================================';
        END TRY

        BEGIN CATCH
                PRINT '=======================================';
                PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
                PRINT 'Error Message: ' + ERROR_MESSAGE();
                PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
                PRINT 'Error State:   ' + CAST(ERROR_STATE() AS NVARCHAR);
                PRINT '=======================================';
        END CATCH
END
