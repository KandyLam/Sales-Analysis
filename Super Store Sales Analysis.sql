-- Data Cleaning
-- 1. Triming blank space in text data
UPDATE superstore_cleaned
SET Order_ID = TRIM(Order_ID),
	Ship_Mode = TRIM(Ship_Mode),
	Customer_ID = TRIM(Customer_ID),
	Customer_Name = TRIM(Customer_Name),
	Segment = TRIM(Segment),
	Country = TRIM(Country),
	City = TRIM(City),
	State = TRIM(State),
	Region = TRIM(Region),
	Product_ID = TRIM(Product_ID),
	Category = TRIM(Category),
	Sub_category = TRIM(Sub_category),
	Product_Name = TRIM(Product_Name)

-- 2. Check for null values
SELECT *
FROM superstore_cleaned
WHERE Row_ID IS NULL
 OR Order_ID IS NULL
 OR Order_Date IS NULL
 OR Ship_Date IS NULL
 OR	Ship_Mode IS NULL
 OR	Customer_ID IS NULL
 OR	Customer_Name IS NULL
 OR	Segment IS NULL
 OR	Country IS NULL
 OR	City IS NULL
 OR	State IS NULL
 OR	Postal_Code IS NULL
 OR	Region IS NULL
 OR	Product_ID IS NULL
 OR	Category IS NULL
 OR	Sub_category IS NULL
 OR	Product_Name IS NULL
 OR	Sales IS NULL
 OR	Quantity IS NULL
 OR	Discount IS NULL
 OR	Profit IS NULL

-- 3. Check for empty string 
SELECT *
FROM superstore_cleaned
WHERE Order_ID = ' '
 OR	Ship_Mode = ' '
 OR	Customer_ID = ' '
 OR	Customer_Name = ' '
 OR	Segment = ' '
 OR	Country = ' '
 OR	City = ' '
 OR	State = ' '
 OR	Region = ' '
 OR	Product_ID = ' '
 OR	Category = ' '
 OR	Sub_category = ' '
 OR	Product_Name = ' '

-- Use the LEAD window function to create a new column sales_next that displays the sales of the next row in the dataset. 
-- This function will help you quickly compare a given row’s values and values in the next row.
SELECT *,
	LEAD(sales, 1) OVER (
		ORDER BY sales
	) AS sales_next
FROM superstore_cleaned;

-- Create a new column sales_previous to display the values of the row above a given row.
SELECT *,
	LEAD(sales, -1) OVER (
		ORDER BY sales
	) AS sales_previous
FROM superstore_cleaned;

-- Rank the data based on sales in descending order using the RANK function.
SELECT *,
	RANK () OVER ( 
		ORDER BY sales DESC
	) sales_rank 
FROM
	superstore_cleaned;

-- Aggreagate functions to show the monthly and daily sales averages.
SELECT DATE_TRUNC('month', "order_date") AS Month, AVG(Sales) AS Average_Monthly_Sales
FROM superstore_cleaned
GROUP BY Month
ORDER BY Month;

SELECT order_date, AVG(Sales) AS Average_Monthly_Sales
FROM superstore_cleaned
GROUP BY order_date
ORDER BY order_date;

-- Analyse average discounts on two consecutive days.
WITH DailyDiscounts AS (
    SELECT order_date,
           AVG(Discount) AS Average_Daily_Discount
    FROM superstore_cleaned
    GROUP BY order_date
)
SELECT order_date,
       Average_Daily_Discount,
       LAG(Average_Daily_Discount, 1) OVER (ORDER BY order_date) AS Previous_Day_Avg_Discount
FROM DailyDiscounts
ORDER BY order_date;

-- Evaluate moving averages using the window functions.
WITH SumSales AS (
	SELECT order_date, 
       round(SUM(sales),2) AS sum_sales 
       FROM superstore_cleaned
	   GROUP BY order_date
	   ORDER BY order_date
)	
SELECT a.order_date,a.sum_sales, 
       round(AVG(a.sum_sales)
       OVER(ORDER BY a.order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),2)
       AS movingavg_sales
       FROM SumSales a ; 


-- Find state with highest and lowest profits
SELECT state, round(sum(profit),2) AS total_profit
FROM superstore_cleaned
GROUP BY state
ORDER BY total_profit DESC;
-- Results show California has the highest profit, and lowest profit is Texas

-- Find highest selling product categories for each country	
SELECT state, category, round(sum(profit),2) AS sum_profit
FROM superstore_cleaned
GROUP BY state, category
ORDER BY sum_profit DESC;

-- Which product categories have the highest profits
SELECT category, round(sum(profit),2) AS sum_profit
FROM superstore_cleaned
GROUP BY category
ORDER BY sum_profit DESC;

-- What is the highest profits sub-categories in the top 3 categories: technology, office supplies, furniture
SELECT category, sub_category, round(sum(profit),2) AS sum_profit
FROM superstore_cleaned
GROUP BY category, sub_category
ORDER BY sum_profit DESC, category ASC;

-- Find month, state, category, sub-category, with the highest profit.
SELECT DATE_TRUNC('month', "order_date")::date AS month, category, sub_category, round(sum(profit),2) AS sum_profit
FROM superstore_cleaned
GROUP BY month, category, sub_category
ORDER BY sum_profit DESC;

