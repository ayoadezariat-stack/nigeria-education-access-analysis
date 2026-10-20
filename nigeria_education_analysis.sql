/*
PROJECT: Nigeria Education Access, Gender and Literacy Analysis
TOOL: PostgreSQL
DATABASE: global_education_db
TABLE: public.nigeria_education_indicators

OBJECTIVE:
Explore selected Nigerian education indicators, compare gender
and geographic gaps, examine available-year changes, and check
basic data quality.

DATA LIMITATION:
This selected dataset contains 46 records for 11 indicators.
Its observations are sparse and cover 1991–2010. Results should
not be interpreted as current education statistics or as a
complete annual time series.
*/


-- =========================================================
-- 1. DATASET OVERVIEW
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT indicator_code) AS unique_indicators,
    COUNT(DISTINCT year) AS unique_years,
    MIN(year) AS earliest_year,
    MAX(year) AS latest_year,
    COUNT(DISTINCT country_code) AS countries
FROM public.nigeria_education_indicators;


-- =========================================================
-- 2. CHECK FOR MISSING VALUES
-- =========================================================

SELECT
    COUNT(*) FILTER (WHERE country_name IS NULL) AS missing_country_names,
    COUNT(*) FILTER (WHERE indicator_name IS NULL) AS missing_indicator_names,
    COUNT(*) FILTER (WHERE indicator_code IS NULL) AS missing_indicator_codes,
    COUNT(*) FILTER (WHERE year IS NULL) AS missing_years,
    COUNT(*) FILTER (WHERE value IS NULL) AS missing_values
FROM public.nigeria_education_indicators;


-- =========================================================
-- 3. CHECK FOR DUPLICATE COUNTRY-INDICATOR-YEAR RECORDS
-- =========================================================

SELECT
    country_code,
    indicator_code,
    year,
    COUNT(*) AS record_count
FROM public.nigeria_education_indicators
GROUP BY country_code, indicator_code, year
HAVING COUNT(*) > 1
ORDER BY indicator_code, year;


-- =========================================================
-- 4. CHECK PERCENTAGE VALUES OUTSIDE THE EXPECTED RANGE
-- =========================================================

SELECT
    indicator_code,
    indicator_name,
    year,
    value
FROM public.nigeria_education_indicators
WHERE value < 0 OR value > 100
ORDER BY indicator_code, year;


-- =========================================================
-- 5. INDICATOR COVERAGE
-- =========================================================

SELECT
    indicator_code,
    indicator_name,
    COUNT(*) AS number_of_records,
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM public.nigeria_education_indicators
GROUP BY indicator_code, indicator_name
ORDER BY indicator_code;


-- =========================================================
-- 6. RECORDS AND INDICATORS AVAILABLE BY YEAR
-- =========================================================

SELECT
    year,
    COUNT(*) AS number_of_records,
    COUNT(DISTINCT indicator_code) AS indicators_available
FROM public.nigeria_education_indicators
GROUP BY year
ORDER BY year;


-- =========================================================
-- 7. DESCRIPTIVE STATISTICS BY INDICATOR
-- =========================================================

SELECT
    indicator_code,
    indicator_name,
    MIN(value) AS minimum_value,
    MAX(value) AS maximum_value,
    ROUND(AVG(value), 2) AS average_value
FROM public.nigeria_education_indicators
GROUP BY indicator_code, indicator_name
ORDER BY indicator_code;


-- =========================================================
-- 8. PRIMARY ENROLMENT: MALE-FEMALE GAP BY YEAR
-- =========================================================

SELECT
    male.year,
    male.value AS male_enrolment_rate,
    female.value AS female_enrolment_rate,
    ROUND(male.value - female.value, 2)
        AS gender_gap_percentage_points
FROM public.nigeria_education_indicators AS male
JOIN public.nigeria_education_indicators AS female
    ON male.year = female.year
WHERE male.indicator_code = 'SE.PRM.TENR.MA'
  AND female.indicator_code = 'SE.PRM.TENR.FE'
ORDER BY male.year;


-- =========================================================
-- 9. SUMMARY OF PRIMARY ENROLMENT GENDER GAP
-- =========================================================

WITH gender_comparison AS (
    SELECT
        male.year,
        male.value AS male_rate,
        female.value AS female_rate,
        male.value - female.value AS gender_gap
    FROM public.nigeria_education_indicators AS male
    JOIN public.nigeria_education_indicators AS female
        ON male.year = female.year
    WHERE male.indicator_code = 'SE.PRM.TENR.MA'
      AND female.indicator_code = 'SE.PRM.TENR.FE'
)
SELECT
    COUNT(*) AS matched_years,
    ROUND(AVG(gender_gap), 2) AS average_gap,
    ROUND(MIN(gender_gap), 2) AS smallest_gap,
    ROUND(MAX(gender_gap), 2) AS largest_gap
FROM gender_comparison;


-- =========================================================
-- 10. URBAN-RURAL PRIMARY COMPLETION GAP
-- =========================================================

SELECT
    rural.year,
    rural.value AS rural_completion_rate,
    urban.value AS urban_completion_rate,
    ROUND(urban.value - rural.value, 2)
        AS urban_rural_gap_percentage_points
FROM public.nigeria_education_indicators AS rural
JOIN public.nigeria_education_indicators AS urban
    ON rural.year = urban.year
WHERE rural.indicator_code = 'HH.DHS.PCR.R'
  AND urban.indicator_code = 'HH.DHS.PCR.U'
ORDER BY rural.year;


-- =========================================================
-- 11. ADULT LITERACY: MALE-FEMALE GAP
-- =========================================================

SELECT
    male.year,
    male.value AS male_literacy_rate,
    female.value AS female_literacy_rate,
    ROUND(male.value - female.value, 2)
        AS gender_gap_percentage_points
FROM public.nigeria_education_indicators AS male
JOIN public.nigeria_education_indicators AS female
    ON male.year = female.year
WHERE male.indicator_code = 'SE.ADT.LITR.MA.ZS'
  AND female.indicator_code = 'SE.ADT.LITR.FE.ZS'
ORDER BY male.year;


-- =========================================================
-- 12. PRIMARY ENROLMENT: EARLIEST-TO-LATEST CHANGE
-- =========================================================

WITH enrolment_summary AS (
    SELECT
        indicator_code,
        indicator_name,
        FIRST_VALUE(value) OVER (
            PARTITION BY indicator_code
            ORDER BY year
        ) AS first_value,
        FIRST_VALUE(year) OVER (
            PARTITION BY indicator_code
            ORDER BY year
        ) AS first_year,
        LAST_VALUE(value) OVER (
            PARTITION BY indicator_code
            ORDER BY year
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS last_value,
        LAST_VALUE(year) OVER (
            PARTITION BY indicator_code
            ORDER BY year
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS last_year
    FROM public.nigeria_education_indicators
    WHERE indicator_code IN (
        'SE.PRM.TENR',
        'SE.PRM.TENR.FE',
        'SE.PRM.TENR.MA'
    )
)
SELECT DISTINCT
    indicator_code,
    indicator_name,
    first_year,
    first_value,
    last_year,
    last_value,
    ROUND(last_value - first_value, 2)
        AS change_percentage_points
FROM enrolment_summary
ORDER BY indicator_code;


-- =========================================================
-- 13. PRIMARY ENROLMENT GENDER GAP AT ENDPOINTS
-- =========================================================

WITH gender_comparison AS (
    SELECT
        male.year,
        male.value AS male_rate,
        female.value AS female_rate
    FROM public.nigeria_education_indicators AS male
    JOIN public.nigeria_education_indicators AS female
        ON male.year = female.year
    WHERE male.indicator_code = 'SE.PRM.TENR.MA'
      AND female.indicator_code = 'SE.PRM.TENR.FE'
)
SELECT
    year,
    ROUND(male_rate - female_rate, 2)
        AS gender_gap_percentage_points
FROM gender_comparison
WHERE year IN (1999, 2010)
ORDER BY year;


-- =========================================================
-- 14. OVERALL ADULT LITERACY: EARLIEST-TO-LATEST CHANGE
-- =========================================================

WITH literacy_summary AS (
    SELECT
        year,
        value,
        FIRST_VALUE(value) OVER (
            ORDER BY year
        ) AS earliest_value,
        FIRST_VALUE(year) OVER (
            ORDER BY year
        ) AS earliest_year,
        LAST_VALUE(value) OVER (
            ORDER BY year
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS latest_value,
        LAST_VALUE(year) OVER (
            ORDER BY year
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS latest_year
    FROM public.nigeria_education_indicators
    WHERE indicator_code = 'SE.ADT.LITR.ZS'
)
SELECT DISTINCT
    earliest_year,
    earliest_value,
    latest_year,
    latest_value,
    ROUND(latest_value - earliest_value, 2)
        AS change_percentage_points
FROM literacy_summary;