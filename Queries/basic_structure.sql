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

CREATE TABLE Employee_Phone (
    emp_ID INT,
    phone_num CHAR(11),
    PRIMARY KEY (emp_ID, phone_num),
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
);

CREATE TABLE Role (
    role_name VARCHAR(50) PRIMARY KEY,
    title VARCHAR(50),
    description VARCHAR(50),
    rank INT,
    base_salary DECIMAL(10,2),
    percentage_YOE DECIMAL(4,2),
    percentage_overtime DECIMAL(4,2),
    annual_balance INT,
    accidental_balance INT
);

CREATE TABLE Employee_Role (
    emp_ID INT,
    role_name VARCHAR(50),
    PRIMARY KEY (emp_ID, role_name),
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (role_name) REFERENCES Role(role_name)
);

CREATE TABLE Role_existsIn_Department (
    department_name VARCHAR(50),
    Role_name VARCHAR(50),
    PRIMARY KEY (department_name, Role_name),
    FOREIGN KEY (department_name) REFERENCES Department(name),
    FOREIGN KEY (Role_name) REFERENCES Role(role_name)
);

CREATE TABLE Leave (
    request_ID INT IDENTITY(1,1) PRIMARY KEY,
    date_of_request DATE,
    start_date DATE,
    end_date DATE,
    num_days AS (DATEDIFF(DAY, start_date, end_date)) PERSISTED,
    final_approval_status VARCHAR(50) DEFAULT 'pending' CHECK (final_approval_status IN ('approved', 'rejected', 'pending'))
);

CREATE TABLE Annual_Leave (
    request_ID INT PRIMARY KEY,
    emp_ID INT,
    replacement_emp INT,
    FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID)
);


CREATE TABLE Accidental_Leave (
    request_ID INT PRIMARY KEY,
    emp_ID INT,
    FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
);

CREATE TABLE Medical_Leave (
    request_ID INT PRIMARY KEY,
    insurance_status BIT,
    disability_details VARCHAR(50),
    type VARCHAR(50) CHECK (type IN ('sick', 'maternity')),
    Emp_ID INT,
    FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(employee_ID)
);

CREATE TABLE Unpaid_Leave (
    request_ID INT PRIMARY KEY,
    Emp_ID INT,
    FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(employee_ID)
);

CREATE TABLE Compensation_Leave (
    request_ID INT PRIMARY KEY,
    reason VARCHAR(50),
    date_of_original_workday DATE,
    emp_ID INT,
    replacement_emp INT,
    FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID)
);

