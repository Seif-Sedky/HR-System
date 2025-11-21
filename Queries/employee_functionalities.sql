-- A
CREATE FUNCTION EmployeeLoginValidation(
    @employee_ID INT,
    @password VARCHAR(50)
) RETURNS BIT
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

--B
CREATE FUNCTION MyPerformance(
    @employee_ID INT,
    @semester char(3)
) RETURNS TABLE
AS 
RETURN
(
    SELECT *
    FROM Performance
    WHERE emp_ID = @employee_ID AND semester = @semester 
)

-- C
CREATE FUNCTION MyAttendance(
    @employee_ID INT
) RETURNS TABLE
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

--D
CREATE FUNCTION Last_month_payroll(
    @employee_ID INT
) RETURNS TABLE
AS 
RETURN(
    SELECT *
    FROM Payroll
    WHERE emp_ID = @employee_ID
    AND from_date >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    AND from_date < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
    AND to_date >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    AND to_date < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
)

-- E
CREATE FUNCTION Deductions_Attendance(
    @employee_ID INT,
    @month INT
) RETURNS TABLE
AS 
RETURN
(
    SELECT d.deduction_ID
    FROM deductions d
    WHERE d.emp_ID = @employee_ID AND MONTH(d.[date]) = @month AND d.[type] = 'missing_days'
)

--F
CREATE FUNCTION Is_On_Leave(
    @employee_ID INT,
    @from_date DATE,
    @to_date DATE
) RETURNS BIT
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


--G
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
        OR (@employee_ID = @dean_id AND dbo.Is_On_Leave(@vice_dean_id, @start_date, @end_date) = 1)
        OR (@employee_ID = @vice_dean_id AND dbo.Is_On_Leave(@dean_id, @start_date, @end_date) = 1)
        OR (Is_On_Leave(@replacement_emp, @start_date, @end_date) = 1)
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


    IF @employee_role IN ('Dean', 'Vice Dean')
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name IN ('President', @hrRep)
    END

    ELSE IF @employee_dept = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE e.dept_name = 'HR' 
          AND e.employee_ID <> @employee_ID
          AND r.rank < @employee_rank
    END

    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep

        DECLARE @approver_id INT
        
        IF dbo.Is_On_Leave(@dean_id, @start_date, @end_date) = 1
            SET @approver_id = @vice_dean_id
        ELSE
            SET @approver_id = @dean_id

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@approver_id, @leaveId, 'pending')
    END
END

--H
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

--I
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

    IF (Is_On_Leave(@replacement_ID, @start_date, @end_date) = 1 OR @employee_dept <> @replacement_dept)
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

--J
CREATE PROCEDURE Submit_accidental
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS 
BEGIN
    IF (GETDATE() > @start_date AND DATEDIFF(DAY, @start_date, GETDATE()) > 2)
    BEGIN
        RETURN;
    END
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


    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep
END

--K
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
        ) AND @type = 'maternity'
        OR (@employee_ID = @dean_id AND dbo.Is_On_Leave(@vice_dean_id, @start_date, @end_date) = 1)
        OR (@employee_ID = @vice_dean_id AND dbo.Is_On_Leave(@dean_id, @start_date, @end_date) = 1)
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

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep OR r.role_name = 'Medical Doctor'
END

--L
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
        OR (@employee_ID = @dean_id AND dbo.Is_On_Leave(@vice_dean_id, @start_date, @end_date) = 1)
        OR (@employee_ID = @vice_dean_id AND dbo.Is_On_Leave(@dean_id, @start_date, @end_date) = 1)
        OR EXISTS(
            SELECT 1
            FROM Unpaid_Leave up
            JOIN Leave l ON up.request_ID = l.request_ID
            WHERE YEAR(l.start_date) = YEAR(@start_date) AND up.Emp_ID = @employee_ID AND l.final_approval_status = 'approved'
        )
        OR DATEDIFF(DAY, @end_date, @start_date) > 30
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

    IF @employee_role IN ('Dean', 'Vice Dean')
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name IN ('President', @hrRep)
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
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep

        DECLARE @approver_id INT
        
        IF dbo.Is_On_Leave(@dean_id, @start_date, @end_date) = 1
            SET @approver_id = @vice_dean_id
        ELSE
            SET @approver_id = @dean_id

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@approver_id, @leaveId, 'pending')
    END
END

--M
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

--N
CREATE PROCEDURE Submit_compensation
    @employee_ID INT,
    @compensation_date DATE,
    @reason VARCHAR(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
BEGIN
    IF(
        YEAR(@compensation_date) <> YEAR(@date_of_original_workday)
        OR MONTH(@compensation_date) <> MONTH (@date_of_original_workday)
        OR @reason IS NULL
        OR (dbo.Is_On_Leave(@replacement_emp, @compensation_date, @compensation_date) = 1)
        OR NOT EXISTS (
        SELECT 1 
        FROM Attendance 
        WHERE Emp_ID = @employee_ID 
          AND date = @date_of_original_workday
          AND DATEDIFF(HOUR, start_time, end_time) >= 8
        )
    )
    BEGIN
        RETURN
    END

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


    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @leaveId, 'pending'
        FROM Employee e
        JOIN Employee_Role er ON e.employee_ID = er.emp_ID
        JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = @hrRep

END

--O
CREATE PROCEDURE Dean_andHR_Evaluation
    @employee_ID INT,
    @rating INT,
    @comment VARCHAR(50),
    @semester char(3)
AS
BEGIN
    IF (@rating < 1 OR @rating > 5)
    BEGIN
        RETURN
    END
    INSERT INTO Performance(rating, comments, semester, emp_ID)
    VALUES (@rating, @comment, @semester, @employee_ID)
END
