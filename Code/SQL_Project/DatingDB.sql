CREATE TABLE zip_codes (
    zip_code VARCHAR(4) PRIMARY KEY CHECK (zip_code ~ '^[0-9]{1,4}$'),
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL
);

-- Insert 9 provinces, 2 cities each
INSERT INTO zip_codes (zip_code, city, province) VALUES
('0001', 'Pretoria', 'Gauteng'),
('0002', 'Johannesburg', 'Gauteng'),
('2001', 'Durban', 'KwaZulu-Natal'),
('2002', 'Pietermaritzburg', 'KwaZulu-Natal'),
('3001', 'Cape Town', 'Western Cape'),
('3002', 'Stellenbosch', 'Western Cape'),
('4001', 'Bloemfontein', 'Free State'),
('4002', 'Welkom', 'Free State'),
('5001', 'Kimberley', 'Northern Cape'),
('5002', 'Upington', 'Northern Cape'),
('6001', 'Polokwane', 'Limpopo'),
('6002', 'Thohoyandou', 'Limpopo'),
('7001', 'Mbombela', 'Mpumalanga'),
('7002', 'Secunda', 'Mpumalanga'),
('8001', 'Mahikeng', 'North West'),
('8002', 'Rustenburg', 'North West'),
('9001', 'Bhisho', 'Eastern Cape'),
('9002', 'Port Elizabeth', 'Eastern Cape');


------------------------------------

CREATE TABLE professions (
    profession_id SERIAL PRIMARY KEY,
    profession VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO professions (profession) VALUES
('Software Engineer'),
('Teacher'),
('Doctor'),
('Artist'),
('Lawyer'),
('Chef'),
('Journalist'),
('Nurse'),
('Architect'),
('Engineer');

------------------------------------

CREATE TABLE my_contacts (
    contact_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    profession_id INT REFERENCES professions(profession_id),
    zip_code VARCHAR(4) REFERENCES zip_codes(zip_code),
    status VARCHAR(50) -- e.g., Single, Dating, Married
);

-- 16 contacts
INSERT INTO my_contacts (first_name, last_name, profession_id, zip_code, status) VALUES
('Alice', 'Nkosi', 1, '0001', 'Single'),
('Bongani', 'Mthembu', 2, '0002', 'Single'),
('Carmen', 'Naidoo', 3, '2001', 'Dating'),
('Dineo', 'Mokoena', 4, '2002', 'Single'),
('Ebrahim', 'Petersen', 5, '3001', 'Married'),
('Farah', 'Khan', 6, '3002', 'Single'),
('Gideon', 'Smith', 7, '4001', 'Single'),
('Hendrik', 'van der Merwe', 8, '4002', 'Dating'),
('Inge', 'Botha', 9, '5001', 'Single'),
('Jabulani', 'Zulu', 10, '5002', 'Single'),
('Kabelo', 'Sithole', 1, '6001', 'Dating'),
('Lerato', 'Molefe', 2, '6002', 'Single'),
('Mandla', 'Dlamini', 3, '7001', 'Married'),
('Nandi', 'Cele', 4, '7002', 'Single'),
('Ouma', 'Mahlangu', 5, '8001', 'Single'),
('Pieter', 'Jacobs', 6, '8002', 'Single'),
('Qinisela', 'Ngcobo', 7, '9001', 'Dating');

------------------------------------

CREATE TABLE interests (
    interest_id SERIAL PRIMARY KEY,
    interest_name VARCHAR(100) NOT NULL
);

INSERT INTO interests (interest_name) VALUES
('Hiking'),
('Reading'),
('Cooking'),
('Traveling'),
('Gaming'),
('Dancing'),
('Photography'),
('Music'),
('Swimming'),
('Cycling');

------------------------------------

CREATE TABLE contact_interests (
    contact_id INT REFERENCES my_contacts(contact_id),
    interest_id INT REFERENCES interests(interest_id),
    PRIMARY KEY (contact_id, interest_id)
);

-- Each contact gets more than 2 interests
INSERT INTO contact_interests VALUES
(1, 1), (1, 2), (1, 3),
(2, 2), (2, 4), (2, 5),
(3, 1), (3, 4), (3, 6),
(4, 5), (4, 6), (4, 7),
(5, 3), (5, 8), (5, 9),
(6, 1), (6, 2), (6, 9),
(7, 4), (7, 5), (7, 6),
(8, 2), (8, 8), (8, 10),
(9, 1), (9, 7), (9, 8),
(10, 2), (10, 3), (10, 9),
(11, 4), (11, 5), (11, 10),
(12, 1), (12, 2), (12, 6),
(13, 3), (13, 8), (13, 9),
(14, 1), (14, 5), (14, 7),
(15, 6), (15, 8), (15, 10),
(16, 1), (16, 4), (16, 5),
(17, 2), (17, 7), (17, 9);

------------------------------------

DROP TABLE IF EXISTS contact_interests;
DROP TABLE IF EXISTS my_contacts;
DROP TABLE IF EXISTS interests;
DROP TABLE IF EXISTS professions;
DROP TABLE IF EXISTS zip_codes;

------------------------------------

SELECT 
    p.profession,
    z.zip_code,
    z.city,
    z.province,
    c.status,
    STRING_AGG(i.interest_name, ', ') AS interests,
    'Seeking: Friendship, Relationship' AS seeking
FROM my_contacts c
LEFT JOIN professions p ON c.profession_id = p.profession_id
LEFT JOIN zip_codes z ON c.zip_code = z.zip_code
LEFT JOIN contact_interests ci ON c.contact_id = ci.contact_id
LEFT JOIN interests i ON ci.interest_id = i.interest_id
GROUP BY p.profession, z.zip_code, z.city, z.province, c.status
ORDER BY p.profession;