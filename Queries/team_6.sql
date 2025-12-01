CREATE DATABASE University_HR_ManagementSystem_6;
GO

USE University_HR_ManagementSystem_6 ;
GO



-- 2.1 BASIC STRUCTURE 

-- IMPORTANT NOTE
------------------------------------------------------------------
-- PLEASE CREATE THE FOLLOWING HELPER FUNCTION BEFORE PROCEEDING 
------------------------------------------------------------------

CREATE OR ALTER FUNCTION dbo.CalculateSalary (@EmpID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @CalculatedSalary DECIMAL(10, 2);
    
    DECLARE @BaseSalary DECIMAL(10, 2);
    DECLARE @PercentageYOE DECIMAL(4, 2);
    DECLARE @YearsExp INT;

    -- 1. Get Years of Experience
    SELECT @YearsExp = years_of_experience 
    FROM Employee 
    WHERE employee_ID = @EmpID;

    -- 2. Get Base Salary and %YOE based on the Highest Rank
    SELECT TOP 1 
        @BaseSalary = r.base_salary,
        @PercentageYOE = r.percentage_YOE
    FROM Role r
    JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.emp_ID = @EmpID
    ORDER BY r.rank ASC; 

    -- 3. Apply the Formula
    
    SET @CalculatedSalary = @BaseSalary + 
                            (
                                (ISNULL(@PercentageYOE, 0) / 100.0) * ISNULL(@YearsExp, 0) * @BaseSalary
                            );

    RETURN @CalculatedSalary;
END;
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
        salary AS dbo.CalculateSalary(employee_ID),
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
        num_days AS (DATEDIFF(DAY, start_date, end_date) + 1) PERSISTED,
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
        total_duration AS (
            CASE 
                WHEN check_out_time >= check_in_time 
                THEN DATEDIFF(MINUTE, check_in_time, check_out_time)
                ELSE DATEDIFF(MINUTE, check_in_time, check_out_time) + 1440 -- Cycle back day (1440 is total minutes in one day) 
            END
        ) PERSISTED,
        status VARCHAR(50) DEFAULT 'absent' CHECK (status IN ('absent', 'attended')), -- Problem with inconsistent capitalization in description 
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );
    CREATE TABLE Deduction (
        deduction_ID INT IDENTITY(1,1),
        emp_ID INT,
        date DATE,
        amount DECIMAL(10,2),
        type VARCHAR(50) CHECK (type IN ('unpaid', 'missing_hours', 'missing_days')),
        status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'finalized')),
        unpaid_ID INT,
        attendance_ID INT,
        PRIMARY KEY (deduction_ID, emp_ID),
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
        Table_ID INT IDENTITY(1,1),
        Emp1_ID INT,
        Emp2_ID INT,
        from_date DATE,
        to_date DATE,
        PRIMARY KEY (Table_ID, Emp1_ID, Emp2_ID),
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

    DECLARE @sql NVARCHAR(MAX) = N'';

    -----------------------------------------------------------------
    -- 1. DROP VIEWS
    -----------------------------------------------------------------
    SELECT @sql = @sql + 'DROP VIEW [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(10)
    FROM sys.views
    WHERE is_ms_shipped = 0;   -- user-created only
    
    EXEC (@sql);

    -----------------------------------------------------------------
    -- 2. DROP FUNCTIONS (scalar + table-valued)
    -- *MODIFIED TO EXCLUDE dbo.CalculateSalary*
    -----------------------------------------------------------------
    SET @sql = N'';
    
    SELECT @sql = @sql + 'DROP FUNCTION [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(10)
    FROM sys.objects
    WHERE type IN ('FN','IF','TF')   -- scalar, inline TVF, multi-statement TVF
      AND is_ms_shipped = 0
      AND name <> 'CalculateSalary'; -- << EXCEPTION ADDED HERE
      
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

-- 2.2 BASIC RETIRIEVAL 



CREATE VIEW allEmployeeProfiles AS
SELECT 
    employee_ID,
    first_name,
    last_name,
    gender,
    email,
    address,
    years_of_experience,
    official_day_off,
    type_of_contract,
    employment_status,
    annual_balance,
    accidental_balance
FROM Employee;
GO

CREATE VIEW NoEmployeeDept AS
SELECT 
    d.name,
    COUNT(e.employee_ID) AS NumberOfEmployees 
FROM Department d
LEFT JOIN Employee e ON e.dept_name = d.name --Uses LEFT JOIN so departments with no employees still appear with 0
GROUP BY d.name;
GO 


CREATE VIEW allPerformance AS
SELECT * 
FROM Performance p
WHERE p.semester LIKE 'W%';
GO

CREATE VIEW allRejectedMedicals AS
SELECT 
    -- explicitly selected columns to avoid duplicate 'request_ID' from SELECT *, WHICH RESULTS IN AN ERROR
    l.request_ID,
    l.date_of_request,
    l.start_date,
    l.end_date,
    l.num_days,
    l.final_approval_status,
    m.insurance_status,
    m.disability_details,
    m.type,
    m.Emp_ID
FROM Medical_Leave m
JOIN Leave l ON m.request_ID = l.request_ID
WHERE l.final_approval_status = 'rejected';
GO

CREATE VIEW allEmployeeAttendance AS
SELECT *
FROM Attendance a 
WHERE a.date = CAST(GETDATE() - 1 AS DATE); -- Get date returns datetime, so we cast to date 
GO

-- 2.3 ADMIN FUNCTIONALITIES 


CREATE PROC Update_Status_Doc

AS

UPDATE  Document 
SET status = 'expired'
WHERE expiry_date < CAST(GETDATE() AS DATE); 
-- Q1 :is the expire date for example 1-1-2025 included to be expired or from 2-1-2025 it will expire
-- in other words make it < or <= 
-- ANSWER :  DONE
GO


CREATE PROC Remove_Deductions

AS

DELETE from Deduction
WHERE emp_ID IN (
	SELECT employee_ID
	FROM Employee 
	WHERE employment_status = 'resigned');
GO



CREATE PROC Update_Employment_Status
@Employee_ID INT 

AS

BEGIN

DECLARE @on_leave BIT
SET @on_leave = dbo.Is_On_Leave(@Employee_ID,CAST(GETDATE() AS DATE),CAST(GETDATE() AS DATE))


IF @on_leave = 1
BEGIN
	UPDATE Employee
    SET employment_status = 'onleave'
	WHERE employee_ID = @Employee_ID;
END

IF @on_leave = 0 AND (SELECT employment_status FROM Employee WHERE employee_ID = @Employee_ID) NOT IN ('resigned', 'notice_period')
BEGIN
	UPDATE Employee
    SET employment_status = 'active'
	WHERE employee_ID = @Employee_ID;
END



--Q1: should i check that inputs are not null and ,make output statements on invalid inputs
-- !!!!IMPORTANT!!!  look at it again "daily" daily deh m3sbany
-- Q2: is daily in the question meant to be likw i implement the function or it have to be automatic 
--     (for exaple every day at 12 pm update all)

-- ANSWER :  Q1: DONE
--			 Q2: DONE

END
GO


CREATE PROC Create_Holiday

AS

CREATE TABLE Holiday(
	holiday_id INT IDENTITY(1,1) PRIMARY KEY,
	name VARCHAR(50),
	from_date DATE,
	to_date  DATE
)
GO


CREATE PROC Add_Holiday
@holiday_name VARCHAR(50), @from_date DATE, @to_date DATE 

AS

INSERT INTO Holiday VALUES(@holiday_name,@from_date,@to_date); 

-- Q1 : this will be valid only if we excute create holiday  first , do i must put this restriction , if yes then how 
--		because this depend on a table that have to be found

-- Q2 : should i check that inputs are not null and ,make output statements on invalid inputs

-- ANSWER :  Q1:DONE
--			 Q2:Done
GO


CREATE PROC Intitiate_Attendance

AS

INSERT INTO Attendance (date,check_in_time,check_out_time,status,emp_ID)
SELECT CAST(GETDATE() AS DATE),null , null ,'absent',employee_ID
FROM Employee E
WHERE employment_status <> 'resigned' 
	  AND NOT EXISTS(
		SELECT 1
        FROM Attendance A
        WHERE A.emp_ID = E.employee_ID
        AND A.date = CAST(GETDATE() AS DATE)
		);

--Q1:  WHERE employment_status <> 'resigned' AND employment_status <> 'notice_period' AND employment_status <> 'onleave';
--    i thin i have to write this condition
--    this is more logical to not initiate for resigned , notice_period , on_leave people a
--    but i follow  what the question say for "all"  employees
--	  so what is right "Leave it as i write for "ALL" peaopl" OR "apply the condition i have commented"

-- ANSWER :  Q1: DONE

GO


CREATE PROC Update_Attendance
@Employee_id INT, @check_in TIME, @check_out TIME

AS

UPDATE Attendance 
SET check_in_time = @check_in , check_out_time = @check_out , status = 'attended'
WHERE emp_ID = @Employee_id AND date = CAST(GETDATE() AS DATE)

-- Q1: should i attend the whole day to be attended or just 1 minute will be suffieient to be attended 

-- Q2: should i check that check_in time ,and check_out time within working hours
--	   and checkin before chekout 

-- Q3: should i check that inputs are not null and ,make output statements on invalid inputs

-- IMPORTANT NOTE : CAROL 2alet msh lazem , bs kda 2l mawdo3 sahl 2wy 

-- ANSWER :  Q1: As long as there are valid IN and OUT values and neither is null, the record will be considered as attended.
--			 Q2:DONE
--			 Q3: No need to make validation checks

-- the answer if carol of Q1 , Q2 contradicts eachother (i will ask)
GO


CREATE PROC Remove_Holiday
AS

DELETE FROM  Attendance 
WHERE attendance_ID in (
	SELECT A.attendance_ID 
	FROM  Attendance as A , Holiday as H 
	WHERE A.date BETWEEN H.from_date AND H.to_date
	)

-- Q1 : this will be valid only if we excute create holiday  first , do i must put this restriction , if yes then how 
--		because this depend on a table that have to be found

-- !! YOU DON'T NEED TO ANSWER IF YOU ANSWER add_holiday , as they are same

-- ANSWER :  Q1: DONE
GO


CREATE PROC Remove_DayOff
@Employee_id INT

AS

Delete FROM Attendance 
WHERE emp_ID = @Employee_id AND
	status = 'absent' AND
	YEAR(date) = YEAR(GETDATE()) AND 
	MONTH(date) = MONTH(GETDATE()) AND 
	DATENAME(WEEKDAY, date) = (SELECT official_day_off 
							   FROM Employee E
							   WHERE E.employee_ID = @Employee_id )

--Q1:  how is the offical day represented in employee ? numbers or days ?
--	   i assume that is represented as weekday as 'Friday'
--	   IS my assumption right ??

--Q2:  should i check that inputs are not null and ,make output statements on invalid inputs

-- ANSWER :  Q1: DONE
--			 Q2:DONE
GO


CREATE PROC Remove_Approved_Leaves
@Employee_id INT

AS


-- This is my first approach:
/*
Delete FROM Attendance
WHERE emp_ID = @Employee_id AND
	status = 'absent' AND
	Is_On_Leave(emp_ID,date,date)=1 ; 
*/



/*Q1:   NEED CLARIFICATION here i build my solution on the the function is_on_leave will give me 1 
		if the leave was APPROVED ONLY , (I think yes , look at the is_on_leave description)
		BUT other opinion that is_on_leave will give 1 also if it is pending 
		SO IS MY FIRST APPROCH RIGHT OR NOT ??     
*/


-- if my first solution approach is wrong so here is another way 

-- This is my second approach:
DELETE A FROM Attendance A
WHERE A.emp_ID = @Employee_id AND
	A.status = 'absent' AND
	EXISTS (
		SELECT L.start_date
		FROM Employee_Approve_Leave AS EAL, Leave AS L
		WHERE EAL.Emp1_ID = @Employee_id AND
		EAL.Leave_ID = L.request_ID  AND 
		A.date  BETWEEN L.start_date AND L.end_date AND
		L.final_approval_status = 'approved'
	)


--Q2:  please check wich of the 2 methods is right 

--Q3:  should i check that inputs are not null and ,make output statements on invalid inputs

-- ANSWER :  Q1: DONE
--			 Q2: DONE
--			 Q3: DONE

GO


CREATE PROC Replace_employee
@Emp1_ID INT, @Emp2_ID INT, @from_date DATE, @to_date DATE

AS

INSERT INTO Employee_Replace_Employee VALUES(@Emp1_ID,@Emp2_ID,@from_date,@to_date)

--Q1: is that the solution correct , just need to insert ? i think it is very easy??

--Q2:  should i check that inputs are not null and ,make output statements on invalid inputs


-- ANSWER :  Q1:DONE
--			 Q2: DONE

GO



-- 2.4 HR EMPLOYEE FUNCTIONALITIES 

-- A
CREATE FUNCTION HRLoginValidation
(
    @employee_ID INT,
    @password VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Success BIT;

    IF EXISTS (
        SELECT *
        FROM Employee
        WHERE employee_ID = @employee_ID
          AND password = @password
          AND dept_name = 'HR'
    )
        SET @Success = 1;  -- Success
    ELSE
        SET @Success = 0;  -- Failure


    RETURN @Success;
END;
GO

--B
CREATE PROC HR_approval_an_acc
    @request_ID INT,
    @HR_ID INT
AS
BEGIN

    DECLARE 
        @num_days INT,
        @employee_id INT,
        @old_balance INT,
        @new_balance INT,
        @leave_type VARCHAR(50),
        @employee_rank INT
    -- Determine leave type
    IF EXISTS (SELECT * FROM Annual_Leave WHERE request_ID = @request_ID)
        SET @leave_type = 'annual';
    ELSE IF EXISTS (SELECT * FROM Accidental_Leave WHERE request_ID = @request_ID)
        SET @leave_type = 'accidental';
    -- Load employee + days depending on leave type
    IF @leave_type = 'annual'
    BEGIN
        SELECT @employee_id = a.emp_ID, @num_days = l.num_days
        FROM Leave l JOIN Annual_Leave a ON l.request_ID = a.request_ID
        WHERE l.request_ID = @request_ID;
        IF 
            (SELECT annual_balance
            FROM Employee
            WHERE employee_ID = @employee_id) < @num_days  
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'Insufficient Annual Leave Balance. Request Rejected.';
            RETURN;
        END
        -- Check replacement employee availability
         IF dbo.Is_On_Leave((SELECT replacement_emp FROM Annual_Leave WHERE request_ID = @request_ID), 
                          (SELECT start_date FROM Leave WHERE request_ID = @request_ID), 
                          (SELECT end_date FROM Leave WHERE request_ID = @request_ID)) = 1
        BEGIN
           UPDATE Leave
           SET final_approval_status = 'rejected'
           WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'Replacement Employee Is On Leave During The Requested Period. Request Rejected.';
           RETURN;
        END
    END
    ELSE  -- accidental
    BEGIN
        DECLARE @days_to_request INT;
        SELECT @employee_id = a.emp_ID, @num_days = l.num_days,  @days_to_request = DATEDIFF(DAY, end_date, date_of_request)
        FROM Leave l 
        JOIN Accidental_Leave a ON l.request_ID = a.request_ID
        WHERE l.request_ID = @request_ID;
        -- Accidental leave exceeds 1 day or has been submitted more then 48 hours after the leave
        IF @num_days > 1 OR @days_to_request > 2
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'Accidental Leave Exceeds 1 Day, or has been submitted more than 48 hours ago. Request Rejected.';
            RETURN;
        END
        IF NOT EXISTS (
            SELECT *
            FROM Employee
            WHERE employee_ID = @employee_id
              AND accidental_balance >= @num_days
        )
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'Insufficient Accidental Leave Balance. Request Rejected.';
            RETURN;
        END
    END
    -- the next will apply to both leaves:

    -- Reject if employee is part-time
    IF EXISTS (
        SELECT * FROM Employee
        WHERE employee_ID = @employee_id
          AND type_of_contract = 'part_time'
    )
    BEGIN
        UPDATE Leave SET final_approval_status = 'rejected'
        WHERE request_ID = @request_ID;

        UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--        PRINT 'Part-Time Employees Cannot Take Annual or Accidental Leave. Rejected.';
        RETURN;
    END
    --APPROVALS HEIRARCHY
        IF EXISTS(
        SELECT status FROM Employee_Approve_Leave
        WHERE Leave_ID = @request_ID
        AND Emp1_ID <> @HR_ID
        AND status = 'rejected')
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'Approvals Heirarchy not met. Unpaid Leave Request Rejected.';
            RETURN;
        END


    -- Everything validated SO HR can now approve
    UPDATE Leave
    SET final_approval_status = 'approved'
    WHERE request_ID = @request_ID;

    UPDATE Employee_Approve_Leave
    SET status = 'approved'
    WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

    IF @leave_type = 'annual'
        UPDATE Employee SET annual_balance = annual_balance - @num_days WHERE employee_ID = @employee_id;
    ELSE
        UPDATE Employee SET accidental_balance = accidental_balance - @num_days WHERE employee_ID = @employee_id;
END
GO

-- C
CREATE PROC HR_approval_unpaid
@request_ID int, @HR_ID int
AS
        DECLARE @employee_id INT;
        DECLARE @annual_balance INT;
        DECLARE @leave_duration INT;
        DECLARE @from_date DATE;

        SELECT @employee_id = emp_ID, @from_date = start_date
        FROM Unpaid_Leave ul, Leave l
        WHERE ul.request_ID = l.request_ID
          AND l.request_ID = @request_ID;

        SELECT @annual_balance = annual_balance
        FROM Employee
        WHERE employee_ID = @employee_id;

       -- check if employee has annual leave balance. if he does reject the unpaid leave request
        IF @annual_balance > 0
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'The Employee Annual Leave Balance Is Greater Than Zero. Unpaid Leave Request Rejected.';
            RETURN;
        END
        -- reject if requested by a part timer
          IF EXISTS (
            SELECT *
            FROM Employee
            WHERE employee_ID = @employee_id
              AND type_of_contract = 'Part-Time'
          )
          BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'The Employee Is Part-Time. Unpaid Leave Request Rejected.';
            RETURN;
        END     
        -- Finally we need to see if the unpaid leave exceeds 30 days or if the employee took unpaid leave in the last  year
        SELECT @leave_duration = DATEDIFF(DAY, start_date, end_date)
        FROM leave l, Unpaid_Leave ul
        WHERE l.request_ID = ul.request_ID
          AND l.request_ID = @request_ID;

        IF @leave_duration > 30
         BEGIN
                 UPDATE Leave
                  SET final_approval_status = 'rejected'
                  WHERE request_ID = @request_ID;

                  UPDATE Employee_Approve_Leave
                SET status = 'rejected'
                WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--                  PRINT 'The Unpaid Leave Duration Exceeds 30 Days. Request Rejected.';
                  RETURN;
          END
          IF EXISTS (
            SELECT *
            FROM Unpaid_Leave ul
            JOIN Leave l ON ul.request_ID = l.request_ID
            WHERE ul.emp_ID = @employee_id
              AND l.final_approval_status = 'approved'
              AND YEAR(l.start_date) = YEAR(@from_date))
          BEGIN
              UPDATE Leave
              SET final_approval_status = 'rejected'
              WHERE request_ID = @request_ID;

               UPDATE Employee_Approve_Leave
               SET status = 'rejected'
               WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

 --               PRINT 'The Employee Has Taken Unpaid Leave In The Last Year. Request Rejected.';
                RETURN;
            END

    -- APPROVALS HEIRARCHY
        IF EXISTS(
        SELECT status FROM Employee_Approve_Leave
        WHERE Leave_ID = @request_ID
        AND Emp1_ID <> @HR_ID
        AND status = 'rejected')
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

 --           PRINT 'Approvals Heirarchy not met. Unpaid Leave Request Rejected.';
            RETURN;
        END

        
        -- Otherwise we accept
		UPDATE Leave
		SET final_approval_status = 'approved'
		WHERE request_ID = @request_ID 

        UPDATE Employee_Approve_Leave
        SET status = 'approved'
        WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

GO

-- D
CREATE PROC HR_approval_comp
@request_ID int, @HR_ID int
AS

        --Compensation leaves are approved by HR employees if the employee applying for the leave spent at least 8 hours during his/her day off.
        declare @date_of_original_workday DATE;
        DECLARE @employee_id INT;
        DECLARE @initial_balance INT;

        -- check if replacement employee is available
         IF dbo.Is_On_Leave((SELECT replacement_emp FROM Compensation_Leave WHERE request_ID = @request_ID), 
                          (SELECT start_date FROM Leave WHERE request_ID = @request_ID), 
                          (SELECT end_date FROM Leave WHERE request_ID = @request_ID)) = 1
        BEGIN
          UPDATE Leave
          SET final_approval_status = 'rejected'
          WHERE request_ID = @request_ID;

          UPDATE Employee_Approve_Leave
          SET status = 'rejected'
          WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--          PRINT 'Replacement Employee Is On Leave During The Requested Period. Request Rejected.';
          RETURN;
        END
        -- get the empoyee id of the requester and the date of original workday
        SELECT @employee_id = emp_ID, @date_of_original_workday = date_of_original_workday
        FROM Compensation_Leave 
        WHERE request_ID = @request_ID;
        -- check if the date in the request is actually a workday for the employee
        IF (SELECT official_day_off FROM Employee WHERE employee_ID = @employee_id) <> DATENAME(WEEKDAY, @date_of_original_workday)
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'The Specified Date Is A Day Off For The Employee. Compensation Leave Request Rejected.';
            RETURN;
        END
        -- check if Compensation not within the same month or more than a day
        IF NOT EXISTS(
            SELECT *
            FROM Leave l JOIN  Compensation_Leave cl ON l.request_ID = cl.request_ID
            WHERE l.request_ID = @request_ID
            AND MONTH(l.start_date) = Month(cl.date_of_original_workday)
            AND YEAR(l.start_date) = YEAR(cl.date_of_original_workday)
            AND l.start_date = l.end_date
        )
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

 --           PRINT 'Compensation not within the same month or more than a day. Compensation Leave Request Rejected.';
            RETURN;
        END
         -- OTHERWISE  we see if the employee has attended at least 8 hours on that day off and that he did not already take compensation leave for that
        IF EXISTS(
            SELECT *
            FROM Attendance
            WHERE emp_ID = @employee_id
                AND date = @date_of_original_workday
                AND total_duration >= 8*60) 
        AND NOT EXISTS (
            SELECT *
            FROM Compensation_Leave cl
            JOIN Leave l ON cl.request_ID = l.request_ID
            WHERE cl.emp_ID = @employee_id
              AND l.final_approval_status = 'approved'
              AND cl.date_of_original_workday = @date_of_original_workday
        )
        BEGIN
        -- we accept
		    UPDATE Leave
		    SET final_approval_status = 'approved'
		    WHERE request_ID = @request_ID 

            UPDATE Employee_Approve_Leave
            SET status = 'approved'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID
        END
        ELSE
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            WHERE Leave_ID = @request_ID AND Emp1_ID = @HR_ID

--            PRINT 'The Employee Has Not Spent At Least 8 Hours During His/Her Day Off. Compensation Leave Request Rejected.';
            RETURN;
        END
GO

-- E
CREATE PROC Deduction_hours
@employee_ID INT
AS

    DECLARE @attendance_id INT;
    DECLARE @deduction_minutes INT;
    DECLARE @hourly_rate DECIMAL(10,2);
    DECLARE @deduction_amount DECIMAL(10,2);
    -- Get hourly rate
    SELECT @hourly_rate = (salary / 22.0) / 8.0
    FROM Employee 
    WHERE employee_ID = @employee_ID;
    -- Get first attendance record this month with less than 8 hours
    SELECT TOP 1 
           @attendance_id = attendance_ID
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND YEAR(date) = YEAR(GETDATE())
      AND MONTH(date) = MONTH(GETDATE())
      AND total_duration < 8*60
    ORDER BY date ASC;
    -- Compute deduction if such record exists
    SELECT @deduction_minutes = (8 * 60 * COUNT(*) - SUM(total_duration)) -- oposite of bonus: number of hours he was supposed to work - number of hours worked
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND status = 'attended'
      AND MONTH(date) = MONTH(GETDATE())
      AND YEAR(date) = YEAR(GETDATE());

    IF @deduction_minutes > 0 
    AND NOT EXISTS(
        SELECT * FROM Deduction d
        WHERE d.attendance_ID = @attendance_id
        AND d.type = 'missing_hours'
    )
    BEGIN
        SET @deduction_amount = (@deduction_minutes / 60.0) * @hourly_rate;
        INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
        VALUES (@employee_ID, GETDATE(), @deduction_amount, 'missing_hours', 'pending', NULL, @attendance_id);
    END
    ELSE
    BEGIN
        PRINT 'No missing hours deduction needed for this month.';
    END
GO

-- F
CREATE PROC Deduction_days
@employee_ID INT
AS 
    DECLARE @hourly_rate DECIMAL(10,2);
    -- Get hourly rate
    SELECT @hourly_rate = (salary / 22.0) / 8.0
    FROM Employee 
    WHERE employee_ID = @employee_ID;
    -- insert the missing days into deduction with the correct values from the attendance records
    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
    SELECT emp_ID, GETDATE(),8 * @hourly_rate, 'missing_days', 'pending', null,attendance_ID
    FROM Attendance a
    WHERE emp_ID = @employee_ID
    AND status = 'absent'
    AND NOT EXISTS(
        SELECT * FROM Deduction d
        WHERE d.attendance_ID = a.attendance_ID
        AND d.type = 'missing_days'
    )

GO

--G
CREATE PROC Deduction_unpaid
@employee_ID INT
AS
-- if deduction spans two months, two separate deductions should be created, one for each month, based on the approved unpaid leave days that occurred within that month.
    DECLARE @hourly_rate DECIMAL(10,2);
    DECLARE @deduction_amount DECIMAL(10,2);
    DECLARE @unpaid_ID INT;
    DECLARE @start_date DATE;
    DECLARE @end_date DATE;
    DECLARE @unpaid_days INT;
    -- Get hourly rate
    SELECT @hourly_rate = (salary / 22.0) / 8.0
    FROM Employee 
    WHERE employee_ID = @employee_ID;
    -- Count approved unpaid leave days in the current year (as there can only be one per year)
    SELECT @unpaid_ID = l.request_ID, 
           @start_date = l.start_date,
           @end_date = l.end_date
    FROM Unpaid_Leave ul
    JOIN Leave l ON ul.request_ID = l.request_ID
    WHERE ul.emp_ID = @employee_ID
      AND l.final_approval_status = 'approved'
      AND YEAR(l.start_date) = YEAR(GETDATE())
      AND NOT EXISTS (
          SELECT * FROM Deduction
          WHERE emp_ID = @employee_ID
          AND unpaid_ID = @unpaid_ID
          AND Month(date) = MONTH(GETDATE())
          AND YEAR(date) = YEAR(GETDATE())
      ); -- make sure we dont add the deduction again if we already did it

    SET @unpaid_days = DATEDIFF(DAY, @start_date, @end_date) + 1
    -- do the deduction
    IF @unpaid_ID IS NOT NULL
    BEGIN
        IF MONTH(@start_date) <> MONTH(@end_date)
        BEGIN
        -- The unpaid leave spans two months
         IF MONTH(@start_date) = MONTH(GETDATE()) and YEAR(@start_date) = YEAR(GETDATE())
         BEGIN
            SET @deduction_amount = 8 * @hourly_rate * (DATEDIFF(DAY, @start_date, EOMONTH(@start_date)) + 1) -- THE DAYS OF MONTH 1
            INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
            VALUES (@employee_ID, GETDATE(), @deduction_amount, 'unpaid', 'pending', @unpaid_ID, NULL);
        END
        ELSE IF MONTH(@end_date) = MONTH(GETDATE()) and YEAR(@end_date) = YEAR(GETDATE())
        BEGIN
            SET @deduction_amount = 8 * @hourly_rate * (@unpaid_days - DATEDIFF(DAY, @start_date, EOMONTH(@start_date)) + 1);-- tHE DAYS OF MONTH 2 (REST OF THE DAYS)
            INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
            VALUES (@employee_ID, GETDATE(), @deduction_amount, 'unpaid', 'pending', @unpaid_ID, NULL);
          END 
        END
        ELSE 
        BEGIN
        -- Unpaid leave is within the same month
            SET @deduction_amount = 8 * @hourly_rate * @unpaid_days;
            INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
            VALUES (@employee_ID, GETDATE(), @deduction_amount, 'unpaid', 'pending', @unpaid_ID, NULL);
        END
    END
    ELSE
    BEGIN
        PRINT 'No approved unpaid leave found';
    END
GO


-- H
CREATE FUNCTION Bonus_amount
(@employee_ID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @bonus DECIMAL(10,2);
    DECLARE @hourly_rate DECIMAL(10,2);
    DECLARE @overtime_factor DECIMAL(4,2);
    DECLARE @extra_hours DECIMAL(10,2);

    -- Overtime amount = rate per hour × ([overtime factor (based on role) × extra hours in attendance]/100).
    SELECT @hourly_rate = (salary / 22.0) / 8.0
    FROM Employee 
    WHERE employee_ID = @employee_ID;
    -- GET THE MAXIMUM OVERTIME FACTOR BASED ON ROLES
    SELECT @overtime_factor = MAX(percentage_overtime)
    FROM Employee e, Employee_Role er, Role r
    WHERE e.employee_ID = er.emp_ID
      AND er.role_name = r.role_name
      AND e.employee_ID = @employee_ID
      AND r.rank >= ALL (
          SELECT r2.rank
          FROM Employee e2, Employee_Role er2, Role r2
          WHERE e2.employee_ID = er2.emp_ID
            AND er2.role_name = r2.role_name
            AND e2.employee_ID = @employee_ID
      );
      -- CALCULATE THE TOTAL EXTRA HOURS IN ATTENDANCE
    SELECT @extra_hours = (ISNULL(SUM(total_duration),0) / 60.0 - 8 * COUNT(*)) -- to be full time each day is 8 hours
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND status = 'attended'
      AND MONTH(date) = MONTH(GETDATE())
      AND YEAR(date) = YEAR(GETDATE())
    -- ENSURE EXTRA HOURS IS NOT NEGATIVE
    IF @extra_hours < 0
        SET @extra_hours = 0;
    -- CALCULATE BONUS/ Overtime AMOUNT
    SET @bonus = @hourly_rate * ((@overtime_factor * @extra_hours)/100);
    RETURN @bonus;


END;
GO

-- I
CREATE PROC Add_Payroll
@employee_ID INT,
@from_date DATE,
@to_date DATE 
AS
    DECLARE @basic_salary DECIMAL(10,2);
    DECLARE @bonus_amount DECIMAL(10,2);
    DECLARE @deductions_amount DECIMAL(10,2);
    DECLARE @net_salary DECIMAL(10,1);

    -- Get basic salary
    SELECT @basic_salary = salary
    FROM Employee 
    WHERE employee_ID = @employee_ID;

    -- Get bonus amount
    SET @bonus_amount = dbo.Bonus_amount(@employee_ID);

    -- Get total deductions in the period -- NOTE BY DATE OF DEDUCTION BUT BY DATE OF ACTION
    SELECT @deductions_amount = ISNULL(SUM(amount), 0) -- isnull does a check. if it is null, it returns 0, otherwise it returns the sum
    FROM Deduction d
    WHERE emp_ID = @employee_ID
      AND d.date BETWEEN @from_date AND @to_date
      AND d.status = 'pending'
    --finalize the deductions
    UPDATE Deduction SET status = 'finalized'
    WHERE emp_ID = @employee_ID
    AND date BETWEEN @from_date AND @to_date
    AND status = 'pending';
    -- Calculate net salary
    SET @net_salary = @basic_salary + @bonus_amount - @deductions_amount;
    -- Insert into Payroll
    INSERT INTO Payroll ( payment_date, final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount, emp_ID)
    VALUES ( GETDATE() ,@net_salary, @from_date, @to_date, 'Monthly Payroll', @bonus_amount, @deductions_amount, @employee_ID);
GO


-- HR EMPLOYEE FUNCTIONALITY APPENDIX 

/* BUSINESS LOGIC JUSTIFICATION: "ISOLATED DAILY CALCULATION" STRATEGY
   -----------------------------------------------------------------------------------
   We have adopted an isolated calculation method where Bonus Hours and Deduction Hours 
   are computed independently of one another. 
   
   1. Bonus Logic: We sum the extra hours ONLY from days where the employee worked 
      more than the required 8 hours. Deficits from other days are ignored to ensure 
      positive reinforcement for overtime work is not negated by previous shortcomings.
      
   2. Deduction Logic: We sum the missing hours ONLY from days where the employee 
      attended but worked less than 8 hours. Surpluses from other days are ignored 
      because contractual hours are daily obligations, and working extra on Tuesday 
      does not legally cancel out missing mandatory hours on Monday.
      
   This ensures that an employee is fairly compensated for specific instances of 
   overtime while still being held accountable for specific instances of missing time.
   -----------------------------------------------------------------------------------
*/

/*
-- E
CREATE PROC Deduction_hours
@employee_ID INT
AS

    DECLARE @attendance_id INT;
    DECLARE @deduction_minutes INT;
    DECLARE @hourly_rate DECIMAL(10,2);
    DECLARE @deduction_amount DECIMAL(10,2);
    -- Get hourly rate
    SELECT @hourly_rate = (salary / 22.0) / 8.0
    FROM Employee 
    WHERE employee_ID = @employee_ID;
    -- Get first attendance record this month with less than 8 hours
    SELECT TOP 1 
            @attendance_id = attendance_ID
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND YEAR(date) = YEAR(GETDATE())
      AND MONTH(date) = MONTH(GETDATE())
      AND total_duration < 8*60
    ORDER BY date ASC;
    
    -- Compute deduction ONLY for underworked days (Ignoring overworked days)
    SELECT @deduction_minutes = ISNULL(SUM((8 * 60) - total_duration), 0)
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND status = 'attended'
      AND total_duration < (8 * 60) -- STRICT CHANGE: Only look at days with deficits
      AND MONTH(date) = MONTH(GETDATE())
      AND YEAR(date) = YEAR(GETDATE());

    IF @deduction_minutes > 0 
    AND NOT EXISTS(
        SELECT * FROM Deduction d
        WHERE d.attendance_ID = @attendance_id
        AND d.type = 'missing_hours'
    )
    BEGIN
        SET @deduction_amount = (@deduction_minutes / 60.0) * @hourly_rate;
        INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
        VALUES (@employee_ID, GETDATE(), @deduction_amount, 'missing_hours', 'pending', NULL, @attendance_id);
    END
    ELSE
    BEGIN
        PRINT 'No missing hours deduction needed for this month.';
    END
GO
*/

/*
-- H
CREATE FUNCTION Bonus_amount
(@employee_ID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @bonus DECIMAL(10,2);
    DECLARE @hourly_rate DECIMAL(10,2);
    DECLARE @overtime_factor DECIMAL(4,2);
    DECLARE @extra_hours DECIMAL(10,2);

    -- Overtime amount = rate per hour × ([overtime factor (based on role) × extra hours in attendance]/100).
    SELECT @hourly_rate = (salary / 22.0) / 8.0
    FROM Employee 
    WHERE employee_ID = @employee_ID;
    -- GET THE MAXIMUM OVERTIME FACTOR BASED ON ROLES
    SELECT @overtime_factor = MAX(percentage_overtime)
    FROM Employee e, Employee_Role er, Role r
    WHERE e.employee_ID = er.emp_ID
      AND er.role_name = r.role_name
      AND e.employee_ID = @employee_ID
      AND r.rank >= ALL (
          SELECT r2.rank
          FROM Employee e2, Employee_Role er2, Role r2
          WHERE e2.employee_ID = er2.emp_ID
            AND er2.role_name = r2.role_name
            AND e2.employee_ID = @employee_ID
      );
      
    -- CALCULATE THE TOTAL EXTRA HOURS IN ATTENDANCE (ISOLATED APPROACH)
    -- STRICT CHANGE: Only sum the excess time from days that EXCEEDED 8 hours.
    SELECT @extra_hours = ISNULL(SUM((total_duration - (8 * 60)) / 60.0), 0)
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND status = 'attended'
      AND total_duration > (8 * 60) -- Only include days with overtime
      AND MONTH(date) = MONTH(GETDATE())
      AND YEAR(date) = YEAR(GETDATE());

    -- ENSURE EXTRA HOURS IS NOT NEGATIVE (Redundant now due to WHERE clause, but kept for safety)
    IF @extra_hours < 0
        SET @extra_hours = 0;
    -- CALCULATE BONUS/ Overtime AMOUNT
    SET @bonus = @hourly_rate * ((@overtime_factor * @extra_hours)/100);
    RETURN @bonus;

END;
GO
*/


-- 2.5 EMPLOYEE FUNCTIONALITIES 

-- A
CREATE FUNCTION EmployeeLoginValidation
(
    @employee_ID INT,
    @password VARCHAR(50)
) 
RETURNS BIT
AS
BEGIN
    DECLARE @isValid BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM Employee
        WHERE employee_ID = @employee_ID AND password = @password
    )
        SET @isValid = 1;

    RETURN @isValid;
END
GO




-- B
CREATE FUNCTION MyPerformance
(
    @employee_ID INT,
    @semester char(3)
) 
RETURNS TABLE
AS 
RETURN
(
    SELECT *
    FROM Performance
    WHERE emp_ID = @employee_ID AND semester = @semester 
)
GO 




-- C
CREATE FUNCTION MyAttendance
(
    @employee_ID INT
) 
RETURNS TABLE
AS
RETURN
(
    SELECT a.*
    FROM Attendance a JOIN Employee e ON e.employee_ID = a.emp_ID 
    WHERE e.employee_ID = @employee_ID
    AND a.[date] >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
    AND a.[date] < DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    AND NOT (DATENAME(weekday, a.[date]) = e.official_day_off AND a.status = 'Absent')
)
GO 




-- D
CREATE FUNCTION Last_month_payroll
(
    @employee_ID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * 
    FROM Payroll
    WHERE emp_ID = @employee_ID
      AND payment_date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
      AND payment_date <  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)

);
GO




-- E
CREATE FUNCTION Deductions_Attendance
(
    @employee_ID INT,
    @month INT
) RETURNS TABLE
AS 
RETURN
(
    SELECT d.deduction_ID
    FROM deductions d
    WHERE d.emp_ID = @employee_ID AND MONTH(d.[date]) = @month AND (d.[type] = 'missing_days' OR d.[type] = 'missing_hours')
)
GO




-- F
CREATE FUNCTION Is_On_Leave
(
    @employee_ID INT,
    @from_date DATE,
    @to_date DATE
) 
RETURNS BIT
AS
BEGIN
    DECLARE @SuccessBit BIT = 0;

    IF @from_date IS NULL OR @to_date IS NULL OR @from_date > @to_date
        RETURN @SuccessBit;

    IF EXISTS(
        SELECT 1

        FROM Leave l
        LEFT JOIN Annual_Leave an ON an.request_ID = l.request_ID
        LEFT JOIN Accidental_Leave ac ON ac.request_ID = l.request_ID
        LEFT JOIN Medical_Leave me ON me.request_ID = l.request_ID
        LEFT JOIN Unpaid_Leave up ON up.request_ID = l.request_ID
        LEFT JOIN Compensation_Leave cm ON cm.request_ID = l.request_ID

        WHERE 
        (
            (an.emp_ID = @employee_ID
            OR ac.emp_ID = @employee_ID
            OR me.emp_ID = @employee_ID
            OR up.emp_ID = @employee_ID
            OR cm.emp_ID = @employee_ID
            )
            AND l.final_approval_status IN ('pending', 'approved')
            AND l.end_date >= @from_date AND l.start_date <= @to_date
        )
    )
        SET @SuccessBit = 1
    RETURN @SuccessBit
END
GO




-- G
CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    DECLARE @employee_dept VARCHAR(50)
    DECLARE @employee_role VARCHAR(50)
    DECLARE @employee_rank INT

    SELECT TOP 1 
           @employee_dept = e.dept_name,
           @employee_role = r.role_name,
           @employee_rank = r.rank
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name 
    WHERE e.employee_id = @employee_ID
    ORDER BY r.rank ASC;

    DECLARE @dean_id INT
    DECLARE @vice_dean_id INT 

    SELECT @dean_id = e.employee_ID
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = @employee_dept AND r.role_name = 'Dean'

    SELECT @vice_dean_id = e.employee_ID
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = @employee_dept AND r.role_name = 'Vice Dean'

    IF (EXISTS(
            SELECT 1 FROM Employee 
            WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time'
        )
    )
    BEGIN
        RETURN;
    END

    INSERT INTO [Leave] (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @start_date, @end_date);

    DECLARE @leaveId INT;
    SET @leaveId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp)
    VALUES (@leaveId, @employee_ID, @replacement_emp);

    DECLARE @hrRep VARCHAR(50)
    SET @hrRep = 'HR_Representative_' + @employee_dept

    DECLARE @hrID INT
    SET @hrID = (
        SELECT TOP 1 e.employee_ID
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep
    )
    
    IF (dbo.Is_On_Leave(@hrId, GETDATE(), GETDATE()) = 1)
    BEGIN
        SET @hrID = (
            SELECT TOP 1 Emp2_ID
            FROM Employee_Replace_Employee
            WHERE Emp1_ID = @hrID AND from_date <= GETDATE() AND to_date >= GETDATE()
        )
    END


    IF @employee_role IN ('Dean', 'Vice Dean')
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President' OR e.employee_ID = @hrID
    END

    ELSE IF @employee_dept = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'HR Manager'
    END

    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        WHERE e.employee_ID = @hrID

        DECLARE @approver_id INT
        
        IF dbo.Is_On_Leave(@dean_id, GETDATE(), GETDATE()) = 1
            SET @approver_id = @vice_dean_id
        ELSE
            SET @approver_id = @dean_id

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@approver_id, @leaveId, 'pending')
    END
END
GO




-- H
CREATE FUNCTION Status_leaves(
    @employee_ID INT
)RETURNS TABLE
AS 
RETURN(
    SELECT l.request_ID, l.date_of_request, l.final_approval_status
    FROM Leave l
    LEFT JOIN Annual_Leave al ON l.request_ID = al.request_ID
    LEFT JOIN Accidental_Leave ac ON l.request_ID = ac.request_ID
    WHERE (
        l.date_of_request >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
        AND l.date_of_request < DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
        AND(
            (al.request_ID IS NOT NULL AND al.emp_ID = @employee_ID)
            OR (ac.request_ID IS NOT NULL AND ac.emp_ID = @employee_ID)
        )
    )
)
GO




-- I
CREATE PROCEDURE Upperboard_approve_annual
    @request_ID INT,
    @Upperboard_ID INT,
    @replacement_ID INT
AS
BEGIN
    DECLARE @start_date DATE
    DECLARE @end_date DATE
    SELECT @start_date = start_date,
           @end_date = end_date
    FROM Leave
    WHERE request_ID = @request_ID

    DECLARE @employee_dept VARCHAR(50)
    DECLARE @replacement_dept VARCHAR(50)

    SELECT @employee_dept = e.dept_name
    FROM Employee e
    JOIN Annual_Leave l ON l.Emp_ID = e.employee_ID 
    WHERE l.request_ID = @request_ID

    SELECT @replacement_dept = dept_name
    FROM Employee e
    WHERE e.employee_ID = @replacement_ID

    IF (dbo.Is_On_Leave(@replacement_ID, @start_date, @end_date) = 1 OR @employee_dept <> @replacement_dept)
    BEGIN
        UPDATE Employee_Approve_Leave 
        SET status = 'rejected'
        WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID
    END
    ELSE
    BEGIN
        UPDATE Employee_Approve_Leave
        SET status = 'approved'
        WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID
    END
END
GO




-- J
CREATE PROCEDURE Submit_accidental
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS 
BEGIN
    DECLARE @employee_dept VARCHAR(50)
    DECLARE @employee_role VARCHAR(50)
    DECLARE @employee_rank INT

    SELECT TOP 1 
           @employee_dept = e.dept_name,
           @employee_role = r.role_name,
           @employee_rank = r.rank
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name 
    WHERE e.employee_id = @employee_ID
    ORDER BY r.rank ASC;

    INSERT INTO [Leave] (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @start_date, @end_date);

    DECLARE @leaveId INT;
    SET @leaveId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO Accidental_Leave (request_ID, emp_ID)
    VALUES (@leaveId, @employee_ID);    

    DECLARE @hrRep VARCHAR(50)
    SET @hrRep = 'HR_Representative_' + @employee_dept

    DECLARE @hrID INT
    SET @hrID = (
        SELECT TOP 1 e.employee_ID
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep
    )
    
    IF (dbo.Is_On_Leave(@hrId, GETDATE(), GETDATE()) = 1)
    BEGIN
        SET @hrID = (
            SELECT TOP 1 Emp2_ID
            FROM Employee_Replace_Employee
            WHERE Emp1_ID = @hrID AND from_date <= GETDATE() AND to_date >= GETDATE()
        )
    END


    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        WHERE e.employee_ID = @hrID
END
GO




-- K
CREATE PROCEDURE Submit_medical
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type VARCHAR(50),
    @insurance_status BIT,
    @disability_details VARCHAR(50),
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN

    DECLARE @employee_dept VARCHAR(50)
    DECLARE @employee_role VARCHAR(50)
    DECLARE @employee_rank INT

    SELECT TOP 1 
           @employee_dept = e.dept_name,
           @employee_role = r.role_name,
           @employee_rank = r.rank
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name 
    WHERE e.employee_id = @employee_ID
    ORDER BY r.rank ASC;

    IF (EXISTS(
            SELECT 1 FROM Employee 
            WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time'
        ) AND @type = 'maternity'
    )
    BEGIN
        RETURN;
    END

    INSERT INTO [Leave] (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @start_date, @end_date);

    DECLARE @leaveId INT;
    SET @leaveId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID)
    VALUES (@leaveId, @insurance_status, @disability_details, @type, @employee_ID); 
    
    INSERT INTO Document(type, description, file_name, creation_date, status, emp_ID, medical_ID)
    VALUES ('medical', @document_description, @file_name, GETDATE(), 'valid', @employee_ID, @leaveId)

    DECLARE @hrRep VARCHAR(50)
    SET @hrRep = 'HR_Representative_' + @employee_dept

    DECLARE @hrID INT
    SET @hrID = (
        SELECT TOP 1 e.employee_ID
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep
    )
    
    IF (dbo.Is_On_Leave(@hrId, GETDATE(), GETDATE()) = 1)
    BEGIN
        SET @hrID = (
            SELECT TOP 1 Emp2_ID
            FROM Employee_Replace_Employee
            WHERE Emp1_ID = @hrID AND from_date <= GETDATE() AND to_date >= GETDATE()
        )
    END

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        WHERE e.employee_ID = @hrID

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT TOP 1 e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'Medical Doctor' AND dbo.Is_On_Leave(e.employee_ID, GETDATE(), GETDATE()) = 0 AND e.employee_ID <> @employee_ID
END
GO




-- L
CREATE PROCEDURE Submit_unpaid
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN

    DECLARE @employee_dept VARCHAR(50)
    DECLARE @employee_role VARCHAR(50)
    DECLARE @employee_rank INT

    SELECT TOP 1 
           @employee_dept = e.dept_name,
           @employee_role = r.role_name,
           @employee_rank = r.rank
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name 
    WHERE e.employee_id = @employee_ID
    ORDER BY r.rank ASC;


    DECLARE @dean_id INT
    DECLARE @vice_dean_id INT 

    SELECT @dean_id = e.employee_ID
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = @employee_dept AND r.role_name = 'Dean'

    SELECT @vice_dean_id = e.employee_ID
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = @employee_dept AND r.role_name = 'Vice Dean'

    IF (EXISTS(
            SELECT 1 FROM Employee 
            WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time'
        )
    )
    BEGIN
        RETURN;
    END
    
    INSERT INTO [Leave] (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @start_date, @end_date);

    DECLARE @leaveId INT;
    SET @leaveId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO Unpaid_Leave (request_ID, Emp_ID)
    VALUES (@leaveId, @employee_ID); 
    
    INSERT INTO Document(type, description, file_name, creation_date, status, emp_ID, unpaid_ID)
    VALUES ('memo', @document_description, @file_name, GETDATE(), 'valid', @employee_ID, @leaveId)

    DECLARE @hrRep VARCHAR(50)
    SET @hrRep = 'HR_Representative_' + @employee_dept

    DECLARE @hrID INT
    SET @hrID = (
        SELECT TOP 1 e.employee_ID
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep
    )
    
    IF (dbo.Is_On_Leave(@hrId, GETDATE(), GETDATE()) = 1)
    BEGIN
        SET @hrID = (
            SELECT TOP 1 Emp2_ID
            FROM Employee_Replace_Employee
            WHERE Emp1_ID = @hrID AND from_date <= GETDATE() AND to_date >= GETDATE()
        )
    END

    IF @employee_role IN ('Dean', 'Vice Dean')
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President' OR e.employee_ID = @hrID
    END

    ELSE IF @employee_dept = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President' OR r.role_name = 'HR Manager'
    END

    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        WHERE e.employee_ID = @hrID

        DECLARE @approver_id INT
        
        IF dbo.Is_On_Leave(@dean_id, GETDATE(), GETDATE()) = 1
            SET @approver_id = @vice_dean_id
        ELSE
            SET @approver_id = @dean_id

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@approver_id, @leaveId, 'pending')
    END
END
GO




-- M
CREATE PROCEDURE Upperboard_approve_unpaids
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN    
    IF EXISTS (
        SELECT 1 
        FROM Document
        WHERE unpaid_ID = @request_ID 
          AND type = 'memo' 
          AND status = 'valid'
          AND description IS NOT NULL
    )
    BEGIN
        UPDATE Employee_Approve_Leave
        SET status = 'approved'
        WHERE Leave_ID = @request_ID
          AND Emp1_ID = @Upperboard_ID;
    END
    ELSE
    BEGIN
        UPDATE Employee_Approve_Leave
        SET status = 'rejected'
        WHERE Leave_ID = @request_ID
          AND Emp1_ID = @Upperboard_ID;
    END
END
GO




-- N
CREATE PROCEDURE Submit_compensation
    @employee_ID INT,
    @compensation_date DATE,
    @reason VARCHAR(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
BEGIN
    DECLARE @employee_dept VARCHAR(50)
    DECLARE @employee_role VARCHAR(50)
    DECLARE @employee_rank INT

    SELECT TOP 1 
           @employee_dept = e.dept_name,
           @employee_role = r.role_name,
           @employee_rank = r.rank
    FROM Employee e
    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    JOIN Role r ON r.role_name = er.role_name 
    WHERE e.employee_id = @employee_ID
    ORDER BY r.rank ASC;

    INSERT INTO [Leave] (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @compensation_date, @compensation_date);

    DECLARE @leaveId INT;
    SET @leaveId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, Emp_ID, replacement_emp)
    VALUES (@leaveId, @reason, @date_of_original_workday, @employee_ID, @replacement_emp);
    
    DECLARE @hrRep VARCHAR(50)
    SET @hrRep = 'HR_Representative_' + @employee_dept

    DECLARE @hrID INT
    SET @hrID = (
        SELECT TOP 1 e.employee_ID
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep
    )
    
    IF (dbo.Is_On_Leave(@hrId, GETDATE(), GETDATE()) = 1)
    BEGIN
        SET @hrID = (
            SELECT TOP 1 Emp2_ID
            FROM Employee_Replace_Employee
            WHERE Emp1_ID = @hrID AND from_date <= GETDATE() AND to_date >= GETDATE()
        )
    END

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        WHERE e.employee_ID = @hrId

END
GO




-- O
CREATE PROCEDURE Dean_andHR_Evaluation
    @employee_ID INT,
    @rating INT,
    @comment VARCHAR(50),
    @semester char(3)
AS
BEGIN
    INSERT INTO Performance(rating, comments, semester, emp_ID)
    VALUES (@rating, @comment, @semester, @employee_ID)
END
GO