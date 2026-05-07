-- Cyclistic Bike-Share Data Analysis (August 2024 - July 2025)
-- Author: William Hill
-- Description: SQL queries used to clean, merge, and analyze 12 months
--              of Cyclistic ride data to compare casual vs member behavior

-- =============================================
-- 1. Merge and clean all 12 monthly datasets
-- =============================================
CREATE TABLE cyclistic_full_year AS
SELECT 
    ride_id,
    member_casual,
    ride_length,
    day_of_week,
    started_at,
    ended_at,
    EXTRACT(MONTH FROM started_at) AS month,
    EXTRACT(YEAR FROM started_at) AS year
FROM (
    SELECT * FROM cyclistic_aug_2024
    UNION ALL SELECT * FROM cyclistic_sep_2024
    UNION ALL SELECT * FROM cyclistic_oct_2024
    UNION ALL SELECT * FROM cyclistic_nov_2024
    UNION ALL SELECT * FROM cyclistic_dec_2024
    UNION ALL SELECT * FROM cyclistic_jan_2025
    UNION ALL SELECT * FROM cyclistic_feb_2025
    UNION ALL SELECT * FROM cyclistic_mar_2025
    UNION ALL SELECT * FROM cyclistic_apr_2025
    UNION ALL SELECT * FROM cyclistic_may_2025
    UNION ALL SELECT * FROM cyclistic_jun_2025
    UNION ALL SELECT * FROM cyclistic_jul_2025
)
WHERE ride_length > 0 
    AND ride_id IS NOT NULL;

-- =============================================
-- 2. Total rides by member type per month
-- =============================================
SELECT 
    year,
    month,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_full_year
GROUP BY year, month, member_casual
ORDER BY year, month, member_casual;

-- =============================================
-- 3. Average ride length by member type per month
-- =============================================
SELECT 
    year,
    month,
    member_casual,
    ROUND(AVG(ride_length), 2) AS avg_ride_length_seconds,
    ROUND(AVG(ride_length) / 60, 2) AS avg_ride_length_minutes
FROM cyclistic_full_year
GROUP BY year, month, member_casual
ORDER BY year, month, member_casual;

-- =============================================
-- 4. Most common day of week by member type
-- =============================================
SELECT 
    member_casual,
    day_of_week,
    COUNT(*) AS ride_count
FROM cyclistic_full_year
GROUP BY member_casual, day_of_week
ORDER BY member_casual, ride_count DESC;

-- =============================================
-- 5. Overall casual vs member ride comparison
-- =============================================
SELECT 
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length) / 60, 2) AS avg_ride_minutes,
    ROUND(MAX(ride_length) / 60, 2) AS max_ride_minutes
FROM cyclistic_full_year
GROUP BY member_casual;

-- =============================================
-- 6. Rides by day of week — seasonal breakdown
-- =============================================
SELECT 
    year,
    month,
    day_of_week,
    member_casual,
    COUNT(*) AS ride_count
FROM cyclistic_full_year
GROUP BY year, month, day_of_week, member_casual
ORDER BY year, month, day_of_week;

-- =============================================
-- 7. Month-over-month ride volume growth
-- =============================================
SELECT 
    year,
    month,
    member_casual,
    COUNT(*) AS total_rides,
    COUNT(*) - LAG(COUNT(*)) OVER (
        PARTITION BY member_casual ORDER BY year, month
    ) AS change_from_prior_month
FROM cyclistic_full_year
GROUP BY year, month, member_casual
ORDER BY member_casual, year, month;

-- =============================================
-- 8. Rides by season
-- =============================================
SELECT 
    member_casual,
    CASE 
        WHEN month IN (12, 1, 2) THEN 'Winter'
        WHEN month IN (3, 4, 5) THEN 'Spring'
        WHEN month IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length) / 60, 2) AS avg_ride_minutes
FROM cyclistic_full_year
GROUP BY member_casual, season
ORDER BY member_casual, total_rides DESC;

-- =============================================
-- 9. Weekend vs weekday ride split by member type
--    (1=Sunday, 7=Saturday in this dataset)
-- =============================================
SELECT 
    member_casual,
    CASE 
        WHEN day_of_week IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length) / 60, 2) AS avg_ride_minutes
FROM cyclistic_full_year
GROUP BY member_casual, day_type
ORDER BY member_casual, total_rides DESC;

-- =============================================
-- 10. Identify rides over 60 minutes (potential outliers)
-- =============================================
SELECT 
    member_casual,
    COUNT(*) AS rides_over_60_min,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 2) AS pct_of_total
FROM cyclistic_full_year
WHERE ride_length > 3600
GROUP BY member_casual;
