CREATE TABLE Department (
    name VARCHAR(50) PRIMARY KEY,
    building_location VARCHAR(50)
);

CREATE TABLE Employee (
    employee_ID INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50),
    password VARCHAR(50),
    address VARCHAR(50),
    gender CHAR(1),
    official_day_off VARCHAR(50),
    years_of_experience INT,
    national_ID CHAR(16),
    employment_status VARCHAR(50) CHECK (employment_status IN ('active', 'onleave', 'notice_period', 'resigned')),
    type_of_contract VARCHAR(50) CHECK (type_of_contract IN ('full_time', 'part_time')),
    emergency_contact_name VARCHAR(50),
    emergency_contact_phone CHAR(11),
    annual_balance INT,
    accidental_balance INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    last_working_date DATE,
    dept_name VARCHAR(50),
    FOREIGN KEY (dept_name) REFERENCES Department(name)
);

