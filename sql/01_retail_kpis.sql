-- ============================================================
--  Module 01: Retail Sales KPI Analysis
--  Project  : Big Data Analytics Platform
--  Author   : Sakthivel Srinivasan
--  DB       : MySQL / PostgreSQL compatible
-- ============================================================
--  Table    : retail_sales
--  Columns  : order_id, date, region, category, sub_category,
--             sku, quantity, unit_price, discount_pct, revenue,
--             cogs, profit, profit_margin, sales_rep, channel,
--             return_flag, month, quarter
-- ============================================================


-- ──────────────────────────────────────────────────────────
-- 1.1  EXECUTIVE SUMMARY — Revenue, Profit and Volume
-- ──────────────────────────────────────────────────────────

SELECT
    COUNT(order_id)                                 AS total_orders,
    SUM(quantity)                                   AS total_units_sold,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(SUM(cogs), 2)                             AS total_cogs,
    ROUND(SUM(profit), 2)                           AS total_profit,
    ROUND(AVG(profit_margin), 2)                    AS avg_profit_margin_pct,
    ROUND(AVG(unit_price), 2)                       AS avg_unit_price,
    ROUND(SUM(revenue) / COUNT(order_id), 2)        AS avg_order_value
FROM retail_sales;


-- ──────────────────────────────────────────────────────────
-- 1.2  MONTHLY REVENUE AND PROFIT TREND
-- ──────────────────────────────────────────────────────────

SELECT
    month,
    COUNT(order_id)                                 AS orders,
    ROUND(SUM(revenue), 2)                          AS revenue,
    ROUND(SUM(profit), 2)                           AS profit,
    ROUND(AVG(profit_margin), 2)                    AS avg_margin_pct,
    ROUND(SUM(revenue) / COUNT(order_id), 2)        AS avg_order_value
FROM retail_sales
GROUP BY month
ORDER BY month;


-- ──────────────────────────────────────────────────────────
-- 1.3  QUARTERLY PERFORMANCE SUMMARY
-- ──────────────────────────────────────────────────────────

SELECT
    quarter,
    COUNT(order_id)                                 AS orders,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(SUM(profit), 2)                           AS total_profit,
    ROUND(AVG(profit_margin), 2)                    AS avg_margin_pct
FROM retail_sales
GROUP BY quarter
ORDER BY quarter;


-- ──────────────────────────────────────────────────────────
-- 1.4  CATEGORY PERFORMANCE — Revenue, Profit, Margin Ranked
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    COUNT(order_id)                                         AS orders,
    ROUND(SUM(revenue), 2)                                  AS total_revenue,
    ROUND(SUM(profit), 2)                                   AS total_profit,
    ROUND(AVG(profit_margin), 2)                            AS avg_margin_pct,
    ROUND(SUM(quantity), 0)                                 AS total_units,
    RANK() OVER (ORDER BY SUM(revenue) DESC)                AS revenue_rank,
    RANK() OVER (ORDER BY AVG(profit_margin) DESC)          AS margin_rank
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;


-- ──────────────────────────────────────────────────────────
-- 1.5  SUB-CATEGORY DEEP DIVE
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    sub_category,
    COUNT(order_id)                                 AS orders,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(AVG(profit_margin), 2)                    AS avg_margin_pct
FROM retail_sales
GROUP BY category, sub_category
ORDER BY category, total_revenue DESC;


-- ──────────────────────────────────────────────────────────
-- 1.6  TOP 10 SKUs BY REVENUE
-- ──────────────────────────────────────────────────────────

SELECT
    sku,
    category,
    COUNT(order_id)                                 AS total_orders,
    SUM(quantity)                                   AS units_sold,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(SUM(profit), 2)                           AS total_profit,
    ROUND(AVG(profit_margin), 2)                    AS avg_margin_pct
FROM retail_sales
GROUP BY sku, category
ORDER BY total_revenue DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────
-- 1.7  REGIONAL PERFORMANCE
-- ──────────────────────────────────────────────────────────

SELECT
    region,
    COUNT(order_id)                                 AS orders,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(SUM(profit), 2)                           AS total_profit,
    ROUND(AVG(profit_margin), 2)                    AS avg_margin_pct,
    ROUND(SUM(return_flag) * 100.0 / COUNT(order_id), 2) AS return_rate_pct
FROM retail_sales
GROUP BY region
ORDER BY total_revenue DESC;


-- ──────────────────────────────────────────────────────────
-- 1.8  REGION x QUARTER HEATMAP (for Power BI matrix)
-- ──────────────────────────────────────────────────────────

SELECT
    region,
    quarter,
    ROUND(SUM(revenue), 2)                          AS revenue,
    ROUND(SUM(profit), 2)                           AS profit,
    COUNT(order_id)                                 AS orders
FROM retail_sales
GROUP BY region, quarter
ORDER BY region, quarter;


-- ──────────────────────────────────────────────────────────
-- 1.9  SALES CHANNEL ANALYSIS
-- ──────────────────────────────────────────────────────────

SELECT
    channel,
    COUNT(order_id)                                 AS orders,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(AVG(unit_price), 2)                       AS avg_unit_price,
    ROUND(AVG(profit_margin), 2)                    AS avg_margin_pct,
    ROUND(SUM(return_flag) * 100.0 / COUNT(order_id), 2) AS return_rate_pct
FROM retail_sales
GROUP BY channel
ORDER BY total_revenue DESC;


-- ──────────────────────────────────────────────────────────
-- 1.10  DISCOUNT IMPACT ON MARGIN AND REVENUE
-- ──────────────────────────────────────────────────────────

SELECT
    CASE
        WHEN discount_pct = 0           THEN '0 - No Discount'
        WHEN discount_pct <= 0.10       THEN '1 - 1 to 10 pct'
        WHEN discount_pct <= 0.20       THEN '2 - 11 to 20 pct'
        ELSE                                 '3 - Above 20 pct'
    END                                         AS discount_tier,
    COUNT(order_id)                             AS orders,
    ROUND(SUM(revenue), 2)                      AS total_revenue,
    ROUND(AVG(profit_margin), 2)                AS avg_margin_pct,
    ROUND(SUM(return_flag) * 100.0
          / COUNT(order_id), 2)                 AS return_rate_pct
FROM retail_sales
GROUP BY discount_tier
ORDER BY discount_tier;


-- ──────────────────────────────────────────────────────────
-- 1.11  RETURN RATE BY CATEGORY
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    COUNT(order_id)                                       AS total_orders,
    SUM(return_flag)                                      AS total_returns,
    ROUND(SUM(return_flag) * 100.0 / COUNT(order_id), 2) AS return_rate_pct
FROM retail_sales
GROUP BY category
ORDER BY return_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 1.12  HIGH-MARGIN ORDERS (Above 55% Margin)
-- ──────────────────────────────────────────────────────────

SELECT
    order_id,
    date,
    category,
    sku,
    region,
    channel,
    ROUND(revenue, 2)       AS revenue,
    ROUND(profit, 2)        AS profit,
    ROUND(profit_margin, 2) AS margin_pct
FROM retail_sales
WHERE profit_margin > 55
ORDER BY profit_margin DESC;
