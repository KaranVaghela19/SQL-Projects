create database Sales;
 use sales;
 
select * from sales_database_customers;
select * from sales_database_delivery_person;
select * from sales_database_orders;
select * from sales_database_pincode;
select * from sales_database_products;

#1.	How many customers do not have DOB information available?
select count(cust_id) as cust_cnt
from sales_database_customers
where dob is null;

#2.	How many customers are there in each pincode and gender combination
select primary_pincode, gender,count(*)
from sales_database_customers
group by primary_pincode,gender;

#3.	Print product name and mrp for products which have more than 50000 MRP
select product_name,mrp
from sales_database_products
where mrp > 50000;

#4.	How many delivery person are there in each pincode
select pincode, count(Delivery_person_id) as Delivery_person_in_each_Pincode
from sales_database_delivery_person
group by pincode;

#5.	For each Pin code, print the count of orders, sum of total amount paid, average amount paid, maximum amount paid, 
#minimum amount paid for the transactions which were paid by 'cash'. Take only 'buy' order types 
select delivery_pincode , count(order_id),sum(total_amount_paid),avg(total_amount_paid),max(total_amount_paid),min(total_amount_paid)
from sales_database_orders
where payment_type ='cash' and order_type='buy'
group by delivery_pincode;

#6.	For each delivery_person_id, print the count of orders and total amount paid for product_id = 12350 or 12348 and total units > 8. 
#Sort the output by total amount paid in descending order. Take only 'buy' order types 
select delivery_person_id,count(order_id),sum(displayed_selling_price_per_unit) as TotalAmount
from sales_database_orders
where product_id = '12350' or product_id = '12348' and totalunits > 8 and order_type = 'buy' 
group by delivery_person_id
order by TotalAmount desc;

#7.	Print the Full names (first name plus last name) for customers that have email on "gmail.com"? 
select concat(first_name," ", last_name), email
from sales_database_customers
where email like '%@gmail.com';

#8.	Which pincode has average amount paid more than 150,000? Take only 'buy' order types 
select delivery_pincode,avg(total_amount_paid) as avg_amt_paid
from sales_database_orders
where order_type = "buy"
group by delivery_pincode
having avg(total_amount_paid) > 150000;

#9.	Create following columns from order_dim data - order_date
#Order day 
#Order month 
#Order year  

select monthname(order_date)
from sales_database_orders;

update sales_database_orders
set order_date = date_format(str_to_date(order_date, '%d-%m-%Y'),'%Y-%m-%d');
 
update  sales_database_orders
set OrderYear =year(order_date);

#10. How many total orders were there in each month and how many of them were returned? 
 select month(order_date) as order_month ,sum(case 
 when (order_type)='buy' then 1 else 0 end) as total_orders_buyed,
 sum(case 
 when (order_type)='return' then 1 else 0 end) as total_orders_return,
 100*sum(case 
 when (order_type)='return' then 1 else 0 end) /sum(case 
 when (order_type)='buy' then 1 else 0 end) as return_rate
 from sales_database_orders
 group by month(order_date);
 
 #11. How many units have been sold by each brand? Also get total returned units for each brand. 
 select  distinct( brand),
 sum(case when order_type = 'buy' then totalunits else 0 end)as total_unit_sold,
 sum(case when order_type = 'return' then totalunits else 0 end) as total_units_returned
 from sales_database_orders left join sales_database_products 
 on sales_database_orders.product_id =sales_database_products. product_id
 group by brand;

#12. How many distinct customers and delivery boys are there in each state? 
select state,dp.pincode ,count(distinct customer_id)as distinct_customers, count(distinct delivery_person_id) as Distinct_DeliveryBoys
from sales_database_customers as c join sales_database_pincode as p
on c.primary_pincode = p.pincode join sales_database_delivery_person as dp
on p.pincode = dp.pincode
group by state,dp.pincode;

#13. For every customer, print how many total units were ordered, how many units were ordered from their primary_pincode and how many were ordered not from the primary_pincode.
# Also calulate the percentage of total units which were ordered from primary_pincode(remember to multiply the numerator by 100.0). 
#Sort by the percentage column in descending order. 
select (cust_id),sum(totalunits) as total_units_order,
sum(case when c.primary_pincode = o.delivery_pincode then o.totalunits else 0 end) as primary_pincode,
sum(case when c.primary_pincode != o.delivery_pincode then o.totalunits else 0 end) as not_primary_pincode,
100*sum(case when c.primary_pincode = o.delivery_pincode then o.totalunits else 0 end)/sum(totalunits) as percent_of_totalunits
from sales_database_customers c left join sales_database_orders o
on c.customer_id = o.cust_id
group by cust_id;

#14. For each product name, print the sum of number of units, total amount paid,
# total displayed selling price, total mrp of these units, and finally the net discount from selling price.  
with cte1 as(
select p.product_name, Sum(totalunits) total_units, 
sum(total_amount_paid) total_amout, 
sum(totalunits*displayed_selling_price_per_unit) 
Display_Amount,
sum(totalunits*mrp) MRP
from sales_database_orders o
join sales_database_products p
on o.product_id = p.product_id
group by p.product_name)
select *, (100-100*total_amout/Display_Amount) 
Net_Discount_from_Display, (100-100*total_amout/MRP) 
Net_Discount_from_mrp
from cte1;

#15. For every order_id (exclude returns), get the product name and calculate the discount percentage from selling price.
#Sort by highest discount and print only those rows where discount percentage was above 10.10%. 
 select o.order_id , product_name,
100-100* total_amount_paid/(displayed_selling_price_per_unit * totalunits) as discounted_percentage
from sales_database_products p join sales_database_orders o
on p.product_id = o.product_id
where o.order_type ='buy'
having discounted_percentage > 10.10;

#16. Using the per unit procurement cost in product_dim, find which product category has made the most profit in both absolute amount and percentage
# Absolute Profit = Total Amt Sold - Total Procurement Cost. Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0  
select category,
sum(total_amount_paid)-sum(procurement_cost_per_unit*totalunits) as absolute_profit,
100.0*sum(total_amount_paid) /sum(procurement_cost_per_unit*totalunits) - 100.0 as percent_profit
from sales_database_products p join sales_database_orders o
on p.product_id = o.product_id
group by category;

#17. For every delivery person(use their name), print the total number of order ids (exclude returns) by month in separate columns
# i.e. there should be one row for each delivery_person_id and 12 columns for every month in the year 
 select dp.name ,
sum(case when month(order_date) = '1' then 1 else 0 end ) as jan,
sum(case when month(order_date) = '2' then 1 else 0 end ) as feb,
sum(case when month(order_date) = '3' then 1 else 0 end ) as mar,
sum(case when month(order_date) = '4' then 1 else 0 end ) as apr,
sum(case when month(order_date) = '5' then 1 else 0 end ) as may,
sum(case when month(order_date) = '6' then 1 else 0 end ) as june,
sum(case when month(order_date) = '7' then 1 else 0 end ) as july,
sum(case when month(order_date) = '8' then 1 else 0 end ) as aug,
sum(case when month(order_date) = '9' then 1 else 0 end ) as sept,
sum(case when month(order_date) = '10' then 1 else 0 end ) as oct,
sum(case when month(order_date) = '11' then 1 else 0 end ) as nov,
sum(case when month(order_date) = '12' then 1 else 0 end ) as december
from sales_database_delivery_person  dp join sales_database_orders o
on dp.delivery_person_id = o.delivery_person_id
where order_type ='buy'
group by dp.name;

#18. For each gender - male and female - find the absolute and percentage profit by product name 
select gender,product_name,
sum(total_amount_paid)-sum(procurement_cost_per_unit*totalunits) as absolute_profit,
100.0*sum(total_amount_paid) /sum(procurement_cost_per_unit*totalunits) - 100.0 as percent_profit
from sales_database_customers c  join sales_database_orders o
on c.customer_id = o.cust_id join sales_database_products p
on o.product_id = p.product_id
group by gender,product_name;

#19. Generally the more numbers of units you buy, the more discount seller will give you.
# For 'Dell AX420' is there a relationship between number of units ordered and average discount from selling price? Take only 'buy' order types 
SELECT 
    o.totalunits,
    COUNT(order_id) AS total_orders,
    100.0 - 100.0 * o.total_amount_paid/(o.displayed_selling_price_per_unit * o.totalunits) AS discount_from_sp
FROM sales_database_products AS p
LEFT JOIN sales_database_orders AS o
    ON p.product_id = o.product_id
WHERE o.order_type = 'buy'
    AND p.product_name = 'Dell AX420'
GROUP BY 
    o.totalunits, discount_from_sp