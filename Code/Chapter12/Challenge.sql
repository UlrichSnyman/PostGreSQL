-- Challenge 2

CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    description TEXT,
    base_salary INTEGER
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    birth_date DATE,
    role_id INTEGER REFERENCES roles(role_id),
    sales_units INTEGER DEFAULT 0
);


SELECT * FROM roles
SELECT * FROM employees

DROP TABLE employees

INSERT INTO roles (role_name, description, base_salary) VALUES
('Graphic Designer', 'Helps with video editing, photo editing and market advertisement designs', 35000),
('Videographer', 'Helps with all digital media productions', 18000),
('Social Marketer', 'Helps with social media strategies and social data', 26000),
('Sales Rep', 'Helps promote and sign clients', 20000);

INSERT INTO employees (employee_name, birth_date, role_id, sales_units) VALUES
('Aragorn', '1994-08-24', 4, 22),
('Gandalf', '1982-05-11', 1, 0),
('Frodo', '1990-01-18', 2, 0),
('Legolas', '1998-04-22', 3, 0),
('Gimli', '2000-11-08', 4, 10),
('Samwise', '2001-01-01', 4, 9),
('Pippin', '1999-09-26', 4, 18),
('Merry', '2005-08-07', 3, 0);

SELECT 
    e.employee_name,
    r.role_name,
    r.base_salary + 
        CASE 
            WHEN r.role_name = 'Sales Rep' AND e.sales_units > 10 
            THEN (e.sales_units - 10) * 200 
            ELSE 0 
        END AS adjusted_salary
FROM employees e
JOIN roles r ON e.role_id = r.role_id;

SELECT 
    e.employee_name,
    r.role_name,
    r.base_salary 
FROM employees e
JOIN roles r ON e.role_id = r.role_id;



SELECT employee_name, birth_date
FROM employees
WHERE birth_date < '1998-08-01';


COPY (
    SELECT 
        e.employee_name,
        r.role_name,
        r.base_salary + 
            CASE 
                WHEN r.role_name = 'Sales Rep' AND e.sales_units > 10 
                THEN (e.sales_units - 10) * 200 
                ELSE 0 
            END AS adjusted_salary
    FROM employees e
    JOIN roles r ON e.role_id = r.role_id
)
TO 'C:\Users\ulric\OneDrive\Documents\Code College\Web bootcamp\SQL\Code\Chapter12\employees_salaries.csv'
WITH (FORMAT CSV, HEADER);