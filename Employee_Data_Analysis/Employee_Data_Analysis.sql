-- How many people work in the company?

SELECT 
	COUNT(EmpID) as NumberofEmp
FROM employee
	WHERE EmployeeStatus ='Active'

-- What is the proportion of each gender among total active employees?

SELECT 
    GenderCode,
    ROUND(CAST(COUNT(*) AS FLOAT) / CAST(SUM(COUNT(*)) OVER() AS FLOAT), 2) AS Shares
FROM employee
	WHERE EmployeeStatus ='Active'
	GROUP BY GenderCode;

-- List the number of active employees for each year.

SELECT 
	Year(StartDate) AS Years, 
	COUNT(*) AS NumberofActiveWorkers 
FROM employee
	WHERE EmployeeStatus ='Active'
	GROUP BY Year(StartDate)
	ORDER BY Years

-- How many people actively work in each business unit? Find the proportion of the business units in terms of employees. 

WITH NAW AS (
	SELECT 
		DepartmentType AS Departments,
		COUNT(*) AS NumberofActiveWorkers
	FROM employee
		WHERE EmployeeStatus='Active'
		GROUP BY DepartmentType
),
PROP AS (
	SELECT 
		COUNT(*) AS NOAW
	FROM employee
	WHERE EmployeeStatus='Active'
)
	SELECT 
		NAW.Departments,
		NAW.NumberofActiveWorkers,
		ROUND(CAST(NAW.NumberofActiveWorkers AS FLOAT) / CAST(PROP.NOAW AS FLOAT),2) AS PercentageOfTotalWorkers
	FROM NAW,PROP

-- Does the pay zone differ by department? Find the numbers of employees by departments for each pay zone. 

SELECT 
	DepartmentType,
	SUM(CASE WHEN PayZone ='Zone C' THEN 1 ELSE 0 END) AS 'ZoneC',
	SUM(CASE WHEN PayZone ='Zone B' THEN 1 ELSE 0 END) AS 'ZoneB',
	SUM(CASE WHEN PayZone ='Zone A' THEN 1 ELSE 0 END) AS 'ZoneA'
FROM employee
	GROUP BY DepartmentType

-- Does the pay zone differ by employee classification? Find the numbers of employees by departments for each pay zone.

SELECT 
	EmployeeClassificationType,
	SUM(CASE WHEN PayZone ='Zone C' THEN 1 ELSE 0 END) AS 'ZoneC',
	SUM(CASE WHEN PayZone ='Zone B' THEN 1 ELSE 0 END) AS 'ZoneB',
	SUM(CASE WHEN PayZone ='Zone A' THEN 1 ELSE 0 END) AS 'ZoneA'
FROM employee
	GROUP BY EmployeeClassificationType

-- Find the average scores from the engagement survey. Do average current employee rating differ by department type?

SELECT 
	DepartmentType,
	AVG(CurrentEmployeeRating) AS AverageScores
FROM employee
	GROUP BY DepartmentType

-- Calculate the average engagement score, satisfaction score and work-life balance score department by department?

SELECT 
	DepartmentType,
	AVG(EngagementScore) AS ES,
	AVG(SatisfactionScore) AS SS,
	AVG(WorkLifeBalanceScore) AS WLBS
FROM employee e
	JOIN employee_engagement_survey ees
	ON e.EmpID=ees.EmployeeID
	GROUP BY DepartmentType

-- What is the average training cost per employee?

SELECT
	AVG(TrainingCost) AS AverageCost
FROM training_and_development

-- What is the average training cost per employee when training outcome is failed?

SELECT
	AVG(TrainingCost) AS AverageCost
FROM training_and_development 
	WHERE TrainingOutcome ='Failed'

-- Find the percentage of failed employees in training and development?

WITH ALL_ AS (
    SELECT 
        COUNT(*) AS NumberofEmployees
    FROM training_and_development
),
FAILED AS (
    SELECT 
        COUNT(*) AS FailNumber
    FROM training_and_development
    WHERE TrainingOutcome = 'Failed'
)
SELECT 
    CAST(FAILED.FailNumber AS FLOAT) / CAST(ALL_.NumberofEmployees AS FLOAT) AS ShareofFail
FROM ALL_, FAILED;


-- What is the average training cost according to training program?

SELECT
	TrainingProgramName,
	AVG(TrainingCost) AS TrainingCost
FROM training_and_development
	GROUP BY TrainingProgramName
	ORDER BY TrainingCost DESC

-- What is the current employee rating by race?

SELECT 
	RaceDesc,
	AVG(CurrentEmployeeRating) AS AVGScore
FROM employee
	GROUP BY RaceDesc
