use shopping_db;

select * from shopping_data;

-- Sales Performance
-- Q1. What is the total revenue generated?
SELECT 
	SUM(purchase_amount) as total_revnue
FROM shopping_data;

-- Q2. What is the average purchase amount?
SELECT
	ROUND(AVG(purchase_amount), 2) as average_purchase_amount
FROM shopping_data;

-- Q3. Which product categories generate the highest revenue?
SELECT
	category,
    SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4. Which five products generate the highest revenue?
SELECT
	item_purchased,
    SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY item_purchased
ORDER BY total_revenue DESC
limit 5;

-- Customer Analysis
-- Q5. Which age groups contribute the most revenue?
SELECT
	age_group,
    SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY age_group
ORDER BY total_revenue DESC;

-- Q6. Compare spending between male and female customers.
SELECT 
	gender,
    COUNT(*) as total_customer,
    ROUND(AVG(purchase_amount), 2) as average_purchases,
	SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY gender;

-- Q7. Which locations generate the highest revenue?
SELECT 
	location,
    COUNT(*) as total_customer,
    ROUND(AVG(purchase_amount), 2) as average_purchases,
	SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY location
ORDER BY total_revenue desc;

-- Q8. Do subscribed customers spend more than non-subscribers?
SELECT 
	subscription_status,
    COUNT(*) as total_customer,
    ROUND(AVG(purchase_amount), 2) as average_purchases,
	SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY subscription_status;

-- Discounts & Customer Loyalty
-- Q9. How many percentage of purchases use discount?
select
	discount_applied,
    round(count(*) * 100 / (select count(*) from shopping_data), 2) as percentage
from shopping_data
group by discount_applied;

-- Q10. Do customers who receive discounts spend more?
SELECT 
	discount_applied,
    COUNT(*) as total_customer,
    ROUND(AVG(purchase_amount), 2) as average_purchases,
	SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY discount_applied;

-- Q11. Segment customers into New, Returning, Loyal
SELECT
	CASE
		WHEN previous_purchases = 0 THEN 'New'
        WHEN previous_purchases BETWEEN 1 AND 10 THEN 'Returning'
        ELSE 'Loyal'
	END AS customer_segment,
    count(*) as customers,
    ROUND(AVG(purchase_amount), 2) as average_purchases,
	SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Q12. Are repeat buyers more likely to subscribe?
SELECT
	CASE
		WHEN previous_purchases = 0 THEN 'New'
        WHEN previous_purchases BETWEEN 1 AND 10 THEN 'Returning'
        ELSE 'Loyal'
	END AS customer_segment,
    subscription_status,
    count(*) as customers,
    ROUND(AVG(purchase_amount), 2) as average_purchases,
	SUM(purchase_amount) as total_revenue
FROM shopping_data
GROUP BY customer_segment, subscription_status
ORDER BY customer_segment;

-- Product Performance
-- Q13. Which products have the highest average ratings?
SELECT
	item_purchased,
    ROUND(AVG(review_rating), 2) as average_rating
FROM shopping_data
GROUP BY item_purchased
ORDER BY average_rating DESC;

-- Q14. Compare review ratings between Express and Standard shipping.
SELECT
	shipping_type,
	ROUND(AVG(review_rating), 2) as average_rating
FROM shopping_data
WHERE shipping_type IN ('Express','Standard')
GROUP BY shipping_type;

-- Q15. Find the Top 3 products in each category.
WITH RankedProducts AS
(
	SELECT
		category,
        item_purchased,
        sum(purchase_amount) as total_revenue,
        RANK() OVER (
				PARTITION BY category
                ORDER BY sum(purchase_amount) DESC
                ) AS product_rank
	FROM shopping_data
    GROUP BY category, item_purchased
)
SELECT
	category,
    item_purchased,
    total_revenue,
    product_rank
FROM RankedProducts
WHERE product_rank <= 3
ORDER BY category, product_rank;

-- Q16. What percentage of total revenue comes from each category?
SELECT
	category,
    SUM(purchase_amount) as total_spent,
    CONCAT(ROUND(
		SUM(purchase_amount) * 100 /
        (SELECT SUM(purchase_amount) FROM shopping_data)
    , 2), '%') as revenue_percentage
FROM shopping_data
GROUP BY category
ORDER BY total_spent DESC;