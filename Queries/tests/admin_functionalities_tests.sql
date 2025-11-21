-------------------------------------------------------------
-- FULL CLEAN START
-------------------------------------------------------------
EXEC dropAllTables;
EXEC createAllTables;
-------------------------------------------------------------


-------------------------------------------------------------
-- INSERT BASE STRUCTURE (DEPT - ROLE - EMPLOYEE)
-------------------------------------------------------------
INSERT INTO Department VALUES
('MET','A'),('HR','C'),('IET','B');

INSERT INTO Role(role_name,title,description,rank,base_salary,percentage_YOE,percentage_overtime,annual_balance,accidental_balance)
VALUES
('Lecturer','Lecturer','L',5,15000,5,10,20,10),
('HR_Representative_HR','HR Rep','H',4,12000,5,10,0,0),
('TA','TA','T',6,5000,5,10,20,10);


INSERT INTO Employee(first_name,last_name,email,password,address,gender,
official_day_off,years_of_experience,national_ID,employment_status,type_of_contract,
emergency_contact_name,emergency_contact_phone,annual_balance,accidental_balance,salary,
hire_date,last_working_date,dept_name)
VALUES
('Ali','A','a','1','x','M','Friday',3,'1234567890123456','active','full_time','X','01234567890',20,10,0,'2024-01-01',NULL,'MET'),
('Omar','B','b','1','x','M','Friday',5,'1234567890123457','resigned','full_time','X','01234567891',20,10,0,'2024-01-01','2024-10-01','MET'),
('Sara','C','c','1','x','F','Saturday',2,'1234567890123458','active','full_time','X','01234567892',20,10,0,'2024-01-01',NULL,'HR'),
('Mona','D','d','1','x','F','Sunday',1,'1234567890123459','active','full_time','X','01234567893',20,10,0,'2024-01-01',NULL,'IET');


INSERT INTO Employee_Role VALUES
(1,'Lecturer'),
(2,'Lecturer'),
(3,'HR_Representative_HR'),
(4,'TA');


-------------------------------------------------------------
-- DOCUMENTS FOR Update_Status_Doc TEST
-------------------------------------------------------------
INSERT INTO Document(type,description,file_name,creation_date,expiry_date,status,emp_ID)
VALUES
('contract','old','c1.pdf','2024-01-01','2024-01-01','valid',1),
('id','ok','n1.pdf','2024-01-01','2030-01-01','valid',2),
('medical','exp','m1.pdf','2024-01-01','2024-01-01','expired',3),
('contract','today','now.pdf','2024-01-01',CAST(GETDATE() AS DATE),'valid',4);


-------------------------------------------------------------
-- DEDUCTIONS FOR Remove_Deductions TEST
-------------------------------------------------------------
INSERT INTO Deduction(emp_ID,date,amount,type,status)
VALUES
(1,'2024-11-01',200,'missing_days','pending'),
(2,'2024-11-01',500,'unpaid','pending'),
(2,'2024-11-05',150,'missing_hours','finalized');


-------------------------------------------------------------
-- LEAVE FOR Update_Employment_Status
-------------------------------------------------------------
INSERT INTO Leave(date_of_request,start_date,end_date,final_approval_status)
VALUES(GETDATE(),GETDATE(),GETDATE(),'approved');

INSERT INTO Employee_Approve_Leave VALUES(1,1,'approved');

INSERT INTO Annual_Leave(request_ID,emp_ID,replacement_emp)
VALUES(1,1,3);


-------------------------------------------------------------
-- HOLIDAY FOR Remove_Holiday
-------------------------------------------------------------
INSERT INTO Holiday(name,from_date,to_date)
VALUES('TestHoliday','2024-11-20','2024-11-21');


-------------------------------------------------------------
-- ATTENDANCE FOR ALL TEST CASES
-- NO DUPLICATES, NO TODAY ROWS YET
-------------------------------------------------------------
INSERT INTO Attendance(emp_ID,date,check_in_time,check_out_time,status)
VALUES
(1,'2024-11-20',NULL,NULL,'absent'),
(1,'2024-11-21',NULL,NULL,'absent'),
(1,'2024-11-22',NULL,NULL,'absent'),
(1,'2024-11-01',NULL,NULL,'absent'),
(1,'2024-11-08',NULL,NULL,'absent'),
(1,'2024-11-05',NULL,NULL,'absent'),


(3,'2024-11-21',NULL,NULL,'absent'),
(4,'2024-11-21',NULL,NULL,'absent');

INSERT INTO Attendance(emp_ID,date,check_in_time,check_out_time,status)
VALUES (1,'2025-11-14',NULL,NULL,'absent');

-------------------------------------------------------------
-- RUN REQUIRED PROCEDURES IN ORDER
-------------------------------------------------------------

PRINT '---- RUN Update_Status_Doc ----';
EXEC Update_Status_Doc;
SELECT * FROM Document;

PRINT '---- RUN Remove_Deductions ----';
EXEC Remove_Deductions;
SELECT * FROM Deduction;
/*
NOT DONE YES I DON'T HAVE IS ON_LEAVE
PRINT '---- RUN Update_Employment_Status ----';
EXEC Update_Employment_Status 1;
EXEC Update_Employment_Status 3;
SELECT employee_ID,employment_status FROM Employee;
*/
PRINT '---- RUN Intitiate_Attendance ----';
EXEC Intitiate_Attendance;
SELECT * FROM Attendance WHERE date = CAST(GETDATE() AS DATE);

PRINT '---- RUN Update_Attendance ----';
EXEC Update_Attendance 1,'09:00','17:00';
SELECT * FROM Attendance WHERE emp_ID=1 AND date = CAST(GETDATE() AS DATE);

PRINT '---- RUN Remove_Holiday ----';
EXEC Remove_Holiday;
SELECT * FROM Attendance;

PRINT '---- RUN Remove_DayOff ----';
EXEC Remove_DayOff 1;
SELECT * FROM Attendance WHERE emp_ID=1;

PRINT '---- RUN Remove_Approved_Leaves ----';
EXEC Remove_Approved_Leaves 1;
SELECT * FROM Attendance WHERE emp_ID=1;

PRINT '---- RUN Replace_employee ----';
EXEC Replace_employee 1,3,'2024-11-25','2024-11-27';
SELECT * FROM Employee_Replace_Employee;
