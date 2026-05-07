# Cyclistic Bike-Share Data Analysis (August 2024 – July 2025)

## Overview
This project is a Google Data Analytics capstone case study analyzing 12 months of Cyclistic bike-share data to uncover behavioral differences between **casual riders** and **annual members**. The goal was to identify patterns that could inform a targeted marketing strategy to convert casual riders into annual members.

A full presentation of findings and recommendations was produced alongside this analysis.

---

## Tools Used
- **SQL** — Data cleaning, merging, and aggregation across 12 monthly datasets
- **Excel** — Pivot tables, ride length calculations, day-of-week analysis, and summary statistics
- **Tableau / Charts** — Visualizations of ride volume, ride length trends, and usage patterns by month

---

## Dataset
- **Source:** Cyclistic historical trip data (12 months: August 2024 – July 2025)
- **Fields:** Ride ID, Member/Casual flag, Ride Length, Day of Week
- **Scale:** Over 5.6 million individual ride records across 12 monthly CSV files
- **Cleaning:** Timestamp normalization, duplicate removal, null value handling, ride length formatting

---

## SQL Queries

### Merge and clean all 12 monthly datasets
```sql
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
```

### Total rides by member type per month
```sql
SELECT 
    year,
    month,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_full_year
GROUP BY year, month, member_casual
ORDER BY year, month, member_casual;
```

### Average ride length by member type per month
```sql
SELECT 
    year,
    month,
    member_casual,
    ROUND(AVG(ride_length), 2) AS avg_ride_length_seconds,
    ROUND(AVG(ride_length) / 60, 2) AS avg_ride_length_minutes
FROM cyclistic_full_year
GROUP BY year, month, member_casual
ORDER BY year, month, member_casual;
```

### Most common day of week by member type
```sql
SELECT 
    member_casual,
    day_of_week,
    COUNT(*) AS ride_count
FROM cyclistic_full_year
GROUP BY member_casual, day_of_week
ORDER BY member_casual, ride_count DESC;
```

### Compare casual vs member ride behavior side by side
```sql
SELECT 
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length) / 60, 2) AS avg_ride_minutes,
    ROUND(MAX(ride_length) / 60, 2) AS max_ride_minutes
FROM cyclistic_full_year
GROUP BY member_casual;
```

### Rides by day of week — seasonal breakdown
```sql
SELECT 
    year,
    month,
    day_of_week,
    member_casual,
    COUNT(*) AS ride_count
FROM cyclistic_full_year
GROUP BY year, month, day_of_week, member_casual
ORDER BY year, month, day_of_week;
```

---

## Key Findings

| Metric | Casual Riders | Annual Members |
|---|---|---|
| Peak day of week | Saturday (most months) | Weekdays (Mon–Thu) |
| Average ride length | ~21–26 min (summer) | ~11–13 min (consistent) |
| Peak month (rides) | August–September | August–October |
| Winter usage | Drops significantly | Remains relatively stable |

- **Casual riders consistently took longer rides** — averaging nearly double the ride length of members across all months
- **Members rode most on weekdays**, suggesting commuting as their primary use case
- **Casual riders peaked on weekends**, pointing to recreational usage
- **Summer months drove the majority of casual rides**, while member volume stayed more consistent year-round

---

## Recommendations
1. **Weekend membership campaign** — Show casual riders how much they'd save by upgrading, with messaging like *"You rode X times this month — a membership would have saved you $X"*
2. **In-app conversion nudges** — After a casual rider logs multiple weekend rides in a row, trigger a personalized push notification encouraging them to upgrade
3. **Year-round commuting promotion** — Market memberships as a reliable commuting option, with winter perks like gear discounts and guaranteed bike availability to drive off-season retention

---

## Files
- [Cyclistic_data_analysis](https://divvy-tripdata.s3.amazonaws.com/index.html) — Monthly pivot tables, ride length summaries, and day-of-week breakdowns
- [cyclistic_queries.sql](https://github.com/bhilliv719/cyclistic-bikeshare-analysis/blob/main/queries.sql) — All SQL queries used in the analysis
- [Cyclistic_Presentation.pptx](https://github.com/bhilliv719/cyclistic-bikeshare-analysis/blob/main/Data%20analysis%20case%20study-cyclistic%20Presentation-2.pptx) — Full slide deck with charts, findings, and recommendations

---

## Author
**William Hill**  
Sports Performance Data Analyst | NCAA DI Athlete  
[LinkedIn](https://www.linkedin.com/in/william-hill-iv) 
