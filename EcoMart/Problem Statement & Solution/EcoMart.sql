/*Data Cleansing Steps*/
create table clean_weekly_sales as
select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calendar_year,
region,platform,
case 
when segment='null' then "Unknown"
else segment
end as Segment,
case 
when right(segment,1) = '1'then "Young Adults"
when right(segment,1) = '2'then "Middle Aged"
when right(segment,1) in ('3','4') then "Retirees"
else "Unknown"
end as "age_band",
case
when left(segment,1) = 'c' then "Couples"
when left(segment,1) = 'f' then "Families"
else "Unkown"
end as "demographic",
customer_type,transactions,sales,
round(sales/transactions,2) as "avg_transaction" 
from weekly_sales;

######################################
select * from clean_weekly_sales limit 10;



/* B. Data Exploration */

/* Which week numbers are missing from the dataset? */
create table seq52(num int Primary KEY);


DELIMITER $$
CREATE PROCEDURE InsertNumbers()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 52 DO
        INSERT INTO seq52(num) VALUES (i);
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

call InsertNumbers();

select * from seq52;

select distinct num from seq52 
where
num not in 
(select distinct week_number from clean_weekly_sales);

/* How many total transactions were there for each year 
in the dataset? */

select calendar_year as Year, sum(transactions) as "Total Transaction" 
from clean_weekly_sales 
group by calendar_year;

/* What are the total sales for each region for each month? */
select region as "Region", month_number as "Month", 
sum(sales) as "Total Sales"
from clean_weekly_sales group by region,month_number;

/* What is the total count of transactions for each platform */
select platform, count(transactions) as "No. of Transaction" 
from clean_weekly_sales
group by platform;

/* What is the percentage of sales for Retail vs Shopify for each month? */

with cte_monthly_platform_sales as 
(select month_number as 'Month_num',
calendar_year as 'Year_num',
platform, sum(sales) as 'Monthly_Sales'
from clean_weekly_sales 
group by month_number,calendar_year,platform)

select Month_num, Year_num,
round(100*max(case when platform ='Retail' then Monthly_Sales 
else null end)/sum(Monthly_sales),2) as 'Retail Percentage',
round(100*max(case when platform ='Shopify' then Monthly_Sales 
else null end)/sum(Monthly_sales),2) as 'Shopify Percentage'
from cte_monthly_platform_sales 
group by Month_num, Year_num
order by Month_num, Year_num;

/* What is the percentage of sales by demographic for 
each year in the dataset */

with cte_yearly_demographic_sales as 
(select calendar_year as 'Year_num',
demographic, sum(sales) as 'Yearly_Sales'
from clean_weekly_sales 
group by calendar_year,demographic)

select Year_num,
round(100*max(case when demographic ='Couples' then Yearly_Sales 
else null end)/sum(Yearly_sales),2) as 'Couples Percentage',
round(100*max(case when demographic ='Families' then Yearly_Sales 
else null end)/sum(Yearly_Sales),2) as 'Families Percentage',
round(100*max(case when demographic ='Unkown' then Yearly_Sales 
else null end)/sum(Yearly_Sales),2) as 'Unknown Percentage'
from cte_yearly_demographic_sales 
group by Year_num
order by Year_num;


/* Which age_band and demographic values contribute the most 
to Retail sales?
  */
SELECT
age_band,
demographic,
SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;
