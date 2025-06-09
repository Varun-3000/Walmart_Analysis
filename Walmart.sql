/*create database*/
create database if not exists walmartSales;
use walmartSales;
CREATE TABLE if not exists sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

/*Feature Engineering*/
select time,
	(case
		when `time` between "00:00:00" and "12:00:00" then "Morning"
		when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
	 end
    ) as time_of_date
from sales;

/*Adding new column*/
alter table sales add column time_of_day varchar(20);

/*Updating the column time_of_day with values*/

update sales
set time_of_day=(case
		when `time` between "00:00:00" and "12:00:00" then "Morning"
		when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
	 end
    );

/*Adding day (Mon,tue etc)*/
select date,dayname(date) from sales;

alter table sales add column day_name varchar(10);

update sales set day_name = dayname(date);

/*Adding month name(jan,feb etc)*/
select date,monthname(date) from sales;

alter table sales add column month_name varchar(10);

update sales set month_name=monthname(date);

------------------------------------------------------------
/*------------------------GENERIC-----------------------------
1)How many unique cities does the data have?*/
select distinct city from sales;
/*2)In which city is each branch?*/
select distinct branch from sales;

select distinct city,branch from sales;

--------------------------------------------
/*--------------------product-----------------
1)How many unique product lines does the data have?*/
select distinct product_line from sales;
select  count( distinct product_line) from sales;

/*2)What is the most common payment method?*/
select payment,count(payment) as cnt from sales group by payment order by cnt desc;

/*3)What is the most selling product line?*/
select product_line,count(product_line) as cnt from sales group by product_line order by cnt desc;

/*
4)What is the total revenue by month?*/
select month_name as month,sum(total) as total_revenue from sales group by month order by total_revenue desc;

/*
5)What month had the largest COGS?*/
select month_name as month,sum(cogs) as cogs from sales group by month order by cogs desc;
/*
6)What product line had the largest revenue?*/
select product_line ,sum(total) as total_revenue from sales group by product_line order by total_revenue desc;
/*
7)What is the city with the largest revenue?*/
select city ,branch,sum(total) as total_revenue from sales group by city,branch order by total_revenue desc;
/*
8)What product line had the largest VAT?*/
select product_line,avg(tax_pct) as avg_tax from sales group by product_line order by avg_tax desc;
/*
9)Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
*/
select product_line ,
case
	when avg(total)>(select avg(total) from sales) then 'Good'
    else 'Bad'
end as performance
from sales 
group by product_line;
/*
10)Which branch sold more products than average product sold?*/
select branch,sum(quantity) as qty
	from sales
	group by branch having sum(quantity)>(select avg(quantity) from sales);
/*
11)What is the most common product line by gender?
*/
select gender,product_line,count(gender) as total_cnt from sales group by gender,product_line
order by total_cnt desc;
/*
12)What is the average rating of each product line?*/
select product_line,round(avg(rating),2) as avg_rat from sales group by product_line order by avg_rat desc;


-------------------------------------------------------------------------------------------------
alter table sales add column VAT varchar(20);
update sales set VAT=(`cogs`*0.05);

/*---------------Sales---------------------------------------------------
1)Number of sales made in each time of the day per weekday*/
select time_of_day,count(*) as cnt,day_name from sales 
group by time_of_day,day_name order by day_name;
/*2)Which of the customer types brings the most revenue?*/
select customer_type,sum(total) as total_revenue from sales
group by customer_type
order by total_revenue desc;

/*
3)Which city has the largest tax percent/ VAT (Value Added Tax)?*/
select city,avg(VAT) as VAT from sales
group by city
order by VAT desc;
/*
4)Which customer type pays the most in VAT?*/
select customer_type,avg(VAT) as VAT from sales
group by customer_type
order by VAT desc;

--------------------------------------------------------------------------------------
-- ------------------------------Customer------------------------------------------------------
-- 1)How many unique customer types does the data have?
select distinct customer_type from sales;
-- 2)How many unique payment methods does the data have?
select distinct payment from sales;
-- 3)What is the most common customer type?
select customer_type,count(*) as csm_cnt from sales
group by customer_type
order by csm_cnt desc;
-- 4)Which customer type buys the most?
select customer_type,count(*) as total_purchases from sales
group by customer_type
order by total_purchases desc
limit 1;

-- 5)What is the gender of most of the customers?
select gender,count(*) as cnt from sales
group by gender
order by cnt desc;
-- 6)What is the gender distribution per branch?
select branch,gender,count(*) as cnt from sales
group by branch,gender
order by branch;
-- 7)Which time of the day do customers give most ratings?
select time_of_day,avg(rating) as rating from sales
-- where day_name="Sunday"
group by time_of_day
order by rating desc;
-- 8)Which time of the day do customers give most ratings per branch?
select time_of_day,branch,avg(rating) as rating from sales
group by time_of_day,branch
order by branch; 
-- 9)Which day fo the week has the best avg ratings?
select day_name,avg(rating) as rating from sales
group by day_name
order by rating desc;
-- 10)Which day of the week has the best average ratings per branch?
select branch,day_name,avg(rating) as rating from sales
where branch in ("A")
group by branch,day_name
order by rating desc;
