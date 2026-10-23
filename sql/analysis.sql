-- Query 1: Monthly revenue, orders, AOV and month-over-month change
WITH monthly AS (
  SELECT strftime('%Y-%m', order_purchase_timestamp) AS month,
         COUNT(DISTINCT order_id) AS orders,
         SUM(price) AS revenue
  FROM master
  GROUP BY month
)
SELECT month, orders, ROUND(revenue, 0) AS revenue,
       ROUND(revenue / orders, 2) AS aov,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_pct
FROM monthly
ORDER BY month;

-- Query 2: Categories with the biggest revenue change, Nov to Dec 2017
SELECT category_en,
       ROUND(SUM(CASE WHEN month = '2017-11' THEN price ELSE 0 END), 0) AS nov_rev,
       ROUND(SUM(CASE WHEN month = '2017-12' THEN price ELSE 0 END), 0) AS dec_rev,
       ROUND(SUM(CASE WHEN month = '2017-12' THEN price ELSE 0 END)
           - SUM(CASE WHEN month = '2017-11' THEN price ELSE 0 END), 0) AS change
FROM (
  SELECT category_en, price,
         strftime('%Y-%m', order_purchase_timestamp) AS month
  FROM master
)
GROUP BY category_en
ORDER BY change ASC
LIMIT 10;

-- Query 3: New vs. returning customers by month
WITH first_order AS (
  SELECT customer_unique_id,
         MIN(strftime('%Y-%m', order_purchase_timestamp)) AS first_month
  FROM master
  GROUP BY customer_unique_id
)
SELECT strftime('%Y-%m', m.order_purchase_timestamp) AS month,
       COUNT(DISTINCT CASE WHEN f.first_month = strftime('%Y-%m', m.order_purchase_timestamp)
             THEN m.customer_unique_id END) AS new_customers,
       COUNT(DISTINCT CASE WHEN f.first_month <> strftime('%Y-%m', m.order_purchase_timestamp)
             THEN m.customer_unique_id END) AS returning_customers
FROM master m
JOIN first_order f USING (customer_unique_id)
GROUP BY month
ORDER BY month;

-- Query 4: Revenue and late-delivery rate by state
SELECT customer_state,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 0) AS revenue,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_late = 1 THEN order_id END)
             / COUNT(DISTINCT order_id), 1) AS late_pct
FROM master
GROUP BY customer_state
ORDER BY revenue DESC;

-- Query 5: Average review score for late vs. on-time orders
SELECT is_late,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review
FROM (SELECT DISTINCT order_id, is_late, review_score FROM master)
GROUP BY is_late;

-- Query 6: Top 3 categories by revenue in each month
WITH cat AS (
  SELECT strftime('%Y-%m', order_purchase_timestamp) AS month,
         category_en, SUM(price) AS revenue
  FROM master GROUP BY 1, 2
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rnk
  FROM cat
)
SELECT month, category_en, ROUND(revenue, 0) AS revenue, rnk
FROM ranked WHERE rnk <= 3
ORDER BY month, rnk;