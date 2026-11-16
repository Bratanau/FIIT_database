ALTER TABLE customers
    ADD COLUMN loyalty_points INT NOT NULL DEFAULT 0;

ALTER TABLE customers
    ADD CONSTRAINT customers_loyalty_points_chk
    CHECK (loyalty_points >= 0);

ALTER TABLE products
    ADD COLUMN discount_percent NUMERIC(5,2) NOT NULL DEFAULT 0;

ALTER TABLE products
    ADD CONSTRAINT products_discount_percent_chk
    CHECK (discount_percent >= 0 AND discount_percent <= 100);

ALTER TABLE orders
    ADD COLUMN delivery_type VARCHAR(20) NOT NULL DEFAULT 'standard';

ALTER TABLE orders
    ADD CONSTRAINT orders_delivery_type_chk
    CHECK (delivery_type IN ('standard', 'express', 'pickup'));

UPDATE customers
SET loyalty_points = 150
WHERE customer_id = 1;

UPDATE customers
SET loyalty_points = 50
WHERE customer_id = 2;

UPDATE customers
SET loyalty_points = 25
WHERE customer_id = 3;

UPDATE products
SET discount_percent = 5.00
WHERE product_id = 1;

UPDATE products
SET discount_percent = 10.00
WHERE product_id = 2;

UPDATE products
SET discount_percent = 0.00
WHERE product_id = 3;

UPDATE orders
SET delivery_type = 'express'
WHERE order_id = 1;

UPDATE orders
SET delivery_type = 'standard'
WHERE order_id IN (2, 3);