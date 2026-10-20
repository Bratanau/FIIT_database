CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INT REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    description TEXT
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30) NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'blocked', 'vip'))
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(40) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'created'
        CHECK (status IN ('created', 'paid', 'shipped', 'delivered', 'cancelled')),
    shipping_address VARCHAR(255) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0)
);

CREATE TABLE order_items (
    order_id INT NOT NULL REFERENCES orders(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)
);