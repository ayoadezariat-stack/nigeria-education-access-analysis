Nigeria Education Access, Gender and Literacy Analysis Using PostgreSQL

Project Overview

This project explores selected education indicators for Nigeria using PostgreSQL and data from the World Bank’s Education Statistics (EdStats) dataset. The analysis focuses on primary school enrolment, gender differences in enrolment, primary completion rates, urban-rural differences in primary completion, and adult literacy rates.

The purpose of the project is to demonstrate how SQL can be used to clean and validate data, summarise education indicators, compare groups, and identify patterns that may be useful for education planning and further research.

Dataset

The project uses a selected subset of World Bank education indicators for Nigeria.

* Country: Nigeria
* Total records: 46
* Distinct indicators: 11
* Observation years: 1991–2010
* Database: PostgreSQL
* Table: nigeria_education_indicators

The dataset contains selected observations rather than a complete annual series for every indicator.

Questions Explored

1. What education indicators and observation years are represented in the dataset?
2. Are there missing values, duplicate records, or values outside the expected percentage range?
3. How do male and female primary enrolment rates compare?
4. How do urban and rural primary completion rates compare?
5. How do adult literacy rates differ between males and females?
6. How do the earliest and latest available observations compare for selected indicators?

Tools and SQL Techniques

* PostgreSQL and pgAdmin 4
* Data quality checks
* Filtering and sorting
* Aggregations using COUNT, AVG, MIN, and MAX
* Joins to compare male and female or urban and rural indicators
* Common Table Expressions (CTEs)
* Window functions for comparing earliest and latest observations
* Percentage-point difference calculations

Key Findings

Primary Enrolment

The adjusted net primary enrolment rate for both sexes increased from approximately 62.91% in 1999 to 65.67% in 2010, a difference of 2.76 percentage points between the two observations.

Female enrolment increased from approximately 57.36% to 59.97%, while male enrolment increased from approximately 68.25% to 71.12% over the same endpoints.

These are comparisons between the earliest and latest available observations, not evidence of a continuous annual trend.

Gender Gap in Primary Enrolment

Male primary enrolment rates were higher than female rates in all nine matched observation years in the dataset. The average gap across those years was approximately 10.84 percentage points.

The gap was approximately 10.88 percentage points in 1999 and 11.15 percentage points in 2010. Because the dataset does not contain every year, these results should not be interpreted as a continuous trend.

Urban-Rural Primary Completion

The recorded urban primary completion rate exceeded the rural rate by approximately 9.83 percentage points in 2003 and 22.80 percentage points in 2008.

This comparison is based on only two observation years and cannot establish a continuous trend or explain the reasons for the difference.

Adult Literacy and Gender

The recorded adult literacy rate for males exceeded the female rate in all three available matched years. The gap narrowed from approximately 23.92 percentage points in 1991 to 19.87 percentage points in 2008.

However, the recorded male, female, and overall adult literacy rates were lower in 2008 than in 1991. These endpoint comparisons do not establish a continuous decline or its cause.

Data Quality Checks

The SQL checks found:

* No missing values in the six fields examined.
* No duplicate combinations of country, indicator, and year.
* No values below 0 or above 100 in the percentage-based records checked.

These checks cover the selected dataset and do not establish that the original source data is free from all possible errors.

Limitations

The analysis uses only 46 records covering 11 selected indicators. Observation years are sparse and vary by indicator, and the latest available year in this extract is 2010. The results therefore should not be presented as a description of Nigeria’s current education situation.

The analysis identifies differences and comparisons but does not establish causation. Indicator definitions, survey methods, and source metadata should be checked before making policy conclusions.

Project Files

* nigeria_education_analysis.sql — SQL queries used for data validation, summaries, comparisons, and endpoint analysis.
* README.md — Project documentation and summary of findings.

Conclusion

This project demonstrates how PostgreSQL can be used to examine selected education indicators, validate records, and compare enrolment, completion, and literacy outcomes across groups. It also highlights the importance of checking data coverage and limitations before drawing conclusions from statistical results.

Data Source

World Bank, Education Statistics (EdStats). The project uses a selected extract of education indicators for Nigeria. The original dataset and indicator metadata should be consulted when reproducing or extending the analysis.