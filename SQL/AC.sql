/*=========================================================
  Awesome Chocolates - Exploratory Data Analysis
  Tool: Microsoft SQL Server
=========================================================*/
use ac 
go

/*---------------------------------------------------------
1. Database Exploration
---------------------------------------------------------*/
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'

-- This is one helps us to know Data Types under TYPE_NAME, Duplicates and representation of the each column of the tables available in the db under sql server
EXEC sp_columns 'people';
EXEC sp_columns 'geo';
EXEC sp_columns 'products';
EXEC sp_columns 'sales';

select * from people
select * from geo
select * from sales
select * from products
-- A query that helps us to find the count/number of occurences in the table
select count(*) from dbo.sales

/*---------------------------------------------------------
2. Schema Exploration
---------------------------------------------------------*/

-- Counting the columns in each table present here
SELECT 
    T.TABLE_SCHEMA, 
    T.TABLE_NAME, 
    COUNT(C.COLUMN_NAME) AS Column_Count
FROM 
    INFORMATION_SCHEMA.TABLES T
INNER JOIN 
    INFORMATION_SCHEMA.COLUMNS C 
    ON T.TABLE_SCHEMA = C.TABLE_SCHEMA 
    AND T.TABLE_NAME = C.TABLE_NAME
WHERE 
    T.TABLE_TYPE = 'BASE TABLE'
GROUP BY 
    T.TABLE_SCHEMA, 
    T.TABLE_NAME
ORDER BY 
    Column_Count DESC;


-- A query that helps us to find the starting and ending Dates in the table
SELECT MIN(Date) as first_date, MAX(Date) as Recent_date
FROM Sales;

-- Descriptive statistics
SELECT
COUNT(*) AS TotalRows,
MIN(Amount) MinAmount,
MAX(Amount) MaxAmount,
AVG(Amount) AvgAmount,
STDEV(Amount) StdDevAmount
FROM Sales;

-- with help of sp_help in-built procedure in sql server we can get all the schema structure of the table
exec sp_help Sales;

-- Checking Null values present or allowed tables with the help of count(*) function
SELECT COUNT(*) MissingValues
FROM dbo.people
WHERE team IS NULL;

SELECT COUNT(*) MissingValues
FROM dbo.sales
WHERE Product IS NULL;

select geo,
count(*) duplicates
from dbo.sales
group by geo
having count(*) > 1;

-- Checks if the exact same combination of Date, Sequence, Salesperson, and Product exists more than once
SELECT Date, Product, Sales_Person, COUNT(*) 
FROM dbo.sales
GROUP BY Date, Product, Sales_Person
HAVING COUNT(*) > 1;
-- Finding duplicates from the table Sales for a column geo(Geo_location)

SELECT
MIN(Amount) Minimum_Amount,
MAX(Amount) Maximum_Amount,
AVG(Amount) Average_Amount
FROM Sales;

--------------------------------------END OF DATA UNDERSTANDING-------------------------------------
/*---------------------------------------------------------
3. Data Quality Checks
---------------------------------------------------------*/

-- Invalid data present under columns Customers and Boxes available here
SELECT *
FROM Sales
WHERE Customers < 0
   OR Boxes < 0;

--Detecting Outliers using Z-Score
WITH Stats AS
(
    SELECT
        AVG(Amount) AvgAmt,
        STDEV(Amount) StdAmt
    FROM Sales
)
SELECT s.*
FROM Sales s
CROSS JOIN Stats st
WHERE ABS((s.Amount - st.AvgAmt)/st.StdAmt) > 3;


-- Sales Performance
-- Average Order Value overall + monthly
SELECT
AVG(Amount) AS AvgOrderValue
FROM Sales;

SELECT
YEAR(Date),
MONTH(Date),
AVG(Amount) AvgOrderValue
FROM Sales
GROUP BY YEAR(Date), MONTH(Date);


-- Finding Distribution of Integer type column such as Amount spent on each product(Chocolate) in order
SELECT
Product,
COUNT(*) Product_category
FROM Sales
GROUP BY Product
ORDER BY Product_category desc;

-- Customer Analysis
-- Total number of Customers 
SELECT SUM(Customers) as Total_customers
FROM Sales;

-- Business Analysis: Sales Performance
SELECT
YEAR(Date) Year,
DATEPART(QUARTER, Date) Quarter,
SUM(Amount) Revenue
FROM Sales
GROUP BY
YEAR(Date),
DATEPART(QUARTER, Date);

-- Growth Trend

WITH MonthlySales AS
(
SELECT
YEAR(Date) Yr,
MONTH(Date) Mn,
SUM(Amount) Revenue
FROM Sales
GROUP BY
YEAR(Date),
MONTH(Date)
)

SELECT *,
LAG(Revenue) OVER
(
ORDER BY Yr,Mn
) PreviousRevenue
FROM MonthlySales;


SELECT
    p.Sales_Person,
    p.Team,
    SUM(s.Amount) Revenue
FROM sales s
JOIN people p
ON s.Sales_Person = p.SP_ID
GROUP BY
p.Sales_Person,
p.Team;

-- Geographic Revenue
SELECT
g.Geo,
g.Region,
SUM(s.Amount) Revenue
FROM sales s
JOIN geo g
ON s.Geo = g.GeoID
GROUP BY
g.Geo,
g.Region;


-- product category sales by the each product from sales table
select * from dbo.sales;

SELECT
YEAR(Date) years,
MONTH(Date) Months,
SUM(Customers) 
FROM dbo.sales
GROUP BY
YEAR(Date),
MONTH(Date);


select * from dbo.sales
select * from dbo.products

SELECT 
    p.Product,
    p.Category,
    SUM(s.Amount) AS Total_Revenue,
    SUM(s.Boxes) AS Total_Boxes_Sold
FROM dbo.sales s
JOIN dbo.products p ON s.Product = p.Product_ID -- Assumes PID is the joining column
GROUP BY p.Product, p.Category
ORDER BY Total_Revenue DESC;


-- Check for data quality anomalies
SELECT COUNT(*) AS [Zero_or_Negative_Sales]
FROM dbo.sales
WHERE Amount <= 0;

SELECT 
    YEAR(Date) AS [Year],
    MONTH(Date) AS [Month],
    COUNT(*) AS [Total_Transactions],
    SUM(Customers) AS [Total_Customers],
    SUM(Amount) AS [Total_Revenue]
FROM dbo.sales
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY YEAR(Date), MONTH(Date); -- Crucial for seeing historical trends

SELECT Table_Name, Column_Name, Data_Type 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE Table_Name IN ('people', 'geo', 'products', 'sales')
ORDER BY Table_Name;


--select * from sys.tables where name = 'people'

--SELECT *
--FROM sys.tables
--WHERE name LIKE '%people%'
--   OR name LIKE '%geo%'
--   OR name LIKE '%products%'
--   OR name LIKE '%sales%';

--select * from sys.all_columns where OBJECT_ID = '1221579390'
