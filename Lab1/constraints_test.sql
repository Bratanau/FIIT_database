DO $$
BEGIN
    INSERT INTO customers (first_name, last_name, email, phone, registration_date, status)
    VALUES ('Анна', 'Белова', 'ivan.petrov@example.com', '+7-900-600-70-80', '2025-06-01', 'active');
    RAISE EXCEPTION 'FAIL: duplicate email must be rejected';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'OK: duplicate customer email rejected';
END $$;

DO $$
BEGIN
    INSERT INTO products (sku, product_name, category_id, price, stock_quantity, is_active)
    VALUES ('SKU-1001', 'Duplicate Product', 2, 1990.00, 5, TRUE);
    RAISE EXCEPTION 'FAIL: duplicate SKU must be rejected';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'OK: duplicate product SKU rejected';
END $$;

DO $$
BEGIN
    INSERT INTO products (sku, product_name, category_id, price, stock_quantity, is_active)
    VALUES ('SKU-9999', 'Broken Stock', 2, 500.00, -1, TRUE);
    RAISE EXCEPTION 'FAIL: negative stock quantity must be rejected';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK: negative stock quantity rejected by CHECK';
END $$;

DO $$
BEGIN
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (1, 1, 0, 34990.00);
    RAISE EXCEPTION 'FAIL: zero quantity must be rejected';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK: order item quantity rejected by CHECK';
END $$;

DO $$
BEGIN
    INSERT INTO orders (customer_id, order_date, status, shipping_address, total_amount)
    VALUES (999, '2025-06-15 10:00:00', 'paid', 'Адрес для проверки', 1500.00);
    RAISE EXCEPTION 'FAIL: foreign key violation should be rejected';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'OK: invalid customer reference rejected';
END $$;

DO $$
BEGIN
    INSERT INTO orders (customer_id, order_date, status, shipping_address, total_amount)
    VALUES (2, '2025-06-16 10:00:00', 'incorrect_status', 'Test address', 1200.00);
    RAISE EXCEPTION 'FAIL: invalid order status must be rejected';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK: invalid status rejected by CHECK';
END $$;

DO $$
BEGIN
    UPDATE orders
    SET total_amount = -500.00
    WHERE order_id = 1;
    RAISE EXCEPTION 'FAIL: negative total_amount must be rejected';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK: negative total_amount rejected by CHECK';
END $$;
