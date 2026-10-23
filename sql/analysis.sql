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