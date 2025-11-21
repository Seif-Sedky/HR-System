CREATE DATABASE University_HR_ManagementSystem_6;
GO

CREATE PROCEDURE createAllTables
AS
BEGIN
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
    CREATE TABLE Document (
        document_ID INT IDENTITY(1,1) PRIMARY KEY,
        type VARCHAR(50),
        description VARCHAR(50),
        file_name VARCHAR(50),
        creation_date DATE,
        expiry_date DATE,
        status VARCHAR(50) CHECK (status IN ('valid', 'expired')),
        emp_ID INT,
        medical_ID INT,
        unpaid_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (medical_ID) REFERENCES Medical_Leave(request_ID),
        FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_Leave(request_ID)
    );
    CREATE TABLE Payroll (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        payment_date DATE,
        final_salary_amount DECIMAL(10,1),
        from_date DATE,
        to_date DATE,
        comments VARCHAR(150),
        bonus_amount DECIMAL(10,2),
        deductions_amount DECIMAL(10,2),
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );
    CREATE TABLE Attendance (
        attendance_ID INT IDENTITY(1,1) PRIMARY KEY,
        date DATE,
        check_in_time TIME,
        check_out_time TIME,
        total_duration AS (DATEDIFF(MINUTE, check_in_time, check_out_time)) PERSISTED,
        status VARCHAR(50) DEFAULT 'absent' CHECK (status IN ('absent', 'attended')), -- Problem with inconsistent capitalization in description 
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );
    CREATE TABLE Deduction (
        deduction_ID INT IDENTITY(1,1) PRIMARY KEY,
        emp_ID INT,
        date DATE,
        amount DECIMAL(10,2),
        type VARCHAR(50) CHECK (type IN ('unpaid', 'missing_hours', 'missing_days')),
        status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'finalized')),
        unpaid_ID INT,
        attendance_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_Leave(request_ID),
        FOREIGN KEY (attendance_ID) REFERENCES Attendance(attendance_ID)
    );
    CREATE TABLE Performance (
        performance_ID INT IDENTITY(1,1) PRIMARY KEY,
        rating INT CHECK (rating BETWEEN 1 AND 5),
        comments VARCHAR(50),
        semester CHAR(3),
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );
    CREATE TABLE Employee_Replace_Employee (
        table_id INT IDENTITY(1,1),
        Emp1_ID INT,
        Emp2_ID INT,
        from_date DATE,
        to_date DATE,
        PRIMARY KEY (table_id, Emp1_ID, Emp2_ID),
        FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (Emp2_ID) REFERENCES Employee(employee_ID),
        CONSTRAINT CHK_Different_Employees CHECK (Emp1_ID <> Emp2_ID) -- Self made contraint infered from last point in 1.2

    );
    CREATE TABLE Employee_Approve_Leave (
        Emp1_ID INT,
        Leave_ID INT,
        status VARCHAR(50),
        PRIMARY KEY (Emp1_ID, Leave_ID),
        FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (Leave_ID) REFERENCES Leave(request_ID)
    );

END;
GO

CREATE PROCEDURE dropAllTables
AS
BEGIN
    --SET NOCOUNT ON; -- Optimization so that it does not return how many rows where affected (unecessary logs)
    -- Drop all tables (reverse dependency order to avoid FK constraint issues)
    DROP TABLE IF EXISTS Employee_Approve_Leave;
    DROP TABLE IF EXISTS Employee_Replace_Employee;
    DROP TABLE IF EXISTS Performance;
    DROP TABLE IF EXISTS Deduction;
    DROP TABLE IF EXISTS Attendance;
    DROP TABLE IF EXISTS Payroll;
    DROP TABLE IF EXISTS Document;
    DROP TABLE IF EXISTS Compensation_Leave;
    DROP TABLE IF EXISTS Unpaid_Leave;
    DROP TABLE IF EXISTS Medical_Leave;
    DROP TABLE IF EXISTS Accidental_Leave;
    DROP TABLE IF EXISTS Annual_Leave;
    DROP TABLE IF EXISTS Leave;
    DROP TABLE IF EXISTS Role_existsIn_Department;
    DROP TABLE IF EXISTS Employee_Role;
    DROP TABLE IF EXISTS Role;
    DROP TABLE IF EXISTS Employee_Phone;
    DROP TABLE IF EXISTS Employee;
    DROP TABLE IF EXISTS Department;
END;
GO



CREATE OR ALTER PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    SET NOCOUNT ON;
    -----------------------------------------------------------------
    -- 1. DROP VIEWS
    -----------------------------------------------------------------
    DECLARE @sql NVARCHAR(MAX) = N'';
    SELECT @sql = @sql + 'DROP VIEW [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(10)
    FROM sys.views
    WHERE is_ms_shipped = 0;   -- user-created only
    EXEC (@sql);
    -----------------------------------------------------------------
    -- 2. DROP FUNCTIONS (scalar + table-valued)
    -----------------------------------------------------------------
    SET @sql = N'';
    SELECT @sql = @sql + 'DROP FUNCTION [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(10)
    FROM sys.objects
    WHERE type IN ('FN','IF','TF')   -- scalar, inline TVF, multi-statement TVF

      AND is_ms_shipped = 0;
    EXEC (@sql);
    -----------------------------------------------------------------
    -- 3. DROP STORED PROCEDURES except this one
    -----------------------------------------------------------------
    SET @sql = N'';
    SELECT @sql = @sql + 'DROP PROCEDURE [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(10)
    FROM sys.procedures
    WHERE name <> 'dropAllProceduresFunctionsViews'
      AND is_ms_shipped = 0;
    EXEC (@sql);
END;
GO




CREATE PROCEDURE clearAllTables
AS
BEGIN
    -- Drop all tables (reverse dependency order to avoid FK constraint issues)
    DELETE FROM Employee_Approve_Leave;
    DELETE FROM Employee_Replace_Employee;
    DELETE FROM Performance;
    DELETE FROM Deduction;
    DELETE FROM Attendance;
    DELETE FROM Payroll;
    DELETE FROM Document;
    DELETE FROM Compensation_Leave;
    DELETE FROM Unpaid_Leave;
    DELETE FROM Medical_Leave;
    DELETE FROM Accidental_Leave;
    DELETE FROM Annual_Leave;
    DELETE FROM Leave;
    DELETE FROM Role_existsIn_Department;
    DELETE FROM Employee_Role;
    DELETE FROM Role;
    DELETE FROM Employee_Phone;
    DELETE FROM Employee;
    DELETE FROM Department;
END;
GO