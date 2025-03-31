select *
from [Sales target]

select *
from [List of Orders];

select *
from [Order Details];

-- CLEANING DATA
SELECT DISTINCT [dbo].[Sales target].Category
FROM [Sales target];

SELECT DISTINCT [dbo].[Sales target].Month_of_Order_Date
FROM [Sales target];

SELECT DISTINCT [dbo].[Sales target].Target
FROM [Sales target];

SELECT *
from [Sales target]
where [dbo].[Sales target].Category is null 
	or [dbo].[Sales target].Month_of_Order_Date is null
	or [dbo].[Sales target].Target is null
;
ALTER TABLE [dbo].[Sales target]
ALTER COLUMN [Month_of_Order_Date] date;

SELECT *
from [dbo].[List of Orders]
where [dbo].[List of Orders].[Order_ID] is null 
	or [dbo].[List of Orders].[Order_Date] is null
	or [dbo].[List of Orders].[CustomerName] is null
	or [dbo].[List of Orders].[State] is null
	or [dbo].[List of Orders].[City] is null
;

DELETE FROM [dbo].[List of Orders]
where [dbo].[List of Orders].[Order_ID] is null 
	or [dbo].[List of Orders].[Order_Date] is null
	or [dbo].[List of Orders].[CustomerName] is null
	or [dbo].[List of Orders].[State] is null
	or [dbo].[List of Orders].[City] is null
;

SELECT DISTINCT [Amount]
FROM [dbo].[Order Details];

SELECT DISTINCT [Profit]
FROM [dbo].[Order Details];

SELECT DISTINCT [Quantity]
FROM [dbo].[Order Details];

SELECT DISTINCT [Category]
FROM [dbo].[Order Details];

SELECT DISTINCT [Sub_Category]
FROM [dbo].[Order Details];

SELECT *
from [dbo].[Order Details]
where [dbo].[Order Details].Order_ID is null 
	or [dbo].[Order Details].Amount IS null
	or [dbo].[Order Details].Profit is null
	or [dbo].[Order Details].Quantity is null
	or [dbo].[Order Details].Category is null
	or [dbo].[Order Details].Sub_Category is null
;

WITH l2 AS (
	SELECT *, ROW_NUMBER () OVER (PARTITION BY [Order_ID], [Order_Date],[CustomerName], [State], [City] ORDER BY [Order_ID]) AS ROW_NUMB
FROM [dbo].[List of Orders])
SELECT *
FROM l2 
where ROW_NUMB >1;

With o2 AS (
	SELECT *, ROW_NUMBER () OVER (PARTITION BY [Order_ID], [Amount],[Profit],[Quantity],[Category],[Sub_Category] 
		ORDER BY [Order_ID]) AS ROW_NUMB
FROM [dbo].[Order Details])
SELECT *
FROM o2
where ROW_NUMB >1;

WITH s2 AS  (
	SELECT *, ROW_NUMBER () OVER (PARTITION BY [Month_of_Order_Date], [Category], [Target] 
		ORDER BY [Category]) AS ROW_NUMB
FROM [dbo].[Sales target])
SELECT *
FROM s2
where ROW_NUMB >1;

UPDATE [dbo].[Sales target]
SET [Month_of_Order_Date] = CONVERT(date, '01-' + [Month_of_Order_Date], 5)
;

SELECT sum([Amount]) as total_revenue
from [dbo].[Order Details];

SELECT sum(Profit) as total_profit
from [dbo].[Order Details];

SELECT CONCAT(ROUND((SUM(Profit) / SUM(Amount))*100,2),' ','%') as profit_margin
from [dbo].[Order Details];


-- Find total revenue each category
SELECT [Category], sum([Amount]) as total_revenue
from [dbo].[Order Details]
group by [Category]

-- Find total profit each category
SELECT [Category], sum(Profit) as total_profit
from [dbo].[Order Details]
group by [Category]

-- Find total quantity each category
SELECT [Category], sum(Quantity) as total_profit
from [dbo].[Order Details]
group by [Category]

-- Find total revenue each sub-category
SELECT Sub_Category, sum([Amount]) as total_revenue
from [dbo].[Order Details]
group by Sub_Category;

-- Find total profit each sub-category
SELECT Sub_Category, sum(Profit) as total_profit
from [dbo].[Order Details]
group by Sub_Category;

-- Find total quantity each sub-category
SELECT Sub_Category, sum(Quantity) as total_profit
from [dbo].[Order Details]
group by Sub_Category;

-- Find total orders
SELECT COUNT(DISTINCT [Order_ID]) AS total_orders
from [dbo].[Order Details];

-- Find Average Order Value - AOV
SELECT 
    SUM([Amount]) / CAST((
        SELECT COUNT(DISTINCT [Order_ID]) 
        FROM [dbo].[Order Details]
    ) AS FLOAT) AS 'Average Order Value - AOV'
FROM [dbo].[Order Details];

-- Find Average Order Profit 
SELECT 
    SUM([Profit]) / CAST((
        SELECT COUNT(DISTINCT [Order_ID]) 
        FROM [dbo].[Order Details]
    ) AS FLOAT) AS 'Average Order Profit'
FROM [dbo].[Order Details];

-- Find Average orders per customer
SELECT 
	ROUND((
    CAST((SELECT COUNT(DISTINCT [Order_ID]) ) AS FLOAT) / 
	CAST((SELECT COUNT(DISTINCT [CustomerName]) ) AS FLOAT)),2) AS 'Average Orders Per Customer'
FROM [dbo].[List of Orders];

-- Find Average Revenue per customer
SELECT 
	ROUND((
    SUM(od.[Amount]) / 
	CAST((SELECT COUNT(DISTINCT [CustomerName]) ) AS FLOAT)),2) AS 'Average Revenue Per Customer'
FROM [dbo].[List of Orders] lo
left join [dbo].[Order Details] od
on lo.Order_ID = od.Order_ID;

-- Find Top-Selling Sub_Category
SELECT [Category], [Sub_Category], SUM([Quantity]) as total_sales
FROM [dbo].[Order Details]
GROUP BY [Category], [Sub_Category]
ORDER BY total_sales DESC

-- Find Total customers
SELECT COUNT(DISTINCT [CustomerName]) as total_customer
FROM [dbo].[List of Orders];

-- Revenue by State
SELECT lo.[State], SUM([Amount]) as 'Total Revenue'
FROM [dbo].[Order Details] od
LEFT join [dbo].[List of Orders] lo
on od.[Order_ID] = lo.[Order_ID]
GROUP BY lo.[State] 
ORDER BY 'Total Revenue' DESC;

-- Revenue by City
SELECT lo.[City], SUM([Amount]) as 'Total Revenue'
FROM [dbo].[Order Details] od
LEFT join [dbo].[List of Orders] lo
on od.[Order_ID] = lo.[Order_ID]
GROUP BY lo.[City] 
ORDER BY 'Total Revenue' DESC;

-- Revenue by State and City
SELECT lo.[State], lo.[City], SUM([Profit]) as 'Total Profit'
FROM [dbo].[Order Details] od
LEFT join [dbo].[List of Orders] lo
on od.[Order_ID] = lo.[Order_ID]
GROUP BY lo.[State], lo.[City]
ORDER BY 'Total Profit' DESC;

-- Monthly Revenue
SELECT 
    FORMAT(lo.[Order_Date], 'yyyy-MM') AS MonthYear,
    SUM(od.[Amount]) AS monthly_revenue
FROM 
    [dbo].[Order Details] od
LEFT JOIN 
    [dbo].[List of Orders] lo ON od.[Order_ID] = lo.[Order_ID]
GROUP BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM')
ORDER BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM');

-- Monthly profit
SELECT 
    FORMAT(lo.[Order_Date], 'yyyy-MM') AS MonthYear,
    SUM(od.[Profit]) AS monthly_profit
FROM 
    [dbo].[Order Details] od
LEFT JOIN 
    [dbo].[List of Orders] lo ON od.[Order_ID] = lo.[Order_ID]
GROUP BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM')
ORDER BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM');

-- Monthly orders
SELECT 
    FORMAT(lo.[Order_Date], 'yyyy-MM') AS MonthYear,
    COUNT(DISTINCT (od.[Order_ID])) AS monthly_orders
FROM 
    [dbo].[Order Details] od
LEFT JOIN 
    [dbo].[List of Orders] lo ON od.[Order_ID] = lo.[Order_ID]
GROUP BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM')
ORDER BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM');

-- MoM Revenue Growth Rate

WITH exps as (
SELECT 
    FORMAT(lo.[Order_Date], 'yyyy-MM') AS MonthYear,
    SUM(od.[Amount]) AS current_revenue,
    LAG(SUM(od.[Amount])) OVER(ORDER BY FORMAT(lo.[Order_Date], 'yyyy-MM') ASC) AS previous_revenue
FROM 
    [dbo].[Order Details] od
LEFT JOIN 
    [dbo].[List of Orders] lo ON od.[Order_ID] = lo.[Order_ID]
GROUP BY 
    FORMAT(lo.[Order_Date], 'yyyy-MM')
)
SELECT MonthYear, 
	   current_revenue, 
	   previous_revenue,
	   ROUND(((current_revenue-previous_revenue)/previous_revenue)*100,2) as MoM_revenue_growth_percentage
from exps
order by MonthYear;

-- Target achievement rate

WITH tb1 AS (
SELECT FORMAT(lo.[Order_Date], 'yyyy-MM') as monthyear,
	   od.[Category],
	   SUM([Amount]) as total_revenue
FROM [dbo].[Order Details] od
left join [dbo].[List of Orders] lo
on od.Order_ID = lo.[Order_ID]
group by FORMAT(lo.[Order_Date], 'yyyy-MM'), od.[Category]
)
SELECT t.monthyear, t.[Category], total_revenue, st.target, ROUND(((total_revenue-st.target)/st.target)*100,2) AS Target_achievement_rate,
	   CASE WHEN total_revenue >= st.target then 'Achieve'
			else 'Not achieve'
		End as Target_achievement
FROM tb1 t
LEFT JOIN (
	SELECT FORMAT([Month_of_Order_Date], 'yyyy-MM') AS monthyear1,
		   [Category],
           [Target]
     FROM [dbo].[Sales target]
) 
st
on t.monthyear = st.monthyear1
and t.Category = st.Category
order by t.monthyear, t.Category;

