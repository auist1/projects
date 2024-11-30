
-- What is the total number of stores?

SELECT COUNT(*) AS NumberofStores FROM Stores 

-- What is the total number of brands?

SELECT COUNT(*) AS NumberofBrands FROM Brands

-- What is the total number of categories? 

SELECT COUNT (*) AS NumberofCategories FROM Categories

-- What is the total number of different customers? 

SELECT COUNT(DISTINCT customer_id) AS NumberofCustomers FROM Customers

--How many different states are my customers from?

SELECT COUNT(DISTINCT state) AS NumberofStates FROM Customers

-- How many different cities are my customers from?

SELECT COUNT(DISTINCT city) AS NumberofCities FROM Customers

-- What is the total revenue year by year?

SELECT 
	YEAR(order_date) AS Years, ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRev
FROM 
	Orders o
LEFT JOIN 
	Order_items oi ON o.order_id=oi.order_id
GROUP BY 
	YEAR(order_date)

-- What is the total number of products year by year?
SELECT 
	YEAR(order_date) AS Years,(SUM(oi.quantity )) AS TotalQuantity
FROM 
	Orders o
LEFT JOIN 
	Order_items oi ON o.order_id=oi.order_id
GROUP BY 
	YEAR(order_date)

-- Show total revenue, total amount of products sold and yearly unit prices in the same table. 
SELECT
	YEAR(order_date) AS Years,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRev,
	SUM(oi.quantity) AS TotalQuantity,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount))/SUM(oi.quantity),0) AS UnitPrice
FROM 
	Orders o
JOIN 
	Order_items oi ON o.order_id=oi.order_id
GROUP BY 
	YEAR(order_date)

-- Calculate the revenue per store. Find their shares in total revenue. 
WITH TR AS (
	SELECT 
		s.store_name, 
		ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRev
	FROM Stores s
	LEFT JOIN Orders o ON s.store_id=o.store_id
	LEFT JOIN Order_items oi ON oi.order_id=o.order_id
	GROUP BY s.store_name
),
TR2 AS (
	SELECT ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TTR
	FROM Stores s
	LEFT JOIN Orders o ON s.store_id=o.store_id
	LEFT JOIN Order_items oi ON oi.order_id=o.order_id
)
SELECT
TR.store_name,
TR.TotalRev,
TR.TotalRev/(SELECT TTR FROM TR2) AS PERC
FROM 
TR

-- Calculate the revenue per category. Find their shares in total revenue. 

WITH TC AS (
	SELECT 
		c.category_name,
		ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRev
	FROM Categories c
	LEFT JOIN Products p ON p.category_id=c.category_id
	LEFT JOIN Order_items oi ON oi.product_id=p.product_id
	GROUP BY c.category_name
),
TTC AS (
	SELECT 
		ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TTotalRev
	FROM Order_items oi
)
SELECT 
	TC.category_name,
	TC.TotalRev,
	TC.TotalRev/(SELECT TTotalRev FROM TTC) AS PERC
FROM TC 

-- Do the brands have all categories? List the brands and categories in the same table. 

SELECT 
	b.brand_name, COUNT( DISTINCT category_name) AS NumberofCategories
FROM 
	Brands b
LEFT JOIN 
	Products p 
ON b.brand_id=p.brand_id
LEFT JOIN 
	Categories c 
ON c.category_id=p.category_id
GROUP BY 
	b.brand_name
ORDER BY 
	b.brand_name

-- List the total amount of product sold, total revenue and unit price by states.

SELECT 
	c.state,
	SUM(oi.quantity) AS Qunatity,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRev,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount))/SUM(oi.quantity),0) AS UnitPrice
FROM Customers c
LEFT JOIN Orders o ON c.customer_id=o.customer_id
LEFT JOIN Order_items oi ON oi.order_id=o.order_id
GROUP BY c.state

-- What are the minimum, maximum and average list prices per categories? 

SELECT 
	category_name, 
	ROUND(MIN(oi.list_price),0) AS Minimum,
	ROUND(AVG(oi.list_price),0) AS Average,
	ROUND(MAX(oi.list_price),0) AS Maximum
FROM
	Categories c
LEFT JOIN 
	Products p
ON 
	p.category_id=c.category_id
LEFT JOIN 
	Order_items oi 
ON 
	oi.product_id=p.product_id
GROUP BY 
	category_name

-- What is the average basket value in each year?

SELECT 
	YEAR(o.order_date) Years,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)) / COUNT (DISTINCT o.order_id),0) AS BasketSize
FROM
	Order_items oi 
LEFT JOIN 
	Orders o 
ON 
	o.order_id=oi.order_id
GROUP BY 
	YEAR(o.order_date)

-- List Top 10 Products according to their sales revenue and list their minimum, average and maximum prices. 
SELECT TOP 10
	p.product_name,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRevenue,
	ROUND(MIN(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS Minimum,
	ROUND(AVG(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS Average,
	ROUND(MAX(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS Maximum
FROM
	Products p
LEFT JOIN 
	Order_items oi 
ON 
	oi.product_id=p.product_id
GROUP BY 
	product_name
ORDER BY 
	TotalRevenue DESC

-- List the top 1 products for each city according to the sales revenue.

WITH ALLP AS (
SELECT 
	c.city,
	p.product_name,
	ca.category_name,
	ROUND(SUM(oi.quantity * oi.list_price * (1-oi.Discount)),0) AS TotalRevenue
FROM 
	Customers c
LEFT JOIN 
	Orders o 
ON 
	o.customer_id=c.customer_id
LEFT JOIN 
	Order_items oi
ON
	oi.order_id=o.order_id
LEFT JOIN 
	Products P 
ON 
	p.product_id=oi.product_id
LEFT JOIN 
	Categories ca
ON 
	ca.category_id=p.category_id
GROUP BY 
	c.city, p.product_name,ca.category_name
),
RankedProducts AS (
SELECT 
	city,
	product_name,
	category_name,
	TotalRevenue,
	RANK () OVER(PARTITION BY city ORDER BY TotalRevenue DESC) AS Ranking
FROM
ALLP
)
SELECT 
	city,
	product_name,
	category_name,
	TotalRevenue
FROM 
	RankedProducts
WHERE Ranking=1

-- What is the average discount rates per product? Order by descending according to discount rates.

SELECT 
	p.product_name,
	AVG(discount) AS AVGDiscount
FROM 
	Products p
LEFT JOIN 
	Order_items oi
ON
	oi.product_id=p.product_id
GROUP BY
	p.product_name
ORDER BY 
	AVGDiscount DESC

-- Find the number of orders whose shipped date is later thatn required date. How many percent of orders do apply for it?

WITH ALLORDERS AS (
    SELECT 
        order_id AS ALO
    FROM 
        Orders
),
DATED AS (
    SELECT 
        order_id AS DD
    FROM 
        Orders
    WHERE 
        required_date < shipped_date
)
SELECT 
    COUNT(ALO) AS TotalOrders,
    COUNT(DD) AS LateOrders,
    CAST(COUNT(DD) AS FLOAT) / CAST(COUNT(ALO) AS FLOAT) AS DelayedRatio
FROM 
	ALLORDERS ao
LEFT JOIN 
	DATED d
ON 
	ao.ALO = d.DD;

-- What are the average price of the products among years? Do not show the product if there is a NULL value in any years.

SELECT 
    p.product_name,
    AVG(CASE WHEN YEAR(o.order_date) = 2016 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE NULL END) AS 'Revenue_2016',
    AVG(CASE WHEN YEAR(o.order_date) = 2017 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE NULL END) AS 'Revenue_2017',
    AVG(CASE WHEN YEAR(o.order_date) = 2018 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE NULL END) AS 'Revenue_2018'
FROM
    Products p
LEFT JOIN 
    Order_items oi
ON
    oi.product_id = p.product_id
LEFT JOIN
    Orders o 
ON 
    o.order_id = oi.order_id
GROUP BY 
    p.product_name
HAVING 
    COUNT(CASE WHEN YEAR(o.order_date) = 2016 THEN 1 ELSE NULL END) > 0 AND
    COUNT(CASE WHEN YEAR(o.order_date) = 2017 THEN 1 ELSE NULL END) > 0 AND
    COUNT(CASE WHEN YEAR(o.order_date) = 2018 THEN 1 ELSE NULL END) > 0;

-- Which store has the highest stock?

SELECT 
	s.store_name,
	SUM(quantity) AS Stocks
FROM
	Stores s
LEFT JOIN 
Stocks st
ON 
st.store_id=s.store_id
GROUP BY 
s.store_name

-- In which categories the stocks are more than the other? List stocks by categories and stores. 

SELECT 
	s.store_name,
	SUM(CASE WHEN c.category_name = 'Children Bicycles' THEN st.quantity END) AS 'Children Bicycles',
	SUM(CASE WHEN c.category_name = 'Comfort Bicycles' THEN st.quantity END) AS 'Comfort Bicycles',
	SUM(CASE WHEN c.category_name = 'Cruisers Bicycles' THEN st.quantity END) AS 'Cruisers Bicycles',
	SUM(CASE WHEN c.category_name = 'Cyclocross Bicycles' THEN st.quantity END) AS 'Cyclocross Bicycles',
	SUM(CASE WHEN c.category_name = 'Electric Bicycles' THEN st.quantity END) AS 'Electric Bicycles',
	SUM(CASE WHEN c.category_name = 'Mountain Bicycles' THEN st.quantity END) AS 'Mountain Bicycles',
	SUM(CASE WHEN c.category_name = 'Road Bicycles' THEN st.quantity END) AS 'Road Bicycles'
FROM 
	Stores s
LEFT JOIN 
	Stocks st 
ON 
	s.store_id=st.store_id
LEFT JOIN 
	Products p 
ON 
	p.product_id=st.product_id
LEFT JOIN 
	Categories c
ON 
	c.category_id=p.category_id
GROUP BY 
	s.store_name
