/*
Some of the tests I have conducted to check the quality of the data 
*/
-- Check for unwanted Spaces 
-- Expectation: No Results 
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) 


-- Data Standartization & Consistency 
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info 

SELECT * FROM silver.crm_cust_info 

-- Check for Negative Numbers 
-- Expectation: No Results 

Select prd_cost
From bronze.crm_prd_info
Where prd_cost < 0 OR prd_cost IS NULL 

SELECT * 
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt 

-- Check for Invalid Dates 
SELECT 
NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 202500101

-- CHECK for Invalid Data Order 
Select 
*
FROM bronze.crm_sales_details  
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL or sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price is NULL or sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0) 
    ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales is NULL OR sls_quantity IS NULL or sls_price is NULL
OR sls_sales < = 0 OR sls_quantity < = 0 or sls_price < = 0 
ORDER BY sls_sales, sls_quantity, sls_price

--CRM erp cust az12
SELECT 
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE () THEN NULL 
    ELSE bdate
END AS bdate,
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
    ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12
------------
SELECT DISTINCT
    gen,
    gen_clean,
    CASE 
        WHEN UPPER(gen_clean) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(gen_clean) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen_std
FROM (
    SELECT
        gen,
        TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), '')) AS gen_clean
    FROM bronze.erp_cust_az12
) s;

----- 
SELECT DISTINCT 
bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

SELECT DISTINCT 
gen 
FROM silver.erp_cust_az12
---------

SELECT 
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) = 'US' THEN 'United States'
    WHEN TRIM(cntry) = 'USA' THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry = NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM (
    SELECT 
        TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) AS cntry,
        cid
    FROM bronze.erp_loc_a101) s;

SELECT DISTINCT cntry 
FROM silver.erp_loc_a101
ORDER by cntry 

SELECT * FROM silver.erp_loc_a101

-----------------------


SELECT * FROM silver.erp_px_cat_g1v2 
