--1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

ALTER TABLE 
	fresh_segments.interest_metrics
DROP COLUMN 
	month_year

ALTER TABLE 
	fresh_segments.interest_metrics
ADD  
	month_year DATE

UPDATE 
	fresh_segments.interest_metrics
SET 
	month_year=CAST(_year + '-' + _month + '-01' AS DATE)


SELECT 
	DATA_TYPE
FROM 
	INFORMATION_SCHEMA.COLUMNS
WHERE 
	TABLE_NAME = 'interest_metrics' AND TABLE_SCHEMA = 'fresh_segments';

--2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

SELECT 
	month_year,
	COUNT(*) AS CountofRecords
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year ASC

--3. What do you think we should do with these null values in the fresh_segments.interest_metrics
SELECT 
    SUM(CASE WHEN month_year IS NULL THEN 1 ELSE 0 END) AS NumberofNullValues,
    COUNT(*) AS NumberofAllValues,
    CAST(SUM(CASE WHEN month_year IS NULL THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS Ratio
FROM fresh_segments.interest_metrics;

DELETE 
FROM fresh_segments.interest_metrics
WHERE month_year IS NULL

SELECT 
    SUM(CASE WHEN _month IS NULL THEN 1 ELSE 0 END) AS NullInMonth,
    SUM(CASE WHEN _year IS NULL THEN 1 ELSE 0 END) AS NullInYear,
    SUM(CASE WHEN interest_id IS NULL THEN 1 ELSE 0 END) AS NullInInterestid,
	SUM(CASE WHEN index_value IS NULL THEN 1 ELSE 0 END) AS NullInIndexValue,
	SUM(CASE WHEN ranking IS NULL THEN 1 ELSE 0 END) AS NullInRanking,
	SUM(CASE WHEN percentile_ranking IS NULL THEN 1 ELSE 0 END) AS NullInPercentileRanking,
	SUM(CASE WHEN month_year IS NULL THEN 1 ELSE 0 END) AS Month_Year
FROM fresh_segments.interest_metrics;

--We can delete the null values since their proportion in dataset is around 8%. 

--4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

SELECT 
	COUNT(*) AS Notinmetrics
FROM
(SELECT 
	id, interest_id 
FROM fresh_segments.interest_map ma
	LEFT JOIN fresh_segments.interest_metrics me
ON ma.id=me.interest_id
WHERE interest_id IS NULL) A 

SELECT 
	COUNT(*) AS Notinmap
FROM
(SELECT 
	 interest_id,id
FROM fresh_segments.interest_metrics me
	LEFT JOIN fresh_segments.interest_map ma
ON ma.id=me.interest_id
WHERE interest_id IS NULL) A 

--5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table.

SELECT 
	interest_name,
	COUNT(interest_id) AS Record
FROM fresh_segments.interest_map ma
JOIN fresh_segments.interest_metrics me
ON ma.id=me.interest_id
GROUP BY interest_name
ORDER BY Record DESC

--6. What sort of table join should we perform for our analysis and why? 
--Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns 
--from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

SELECT 
	_month, _year, interest_id, composition, index_value, ranking, percentile_ranking, month_year, interest_name, interest_summary, created_at, last_modified
FROM fresh_segments.interest_metrics me 
INNER JOIN fresh_segments.interest_map ma 
ON me.interest_id=ma.id
WHERE interest_id = 21246

--We should use inner join due to there are 7 id values in maps table which do not take place in metrics table. 


--7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

SELECT 
	_month, _year, interest_id, composition, index_value, ranking, percentile_ranking, month_year, interest_name, interest_summary, created_at, last_modified
FROM fresh_segments.interest_metrics me 
INNER JOIN fresh_segments.interest_map ma 
ON me.interest_id=ma.id
WHERE month_year<created_at

--There are 188 rows that match this condition. However, all of them fall within the same month. Since we assign the first day of the month to the month_year column, 
--it appears that the month_year date is earlier than the created_at date, which is not actually the case.


--8. Which interests have been present in all month_year dates in our dataset?
SELECT 
	interest_id, 
	COUNT (DISTINCT month_year) AS NumberofMonths
FROM
fresh_segments.interest_metrics me
GROUP BY interest_id
HAVING COUNT (DISTINCT month_year)=14

--9. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH CountofMonths AS (
  SELECT 
    interest_id, 
    COUNT(DISTINCT month_year) AS CountofMonths
  FROM
    fresh_segments.interest_metrics me
  GROUP BY interest_id
),
CountofID AS (
  SELECT
    CountofMonths, 
    COUNT(DISTINCT interest_id) AS CountofID
  FROM CountofMonths
  GROUP BY CountofMonths
),
Cumulative AS (
  SELECT
    CountofMonths,
    CountofID,
    ROUND(
      SUM(CountofID) OVER (ORDER BY CountofMonths DESC) * 100.0 / 
      (SELECT SUM(CountofID) FROM CountofID), 
      2
    ) AS Cumulative
  FROM CountofID
)
SELECT *
FROM Cumulative
WHERE Cumulative > 90

--10. What is the top 10 interests by the average composition for each month?
WITH AverageComp AS (
SELECT
	interest_name,
	month_year,
	AVG(composition) AS AverageComp

FROM fresh_segments.interest_metrics me
JOIN fresh_segments.interest_map ma
ON ma.id=me.interest_id
GROUP BY interest_name, month_year
)
SELECT TOP 10
	interest_name,
	RANK () OVER(PARTITION BY month_year ORDER BY AverageComp DESC ) AS Ranking,
	AverageComp
FROM AverageComp
