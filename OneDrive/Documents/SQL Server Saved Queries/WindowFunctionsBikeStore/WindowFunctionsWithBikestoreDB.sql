USE BikeStores;
GO

--View tables using the SELECT Statement--
SELECT * FROM sales.customers;
SELECT * FROM sales.order_items;
SELECT * FROM sales.orders;
SELECT * FROM production.products;

--Create three INNER JOINS to connect the related tables above--
SELECT c.customer_id,
	c.first_name,
	c.last_name,
	c.city,
	c.state,
	i.quantity,
	i.list_price,
	o.order_status,
	o.required_date,
	o.shipped_date,
	p.product_name,
	p.model_year
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items i
ON o.order_id = i.order_id
INNER JOIN production.products p
ON i.product_id = p.product_id;

--Aggregate window functions with the OVER clause--
SELECT c.customer_id,
	c.first_name,
	c.last_name,
	c.city,
	c.state,
	i.quantity,
	i.list_price,
	o.order_status,
	o.required_date,
	o.shipped_date,
	p.product_name,
	p.model_year,
	SUM(i.list_price) OVER() AS total_price,
	AVG(i.list_price) OVER() AS avg_price,
	MAX(i.list_price) OVER() AS max_price,
	MIN(i.list_price) OVER() AS min_price,
	COUNT(*) OVER() AS total_transaction
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items i
ON o.order_id = i.order_id
INNER JOIN production.products p
ON i.product_id = p.product_id;


--Aggregate window functions with the OVER and PARTITION BY clauses--
SELECT c.customer_id,
	c.first_name,
	c.last_name,
	c.city,
	c.state,
	i.quantity,
	i.list_price,
	o.order_status,
	o.required_date,
	o.shipped_date,
	p.product_name,
	p.model_year,
	SUM(i.list_price) OVER(PARTITION BY product_name ORDER BY i.list_price DESC) AS total_price,
	AVG(i.list_price) OVER() AS avg_price,
	MAX(i.list_price) OVER() AS max_price,
	MIN(i.list_price) OVER() AS min_price,
	COUNT(*) OVER() AS total_transaction,
	CASE
		WHEN o.shipped_date > o.required_date THEN 'late'
		ELSE 'on time'
		END AS shipping_status
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items i
ON o.order_id = i.order_id
INNER JOIN production.products p
ON i.product_id = p.product_id;

--Using window functions in a subquery--
SELECT * FROM
(SELECT c.customer_id,
	c.first_name,
	c.last_name,
	c.city,
	c.state,
	i.quantity,
	i.list_price,
	o.order_status,
	o.required_date,
	o.shipped_date,
	p.product_name,
	p.model_year,
	AVG(i.list_price) OVER() AS avg_price,
	AVG(i.list_price) OVER(PARTITION BY product_name ORDER BY i.list_price DESC) AS avg_price_by_name
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items i
ON o.order_id = i.order_id
INNER JOIN production.products p
ON i.product_id = p.product_id) AS new_table
WHERE new_table.list_price > avg_price
;
