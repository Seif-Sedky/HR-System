USE University_HR_ManagementSystem_6 ;
GO

EXEC createAllTables ;
GO


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


