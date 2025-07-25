SELECT * from teachers

SELECT first_name, last_name from teachers

SELECT DISTINCT last_name from teachers

SELECT DISTINCT last_name as "Alias", first_name as "Name" from teachers where last_name LIKE 'Snyman' ORDER BY last_name ASC

SELECT first_name from teachers where salary between 44000 and 66000

SELECT first_name from teachers where first_name ILIKE '%ul%'


CREATE TABLE new_teachers AS
SELECT first_name, last_name, school FROM teachers;