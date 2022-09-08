PRAGMA foreign_keys=OFF;

DROP TABLE IF EXISTS tenants;
DROP TABLE IF EXISTS janitors;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS apartments;
DROP TABLE IF EXISTS errorReports;

PRAGMA foreign_keys=ON;

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
    is_terminated DEFAULT true,
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
VALUES ('Tegel6', 'Panelgatan5', '6507054419'),
       ('Tegel8', 'Panelgatan19', '6507054419'),
       ('Egino14', 'Lundavägen10', '7012083994');

INSERT INTO tenants(tenant_name, personnumber, property_address, property_name, apartment_number )
VALUES ('Stina Hansson', '9906075512', 'Panelgatan19', 'Tegel8', '1005'),
       ('Carl Svensson', '9512053020','Panelgatan5', 'Tegel6', '1001'),
       ('Emilia Carlsson', '9706011133', 'Lundavägen10', 'Egino14', '0002');

INSERT INTO apartments(property_name, property_address, apartment_number,end_of_contract_date, is_terminated)
VALUES ('Tegel6', 'Panelgatan5', '1001', NULL, false),
       ('Tegel8', 'Panelgatan19', '1005', '2024-01-01', true),
       ('Egino14', 'Lundavägen10', '0002', NULL, false),
       ('Egino14', 'Lundavägen10', '0003', '2022-10-01', true);

INSERT INTO errorReports(error_ID, personnumber, tenant_name, property_address, apartment_number, information)
VALUES ('12345', '9906075512', 'Stina Hansson', 'Panelgatan19','1005', 'Kass ventil'),
       ('11111', '9512053020', 'Carl Svensson', 'Panelgatan5','1001', 'List av'),
       ('22222', '9706011133', 'Emilia Carlsson', 'Lundavägen10','0002', 'Kallt element');
