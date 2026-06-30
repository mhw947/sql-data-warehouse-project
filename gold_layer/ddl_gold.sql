/* =================================
DDL Script: Create Gold Layer Views
====================================
Purpose:
    Create business-ready views in the 'gold' schema by integrating and enriching
    cleansed silver tables into a star schema: two dimension views and one fact view.

Data Model:
    fact_sales
        ├── dim_customers  (via customer_key)
        └── dim_products   (via product_key)

Join Logic:
    dim_customers : crm_cust_info.cst_key  = erp_cust_az12.cid = erp_loc_a101.cid
    dim_products  : crm_prd_info.cat_id    = erp_px_cat_g1v2.id
    fact_sales    : sls_cust_id            = dim_customers.customer_id
                    sls_prd_key            = dim_products.product_number
*/

-- ============================================================
-- Dimension: Customers
-- ============================================================
-- Unified customer profile combining CRM identity data with
-- ERP birthdate/gender and location.
-- Gender priority: CRM is preferred; ERP used as fallback.

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id)                              AS customer_key, -- surrogate key for star schema
    ci.cst_id                                                           AS customer_id,
    ci.cst_key                                                          AS customer_number,
    ci.cst_firstname                                                    AS first_name,
    ci.cst_lastname                                                     AS last_name,
    la.cntry                                                            AS country,
    ci.cst_marital_status                                               AS marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
         ELSE COALESCE(ca.gen, 'n/a')
    END                                                                 AS gender, -- CRM preferred, ERP fallback
    ca.bdate                                                            AS birthdate,
    ci.cst_create_date                                                  AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101  la ON ci.cst_key = la.cid;
GO

-- ============================================================
-- Dimension: Products
-- ============================================================
-- Current products only (prd_end_dt IS NULL = no successor version).
-- Enriched with category and subcategory from ERP.

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY p.prd_start_dt, p.prd_id)             AS product_key, -- surrogate key for star schema
    p.prd_id                                                           AS product_id,
    p.prd_key                                                          AS product_number,
    p.prd_nm                                                           AS product_name,
    p.cat_id                                                           AS category_id,
    c.cat                                                              AS category,
    c.subcat                                                           AS subcategory,
    c.maintenance                                                      AS maintenance,
    p.prd_cost                                                         AS cost,
    p.prd_line                                                         AS product_line,
    p.prd_start_dt                                                     AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 c ON p.cat_id = c.id
WHERE p.prd_end_dt IS NULL;
GO

-- ============================================================
-- Fact: Sales
-- ============================================================
-- Transactional sales data enriched with surrogate keys from
-- dim_customers and dim_products for star schema compatibility.

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    f.sls_ord_num                                                       AS order_number,
    p.product_key,
    c.customer_key,
    f.sls_order_dt                                                      AS order_date,
    f.sls_ship_dt                                                       AS ship_date,
    f.sls_due_dt                                                        AS due_date,
    f.sls_sales                                                         AS sales_amount,
    f.sls_quantity                                                      AS quantity,
    f.sls_price                                                         AS price
FROM silver.crm_sales_details f
LEFT JOIN gold.dim_customers c ON f.sls_cust_id  = c.customer_id
LEFT JOIN gold.dim_products  p ON f.sls_prd_key  = p.product_number;
GO