-- Демонстрация INSERT, UPDATE, массового UPDATE и DELETE.
-- Все изменения намеренно отменяются в конце транзакции.
-- Перед запуском выполните seed.sql из этой папки.

BEGIN;

DO $$
DECLARE
    new_customer_id INT;
    new_product_id INT;
    new_order_id INT;
    bulk_updated_count INT;
    deleted_product_count INT;
BEGIN
    INSERT INTO customers (
        first_name,
        last_name,
        email,
        phone,
        registration_date,
        status
    )
    VALUES (
        'Transaction',
        'Demo Customer',
        'lab2.transaction.demo@example.com',
        '+7-900-777-00-01',
        CURRENT_DATE,
        'active'
    )
    RETURNING customer_id INTO new_customer_id;

    INSERT INTO products (
        sku,
        product_name,
        category_id,
        price,
        stock_quantity,
        is_active
    )
    VALUES (
        'LAB2-TXN-DEMO',
        'Transaction Demo Product',
        (SELECT MIN(category_id) FROM categories),
        500.00,
        3,
        TRUE
    )
    RETURNING product_id INTO new_product_id;

    INSERT INTO orders (
        customer_id,
        order_date,
        status,
        shipping_address,
        total_amount
    )
    VALUES (
        new_customer_id,
        CURRENT_TIMESTAMP,
        'created',
        'Transaction demo address',
        500.00
    )
    RETURNING order_id INTO new_order_id;

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (new_order_id, new_product_id, 1, 500.00);

    RAISE NOTICE 'INSERT: customer %, product %, order % and order item created',
        new_customer_id, new_product_id, new_order_id;

    UPDATE orders
    SET status = 'paid'
    WHERE order_id = new_order_id;

    RAISE NOTICE 'UPDATE: order % status changed from created to paid', new_order_id;

    UPDATE orders
    SET status = 'cancelled'
    WHERE status = 'created'
      AND order_date < TIMESTAMP '2026-01-01';

    GET DIAGNOSTICS bulk_updated_count = ROW_COUNT;
    RAISE NOTICE 'Bulk UPDATE: % old created orders marked as cancelled',
        bulk_updated_count;

    DELETE FROM products
    WHERE sku = 'LAB2-SKU-00045'
      AND NOT EXISTS (
          SELECT 1
          FROM order_items
          WHERE order_items.product_id = products.product_id
      );

    GET DIAGNOSTICS deleted_product_count = ROW_COUNT;
    IF deleted_product_count <> 1 THEN
        RAISE EXCEPTION
            'Expected to delete one unreferenced product; deleted %',
            deleted_product_count;
    END IF;
    RAISE NOTICE 'DELETE: unreferenced product LAB2-SKU-00045 deleted';
END $$;

ROLLBACK;

-- После ROLLBACK добавленные выше записи и изменения отсутствуют.
