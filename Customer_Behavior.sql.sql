create database customer_behavior;

select * from mytable;

# 1. sum of revenue male vs female
select gender,sum(purchase_amount) as revenue from mytable group by gender;

# 2. which customer is used discount but still spent more than the avg purchase amount
select discount_applied,purchase_amount from mytable
where purchase_amount > (select avg(purchase_amount) from mytable group by discount_applied having discount_applied="yes");

# 3. which are the top 5 products with highest average review rating 
select item_purchased, round(avg(review_rating),2) as avg_product_rating from mytable 
group by item_purchased 
order by avg(review_rating) desc limit 5;

# 4.  campare the avg purchase amounts between standerd and express shipping.
select shipping_type, avg(purchase_amount) from mytable
where shipping_type in ("standard", "express") 
group by shipping_type;

# 5. do subscribed customers spend more? compare average spend and total revenue betveen subscribers and non subscribers
select subscription_status,
count(customer_id) as total_customers, 
avg(purchase_amount) as avg_spend, 
sum(purchase_amount) as total_revenue from mytable
group by subscription_status;

# 6. which 5 products have the highest percentage of puchases with discount applied 
select item_purchased,
sum(case when discount_applied="yes" then 1 else 0 end)*100 / count(*) as discount_rate from mytable
group by item_purchased
order by discount_rate desc limit 5;

# 7. segment customers into new, returning and loyal based on their total number of privious purchases, and show the count of each segment
with customer_type as (
select customer_id, previous_purchases,
case
	when previous_purchases=1 then "new"
    when previous_purchases between 2 and 10 then "returning"
    else "loyal"
    end as customer_segment
from mytable
)
select customer_segment, count(*) as num_of_cust
from customer_type
group by customer_segment;

# 8. what are the top 3 most purchased products within each category
with item_counts as(
select item_purchased,
category,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from mytable
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <=3; 

# 9. are customers who are repeat buyers (more than 5 privious purchases) also likely to subscribe ?
select subscription_status, 
count(customer_id) as repeat_buyers
from mytable
where previous_purchases > 5
group by subscription_status;

# 10. what is the revenue contribution of the age group
select age_group, sum(purchase_amount) as total_revenue from mytable
group by age_group order by total_revenue desc;