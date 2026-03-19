-- ============================================================
--  Module 04: Advanced Analytics
--  Project  : Big Data Analytics Platform
--  Author   : Sakthivel Srinivasan
--  DB       : PostgreSQL (window functions, CTEs)
--             MySQL 8.0+ compatible
-- ============================================================
--  Covers   : Window functions, CTEs, MoM growth, running
--             totals, customer segmentation, cross-domain
--             joins, cohort-style analysis
-- ============================================================


-- ──────────────────────────────────────────────────────────
-- 4.1  RUNNING TOTAL — Cumulative Revenue Over Time
-- ──────────────────────────────────────────────────────────

SELECT
    date,
    order_id,
    category,
    ROUND(revenue, 2)                                               AS daily_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY date
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)    AS cumulative_revenue
FROM retail_sales
ORDER BY date;


-- ──────────────────────────────────────────────────────────
-- 4.2  MONTH-OVER-MONTH REVENUE GROWTH (CTE + LAG)
-- ──────────────────────────────────────────────────────────

WITH monthly_rev AS (
    SELECT
        month,
        ROUND(SUM(revenue), 2)  AS revenue
    FROM retail_sales
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                              AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
    )                                                               AS mom_growth_pct
FROM monthly_rev
ORDER BY month;


-- ──────────────────────────────────────────────────────────
-- 4.3  SKU RANK WITHIN EACH CATEGORY (Partition by)
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    sku,
    ROUND(SUM(revenue), 2)                                          AS sku_revenue,
    ROUND(AVG(profit_margin), 2)                                    AS avg_margin_pct,
    RANK() OVER (PARTITION BY category ORDER BY SUM(revenue) DESC)  AS rank_in_category,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY AVG(profit_margin) DESC) AS margin_rank_in_category
FROM retail_sales
GROUP BY category, sku
ORDER BY category, rank_in_category;


-- ──────────────────────────────────────────────────────────
-- 4.4  AGENT PERFORMANCE VS TEAM AVERAGE (Window Function)
-- ──────────────────────────────────────────────────────────

WITH agent_stats AS (
    SELECT
        agent_id,
        ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)   AS conv_rate,
        ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)           AS avg_arpu,
        ROUND(AVG(error_flag) * 100, 2)                                AS error_rate
    FROM telecom_crm
    GROUP BY agent_id
)
SELECT
    agent_id,
    conv_rate                                                           AS agent_conv_rate_pct,
    ROUND(AVG(conv_rate) OVER (), 2)                                    AS team_avg_conv_rate_pct,
    ROUND(conv_rate - AVG(conv_rate) OVER (), 2)                        AS delta_vs_team_avg,
    avg_arpu,
    ROUND(AVG(avg_arpu) OVER (), 2)                                     AS team_avg_arpu,
    error_rate                                                          AS agent_error_rate_pct,
    ROUND(AVG(error_rate) OVER (), 2)                                   AS team_avg_error_rate_pct
FROM agent_stats
ORDER BY conv_rate DESC;


-- ──────────────────────────────────────────────────────────
-- 4.5  CUMULATIVE ERROR COUNT PER ANALYST (Quality Drift)
-- ──────────────────────────────────────────────────────────

SELECT
    analyst_id,
    date,
    has_error,
    SUM(has_error) OVER (
        PARTITION BY analyst_id
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                           AS cumulative_errors
FROM catalog_quality
ORDER BY analyst_id, date;


-- ──────────────────────────────────────────────────────────
-- 4.6  RETAIL: ROLLING 3-MONTH AVERAGE REVENUE
-- ──────────────────────────────────────────────────────────

WITH monthly_agg AS (
    SELECT
        month,
        ROUND(SUM(revenue), 2)  AS monthly_revenue
    FROM retail_sales
    GROUP BY month
)
SELECT
    month,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                       AS rolling_3m_avg_revenue
FROM monthly_agg
ORDER BY month;


-- ──────────────────────────────────────────────────────────
-- 4.7  RETAIL CUSTOMER SEGMENTATION BY ORDER VALUE
-- ──────────────────────────────────────────────────────────

WITH order_value AS (
    SELECT
        sales_rep,
        COUNT(order_id)                                     AS total_orders,
        ROUND(SUM(revenue), 2)                              AS total_revenue,
        ROUND(SUM(revenue) / COUNT(order_id), 2)            AS avg_order_value
    FROM retail_sales
    GROUP BY sales_rep
)
SELECT
    sales_rep,
    total_orders,
    total_revenue,
    avg_order_value,
    NTILE(4) OVER (ORDER BY total_revenue DESC)             AS revenue_quartile,
    CASE NTILE(4) OVER (ORDER BY total_revenue DESC)
        WHEN 1 THEN 'High Value'
        WHEN 2 THEN 'Mid-High Value'
        WHEN 3 THEN 'Mid-Low Value'
        WHEN 4 THEN 'Low Value'
    END                                                     AS segment
FROM order_value
ORDER BY total_revenue DESC;


-- ──────────────────────────────────────────────────────────
-- 4.8  TELECOM: CONVERSION TREND — 3-MONTH MOVING AVERAGE
-- ──────────────────────────────────────────────────────────

WITH monthly_conv AS (
    SELECT
        month,
        ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)   AS conv_rate_pct
    FROM telecom_crm
    GROUP BY month
)
SELECT
    month,
    conv_rate_pct,
    ROUND(AVG(conv_rate_pct) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                                               AS rolling_3m_avg_conv_pct
FROM monthly_conv
ORDER BY month;


-- ──────────────────────────────────────────────────────────
-- 4.9  CROSS-DOMAIN: REGION-LEVEL UNIFIED SUMMARY
--       Joins retail and telecom on shared region column
-- ──────────────────────────────────────────────────────────

WITH retail_by_region AS (
    SELECT
        region,
        ROUND(SUM(revenue), 2)          AS retail_revenue,
        ROUND(AVG(profit_margin), 2)    AS retail_margin_pct
    FROM retail_sales
    GROUP BY region
),
telecom_by_region AS (
    SELECT
        region,
        ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)   AS telecom_conv_rate_pct,
        ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)           AS telecom_avg_arpu
    FROM telecom_crm
    GROUP BY region
)
SELECT
    r.region,
    r.retail_revenue,
    r.retail_margin_pct,
    t.telecom_conv_rate_pct,
    t.telecom_avg_arpu
FROM retail_by_region r
LEFT JOIN telecom_by_region t
    ON r.region = t.region
ORDER BY r.retail_revenue DESC;


-- ──────────────────────────────────────────────────────────
-- 4.10  TOP PERFORMING SKUs ABOVE AVERAGE MARGIN
--        Using a subquery as a threshold filter
-- ──────────────────────────────────────────────────────────

SELECT
    sku,
    category,
    ROUND(SUM(revenue), 2)          AS total_revenue,
    ROUND(AVG(profit_margin), 2)    AS avg_margin_pct
FROM retail_sales
GROUP BY sku, category
HAVING AVG(profit_margin) > (
    SELECT AVG(profit_margin) FROM retail_sales
)
ORDER BY avg_margin_pct DESC
LIMIT 15;


-- ──────────────────────────────────────────────────────────
-- 4.11  CATALOG: ANALYST PERFORMANCE QUARTILES
-- ──────────────────────────────────────────────────────────

WITH analyst_acc AS (
    SELECT
        analyst_id,
        ROUND((COUNT(catalog_id) - SUM(has_error)) * 100.0
              / COUNT(catalog_id), 2)   AS accuracy_pct,
        ROUND(AVG(review_time_min), 2)  AS avg_review_min
    FROM catalog_quality
    GROUP BY analyst_id
)
SELECT
    analyst_id,
    accuracy_pct,
    avg_review_min,
    NTILE(4) OVER (ORDER BY accuracy_pct DESC)          AS accuracy_quartile,
    CASE NTILE(4) OVER (ORDER BY accuracy_pct DESC)
        WHEN 1 THEN 'Top Performer'
        WHEN 2 THEN 'Solid'
        WHEN 3 THEN 'Developing'
        WHEN 4 THEN 'Needs Support'
    END                                                 AS performance_tier
FROM analyst_acc
ORDER BY accuracy_pct DESC;
