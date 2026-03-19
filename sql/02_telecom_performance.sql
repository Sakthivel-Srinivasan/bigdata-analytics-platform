-- ============================================================
--  Module 02: Telecom CRM Performance Analysis
--  Project  : Big Data Analytics Platform
--  Author   : Sakthivel Srinivasan
--  DB       : MySQL / PostgreSQL compatible
-- ============================================================
--  Table    : telecom_crm
--  Columns  : interaction_id, date, agent_id, channel, product,
--             eligible, converted, upsell, arpu, aht_minutes,
--             error_flag, order_success, region, month
-- ============================================================


-- ──────────────────────────────────────────────────────────
-- 2.1  PLATFORM-LEVEL KPI SUMMARY
-- ──────────────────────────────────────────────────────────

SELECT
    COUNT(interaction_id)                                             AS total_interactions,
    SUM(eligible)                                                     AS eligible_leads,
    SUM(converted)                                                    AS total_conversions,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)      AS conversion_rate_pct,
    SUM(upsell)                                                       AS total_upsells,
    ROUND(SUM(upsell) * 100.0 / NULLIF(SUM(converted), 0), 2)        AS upsell_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)             AS avg_arpu,
    ROUND(AVG(aht_minutes), 2)                                        AS avg_aht_minutes,
    ROUND(AVG(error_flag) * 100, 2)                                   AS error_rate_pct,
    ROUND(AVG(order_success) * 100, 2)                                AS order_success_rate_pct
FROM telecom_crm;


-- ──────────────────────────────────────────────────────────
-- 2.2  AGENT-LEVEL PERFORMANCE SCORECARD
-- ──────────────────────────────────────────────────────────

SELECT
    agent_id,
    COUNT(interaction_id)                                               AS total_interactions,
    SUM(eligible)                                                       AS eligible_leads,
    SUM(converted)                                                      AS conversions,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)        AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)               AS avg_arpu,
    SUM(upsell)                                                         AS upsells,
    ROUND(SUM(upsell) * 100.0 / NULLIF(SUM(converted), 0), 2)          AS upsell_rate_pct,
    ROUND(AVG(aht_minutes), 2)                                          AS avg_aht_minutes,
    ROUND(AVG(error_flag) * 100, 2)                                     AS error_rate_pct,
    ROUND(AVG(order_success) * 100, 2)                                  AS order_success_pct
FROM telecom_crm
GROUP BY agent_id
ORDER BY conversion_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 2.3  MONTHLY KPI TRENDS
-- ──────────────────────────────────────────────────────────

SELECT
    month,
    COUNT(interaction_id)                                             AS interactions,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)     AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)            AS avg_arpu,
    ROUND(SUM(upsell) * 100.0 / NULLIF(SUM(converted), 0), 2)       AS upsell_rate_pct,
    ROUND(AVG(aht_minutes), 2)                                        AS avg_aht_minutes,
    ROUND(AVG(error_flag) * 100, 2)                                   AS error_rate_pct,
    ROUND(AVG(order_success) * 100, 2)                                AS order_success_pct
FROM telecom_crm
GROUP BY month
ORDER BY month;


-- ──────────────────────────────────────────────────────────
-- 2.4  PRODUCT ANALYSIS — Conversion Rate and ARPU
-- ──────────────────────────────────────────────────────────

SELECT
    product,
    COUNT(interaction_id)                                             AS total_interactions,
    SUM(eligible)                                                     AS eligible_leads,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)     AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)            AS avg_arpu,
    ROUND(SUM(upsell) * 100.0 / NULLIF(SUM(converted), 0), 2)       AS upsell_rate_pct
FROM telecom_crm
GROUP BY product
ORDER BY avg_arpu DESC;


-- ──────────────────────────────────────────────────────────
-- 2.5  CHANNEL ANALYSIS — Conversion, ARPU and AHT
-- ──────────────────────────────────────────────────────────

SELECT
    channel,
    COUNT(interaction_id)                                             AS interactions,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)     AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)            AS avg_arpu,
    ROUND(AVG(aht_minutes), 2)                                        AS avg_aht_minutes,
    ROUND(AVG(error_flag) * 100, 2)                                   AS error_rate_pct
FROM telecom_crm
GROUP BY channel
ORDER BY avg_arpu DESC;


-- ──────────────────────────────────────────────────────────
-- 2.6  REGIONAL BREAKDOWN
-- ──────────────────────────────────────────────────────────

SELECT
    region,
    COUNT(interaction_id)                                             AS interactions,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)     AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN arpu END), 2)            AS avg_arpu,
    ROUND(AVG(error_flag) * 100, 2)                                   AS error_rate_pct
FROM telecom_crm
GROUP BY region
ORDER BY conversion_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 2.7  ROOT-CAUSE: AGENTS WITH ERROR RATE ABOVE 12%
-- ──────────────────────────────────────────────────────────

SELECT
    agent_id,
    COUNT(interaction_id)                 AS total_interactions,
    SUM(error_flag)                       AS total_errors,
    ROUND(AVG(error_flag) * 100, 2)       AS error_rate_pct,
    ROUND(AVG(order_success) * 100, 2)    AS order_success_pct,
    ROUND(AVG(aht_minutes), 2)            AS avg_aht_minutes
FROM telecom_crm
GROUP BY agent_id
HAVING ROUND(AVG(error_flag) * 100, 2) > 12
ORDER BY error_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 2.8  ERROR RATE vs CONVERSION CORRELATION (Agent Level)
-- ──────────────────────────────────────────────────────────

SELECT
    agent_id,
    ROUND(SUM(converted) * 100.0 / NULLIF(SUM(eligible), 0), 2)   AS conversion_rate_pct,
    ROUND(AVG(error_flag) * 100, 2)                                AS error_rate_pct,
    CASE
        WHEN AVG(error_flag) < 0.07 AND
             SUM(converted) * 1.0 / NULLIF(SUM(eligible), 0) > 0.60
             THEN 'Top Performer'
        WHEN AVG(error_flag) > 0.12
             THEN 'Needs Coaching'
        ELSE     'Average'
    END                                                            AS performance_band
FROM telecom_crm
GROUP BY agent_id
ORDER BY performance_band, conversion_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 2.9  HIGH-VALUE SEGMENT — Converted, Upsold, ARPU > 90
-- ──────────────────────────────────────────────────────────

SELECT
    interaction_id,
    agent_id,
    region,
    product,
    channel,
    ROUND(arpu, 2)          AS arpu,
    ROUND(aht_minutes, 2)   AS aht_minutes
FROM telecom_crm
WHERE converted     = 1
  AND upsell        = 1
  AND arpu          > 90
ORDER BY arpu DESC;


-- ──────────────────────────────────────────────────────────
-- 2.10  UPSELL SUCCESS BY PRODUCT AND CHANNEL
-- ──────────────────────────────────────────────────────────

SELECT
    product,
    channel,
    SUM(converted)                                                     AS conversions,
    SUM(upsell)                                                        AS upsells,
    ROUND(SUM(upsell) * 100.0 / NULLIF(SUM(converted), 0), 2)         AS upsell_rate_pct,
    ROUND(AVG(CASE WHEN upsell = 1 THEN arpu END), 2)                 AS avg_arpu_upsold
FROM telecom_crm
GROUP BY product, channel
ORDER BY upsell_rate_pct DESC;
