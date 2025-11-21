USE University_HR_ManagementSystem_6 ;

EXEC createAllTables 
EXEC dropAllTables
EXEC dropAllProceduresFunctionsViews
EXEC clearAllTables



SELECT * FROM allEmployeeProfiles
SELECT * FROM NoEmployeeDept
SELECT * FROM allPerformance
SELECT * FROM allRejectedMedicals
SELECT * FROM allEmployeeAttendance


--------------------------------
-- SHOW USER DEFINED TABLES
--------------------------------

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM 
    sys.tables t
INNER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
ORDER BY 
    SchemaName, TableName;


--------------------------------
-- SHOW USER DEFINED PROCEDURES
--------------------------------

SELECT
    s.name AS SchemaName,
    p.name AS ProcedureName,
    p.create_date,
    p.modify_date
FROM
    sys.procedures p
INNER JOIN
    sys.schemas s ON p.schema_id = s.schema_id
WHERE
    p.is_ms_shipped = 0 -- Excludes built-in system procedures
ORDER BY
    p.name;


--------------------------------
-- SHOW USER DEFINED VIEWS
--------------------------------

SELECT
    s.name AS SchemaName,
    v.name AS ViewName,
    v.create_date,
    v.modify_date
FROM
    sys.views v
INNER JOIN
    sys.schemas s ON v.schema_id = s.schema_id
WHERE
    v.is_ms_shipped = 0 -- Excludes built-in system views
ORDER BY
    v.name;

--------------------------------
-- SHOW USER DEFINED FUNCTIONS
--------------------------------
SELECT
    s.name AS SchemaName,
    o.name AS FunctionName,
    o.type_desc AS FunctionType,
    o.create_date,
    o.modify_date
FROM
    sys.objects o
INNER JOIN
    sys.schemas s ON o.schema_id = s.schema_id
WHERE
    o.type IN ('FN', 'IF', 'TF') -- Filters for all types of user functions
    AND o.is_ms_shipped = 0     -- Excludes built-in system functions
ORDER BY
    o.name;




---------------------------------
-- INSERTIONS WITH DEPENDENCIES 
---------------------------------


-- 1. Insert Departments (Root Level)
INSERT INTO Department (name, building_location) VALUES 
('HR', 'Building A'),
('IT', 'Building B'),
('Finance', 'Building A');

-- 2. Insert Roles (Root Level)
INSERT INTO Role (role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES 
('Manager', 'Senior Manager', 'Manages team', 1, 5000.00, 0.10, 0.05, 30, 7),
('Developer', 'Software Dev', 'Writes code', 2, 3000.00, 0.05, 0.10, 21, 7),
('Accountant', 'Junior Accountant', 'Handles books', 3, 2500.00, 0.02, 0.05, 21, 7);

-- 3. Link Roles to Departments
INSERT INTO Role_existsIn_Department (department_name, Role_name) VALUES 
('HR', 'Manager'),
('IT', 'Manager'),
('IT', 'Developer'),
('Finance', 'Accountant');

-- 4. Insert Employees (Depends on Department)
-- Note: 'active', 'full_time' satisfy CHECK constraints
INSERT INTO Employee (first_name, last_name, email, password, address, gender, official_day_off, years_of_experience, national_ID, employment_status, type_of_contract, emergency_contact_name, emergency_contact_phone, annual_balance, accidental_balance, hire_date, dept_name) VALUES 
('Alice', 'Smith', 'alice@company.com', 'pass123', '123 Main St', 'F', 'Sunday', 10, '1234567890123456', 'active', 'full_time', 'Bob Smith', '01000000001', 30, 7, '2020-01-01', 'HR'),
('Bob', 'Jones', 'bob@company.com', 'pass123', '456 Tech Ave', 'M', 'Saturday', 5, '6543210987654321', 'active', 'full_time', 'Sara Jones', '01000000002', 21, 7, '2022-05-15', 'IT'),
('Charlie', 'Brown', 'charlie@company.com', 'pass123', '789 Money Rd', 'M', 'Friday', 2, '1111222233334444', 'onleave', 'part_time', 'Lucy Brown', '01000000003', 15, 5, '2023-08-01', 'Finance');

-- 5. Insert Employee Phones (Depends on Employee)
INSERT INTO Employee_Phone (emp_ID, phone_num) VALUES 
(1, '01234567890'),
(2, '01234567891'),
(3, '01234567892');

-- 6. Insert Employee Roles (Depends on Employee & Role)
INSERT INTO Employee_Role (emp_ID, role_name) VALUES 
(1, 'Manager'),
(2, 'Developer'),
(3, 'Accountant');

-- 7. Insert Attendance (Depends on Employee)
-- Adding one record for yesterday to satisfy your 'allEmployeeAttendance' view test
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID) VALUES 
(CAST(GETDATE() - 1 AS DATE), '09:00:00', '17:00:00', 'attended', 2), -- Bob attended yesterday
(CAST(GETDATE() - 2 AS DATE), '09:00:00', '17:00:00', 'attended', 1);

-- 8. Insert Performance (Depends on Employee)
INSERT INTO Performance (rating, comments, semester, emp_ID) VALUES 
(5, 'Excellent leadership', 'W24', 1),
(4, 'Great code quality', 'W24', 2);

-- 9. Insert Base Leave Requests (Root for Leave types)
-- We insert 5 requests. IDs will be generated 1, 2, 3, 4, 5 automatically.
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES 
('2024-01-01', '2024-02-01', '2024-02-05', 'approved'), -- ID 1 (Annual)
('2024-03-01', '2024-03-10', '2024-03-15', 'rejected'), -- ID 2 (Medical - Rejected)
('2024-04-01', '2024-04-20', '2024-04-25', 'pending'),  -- ID 3 (Unpaid)
('2024-05-01', '2024-05-02', '2024-05-03', 'approved'), -- ID 4 (Accidental)
('2024-06-01', '2024-06-01', '2024-06-01', 'approved'); -- ID 5 (Compensation)

-- 10. Insert Specific Leave Types (Depends on Leave & Employee)
-- Note: referencing IDs 1-5 generated above

-- ID 1: Annual Leave for Bob, replaced by Charlie
INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) VALUES (1, 2, 3);

-- ID 2: Medical Leave for Charlie (Rejected)
INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID) VALUES (2, 1, 'Flu', 'sick', 3);

-- ID 3: Unpaid Leave for Alice
INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES (3, 1);

-- ID 4: Accidental Leave for Bob
INSERT INTO Accidental_Leave (request_ID, emp_ID) VALUES (4, 2);

-- ID 5: Compensation Leave for Charlie
INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, emp_ID, replacement_emp) VALUES (5, 'Overtime work', '2024-05-20', 3, 2);

-- 11. Employee Approves Leave (Depends on Employee & Leave)
-- Alice (Manager) approves Bob's leave (ID 1)
INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (1, 1, 'approved');

-- 12. Documents (Depends on Employee & Leave Types)
-- Document for Medical Leave (ID 2)
INSERT INTO Document (type, description, file_name, creation_date, expiry_date, status, emp_ID, medical_ID) 
VALUES ('PDF', 'Doctor Note', 'sick_note.pdf', '2024-03-01', '2024-03-20', 'valid', 3, 2);

-- Document for Unpaid Leave (ID 3)
INSERT INTO Document (type, description, file_name, creation_date, expiry_date, status, emp_ID, unpaid_ID) 
VALUES ('Form', 'Unpaid Request Form', 'form.docx', '2024-04-01', '2024-12-31', 'valid', 1, 3);

-- 13. Deductions (Depends on Unpaid_Leave or Attendance)
-- Deduction for Alice's Unpaid Leave (ID 3)
INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID) 
VALUES (1, '2024-04-25', 500.00, 'unpaid', 'finalized', 3);

-- 14. Payroll (Depends on Employee)
INSERT INTO Payroll (payment_date, final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount, emp_ID) 
VALUES ('2024-05-01', 2500.00, '2024-04-01', '2024-04-30', 'Regular Pay', 0, 500.00, 1);

-- 15. Employee Replacement History (Depends on Employee)
INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date) 
VALUES (2, 3, '2024-02-01', '2024-02-05'); -- Bob was replaced by Charlie

