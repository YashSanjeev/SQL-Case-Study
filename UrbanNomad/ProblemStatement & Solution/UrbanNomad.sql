create database case2;
use case2;

/* What was the total quantity sold for all products? */
select details.product_name, 
sum(sale.qty) as Total_Quantity
from  product_details as details
INNER JOIN 
sales as sale
ON details.product_id = sale.prod_id
Group by details.product_name;

/* What is the total generated revenue for all 
products before discounts? */

select sum(qty*price) as 'Total_Revenue_before_disc' 
from sales;

/* What was the total discount amount for all products? */

select sum(qty*price*discount)/100 as 'Total Amount' 
from sales;

/* How many unique transactions were there? */
select count(distinct txn_id) as Number_of_Unq_Transiction
from sales;

/*  What are the average unique products purchased in each
transaction? */
with cte_unique_prod as
(select txn_id, count(distinct prod_id) as No_of_DistiProduc
from sales
group by txn_id)

select round(avg(No_of_DistiProduc)) as 
'Average No. of products per transaction'
from cte_unique_prod ;

/* What is the average discount value per transaction? */
with cte_avg_disc as
(select txn_id, sum(price*qty*discount)/100 as Discount
from sales
group by txn_id)

select round(avg(Discount),2) as 
'Average Discount per transaction'
from cte_avg_disc ;

/* What is the average revenue for member transactions 
and nonmember transactions? */
with cte_mem as 
(select member, txn_id, sum(qty*price) as 'Total_Revenue'
from sales
group by member, txn_id)

select member, round(avg(Total_Revenue),2) as Avg_Revenue 
from cte_mem
group by member;

/* What are the top 3 products by total revenue 
before discount? */

select details.product_name, sum(sale.qty*sale.price) 
as TotalRevenue
from product_details as details
INNER JOIN
Sales as sale
ON details.product_id=sale.prod_id
Group by details.product_name
ORDER BY TotalRevenue desc
LIMIT 3;


/*  What are the total quantity, revenue and discount for 
each segment? */

select details.segment_name as Segment, 
count(sale.prod_id) as Total_Quan,
sum(sale.qty*sale.price) as TotaRev, 
sum(sale.qty*sale.price*sale.discount)/100 as TotalDisc
from product_details as details
INNER JOIN
Sales sale
on details.product_id=sale.prod_id
group by Segment;

/* . What is the top selling product for each segment */
select details.segment_name as Segment,
sum(sale.qty) as TotalQty
from product_details as details
inner JOIN
Sales as sale 
on details.product_id=sale.prod_id
group by Segment
order by TotalQty desc;






