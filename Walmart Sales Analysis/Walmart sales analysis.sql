create database WalmartSalesAnalysis;
use WalmartSalesAnalysis;

select * from walmartsalesdata;

#---Feature Enineering---

#--Time of Day---

Select time,
(case when 'time' between "00:00:00" and "12:00:00" then "Morning"
 when 'time' between "12:01:00" and "16:00:00" then "Afternoon"
 else "Evening" End) as Time_of_date
 from walmartsalesdata;
 
 alter table walmartsalesdata
 add column Time_of_date varchar(20);
 
 update walmartsalesdata
 set Time_of_date =(case when 'time' between "00:00:00" and "12:00:00" then "Morning"
 when 'time' between "12:01:00" and "16:00:00" then "Afternoon"
 else "Evening" End);
 
# --Day Name--

 select date, dayname(date)
 from walmartsalesdata;
 
 alter table walmartsalesdata 
 add column day_name varchar(10);
 
 update walmartsalesdata
 set day_name = dayname(date);
 
 update walmartsalesdata 
 set date = date_format(str_to_date(date, '%d-%m-%Y'),'%Y-%m-%d');
 
 #--Month_name--
 select date,
 monthname(date) from walmartsalesdata;
 
 alter table walmartsalesdata
 add column month_name varchar(10);
 
 update walmartsalesdata
 set month_name = monthname(date);
 
 
 #-------General Questions-----
 
 #1) How many unique cities does data have
 select  distinct(city)
 from walmartsalesdata;

#2) in which city is each branch
select distinct(city), branch
 from walmartsalesdata;
 
 
 #-----Product Analysis-------
 
#1) How many unique product lines does data have
select distinct(`Product line`) 
from walmartsalesdata;
 
 #2) What is most common payment method
 select payment, count(payment)as most_common_payment_method 
 from walmartsalesdata
 group by payment;
 
 #3) what is most selling product line
 select `Product line`, sum(quantity) as Total_product_sold
 from walmartsalesdata
 group by `Product line`
 order by   Total_product_sold desc;
 
 #4) what is total revenue by month
 select month_name, sum(total) as Total_revenue_by_month
 from walmartsalesdata
 group by month_name
 order by Total_revenue_by_month  desc;
 
 #5) what month had the largest COGS
 select month_name , sum(cogs) 
 from walmartsalesdata
 group by month_name
 order by sum(cogs) desc;
 
 #6) what product line had the largest revenue
 select `Product line`, sum(Total) as Total_revenue
 from walmartsalesdata
 group by `Product line`
 order by Total_revenue desc;
 
 #7) what is the city with larget revenue
 select city , sum(Total) as Total_revenue
 from walmartsalesdata
 group by city
 order by Total_revenue desc;
 
 #8) what product line had the largest VAT(Value Added Tax)
 select `Product line`, avg(`Tax 5%`) as Largest_VAT
 from walmartsalesdata
 group by `Product line`
 order by Largest_VAT desc;
 
 #9) Fetch each product line and add a column to these product line showing "Good","Bad".Good if it is greater than average Sales
 select avg(quantity) as avg_quantity from walmartsalesdata; 
 select `Product line`,  Case
 when avg(quantity) >6 then "Good" else "Bad" end as remark
 from walmartsalesdata
 group by `Product line`;
 
 #10) which branch sold more product than average product sold
 with cte as (
 select branch , sum(quantity) as sum_quantity from walmartsalesdata
 group by branch
 having sum(quantity) > (select avg(quantity) from walmartsalesdata))
 select * from cte;
 
 # 11) what is most common product line by gender
 select gender, `Product line`,count(gender) as total_cnt  from walmartsalesdata
 group by gender, `Product line`
 order by total_cnt desc;
 
 # 12)  what is average rating of each product line
 select `Product line`, avg(rating) from walmartsalesdata
 group by `Product line`
 order by avg(rating) desc;
 
 #------- Sales ---------
 
  #1) Number of sales made in each time of of the day per weekday
  select time_of_date, count(*) as total_sales
  from walmartsalesdata
  group by time_of_date
  order by total_sales desc;
  
  #2) which customer types brings the most revenue
  select `Customer type`, sum(total) as Total_revenue
  from walmartsalesdata
  group by `Customer type`
  order by Total_revenue desc;
  
  #3) which city has largest tax/VAT percentage
  select city, round(avg(`Tax 5%`),2)as largest_tax_percent
  from walmartsalesdata
  group by city
  order by largest_tax_percent desc;
  
  #4) which customer type pays most in VAT
  select `Customer type`, avg(`Tax 5%`)as largest_tax_percent
  from walmartsalesdata
  group by `Customer type`
  order by largest_tax_percent desc
  
  #----- Customer -----------
  
  #1) How many unique customer type does data have
  select distinct(`Customer type`) 
  from walmartsalesdata;
  
  #2) How many unique payment methods does the data have
  select distinct(payment)
  from walmartsalesdata;
  
  #3) What is most common customer type
  select `Customer type`,count(*)
  from walmartsalesdata
  group by `Customer type`;
  
  #4) which customer type buys the most
  select `Customer type`,count(`Customer type`)
  from walmartsalesdata
  group by `Customer type`;
  
  #5) what is gender of most of customers
  select Gender,count(*)
  from walmartsalesdata
  group by gender;
  
  #6) what is gender distribution per branch
  select branch ,count(gender)
  from walmartsalesdata
  group by branch;
  
  #7) which time of the day do customers give most ratings
  select time_of_date, avg(rating) as avg_rating
  from walmartsalesdata
  group by time_of_date
  order by avg_rating desc;
  
  #8) which time of day do customers give most ratings per branch
   select time_of_date,branch, avg(rating) as avg_rating
  from walmartsalesdata
  group by time_of_date,branch
  order by avg_rating desc;
  
  #9) which day of the week has the best avg rating
   select day_name, avg(rating) as avg_rating
  from walmartsalesdata
  group by day_name
  order by avg_rating desc;
  
  #10) which day of the week has the best average ratings per branch
  select day_name,branch, avg(rating) as avg_rating
  from walmartsalesdata
  group by day_name,branch
  order by avg_rating desc;