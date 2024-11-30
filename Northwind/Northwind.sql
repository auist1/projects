
-- What is the overall revenue of the company?

SELECT ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) as Total_Sales  
FROM [Order Details] od

-- What is the total quantity of sales?

SELECT ROUND(SUM(od.Quantity),0) as Total_Sales  
FROM [Order Details] od

-- What is the overall unit price?

SELECT ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))/SUM(od.Quantity),2) AS Unit_Price
FROM [Order Details] od

-- What is the total number of customers of the company?

SELECT COUNT(CompanyName) AS NumberofCustomers 
FROM Customers

-- How many countries do the company sell its products to?

SELECT COUNT(DISTINCT Country)  AS NumberofCountries
FROM Customers

-- How much is the annual sales of the firm?

SELECT YEAR(OrderDate) as Years, ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) as Total_Sales 
FROM [Order Details] od
JOIN Orders o ON od.OrderID=o.OrderID
JOIN Customers c ON c.CustomerID=o.CustomerID
GROUP BY YEAR(OrderDate)
ORDER BY Years

-- What are the annual revenues of the company for each category?

SELECT c.CategoryName, 
ROUND(SUM(CASE WHEN YEAR(o.OrderDate)=1996 THEN od.UnitPrice * od.Quantity * (1-od.Discount) END),0) AS '1996',
ROUND(SUM(CASE WHEN YEAR(o.OrderDate)=1997 THEN od.UnitPrice * od.Quantity * (1-od.Discount) END),0) AS '1997',
ROUND(SUM(CASE WHEN YEAR(o.OrderDate)=1998 THEN od.UnitPrice * od.Quantity * (1-od.Discount) END),0) AS '1998'
FROM [Order Details] od
JOIN Products p ON od.ProductID=p.ProductID
JOIN Categories c ON c.CategoryID=p.CategoryID
JOIN Orders o ON od.OrderID=o.OrderID
GROUP By c.CategoryName
ORDER BY CategoryName


-- What are the sales in the each category year by year?

SELECT 
    ca.CategoryName,
    YEAR(o.OrderDate) AS SalesYear,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) AS TotalRevenue
FROM 
    [Order Details] od
JOIN 
    Orders o ON od.OrderID = o.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Categories ca ON p.CategoryID = ca.CategoryID
WHERE 
    YEAR(o.OrderDate) IN (1996, 1997, 1998)
GROUP BY 
    ca.CategoryID, ca.CategoryName, YEAR(o.OrderDate)
ORDER BY CategoryName, SalesYear

-- List TOP 3 categories in terms of sales revenue. 

WITH TopCategories AS (
SELECT c.CategoryName, YEAR(o.OrderDate) as Years, ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)),0) as Total_Sales  
FROM [Order Details] od
JOIN Products p ON od.ProductID=p.ProductID
JOIN Categories C on c.CategoryID=p.CategoryID
JOIN Orders o ON o.OrderID=od.OrderID
GROUP By c.CategoryName, YEAR(o.OrderDate)
)
SELECT TOP 3 CategoryName, SUM(Total_Sales) AS TotalSalesPerCategory 
FROM TopCategories
GROUP BY CategoryName
ORDER BY TotalSalesPerCategory DESC

-- List the star products of each category in terms of sales revenues. Star products are the products that are sold most in each category. 

WITH TopCategories AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) AS Total_Sales  
    FROM [Order Details] od
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    JOIN Orders o ON o.OrderID = od.OrderID
    GROUP BY c.CategoryName, p.ProductName
)
SELECT CategoryName, ProductName, SUM(Total_Sales) AS TotalSales
FROM ( 
    SELECT
        CategoryName,
        ProductName, 
        Total_Sales,
        RANK() OVER(PARTITION BY CategoryName ORDER BY Total_Sales DESC) AS TopSalesperCategory
    FROM TopCategories
) AS TopSales
WHERE TopSalesperCategory = 1
GROUP BY CategoryName, ProductName
ORDER BY ProductName;

-- List the proportion of the star products in each category in the sales of related category. 

WITH TopCategories AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) AS Total_Sales  
    FROM [Order Details] od
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    JOIN Orders o ON o.OrderID = od.OrderID
    GROUP BY c.CategoryName, p.ProductName, YEAR(o.OrderDate)
),
CategoryTotals AS (
    SELECT 
        CategoryName,
        SUM(Total_Sales) AS Category_Total_Sales
    FROM TopCategories
    GROUP BY CategoryName
),
TopProducts AS (
    SELECT
        CategoryName,
        ProductName, 
        SUM(Total_Sales) AS Product_Total_Sales,
        RANK() OVER(PARTITION BY CategoryName ORDER BY SUM(Total_Sales) DESC) AS TopSalesperCategory
    FROM TopCategories
    GROUP BY CategoryName, ProductName
)
SELECT 
    tp.CategoryName, 
    tp.ProductName, 
    tp.Product_Total_Sales AS TotalSales,
    ROUND(tp.Product_Total_Sales * 100.0 / ct.Category_Total_Sales, 2) AS SalesProportion
FROM TopProducts tp
JOIN CategoryTotals ct ON tp.CategoryName = ct.CategoryName
WHERE tp.TopSalesperCategory = 1
ORDER BY tp.CategoryName;

-- List the countries where the products are sold. Determine how many customers do the company have from that related country?

SELECT DISTINCT Country, COUNT(*) as CountofCustomers 
FROM Customers
GROUP BY Country
ORDER BY CountofCustomers DESC

-- Calculate the revenues from each county.

SELECT c.Country, ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)),0) as TotalSales 
FROM Customers c
JOIN Orders o ON o.CustomerID=c.CustomerID
JOIN [Order Details] od ON od.OrderID=o.OrderID
GROUP BY c.Country
ORDER BY TotalSales DESC

-- What are the best-selling products in the relevant countries and how much revenue has been generated from these products?

SELECT Country, ProductName, Quantity, TotalSales
FROM (
    SELECT c.Country, 
           p.ProductName, 
           SUM(od.Quantity) as Quantity, 
           ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) as TotalSales,
           RANK() OVER (PARTITION BY c.Country ORDER BY ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) DESC) as SalesRank
    FROM Customers c
    JOIN Orders o ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY c.Country, p.ProductName
) AS CountryProductSales
WHERE SalesRank = 1
ORDER BY TotalSales DESC;

--List the products that their total sales revenue is below 5.000 USD.

SELECT p.ProductName, ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) as TotalSales 
FROM [Order Details] od 
JOIN Products p ON od.ProductID=p.ProductID
GROUP BY p.ProductName
HAVING ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0)<5000
ORDER BY TotalSales 

-- Which products have the highest and lowest average prices?

SELECT * FROM (
    SELECT TOP 1 p.ProductName, ROUND(AVG(od.UnitPrice), 0) as AveragePrices
    FROM [Order Details] od
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY p.ProductName
    ORDER BY AveragePrices DESC
) AS HighestPrice
UNION
SELECT * FROM (
    SELECT TOP 1 p.ProductName, ROUND(AVG(od.UnitPrice), 0) as AveragePrices
    FROM [Order Details] od
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY p.ProductName
    ORDER BY AveragePrices ASC
) AS LowestPrice;

-- Which products have had the most price changes over the years?

SELECT 
    p.ProductName,
    ROUND(AVG(CASE WHEN YEAR(o.OrderDate) = 1996 THEN od.UnitPrice END), 0) AS AveragePrice_1996,
    ROUND(AVG(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.UnitPrice END), 0) AS AveragePrice_1998,
    ROUND(
        (AVG(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.UnitPrice END) /
         NULLIF(AVG(CASE WHEN YEAR(o.OrderDate) = 1996 THEN od.UnitPrice END), 0) - 1), 
        2
    ) AS Changing
FROM Products p
JOIN [Order Details] od ON od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) IN (1996, 1998)
GROUP BY p.ProductName
ORDER BY Changing DESC

-- In total, is there any delay regarding shipment days?

SELECT AVG(DATEDIFF(DAY,RequiredDate, ShippedDate))
FROM Orders

-- For the cargos whıch is delivered later than required date, hoy many days is the aveage delay?

SELECT AVG(DATEDIFF(DAY,RequiredDate, ShippedDate))
FROM Orders
WHERE ShippedDate>RequiredDate

--What is the shipment situation for each country? Are the cargos delivered on time or not?

SELECT ShipCountry, AVG(DATEDIFF(DAY, RequiredDate, ShippedDate)) as Delay
FROM Orders
GROUP BY ShipCountry
ORDER BY Delay 

-- Are there any significant difference on shipment in terms of products?

SELECT p.ProductName, AVG(DATEDIFF(DAY, RequiredDate, ShippedDate)) as Delay
FROM Orders o
JOIN [Order Details] od ON od.OrderID=o.OrderID
JOIN Products p ON p.ProductID=od.ProductID
GROUP BY p.ProductName

-- Is there any significant differences between cargo companies?

SELECT CompanyName, AVG(DATEDIFF(DAY, RequiredDate, ShippedDate)) as Delay
FROM Shippers s
JOIN Orders o ON s.ShipperID=o.ShipVia
GROUP BY CompanyName

-- Please find the number of delayed shipment for each country and find the ratio of the delays in all shipments. 

SELECT 
    o.ShipCountry, 
    COUNT(CASE WHEN o.ShippedDate > o.RequiredDate THEN 1 END) AS CountOfDelayedShipments,
    COUNT(o.ShippedDate) AS CountOfAllShipments,
    CAST(COUNT(CASE WHEN o.ShippedDate > o.RequiredDate THEN 1 END) * 1.0 / NULLIF(COUNT(o.ShippedDate), 0) AS DECIMAL(10, 2)) AS RatioofDelayedShipments
FROM Orders o
GROUP BY o.ShipCountry;

-- How is the performance of the employees?
SELECT e.FirstName + ' ' + e.LastName as EmployeeName,
SUM(od.Quantity) AS QuantitySold
FROM Employees e
JOIN Orders o ON e.EmployeeID=o.EmployeeID
JOIN [Order Details] od ON od.OrderID=o.OrderID
GROUP BY e.FirstName + ' ' + e.LastName
ORDER BY QuantitySold DESC

-- How is the performance of the employees year by year?

SELECT 
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    SUM(CASE WHEN YEAR(o.OrderDate) = 1996 THEN od.Quantity ELSE 0 END) AS Soldin1996,
    SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity ELSE 0 END) AS Soldin1997,
    SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity ELSE 0 END) AS Soldin1998
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY e.FirstName + ' ' + e.LastName;

-- What is my freight expense? List them company by company. Does it change drastically among years?

SELECT s.CompanyName, 
SUM(CASE WHEN YEAR(o.OrderDate)=1996 THEN o.Freight ELSE 0 END) AS '1996',
SUM(CASE WHEN YEAR(o.OrderDate)=1997 THEN o.Freight ELSE 0 END) AS '1997',
SUM(CASE WHEN YEAR(o.OrderDate)=1998 THEN o.Freight ELSE 0 END) AS '1998'
FROM Orders o
JOIN Shippers s ON o.ShipVia=s.ShipperID
GROUP BY s.CompanyName

-- What are the average prices per category over the years?

SELECT c.CategoryName, 
ROUND(AVG(CASE WHEN YEAR(o.OrderDate)=1996 THEN od.UnitPrice  ELSE 0 END),0) AS '1996',
ROUND(AVG(CASE WHEN YEAR(o.OrderDate)=1997 THEN od.UnitPrice  ELSE 0 END),0) AS '1997',
ROUND(AVG(CASE WHEN YEAR(o.OrderDate)=1998 THEN od.UnitPrice  ELSE 0 END),0) AS '1998'
FROM [Order Details] od
JOIN Products p ON p.ProductID=od.ProductID
JOIN Categories c ON c.CategoryID=p.CategoryID
JOIN Orders o ON o.OrderID=od.OrderID
GROUP BY c.CategoryName

-- What are the quantity sold per category over the years?

SELECT c.CategoryName, 
SUM(CASE WHEN YEAR(o.OrderDate)=1996 THEN od.Quantity  ELSE 0 END) AS '1996',
SUM(CASE WHEN YEAR(o.OrderDate)=1997 THEN od.Quantity  ELSE 0 END) AS '1997',
SUM(CASE WHEN YEAR(o.OrderDate)=1998 THEN od.Quantity  ELSE 0 END) AS '1998'
FROM [Order Details] od
JOIN Products p ON p.ProductID=od.ProductID
JOIN Categories c ON c.CategoryID=p.CategoryID
JOIN Orders o ON o.OrderID=od.OrderID
GROUP BY c.CategoryName

--List the Top 5 orders in terms of their monetary value. 

SELECT TOP 5 o.OrderID, ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)),0) as TotalSales
FROM Orders o
JOIN [Order Details] od ON o.OrderID=od.OrderID
GROUP BY o.OrderID
ORDER BY TotalSales DESC
