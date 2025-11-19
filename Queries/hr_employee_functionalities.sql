
EXEC createAllTables
 GO

 drop FUNCTION HRLoginValidation
 Go
-- 2.4 (a) HR Login Validation Function
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


DROP PROC HR_approval_an_acc
go
CREATE PROC HR_approval_an_acc
    @request_ID INT,
    @HR_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @num_days INT,
        @employee_id INT,
        @old_balance INT,
        @new_balance INT,
        @leave_type VARCHAR(50),
        @employee_rank INT,

        -- better for readbility
        @employee_is_dean BIT = 0, -- dean or vice dean 
        @employee_is_HR BIT = 0;


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

        -- Check replacement employee availability
        ------------------------------------IMPLEMENT------------------------------

  

    END
    ELSE  -- accidental
    BEGIN

        DECLARE @hours_since_request INT;

        SELECT @employee_id = a.emp_ID, @num_days = l.num_days,  @hours_since_request = DATEDIFF(HOUR, date_of_request, GETDATE())
        FROM Leave l 
        JOIN Accidental_Leave a ON l.request_ID = a.request_ID
        WHERE l.request_ID = @request_ID;

        -- Accidental leave exceeds 1 day or has been submitted more then 48 hours ago

        IF @num_days > 1 OR @hours_since_request > 48
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;

            PRINT 'Accidental Leave Exceeds 1 Day, or has been submitted more than 48 hours ago. Request Rejected.';
            RETURN;
        END
    END


    -- Reject if employee is part-time
    IF EXISTS (
        SELECT * FROM Employee
        WHERE employee_ID = @employee_id
          AND type_of_contract = 'part_time'
    )
    BEGIN
        UPDATE Leave SET final_approval_status = 'rejected'
        WHERE request_ID = @request_ID;
        PRINT 'Part-Time Employees Cannot Take Annual or Accidental Leave. Rejected.';
        RETURN;
    END


    -- Load rank and determine role category
    SELECT @employee_rank = MAX(r.rank)
    FROM Employee_Role er
    JOIN Role r ON er.role_name = r.role_name
    WHERE er.emp_ID = @employee_id;

    IF EXISTS (SELECT * FROM Employee_Role WHERE emp_ID = @employee_id AND role_name = 'Dean')
        SET @employee_is_dean = 1;

    IF EXISTS (SELECT * FROM Employee_Role WHERE emp_ID = @employee_id AND role_name = 'Vice Dean')
        SET @employee_is_dean = 1;

    IF EXISTS (SELECT * FROM Employee WHERE employee_ID = @employee_id AND dept_name = 'HR')
        SET @employee_is_HR = 1;


    -- Annual leave approval logic
    IF @leave_type = 'annual'
    BEGIN

        -- Case 1: Employee is Normal employee
        IF @employee_is_dean = 0 AND @employee_is_HR = 0
        BEGIN
            -- Must be approved by Dean
            IF NOT EXISTS (
                SELECT *
                FROM Employee_Approve_Leave eal
                JOIN Employee_Role er ON eal.Emp1_ID = er.emp_ID
                WHERE eal.Leave_ID = @request_ID
                  AND er.role_name = 'Dean'
            )
            BEGIN
                PRINT 'Annual Leave Requires Dean Approval First.';
                RETURN;
            END
        END

        -- Case 2: Employee is Dean or Vice-Dean
        IF @employee_is_dean = 1 
        BEGIN
            -- Must have approval from someone with higher rank
            IF NOT EXISTS (
                SELECT *
                FROM Employee_Approve_Leave eal
                JOIN Employee ER ON eal.Emp1_ID = ER.employee_ID
                JOIN Employee_Role RR ON ER.employee_ID = RR.emp_ID
                JOIN Role R ON RR.role_name = R.role_name
                WHERE eal.Leave_ID = @request_ID
                  AND ER.dept_name = 'Upper Board'
                  AND R.rank > @employee_rank
            )
            BEGIN
                PRINT 'Annual Leave Requires Approval From a Higher-Rank Upper Board Member.';
                RETURN;
            END
        END


        -- Case 3: Employee is HR
        IF @employee_is_HR = 1
        BEGIN
            -- Must be approved by HR staff of higher rank
            IF NOT EXISTS (
                SELECT *
                FROM Employee_Approve_Leave eal
                JOIN Employee ER ON eal.Emp1_ID = ER.employee_ID
                JOIN Employee_Role RR ON ER.employee_ID = RR.emp_ID
                JOIN Role R ON RR.role_name = R.role_name
                WHERE eal.Leave_ID = @request_ID
                  AND ER.dept_name = 'HR'
                  AND R.rank > @employee_rank
            )
            BEGIN
                PRINT 'Annual Leave Requires Approval From Higher-Rank HR Personnel.';
                RETURN;
            END
        END
    END


    -- Everything validated SO HR can now approve
    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
    VALUES (@HR_ID, @request_ID, 'approved');

    UPDATE Leave
    SET final_approval_status = 'approved'
    WHERE request_ID = @request_ID;


    IF @leave_type = 'annual'
        UPDATE Employee SET annual_balance = annual_balance - @num_days WHERE employee_ID = @employee_id;
    ELSE
        UPDATE Employee SET accidental_balance = accidental_balance - @num_days WHERE employee_ID = @employee_id;

END
GO


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
            PRINT 'The Employee Annual Leave Balance Is Greater Than Zero. Unpaid Leave Request Rejected.';
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
            PRINT 'The Employee Is Part-Time. Unpaid Leave Request Rejected.';
            RETURN;

        END

        -- MAKE SURE THE PRESIDENT AND HR MANAGER HAS APPROVED THE REQUEST IF THE EMPLOYEE IS AN HR REP or a dean/vice dean
        if EXISTS (
              SELECT *
              FROM Employee_Role
              WHERE emp_ID = @employee_id
                AND role_name IN ('HR Representative', 'Dean', 'Vice Dean')
          )
          -- start of the condition in the case that the role of the requester is HR REP/ DEAN/ VICE DEAN
          -- NEEDS TO BE APPROVED BY hr manager and president who already check if it has a valid memo
            iF
            NOT EXISTS (
              SELECT *
              FROM Employee_Approve_Leave
              WHERE Leave_ID = @request_ID
                AND Emp1_ID IN (
                    SELECT e.employee_ID
                    FROM Employee e
                    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
                    WHERE er.role_name = 'President'
                )
                AND status = 'approved') 

             OR NOT EXISTS (
              SELECT *
              FROM Employee_Approve_Leave
              WHERE Leave_ID = @request_ID
                AND Emp1_ID IN (
                    SELECT e.employee_ID
                    FROM Employee e
                    JOIN Employee_Role er ON e.employee_ID = er.emp_ID
                    WHERE er.role_name = 'HR Manager'
                )
                AND status = 'approved')

             BEGIN
             PRINT 'The Unpaid Leave Request Has Not Been Approved By Dean Or Vice Dean Yet.';
                  RETURN;
              END
       
        ELSE
        -- make sure the dean/vice dean/ president already approved the request
        BEGIN
             -- Start of the condition if this is the regular employee
             -- needs to be approved by dean/vice dean/ president who already checked if it has a valid memo
            iF EXISTS(
            SELECT *
            FROM Employee_Approve_Leave
            WHERE Leave_ID = @request_ID
              AND Emp1_ID IN (
                  SELECT e.employee_ID
                  FROM Employee e
                  JOIN Employee_Role er ON e.employee_ID = er.emp_ID
                  WHERE er.role_name IN ('Dean', 'Vice Dean', 'President')
              )
              AND status = 'approved')

             BEGIN
                 PRINT 'The Unpaid Leave Request Has Not Been Approved By Dean Or Vice Dean Yet.';
                 RETURN;
              END
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
                  PRINT 'The Unpaid Leave Duration Exceeds 30 Days. Request Rejected.';
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
                  PRINT 'The Employee Has Taken Unpaid Leave In The Last Year. Request Rejected.';
                  RETURN;
            END
        
        -- Otherwise we accept
		INSERT INTO Employee_Approve_Leave 
		VALUES (@employee_id, @request_ID, 'approved')

		UPDATE Leave
		SET final_approval_status = 'approved'
		WHERE request_ID = @request_ID 

GO

drop PROC HR_approval_comp
go

CREATE PROC HR_approval_comp
@request_ID int, @HR_ID int
AS

        --Compensation leaves are approved by HR employees if the employee applying for the leave spent at least 8 hours during his/her day off.
        declare @date_of_original_workday DATE;
        DECLARE @employee_id INT;
        DECLARE @initial_balance INT;

        -- check if replacement employee is available
        ------------------------------------------------------IMPLEMENT---------------------------------------------------------------------


        -- get the empoyee id of the requester and the date of original workday
        SELECT @employee_id = emp_ID, @date_of_original_workday = date_of_original_workday
        FROM Compensation_Leave 
        WHERE request_ID = @request_ID;


        -- check if the date in the request is actually a workday for the employee
        IF (SELECT official_day_off FROM Employee WHERE employee_ID = @employee_id) = DATENAME(WEEKDAY, @date_of_original_workday)
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;
            PRINT 'The Specified Date Is A Day Off For The Employee. Compensation Leave Request Rejected.';
            RETURN;
        END

        -- check if Compensation not within the same month or more than a day
        IF NOT EXISTS(
            SELECT *
            FROM Leave l JOIN  Compensation_Leave cl ON l.request_ID = cl.request_ID
            WHERE l.request_ID = @request_ID
            AND MONTH(l.start_date) = Month(cl.date_of_original_workday)
            AND l.start_date = l.end_date
        )
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;
            PRINT 'Compensation not within the same month or more than a day. Compensation Leave Request Rejected.';
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
            INSERT INTO Employee_Approve_Leave 
		    VALUES (@HR_ID, @request_ID, 'approved')

		    UPDATE Leave
		    SET final_approval_status = 'approved'
		    WHERE request_ID = @request_ID 
        END
        ELSE
        BEGIN
            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID;
            PRINT 'The Employee Has Not Spent At Least 8 Hours During His/Her Day Off. Compensation Leave Request Rejected.';
            RETURN;
        END
GO

DROP PROC Deduction_hours
GO
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

DROP PROC Deduction_days
GO
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
    AND status = 'Absent'
    AND NOT EXISTS(
        SELECT * FROM Deduction d
        WHERE d.attendance_ID = a.attendance_ID
        AND d.type = 'missing_days'
    )

GO

DROP PROC Deduction_unpaid
GO

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
      ); -- make sure we dont add the deduction again if we already did it

    SET @unpaid_days = DATEDIFF(DAY, @start_date, @end_date) + 1

    -- do the deduction
    IF @unpaid_ID IS NOT NULL
    BEGIN
        IF MONTH(@start_date) <> MONTH(@end_date)
        BEGIN
        -- The unpaid leave spans two months
            SET @deduction_amount = 8 * @hourly_rate * (DATEDIFF(DAY, @start_date, EOMONTH(@start_date)) + 1) -- THE DAYS OF MONTH 1
            INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
            VALUES (@employee_ID, GETDATE(), @deduction_amount, 'unpaid', 'pending', @unpaid_ID, NULL);

            SET @deduction_amount = 8 * @hourly_rate * (@unpaid_days - DATEDIFF(DAY, @start_date, EOMONTH(@start_date)) + 1);-- tHE DAYS OF MONTH 2 (REST OF THE DAYS)
            INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
            VALUES (@employee_ID, GETDATE(), @deduction_amount, 'unpaid', 'pending', @unpaid_ID, NULL);

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


DROP FUNCTION Bonus_amount
go
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
      AND e.employee_ID = @employee_ID;


      -- CALCULATE THE TOTAL EXTRA HOURS IN ATTENDANCE
    SELECT @extra_hours = (ISNULL(SUM(total_duration),0) / 60.0 - 8 * COUNT(*)) -- to be full time each day is 8 hours
    FROM Attendance
    WHERE emp_ID = @employee_ID
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

    -- Get total deductions in the period
    SELECT @deductions_amount = ISNULL(SUM(amount), 0) -- isnull does a check. if it is null, it returns 0, otherwise it returns the sum
    FROM Deduction
    WHERE emp_ID = @employee_ID
      AND date BETWEEN @from_date AND @to_date
      AND status = 'pending';

    --finalize the deductions
    UPDATE Deduction SET status = 'finalized'
    WHERE emp_ID = @employee_ID
    AND date BETWEEN @from_date AND @to_date;
    -- Calculate net salary
    SET @net_salary = @basic_salary + @bonus_amount - @deductions_amount;
    -- Insert into Payroll
    INSERT INTO Payroll ( final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount, emp_ID)
    VALUES ( @net_salary, @from_date, @to_date, 'Monthly Payroll', @bonus_amount, @deductions_amount, @employee_ID);
GO




