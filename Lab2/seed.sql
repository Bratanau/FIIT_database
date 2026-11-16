BEGIN;

INSERT INTO customers (
    first_name,
    last_name,
    email,
    phone,
    registration_date,
    status
)
SELECT
    'Lab2',
    'Customer ' || g,
    'lab2.customer.' || lpad(g::text, 3, '0') || '@example.com',
    '+7-900-000-' || lpad(g::text, 2, '0') || '-00',
    DATE '2025-01-01' + g,
    CASE
        WHEN g % 13 = 0 THEN 'blocked'
        WHEN g % 7 = 0 THEN 'vip'
        ELSE 'active'
    END
FROM generate_series(1, 36) AS series(g)
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (
    sku,
    product_name,
    category_id,
    price,
    stock_quantity,
    is_active
)
SELECT
    'LAB2-SKU-' || lpad(g::text, 5, '0'),
    'Lab2 Product ' || lpad(g::text, 3, '0'),
    category.category_id,
    (199.00 + ((g * 137) % 50000))::NUMERIC(10, 2),
    CASE WHEN g % 10 = 0 THEN 0 ELSE (g * 7) % 80 END,
    g % 17 <> 0
FROM generate_series(1, 45) AS series(g)
CROSS JOIN LATERAL (
    SELECT category_id
    FROM categories
    ORDER BY category_id
    OFFSET ((g - 1) % (SELECT COUNT(*) FROM categories))
    LIMIT 1
) AS category
ON CONFLICT (sku) DO NOTHING;

WITH order_source AS (
    SELECT
        g,
        1 + ((g - 1) % 25) AS customer_number,
        TIMESTAMP '2025-01-01 09:00:00'
            + ((g - 1) * INTERVAL '9 days')
            + ((g % 12) * INTERVAL '1 hour') AS order_date
    FROM generate_series(1, 60) AS series(g)
)

INSERT INTO orders (
    customer_id,
    order_date,
    status,
    shipping_address,
    total_amount
)
SELECT
    customer.customer_id,
    source.order_date,
    CASE source.g % 5
        WHEN 0 THEN 'created'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'shipped'
        WHEN 3 THEN 'delivered'
        ELSE 'cancelled'
    END,
    'Lab2 delivery address ' || source.customer_number,
    0
FROM order_source AS source
JOIN customers AS customer
    ON customer.email =
        'lab2.customer.' || lpad(source.customer_number::text, 3, '0') || '@example.com'
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS existing_order
    WHERE existing_order.customer_id = customer.customer_id
      AND existing_order.order_date = source.order_date
);

WITH order_source AS (
    SELECT
        g,
        1 + ((g - 1) % 25) AS customer_number,
        TIMESTAMP '2025-01-01 09:00:00'
            + ((g - 1) * INTERVAL '9 days')
            + ((g % 12) * INTERVAL '1 hour') AS order_date
    FROM generate_series(1, 60) AS series(g)
),
order_lines AS (
    SELECT
        source.g,
        source.customer_number,
        source.order_date,
        line.line_number,
        1 + ((source.g * 3 + line.line_number * 7) % 40) AS product_number,
        1 + ((source.g + line.line_number) % 4) AS quantity
    FROM order_source AS source
    CROSS JOIN LATERAL generate_series(
        1,
        CASE source.g % 4
            WHEN 0 THEN 1
            WHEN 1 THEN 2
            ELSE 3
        END
    ) AS line(line_number)
)

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    customer_order.order_id,
    product.product_id,
    order_lines.quantity,
    product.price
FROM order_lines
JOIN customers AS customer
    ON customer.email =
        'lab2.customer.' || lpad(order_lines.customer_number::text, 3, '0') || '@example.com'
JOIN orders AS customer_order
    ON customer_order.customer_id = customer.customer_id
   AND customer_order.order_date = order_lines.order_date
JOIN products AS product
    ON product.sku = 'LAB2-SKU-' || lpad(order_lines.product_number::text, 5, '0')
ON CONFLICT (order_id, product_id) DO NOTHING;

UPDATE orders AS customer_order
SET total_amount = line_totals.total_amount
FROM (
    SELECT
        item.order_id,
        SUM(item.quantity * item.unit_price) AS total_amount
    FROM order_items AS item
    GROUP BY item.order_id
) AS line_totals
WHERE customer_order.order_id = line_totals.order_id
  AND EXISTS (
      SELECT 1
      FROM customers AS customer
      WHERE customer.customer_id = customer_order.customer_id
        AND customer.email LIKE 'lab2.customer.%@example.com'
  );

COMMIT;
