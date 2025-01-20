select top 10 *from superstore

select
	count(distinct Customer_ID) customerid,
	count(distinct Customer_Name) cusomername,
	count(distinct Product_ID) productid,
	count(distinct Product_Name) productname
from superstore 

--There is a mistake in product ids and product names. They should be identical. 

create view newproductids as
with ranks as (
select 
	Product_Name,
	Product_ID,
	row_number() over(partition by Product_Name order by Product_Name) as ranked
from superstore
)
select * from ranks
where ranked=1

alter table superstore
add newproductid varchar(255)

update s
set s.newproductid=n.Product_ID
from superstore s 
join newproductids n
on n.Product_Name=s.Product_Name


create view newproductnames as
with ranks as (
select 
	newproductid,
	Product_Name,
	row_number() over(partition by newproductid order by newproductid) as ranked
from superstore
)
select * from ranks
where ranked=1

alter table superstore
add newproductname varchar(400)

update s
set s.newproductname=n.Product_Name
from superstore s 
join newproductnames n
on n.newproductid=s.newproductid

select top 100 * from superstore 

select
	count(distinct Customer_ID) customerid,
	count(distinct Customer_Name) cusomername,
	count(distinct newproductid) productid,
	count(distinct newproductname) productname
from superstore

-- We match the product ids and product names so that they would be equal. Now, same product ids have same product names and vice versa. 

alter table superstore
drop column Product_ID, Product_Name

-- Let's check the quantitave values. 

select 
    sum(Sales) as Sales,
    sum(Unit_Price * Quantity * (1 - Discount)) as Sales_v2,
    sum(Profit) as Profit,
    sum((Unit_Price * Quantity * (1 - Discount)) - (CostperUnit * Quantity)) as Profit_v2
from superstore;

-- There are some errors on sales and profit values. We have to update them and related variables with CostperUnit, UnitPrice, and Quantity. 

select top 10 * from superstore

alter table superstore 
add Sales_v2 float, Profit_v2 float, ProfitperUnit_v2 float, PercentageofProfit_v2 float

update superstore 
set 
Sales_v2 = (1-Discount)*Quantity*Unit_Price

update superstore 
set 
Profit_v2= Sales_v2 - (CostperUnit * Quantity)

update superstore 
set
ProfitperUnit_v2 = Profit_v2/Quantity

update superstore 
set
PercentageofProfit_v2 = ProfitperUnit_v2 / CostperUnit


alter table superstore
drop column Sales, Profit, ProfitperUnit, PercentageofProfit

-- We have to change tenure column. There are date values in tenure column. we have to recalculate it. 

alter table superstore
drop column Tenure

alter table superstore
add Tenure int

select max(order_date) 
from superstore

update superstore
set Tenure = DATEDIFF(DAY, Order_Date, CAST('2017-12-30' as Date))

select top 100 * from superstore 

-- Let's check if there is any duplicates. 

select Order_ID, count (*) as rowcounts 
from superstore 
group by
Order_ID,
Order_Date,
Shipment_Date,
Ship_Mode,
Customer_ID,
Customer_Name,
Segment,
City,
State,
Region,
Category,
Sub_Category,
Quantity,
Discount,
Unit_Price,
CostperUnit,
Order_Month,
Order_Year,
newproductid,
newproductname,
Sales_v2,
Profit_v2,
ProfitperUnit_v2,
PercentageofProfit_v2,
Tenure
having count(*)>1

select * from superstore 
where Order_ID='US-2014-150119'

delete from superstore
where ID=1176

-- We deleted one duplicated row in our data. 

-- Now our data is ready to analyze. 

select top 10 * from superstore 

--1. What are the annual sales, profits, average unit price and quantity sold of the company?

select 
	Order_Year,
	sum(Sales_v2) as Sales,
	sum(Profit_v2) as Profit,
	avg(Unit_Price) as UnitPrice,
	sum(Quantity) as Quantity
from superstore 
group by Order_Year
order by Order_Year asc

-- 2. What are sales, profits, average unit price and quantity sold of the company by category?

select 
	Category,
	sum(Sales_v2) as Sales,
	sum(Profit_v2) as Profit,
	avg(Unit_Price) as UnitPrice,
	sum(Quantity) as Quantity
from superstore 
group by Category

-- 3. List the sales of the states. What is the top category in each state in terms of their sales?
select
	State, sum(Sales_v2) as TotalSales
from superstore
group by State
order by TotalSales DESC

with rn1 as (
select
state, Category, sum(Sales_v2) as TotalSales,
row_number() over(partition by State order by category) as RN
from superstore
group by State,Category
)
select * from rn1
where RN=1

--4. What is the average day difference between shipment date and order date? Is this difference changing according to region?

select avg(datediff(day, Order_Date, Shipment_Date)) as Difference
from superstore

select Region, avg(datediff(day, Order_Date, Shipment_Date)) as Difference
from superstore
group by Region

--5. Which shipment mode is most used and which shipment mode is used at what percentage?

with a1 as (
	select Ship_Mode, Count(Distinct Order_ID) as Segments
	from superstore
	group by Ship_Mode
),
a2 as (
	select count(distinct Order_ID) as TotalSegments
	from superstore
)
select 
	a1.Ship_Mode,(a1.Segments * 1.0 / a2.TotalSegments) as Percentage
	from a1
	cross join a2

