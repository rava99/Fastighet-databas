PRAGMA foreign_keys=OFF;

DROP TABLE IF EXISTS tenants;
DROP TABLE IF EXISTS janitors;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS apartments;
DROP TABLE IF EXISTS errorReports;

-- DROP TRIGGER IF EXISTS add_new_pallet;

PRAGMA foreign_keys=ON;


-- SKRIV IN ALLA FOREIGN KEYS!!!

CREATE TABLE tenants (
    tenant_name TEXT,
    personnumber INT,
    property_address TEXT,
    property_name TEXT,
    apartment_number INT,
    PRIMARY KEY (personnumber),
    FOREIGN KEY (property_name) REFERENCES properties(property_name)
);

CREATE TABLE janitors (
    janitor_name TEXT,
    janitor_personnumber INT,
    PRIMARY KEY (janitor_personnumber)
);

CREATE TABLE properties (
    property_name TEXT,
    property_address TEXT,
    janitor_personnumber INT,
    PRIMARY KEY (property_name),
    FOREIGN KEY (janitor_personnumber) REFERENCES janitors(janitor_personnumber)
);
CREATE TABLE apartments (
    property_name TEXT,
    property_address TEXT,
    apartment_number INT,
    is_terminated TEXT,
    end_of_contract_date DATE,
    PRIMARY KEY (property_address, apartment_number),
    FOREIGN KEY (property_name) REFERENCES properties(property_name)
);
CREATE TABLE errorReports (
    error_ID TEXT DEFAULT (lower(hex(randomblob(16)))),
    personnumber INT,
    tenant_name TEXT,
    property_address TEXT,
    apartment_number INT,
    information TEXT,
    PRIMARY KEY (error_ID),
    FOREIGN KEY (personnumber) REFERENCES tenants(personnumber),
    FOREIGN KEY (property_address, apartment_number) REFERENCES apartments(property_address, apartment_number)
);






INSERT INTO janitors(janitor_name, janitor_personnumber)
VALUES ('Bertil Carlsson', '6507054419'),
       ('Kalle Henriksson', '7012083994');

INSERT INTO properties(property_name, property_address, janitor_personnumber)
VALUES ('Tegel 6', 'Panelgatan 5', '6507054419'),
       ('Tegel 8', 'Panelgatan 19', '6507054419'),
       ('Egino14', 'Lundavägen 10', '7012083994');

INSERT INTO tenants(tenant_name, personnumber, property_address, property_name, apartment_number )
VALUES ('Stina Hansson', '9906075512', 'Panelgatan 19', 'Tegel 8', '1005'),
       ('Carl Svensson', '9512053020','Panelgatan 5', 'Tegel 6', '1001'),
       ('Emilia Carlsson', '9706011133', 'Lundavägen 10', 'Egino14', '0002');


--utflytt bestämt datum. Ta bort rented from?

INSERT INTO apartments(property_name, property_address, apartment_number,end_of_contract_date, is_terminated)
VALUES ('Tegel 6', 'Panelgatan 5', '1001', NULL, 'No'),
       ('Tegel 8', 'Panelgatan 19', '1005', '2024-01-01', "Yes"),
       ('Egino14', 'Lundavägen 10', '0002', NULL, 'No'),
       ('Egino14', 'Lundavägen 10', '0003', '2022-10-01', "Yes");

INSERT INTO errorReports(error_ID, personnumber, tenant_name, property_address, apartment_number, information)
VALUES ('12345', '9906075512', 'Stina Hansson', 'Panelgatan 19','1005', 'Kass ventil'),
       ('11111', '9512053020', 'Carl Svensson', 'Panelgatan 5','1001', 'List av'),
       ('22222', '9706011133', 'Emilia Carlsson', 'Lundavägen 10','0002', 'Kallt element');










-- CREATE TABLE ingredients (
--     ingredient_name TEXT,
--     in_stock INT DEFAULT 0,
--     measure TEXT,
--     delivery_date DATE,
--     delivery_quantity INT,
--     PRIMARY KEY (ingredient_name)
-- );

-- CREATE TABLE recipeitems (
--     cookie_name TEXT,
--     quantity INT,
--     ingredient_name TEXT,
--     PRIMARY KEY (cookie_name, ingredient_name),
--     FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name),
--     FOREIGN KEY (ingredient_name) REFERENCES ingredients(ingredient_name)
-- );

-- CREATE TABLE cookies (
--     cookie_name TEXT,
--     PRIMARY KEY (cookie_name)
-- );


-- CREATE TABLE pallets (
--     pallet_id TEXT DEFAULT (lower(hex(randomblob(16)))),
--     production_date DATE,
--     is_blocked DEFAULT false,
--     cookie_name TEXT,
--     PRIMARY KEY (pallet_id),
--     FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name)
-- );


-- CREATE TABLE orders (
--     order_id TEXT DEFAULT (lower(hex(randomblob(16)))),
--     order_date DATE,
--     delivery_date DATE,
--     customer_name TEXT,
--     PRIMARY KEY (order_id),
--     FOREIGN KEY (customer_name) REFERENCES customers(customer_name)
-- );

-- CREATE TABLE orderspecs (
--     order_id TEXT,
--     quantity INT,
--     cookie_name TEXT,
--     PRIMARY KEY (order_id, cookie_name),
--     FOREIGN KEY (order_id) REFERENCES orders(order_id),
--     FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name)
-- );




-- INSERT INTO pallets(production_date, cookie_name)
-- VALUES ('2022-03-10', 'Hallongrotta'),
--        ('2024-03-10', 'Hallongrotta'),
--        ('2022-03-01', 'Almond delight'),
--        ('2020-04-01', 'Hallongrotta'),
--        ('2021-06-17', 'Kollabollar');

-- CREATE TRIGGER add_new_pallet
-- BEFORE INSERT ON pallets
-- BEGIN
--     WITH 
--         new_pallet_ingredients(ingredient_name, quantity) AS (
--             SELECT ingredient_name, quantity
--             FROM recipeitems
--             WHERE cookie_name = NEW.cookie_name),
--         new_pallet_quantities(in_stock, quantity) AS (
--             SELECT in_stock, quantity
--             FROM ingredients
--             JOIN new_pallet_ingredients
--             USING (ingredient_name))
--     SELECT
--         CASE WHEN
--         (SELECT count()
--          FROM new_pallet_quantities
--          WHERE in_stock >= quantity * 54) < (SELECT count()
--                                              FROM new_pallet_quantities)
--         THEN
--             RAISE (ROLLBACK, "Insufficient ingredients in stock")
--         END;
-- END;
