CREATE TABLE techno_products (
product_id INT IDENTITY (1,1) PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(50),
stock INT,
price FLOAT
);

INSERT INTO techno_products (product_name, category, stock, price)
VALUES
('Laptop', 'Computer', 50, 3500.00),
('Telephone', 'Electronics', 100, 2000.00),
('TV', 'Electronics', 30, 5000.00),
('Keyboard', 'Computer', 80, 100.00),
('Mouse', 'Computer', 70, 50.00),
('Mobile_Phone_Cases', 'Mobile_Phone_Accessories', 200, 20.00),
('Headphone', 'Audio_Systems', 150, 100.00),
('Monitor', 'Computer', 40, 700.00),
('Speaker', 'Audio_Systems', 50, 300.00),
('Tablet', 'Electronics', 60, 1500.00),
('Table_Lamb', 'Household_Goods', 120, 80.00),
('Desktop_Case_Fan', 'Computer', 90, 30.00),
('Bluetooth_Mouse', 'Computer', 60, 70.00),
('Smart_Watch', 'Electronics', 40, 400.00),
('Printer', 'Computer', 20, 600.00);

-- What is the total stock quantity of our products?

SELECT 
	SUM(stock) as TotalStock
FROM techno_products

-- What is the average price of the products?

SELECT
	ROUND(AVG(price),2) AS AveragePrice
FROM techno_products

-- What is the name and price of our lowest-priced product?

SELECT 
	product_name,
	price
FROM techno_products
WHERE price = (SELECT MIN(price) FROM techno_products)

-- How many units does the product with the highest stock quantity have? Which product is that?

SELECT 
	product_name,
	stock
FROM techno_products
WHERE stock = (SELECT MAX(stock) FROM techno_products)

-- What is the total price of products in the computer category, and how many units do we have?

SELECT 
	SUM(stock) AS TotalStock,
	SUM(price) AS TotalPrice
FROM techno_products
WHERE category= 'Computer'

-- What is the average price of products in the electronics category, and what is the total revenue generated?

SELECT 
	AVG(price) AS AveragePrice,
	SUM(stock * price) AS TotalRevGenerated
FROM techno_products
WHERE category='Electronics'

-- What is the average price of products priced above 500 TL?

SELECT 
	ROUND(AVG(price),2) AS AvgPrice
FROM techno_products
WHERE price>500

-- What is the total quantity of products priced below 100 TL?

SELECT 
	SUM(stock) AS TotalQuantity
FROM techno_products
WHERE price<100

-- What is the price difference between the lowest-priced and highest-priced products?

SELECT
	MAX(price)-MIN(price) AS Difference
FROM
techno_products

-- What is the average price of products priced above 1000 TL and with at least 50 units in stock?

SELECT
	ROUND(AVG(price),2) AS AVGPrice
FROM techno_products
WHERE price>1000 AND stock>=50
