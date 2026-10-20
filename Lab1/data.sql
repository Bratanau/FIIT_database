INSERT INTO categories (category_name, parent_category_id, description) VALUES
    ('Electronics', NULL, 'Electronics and gadgets'),
    ('Smartphones', 1, 'Mobile phones and accessories'),
    ('Laptops', 1, 'Portable computers'),
    ('Home', NULL, 'Household items and home goods'),
    ('Audio', 1, 'Headphones and speakers');

INSERT INTO customers (first_name, last_name, email, phone, registration_date, status) VALUES
    ('Иван', 'Петров', 'ivan.petrov@example.com', '+7-900-111-22-33', '2025-01-15', 'vip'),
    ('Мария', 'Сидорова', 'maria.sidorova@example.com', '+7-900-222-33-44', '2025-02-10', 'active'),
    ('Алексей', 'Кузнецов', 'alex.kuznetsov@example.com', '+7-900-333-44-55', '2025-03-01', 'active'),
    ('Елена', 'Васильева', 'elena.vasilieva@example.com', '+7-900-444-55-66', '2025-04-20', 'blocked');

INSERT INTO products (sku, product_name, category_id, price, stock_quantity, is_active) VALUES
    ('SKU-1001', 'Smartphone X10', 2, 34990.00, 25, TRUE),
    ('SKU-1002', 'Wireless Headphones Pro', 5, 8990.00, 40, TRUE),
    ('SKU-2001', 'Laptop UltraBook 14', 3, 72990.00, 12, TRUE),
    ('SKU-3001', 'Smart Lamp', 4, 2490.00, 50, TRUE),
    ('SKU-3002', 'Desk Organizer', 4, 890.00, 70, TRUE);

INSERT INTO orders (customer_id, order_date, status, shipping_address, total_amount) VALUES
    (1, '2025-06-01 10:15:00', 'paid', 'Москва, ул. Ленина, 10, кв. 5', 44980.00),
    (2, '2025-06-05 15:40:00', 'shipped', 'Санкт-Петербург, пр. Невский, 15', 8990.00),
    (3, '2025-06-12 08:00:00', 'created', 'Казань, ул. Баумана, 8', 75480.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 34990.00),
    (1, 2, 1, 8990.00),
    (2, 2, 1, 8990.00),
    (3, 3, 1, 72990.00),
    (3, 5, 2, 890.00);
