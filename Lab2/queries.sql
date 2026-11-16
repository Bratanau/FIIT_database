SELECT
    o.order_id,
    o.order_date,
    o.status AS order_status,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.sku,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_amount
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
ORDER BY o.order_date DESC, o.order_id, p.product_name;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    o.order_id,
    oi.product_id,
    p.product_name
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
LEFT JOIN products AS p ON p.product_id = oi.product_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.status,
    p.product_name,
    category.category_name
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
JOIN categories AS category ON category.category_id = p.category_id
WHERE c.status IN ('active', 'vip')
  AND o.status IN ('paid', 'shipped', 'delivered')
  AND p.is_active = TRUE
  AND category.category_name = 'Laptops'
ORDER BY o.order_date DESC, c.customer_id;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0)::NUMERIC(14, 2) AS total_order_amount,
    ROUND(AVG(o.total_amount), 2) AS average_order_amount,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_order_amount DESC, c.customer_id;

SELECT
    category.category_id,
    category.category_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price)::NUMERIC(14, 2) AS sales_amount,
    ROUND(AVG(oi.unit_price), 2) AS average_selling_price,
    COUNT(DISTINCT o.order_id) AS order_count
FROM categories AS category
JOIN products AS p ON p.category_id = category.category_id
JOIN order_items AS oi ON oi.product_id = p.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY category.category_id, category.category_name
HAVING SUM(oi.quantity) >= 10
ORDER BY sales_amount DESC;

SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS sales_month,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount)::NUMERIC(14, 2) AS declared_order_amount,
    ROUND(AVG(o.total_amount), 2) AS average_order_amount,
    MIN(o.total_amount) AS minimum_order_amount,
    MAX(o.total_amount) AS maximum_order_amount
FROM orders AS o
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY sales_month;

SELECT
    p.product_id,
    p.sku,
    p.product_name,
    category.category_name,
    p.price,
    (
        SELECT ROUND(AVG(category_product.price), 2)
        FROM products AS category_product
        WHERE category_product.category_id = p.category_id
    ) AS category_average_price
FROM products AS p
JOIN categories AS category ON category.category_id = p.category_id
WHERE p.price > (
    SELECT AVG(category_product.price)
    FROM products AS category_product
    WHERE category_product.category_id = p.category_id
)
ORDER BY category.category_name, p.price DESC;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE o.customer_id = c.customer_id
      AND o.status IN ('paid', 'shipped', 'delivered')
      AND oi.quantity >= 2
)
ORDER BY c.customer_id;

SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.price,
    p.stock_quantity
FROM products AS p
WHERE p.is_active = TRUE
  AND NOT EXISTS (
      SELECT 1
      FROM order_items AS oi
      JOIN orders AS o ON o.order_id = oi.order_id
      WHERE oi.product_id = p.product_id
        AND o.status IN ('paid', 'shipped', 'delivered')
  )
ORDER BY p.product_name;

SELECT
    o.order_id,
    o.customer_id,
    c.first_name,
    c.last_name,
    o.order_date,
    o.total_amount,
    (
        SELECT ROUND(AVG(customer_order.total_amount), 2)
        FROM orders AS customer_order
        WHERE customer_order.customer_id = o.customer_id
    ) AS customer_average_order_amount
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
WHERE o.total_amount > (
    SELECT AVG(customer_order.total_amount)
    FROM orders AS customer_order
    WHERE customer_order.customer_id = o.customer_id
)
ORDER BY o.customer_id, o.total_amount DESC;