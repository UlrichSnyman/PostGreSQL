CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE jobs (
    job_id SERIAL PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    salary NUMERIC(10,2) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dept_id INT REFERENCES departments(dept_id),
    job_id INT REFERENCES jobs(job_id)
);

CREATE TABLE overtime (
    ot_id SERIAL PRIMARY KEY,
    emp_id INT REFERENCES employees(emp_id),
    hours_worked NUMERIC(5,2),
    ot_date DATE
);

CREATE TABLE attendance (
    att_id SERIAL PRIMARY KEY,
    emp_id INT REFERENCES employees(emp_id),
    att_date DATE,
    status VARCHAR(20)
);




INSERT INTO departments (dept_name) VALUES
('Human Resources'),
('Finance'),
('IT');

INSERT INTO jobs (job_title, salary) VALUES
('HR Manager', 55000),
('Accountant', 48000),
('Software Engineer', 65000);

INSERT INTO employees (first_name, last_name, dept_id, job_id) VALUES
('Alice', 'Smith', 1, 1),
('Bob', 'Johnson', 2, 2),
('Charlie', 'Brown', 3, 3);

INSERT INTO overtime (emp_id, hours_worked, ot_date) VALUES
(1, 5, '2025-07-01'),
(3, 8, '2025-07-02');

INSERT INTO attendance (emp_id, att_date, status) VALUES
(1, '2025-07-01', 'Present'),
(2, '2025-07-01', 'Absent'),
(3, '2025-07-01', 'Present');





SELECT 
    d.dept_name,
    j.job_title,
    j.salary,
    ot.hours_worked
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN overtime ot ON e.emp_id = ot.emp_id;