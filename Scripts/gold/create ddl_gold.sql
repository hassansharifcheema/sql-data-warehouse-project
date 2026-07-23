/*
======================================================================================
DDL Script: Create Gold Views 
======================================================================================
Script purpose:
  This script creates views for the gold layer in the data Warehouse.
  the gold layer represents the final dimension and fact tables(Star Schema)

  Each view performs transformations and combines data from Silver layer 
to produce a clean , enriched and business ready dataset.

Usage:
  -these views can be queried directly for analytics and reporting.
=====================================================================================
*/

--=========================================================================
--Create Dimension:gold.customer_dim
--=========================================================================
if OBJECT_ID('gold.customer_dim', 'V') IS NOT NULL
	drop view gold.customer_dim;
	GO
CREATE VIEW gold.customer_dim AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'N/A'  THEN ci.cst_gndr -- CRM is the master for gender info
	else coalesce(ca.gendr, 'N/A') 
	end as gender,
	ca.b_date as birth_date,
	ci.cst_create_date as customer_create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid
--=========================================================================
--Create Dimension:gold.product_dim
--=========================================================================
IF OBJECT_ID('gold.product_dim') IS NOT NULL
	DROP VIEW gold.product_dim;
	GO
create view gold.product_dim as
SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id as product_id,
	pn.prd_nm as product_number,
	pc.subcat as product_name,
	pn.prd_key as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
		pc.maintanace as maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date

FROM silver.crm_prd_info  pn
left join silver.erp_px_cat_g1v2  pc
on pn.prd_key = pc.id
WHERE prd_end_dt IS NULL -- filter out all historical data
--=========================================================================
--Create Dimension:gold.fact_sales
--=========================================================================
if OBJECT_ID ('gold.fact_sales', 'V') IS NOT NULL
drop view gold.fact_sales
go
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num as order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shiping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
FROM silver.crm_sales_details sd  
left join gold.product_dim pr
on sd.sls_prd_key = pr.product_number
LEFT JOIN gold.customer_dim cu
on sd.sls_cust_id = cu.customer_id
