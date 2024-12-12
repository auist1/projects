CREATE TABLE teachers (
id INT IDENTITY (1,1) PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
age INT,
city VARCHAR(50),
course_name VARCHAR(100),
salary REAL
);

INSERT INTO teachers (first_name, last_name, age, city, course_name,
salary) VALUES
('Adam', 'Smith', 35, 'New York', 'Web Development', 5000),
('John', 'Doe', 33, 'Los Angeles', 'Data Science', 4000),
('Emily', 'Johnson', 34, 'Boston', 'Database Administration', 3000),
('Michael', 'Brown', 30, 'Houston', 'Database Administration', 3000),
('Sarah', 'Wilson', 30, 'San Francisco', 'Database Management', 3500),
('David', 'Martinez', 36, 'Miami', 'Java Development', 4000.5),
('Laura', 'Garcia', 38, 'Washington D.C.', 'Mobile App Development',
5550),
('Daniel', 'Rodriguez', 44, 'Boston', 'Python Programming', 3999.5),
('Jessica', 'Davis', 32, 'New York', 'Data Science', 2999.5),
('Ashley', 'Hernandez', 32, 'Boston', 'UI/UX Design', 2999.5),
('Jason', 'Perez', 40, 'New York', 'Cybersecurity', 5550),
('Amanda', 'Carter', 32, 'Phoenix', 'Machine Learning', 2550.22),
('Kevin', 'Parker', 32, 'Philadelphia', 'Database Administration', 3000.5),
('Rachel', 'Lopez', 37, 'New York', 'Cybersecurity', 3000.5);

CREATE TABLE courses (
course_id INT IDENTITY (1,1) PRIMARY KEY,
course_name VARCHAR(100) UNIQUE,
credit INT,
course_fee NUMERIC(6, 2),
start_date DATE,
finish_date DATE
);

INSERT INTO courses (course_name, credit, course_fee, start_date,
finish_date) VALUES
('Web Development', 10, 100.05, '1990-01-10', '1990-02-10'),
('Data Science', 8, 120.25, '1990-02-11', '1990-02-28'),
('Database Administration', 6, 200.15, '1990-03-03', '1990-03-12'),
('Programming Fundamentals', 26, 159.99, '1990-11-03', '1991-01-12'),
('Database Management', 6, 175.55, '1990-01-03', '1990-03-12'),
('Java Development', 12, 255.85, '1990-06-03', '1990-07-12'),('Mobile App Development', 6, 125.99, '1990-03-03', '1990-03-22'),
('Python Programming', 5, 125.99, '1990-04-03', '1990-04-22'),
('Frontend Development', 10, 199.99, '1990-05-03', '1990-05-31');

-- List the names and credit numbers of the courses taught by teachers under the age of 35.
SELECT DISTINCT
	c.course_name,
	c.credit
FROM courses c 
LEFT JOIN teachers t 
ON c.course_name=t.course_name
WHERE t.age<35

-- List the names and credits of the courses offered in each city.
SELECT DISTINCT 
	city,
	t.course_name,
	SUM(credit) as TotalCredit
FROM teachers t
LEFT JOIN courses c
ON t.course_name=c.course_name
GROUP BY city, t.course_name

-- List the names and start dates of the courses taught by teachers living in New York.
SELECT DISTINCT
	t.course_name,
	c.start_date
FROM teachers t 
LEFT JOIN courses c 
ON t.course_name=c.course_name
WHERE t.city = 'New York'

-- List the names (first names) of the teachers living in New York, the names of the courses they teach, and the end dates of those courses.
SELECT 
	t.first_name,
	t.course_name,
	c.finish_date
FROM teachers t
LEFT JOIN courses c 
ON c.course_name=t.course_name
WHERE city = 'New York'

-- Find the average salary of teachers who teach courses that started before '1990-06-03'.
SELECT
	ROUND(AVG(salary),2) AS AverageSalary
FROM teachers t
LEFT JOIN courses c 
ON c.course_name=t.course_name
WHERE start_date<'1990-06-03'

-- Calculate the total salary of teachers who teach courses that started between February and May 1990.
SELECT
	SUM(salary) AS TotalSalary
FROM teachers t
LEFT JOIN courses c 
ON c.course_name=t.course_name
WHERE start_date BETWEEN '1990-01-31' AND '1990-06-01'

-- List the names, credits of courses with fees greater than 125, and the maximum and minimum salaries of the teachers who teach these courses.

SELECT 
	A.course_name,
	credit,
	MIN(A.salary) AS Minimum,
	MAX(A.salary) AS Maximum
FROM
(SELECT 
	t.first_name,
	c.course_name,
	c.credit,
	t.salary
FROM courses c
LEFT JOIN teachers t
ON t.course_name=c.course_name
WHERE c.course_fee>125) A
GROUP BY A.course_name, credit

--If John Doe's salary is greater than the average salary, list all his information.
SELECT *
FROM
teachers
WHERE first_name = 'John' AND last_name='Doe' AND salary>(SELECT AVG(salary) FROM teachers)

-- Update the age of teachers over 37 to the minimum age of those taking the Java Development course.
UPDATE teachers
SET age = (
    SELECT MIN(age)
    FROM teachers t
    JOIN courses c ON t.course_name = c.course_name
    WHERE c.course_name = 'Java Development'
)
WHERE age > 37;

-- If there are teachers over the age of 35, list the names and start dates of the courses they teach.

SELECT 
	t.first_name,
	c.start_date
FROM teachers t 
LEFT JOIN courses c 
ON t.course_name=C.course_name
WHERE t.age>35

-- List the names, start dates, and finish dates of courses not taught by any teacher.
SELECT 
	c.course_name,
	c.start_date,
	c.finish_date
FROM courses c
LEFT JOIN teachers t 
ON t.course_name=c.course_name
WHERE t.first_name IS NULL

-- Increase the fees of courses taught by at least one teacher by 10.
UPDATE teachers 
SET salary = ( 
SELECT salary * 1.1
FROM teachers 
WHERE id=1
)
WHERE id=1

-- If there is a course with a fee greater than 170, list all the information of the teachers who teach this course.
SELECT *
FROM teachers t
LEFT JOIN courses c
ON c.course_name=t.course_name
WHERE c.course_fee>170

-- Change the city of the teacher whose salary is higher than the average salary to Denver.
UPDATE teachers
SET city = 'Denver'
WHERE salary > (SELECT AVG(salary) FROM teachers)
