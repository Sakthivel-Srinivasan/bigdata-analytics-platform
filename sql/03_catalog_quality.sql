-- ============================================================
--  Module 03: E-Commerce Catalog Quality Analysis
--  Project  : Big Data Analytics Platform
--  Author   : Sakthivel Srinivasan
--  DB       : MySQL / PostgreSQL compatible
-- ============================================================
--  Table    : catalog_quality
--  Columns  : catalog_id, date, analyst_id, category, sku,
--             error_type, has_error, rework_required,
--             approved, review_time_min
-- ============================================================


-- ──────────────────────────────────────────────────────────
-- 3.1  PLATFORM-LEVEL QUALITY SUMMARY
-- ──────────────────────────────────────────────────────────

SELECT
    COUNT(catalog_id)                                       AS total_items_reviewed,
    SUM(has_error)                                          AS total_errors_found,
    ROUND(AVG(has_error) * 100, 2)                         AS error_rate_pct,
    SUM(approved)                                          AS total_approved,
    ROUND(AVG(approved) * 100, 2)                          AS approval_rate_pct,
    SUM(rework_required)                                   AS total_rework_items,
    ROUND(AVG(rework_required) * 100, 2)                   AS rework_rate_pct,
    ROUND(AVG(review_time_min), 2)                         AS avg_review_time_min,
    MIN(review_time_min)                                   AS min_review_time_min,
    MAX(review_time_min)                                   AS max_review_time_min
FROM catalog_quality;


-- ──────────────────────────────────────────────────────────
-- 3.2  ERROR TYPE FREQUENCY — Root-Cause Classification
-- ──────────────────────────────────────────────────────────

SELECT
    error_type,
    COUNT(catalog_id)                                                      AS occurrences,
    ROUND(COUNT(catalog_id) * 100.0 /
          (SELECT COUNT(*) FROM catalog_quality WHERE has_error = 1), 2)   AS share_of_total_errors_pct
FROM catalog_quality
WHERE has_error = 1
GROUP BY error_type
ORDER BY occurrences DESC;


-- ──────────────────────────────────────────────────────────
-- 3.3  CATEGORY-LEVEL ERROR BREAKDOWN
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    COUNT(catalog_id)                                        AS items_reviewed,
    SUM(has_error)                                           AS errors,
    ROUND(AVG(has_error) * 100, 2)                          AS error_rate_pct,
    ROUND(AVG(approved) * 100, 2)                           AS approval_rate_pct,
    ROUND(AVG(review_time_min), 2)                          AS avg_review_time_min
FROM catalog_quality
GROUP BY category
ORDER BY error_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 3.4  ERROR TYPE BY CATEGORY (Cross-Tab for Heatmap)
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    error_type,
    COUNT(catalog_id)       AS count
FROM catalog_quality
WHERE has_error = 1
GROUP BY category, error_type
ORDER BY category, count DESC;


-- ──────────────────────────────────────────────────────────
-- 3.5  ANALYST ACCURACY AND PRODUCTIVITY SCORECARD
-- ──────────────────────────────────────────────────────────

SELECT
    analyst_id,
    COUNT(catalog_id)                                                    AS total_items,
    SUM(has_error)                                                       AS errors_flagged,
    SUM(rework_required)                                                 AS rework_items,
    ROUND((COUNT(catalog_id) - SUM(has_error)) * 100.0
          / COUNT(catalog_id), 2)                                        AS accuracy_pct,
    ROUND(AVG(review_time_min), 2)                                       AS avg_review_time_min,
    ROUND(COUNT(catalog_id) / AVG(review_time_min), 2)                   AS items_per_minute
FROM catalog_quality
GROUP BY analyst_id
ORDER BY accuracy_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 3.6  ANALYSTS FLAGGED — Error Rate Above 40%
-- ──────────────────────────────────────────────────────────

SELECT
    analyst_id,
    COUNT(catalog_id)                AS total_items,
    SUM(has_error)                   AS errors,
    ROUND(AVG(has_error) * 100, 2)   AS error_rate_pct,
    ROUND(AVG(review_time_min), 2)   AS avg_review_time_min
FROM catalog_quality
GROUP BY analyst_id
HAVING ROUND(AVG(has_error) * 100, 2) > 40
ORDER BY error_rate_pct DESC;


-- ──────────────────────────────────────────────────────────
-- 3.7  REVIEW TIME DISTRIBUTION (Efficiency Buckets)
-- ──────────────────────────────────────────────────────────

SELECT
    CASE
        WHEN review_time_min < 10   THEN '1 - Under 10 min'
        WHEN review_time_min < 20   THEN '2 - 10 to 19 min'
        WHEN review_time_min < 30   THEN '3 - 20 to 29 min'
        ELSE                             '4 - 30 min and above'
    END                                     AS time_bucket,
    COUNT(catalog_id)                       AS items,
    ROUND(AVG(has_error) * 100, 2)         AS avg_error_rate_pct,
    ROUND(AVG(approved) * 100, 2)          AS avg_approval_rate_pct
FROM catalog_quality
GROUP BY time_bucket
ORDER BY time_bucket;


-- ──────────────────────────────────────────────────────────
-- 3.8  WEEKLY QUALITY TREND
-- ──────────────────────────────────────────────────────────

-- PostgreSQL version
SELECT
    DATE_TRUNC('week', date::DATE)          AS week_start,
    COUNT(catalog_id)                       AS items_reviewed,
    ROUND(AVG(has_error) * 100, 2)         AS error_rate_pct,
    ROUND(AVG(approved) * 100, 2)          AS approval_rate_pct,
    ROUND(AVG(review_time_min), 2)         AS avg_review_time_min
FROM catalog_quality
GROUP BY 1
ORDER BY 1;

-- MySQL version (uncomment if using MySQL)
-- SELECT
--     DATE_FORMAT(date, '%Y-%u')              AS year_week,
--     COUNT(catalog_id)                       AS items_reviewed,
--     ROUND(AVG(has_error) * 100, 2)         AS error_rate_pct,
--     ROUND(AVG(approved) * 100, 2)          AS approval_rate_pct,
--     ROUND(AVG(review_time_min), 2)         AS avg_review_time_min
-- FROM catalog_quality
-- GROUP BY year_week
-- ORDER BY year_week;


-- ──────────────────────────────────────────────────────────
-- 3.9  REWORK COST ESTIMATE (by Avg Review Time)
-- ──────────────────────────────────────────────────────────

SELECT
    category,
    SUM(rework_required)                                        AS rework_items,
    ROUND(SUM(rework_required) * AVG(review_time_min), 2)      AS est_rework_minutes,
    ROUND(SUM(rework_required) * AVG(review_time_min) / 60, 2) AS est_rework_hours
FROM catalog_quality
WHERE rework_required = 1
GROUP BY category
ORDER BY est_rework_hours DESC;


-- ──────────────────────────────────────────────────────────
-- 3.10  CLEAN ITEMS APPROVED FIRST PASS (No Rework)
-- ──────────────────────────────────────────────────────────

SELECT
    analyst_id,
    COUNT(catalog_id)                           AS total_items,
    SUM(CASE WHEN approved = 1 AND rework_required = 0 THEN 1 ELSE 0 END) AS first_pass_approvals,
    ROUND(
        SUM(CASE WHEN approved = 1 AND rework_required = 0 THEN 1 ELSE 0 END) * 100.0
        / COUNT(catalog_id), 2
    )                                           AS first_pass_rate_pct
FROM catalog_quality
GROUP BY analyst_id
ORDER BY first_pass_rate_pct DESC;
