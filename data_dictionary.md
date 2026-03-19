# Data dictionary

**Project:** Big Data Analytics Platform  
**Author:** Sakthivel Srinivasan  
**Last updated:** 2025

This document defines the schema, data types, and field-level descriptions for all three datasets used in this project.

---

## Table of Contents

- [Retail Sales](#retail-sales)
- [Telecom CRM](#telecom-crm)
- [Catalog Quality](#catalog-quality)
- [Data Assumptions](#data-assumptions)

---

## Retail sales

**Table name:** `retail_sales`  
**Row count:** 1,200  
**Grain:** One row per order  
**Source module:** [01_retail_kpis.sql](../sql/01_retail_kpis.sql)

| Column | Type | Description |
|---|---|---|
| order_id | VARCHAR | Unique order identifier. Format: ORD-XXXXX |
| date | DATE | Order date. Range: 2024-01-01 to 2024-12-31 |
| region | VARCHAR | Geographic region. Values: North, South, East, West |
| category | VARCHAR | Product category. Values: Electronics, Apparel, Home and Garden, Toys, Beauty |
| sub_category | VARCHAR | Sub-category within the parent category |
| sku | VARCHAR | Stock Keeping Unit identifier. Format: SKU-XXXX |
| quantity | INT | Number of units ordered. Range: 1 to 50 |
| unit_price | DECIMAL(10,2) | Price per unit in USD before discount |
| discount_pct | DECIMAL(5,2) | Discount applied as a decimal. Range: 0.00 to 0.50 |
| revenue | DECIMAL(10,2) | Net revenue after discount. Calculated as: quantity x unit_price x (1 - discount_pct) |
| cogs | DECIMAL(10,2) | Cost of goods sold. Estimated as 45 to 65 percent of revenue |
| profit | DECIMAL(10,2) | Gross profit. Calculated as: revenue - cogs |
| profit_margin | DECIMAL(5,2) | Profit margin percentage. Calculated as: profit / revenue x 100 |
| sales_rep | VARCHAR | Name of the sales representative handling the order |
| channel | VARCHAR | Sales channel. Values: Online, In-Store, Wholesale |
| return_flag | INT | Binary flag. 1 = returned, 0 = not returned |
| month | INT | Calendar month extracted from date. Range: 1 to 12 |
| quarter | INT | Calendar quarter extracted from date. Range: 1 to 4 |

---

## Telecom CRM

**Table name:** `telecom_crm`  
**Row count:** 800  
**Grain:** One row per customer interaction  
**Source module:** [02_telecom_performance.sql](../sql/02_telecom_performance.sql)

| Column | Type | Description |
|---|---|---|
| interaction_id | VARCHAR | Unique interaction identifier. Format: INT-XXXXX |
| date | DATE | Date of the interaction. Range: 2024-01-01 to 2024-12-31 |
| agent_id | VARCHAR | Agent identifier. Format: AGT-XXX. 17 active agents |
| channel | VARCHAR | Interaction channel. Values: Chat, Phone, Email |
| product | VARCHAR | Product pitched. Values: Starter Plan, Standard Plan, Premium Plan, Home Internet, Business Bundle |
| eligible | INT | Binary flag. 1 = customer was eligible for the product, 0 = not eligible |
| converted | INT | Binary flag. 1 = sale completed, 0 = no sale. Always 0 if eligible = 0 |
| upsell | INT | Binary flag. 1 = upsell product added, 0 = no upsell. Always 0 if converted = 0 |
| arpu | DECIMAL(8,2) | Average Revenue Per User in USD. Populated only if converted = 1, otherwise 0 |
| aht_minutes | DECIMAL(6,2) | Average Handling Time in minutes. Range: 1 to 60 |
| error_flag | INT | Binary flag. 1 = a data entry or process error occurred during the interaction |
| order_success | INT | Binary flag. 1 = order completed without error. 0 if error_flag = 1 or converted = 0 |
| region | VARCHAR | Customer region. Values: Ontario, BC, Alberta, Quebec |
| month | INT | Calendar month extracted from date. Range: 1 to 12 |

---

## Catalog quality

**Table name:** `catalog_quality`  
**Row count:** 500  
**Grain:** One row per catalog item reviewed  
**Source module:** [03_catalog_quality.sql](../sql/03_catalog_quality.sql)

| Column | Type | Description |
|---|---|---|
| catalog_id | VARCHAR | Unique catalog item identifier. Format: CAT-XXXXX |
| date | DATE | Date the item was reviewed. Range: 2024-01-01 to 2024-12-31 |
| analyst_id | VARCHAR | QA analyst identifier. Format: QA-X. 8 active analysts |
| category | VARCHAR | Product category of the item reviewed |
| sku | VARCHAR | Stock Keeping Unit of the product being validated |
| error_type | VARCHAR | Type of error found. Values: Missing image, Wrong price, Duplicate SKU, Bad description, Missing attribute, Incorrect category, None |
| has_error | INT | Binary flag. 1 = error found during review, 0 = clean item |
| rework_required | INT | Binary flag. 1 = item must be returned for correction. Equal to has_error |
| approved | INT | Binary flag. 1 = item approved for catalog upload. Equal to inverse of has_error |
| review_time_min | DECIMAL(6,2) | Time taken by the analyst to review the item. Range: 1 to 120 minutes |

---

## Data assumptions

- All monetary values are in USD.
- Datasets are synthetic and do not represent real individuals, organisations, or transactions.
- The `eligible` and `converted` fields in the telecom dataset follow a conditional logic: a customer cannot convert if they are not eligible. SQL queries using these fields use `NULLIF` guards to avoid division-by-zero errors.
- `profit_margin` in the retail dataset is pre-calculated as a percentage and stored as a DECIMAL rather than computed at query time, except where window functions require re-calculation.
- In the catalog dataset, `rework_required` and `has_error` are identical by design, representing the same state (an error found = rework needed). `approved` is the logical inverse of `has_error`.
- The `region` column exists in both retail and telecom datasets but uses different value sets. The advanced analytics module [04_advanced_analytics.sql](../sql/04_advanced_analytics.sql) includes a cross-domain join on this field for illustrative purposes.
