# Data notes: Olist e-commerce dataset

## Tables

### orders
- Rows: 99,441  Columns: 8 [check]
- One row = one order
- Key column: order_id (links to items, reviews, payments)
- Missing values: order_approved_at (about 160), order_delivered_carrier_date (about 1,800), order_delivered_customer_date (about 3,000), because not every order was delivered [check]

### items
- Rows: 112,650  Columns: 7 [check]
- One row = one item inside an order
- Key columns: order_id, product_id, seller_id
- Missing values: none [check]

### customers
- Rows: 99,441  Columns: 5 [check]
- One row = one customer record
- Key columns: customer_id (changes per order), customer_unique_id (identifies the person)
- Missing values: none [check]

### products
- Rows: about 32,951  Columns: 9 [check]
- One row = one product
- Key column: product_id
- Missing values: product_category_name (about 610) plus a few size and weight columns [check]

### reviews
- Rows: about 99,224  Columns: 7 [check]
- One row = one review
- Key column: order_id
- Missing values: review_comment_title (about 88,000) and review_comment_message (about 58,000) [check]

### payments
- Rows: about 103,886  Columns: 5 [check]
- One row = one payment on an order
- Key column: order_id
- Missing values: none [check]

## Findings

1. Order status: about 97% of orders are delivered (about 96,478 of 99,441). The rest are canceled, unavailable, shipped, invoiced, processing, created or approved. [check]
2. Months with very few orders: the first months (Sep to Dec 2016) and the last months (Sep and Oct 2018) have almost none. I will exclude them. [check]
3. Orders with more than one review: 551 duplicated order_id values in reviews.
4. Unique customers: 96,096 people out of 99,441 customer records, so some people ordered more than once.
5. order_id is unique in orders (99,441 of 99,441), but only 98,666 orders appear in items. About 775 orders have no items, probably canceled or unavailable ones.
6. Items has 112,650 rows for 98,666 orders, so many orders contain several items. Joining on order_id will multiply rows, so revenue must be summed carefully.

## Decisions for the cleaning phase

- Keep only delivered orders
- Exclude months with very few orders
- Keep one review per order (the latest)
- Revenue = item price, excluding freight