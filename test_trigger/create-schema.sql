PRAGMA foreign_keys=OFF;

DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS recipeitems;
DROP TABLE IF EXISTS cookies;
DROP TABLE IF EXISTS pallets;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS orderspecs;
DROP TABLE IF EXISTS customers;
DROP TRIGGER IF EXISTS add_new_pallet;

PRAGMA foreign_keys=ON;

CREATE TABLE ingredients (
    ingredient_name TEXT,
    in_stock INT DEFAULT 0,
    measure TEXT,
    delivery_date DATE,
    delivery_quantity INT,
    PRIMARY KEY (ingredient_name)
);

CREATE TABLE recipeitems (
    cookie_name TEXT,
    quantity INT,
    ingredient_name TEXT,
    PRIMARY KEY (cookie_name, ingredient_name),
    FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name),
    FOREIGN KEY (ingredient_name) REFERENCES ingredients(ingredient_name)
);

CREATE TABLE cookies (
    cookie_name TEXT,
    PRIMARY KEY (cookie_name)
);

CREATE TABLE pallets (
    pallet_id TEXT DEFAULT (lower(hex(randomblob(16)))),
    production_date DATE,
    delivery_date DATE,
    is_blocked false,
    cookie_name TEXT,
    order_id TEXT,
    PRIMARY KEY (pallet_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name)
);

CREATE TABLE customers (
    customer_name TEXT,
    customer_address TEXT,
    PRIMARY KEY (customer_name)
);

CREATE TABLE orders (
    order_id TEXT DEFAULT (lower(hex(randomblob(16)))),
    order_date DATE,
    delivery_date DATE,
    customer_name TEXT,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_name) REFERENCES customers(customer_name)
);

CREATE TABLE orderspecs (
    order_id TEXT,
    quantity INT,
    cookie_name TEXT,
    PRIMARY KEY (order_id, cookie_name),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name)
);

CREATE TRIGGER add_new_pallet
BEFORE INSERT ON pallets
BEGIN
    WITH 
        new_pallet_ingredients(ingredient_name, quantity) AS (
            SELECT ingredient_name, quantity
            FROM recipeitems
            WHERE cookie_name = NEW.cookie_name),
        new_pallet_quantities(in_stock, quantity) AS (
            SELECT in_stock, quantity
            FROM ingredients
            JOIN new_pallet_ingredients
            USING (ingredient_name))
    SELECT
        CASE WHEN
        (SELECT count()
         FROM new_pallet_quantities
         WHERE in_stock >= quantity * 54) < (SELECT count()
                                             FROM new_pallet_quantities)
        THEN
            RAISE (ROLLBACK, "Insufficient ingredients in stock")
        
        WHEN
        (SELECT count()
         FROM new_pallet_quantities
         WHERE in_stock >= quantity * 54) = (SELECT count()
                                             FROM new_pallet_quantities)
        THEN
            UPDATE ingredients
            SET in_stock = in_stock - 1000 -- mumbo jumbo number, just for testing
            WHERE ingredient_name IN (SELECT ingredient_name 
                                      FROM new_pallet_ingredients);
        END
END;


