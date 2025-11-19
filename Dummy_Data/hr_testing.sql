/********************************************************************************
-- Milestone 2: Section 2.4 SQL Test Suite (Option A)
-- Usage:
-- 1) Run in a test database that has your Milestone-2 schema (tables + procs + functions).
-- 2) After verifying outputs, change the ROLLBACK at the end to COMMIT if you want to persist.
-- 3) If any object/column names differ slightly, adapt the script to your schema.
********************************************************************************/

SET NOCOUNT ON;
BEGIN TRANSACTION;

--------------------------------------------------------------------------------
-- Helper: clear any previous test rows (safe for a test DB). Comment out if not desired.
--------------------------------------------------------------------------------
-- WARNING: these deletes are intended for test data only. Make sure you run in a test DB.
DELETE FROM Employee_Approve_Leave; 
DELETE FROM Employee_Replace_Employee;
DELETE FROM Payroll;
DELETE FROM Deduction;
DELETE FROM Attendance;
DELETE FROM Document;
DELETE FROM Compensation_Leave;
DELETE FROM Unpaid_Leave;
DELETE FROM Annual_Leave;
DELETE FROM Accidental_Leave;
DELETE FROM Medical_Leave;
DELETE FROM [Leave];          -- table named Leave in schema
DELETE FROM Employee_Role;
DELETE FROM Role;
DELETE FROM Employee_Phone;
DELETE FROM Employee;
DELETE FROM Department;
DELETE FROM Performance;

Go
--------------------------------------------------------------------------------
-- 1) Populate Departments
--------------------------------------------------------------------------------
INSERT INTO Department (name, building_location)
VALUES ('MET','B1'), ('IET','B2'), ('HR','HR_Building'), ('Medical','Med_Building'), ('UpperBoard','UB_Building');

--------------------------------------------------------------------------------
-- 2) Populate Roles
-- fields: role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance
--------------------------------------------------------------------------------
INSERT INTO Role (role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance)
VALUES
('President','President','Head',1,20000.00,2.00,20.00,30,1),
('Vice_President','Vice President','Deputy',2,15000.00,1.75,15.00,25,1),
('Dean_MET','Dean MET','Dean',3,12000.00,1.5,12.00,20,1),
('HR_Manager','HR Manager','HR Manager',3,10000.00,1.2,10.00,20,1),
('HR_Representative_MET','HR Rep MET','HR Rep',4,7000.00,1.0,8.00,15,1),
('Lecturer_MET','Lecturer MET','Lecturer',5,6000.00,1.0,6.00,10,1),
('TA_MET','TA MET','TA',6,2000.00,0.5,4.00,5,1)

--------------------------------------------------------------------------------
-- 3) Populate Employees
-- Using identity_insert to control employee_IDs for referential tests
--------------------------------------------------------------------------------
SET IDENTITY_INSERT Employee ON;

INSERT INTO Employee (employee_ID, first_name, last_name, email, password, address, gender, official_day_off, years_of_experience, national_ID, employment_status, type_of_contract, emergency_contact_name, emergency_contact_phone, annual_balance, accidental_balance, salary, hire_date, last_working_date, dept_name)
VALUES
(1001,'Alice','HR','alice.hr@guc.edu','passHR1','Addr1','F','Friday',10,'1234567890123456','active','full_time','E1','01000000000',20,1,10000.00,'2020-01-01',NULL,'HR'), -- HR Manager
(1002,'Bob','Rep','bob.rep@guc.edu','passHR2','Addr2','M','Friday',6,'1234567890123457','active','full_time','E2','01000000001',15,1,7000.00,'2021-01-01',NULL,'HR'), -- HR Representative
(2001,'Carol','Dean','carol@guc.edu','passDean','Addr3','F','Saturday',12,'1234567890123458','active','full_time','E3','01000000002',20,1,12000.00,'2018-09-01',NULL,'MET'), -- Dean
(3001,'Dave','Lect','dave@guc.edu','passLect','Addr4','M','Saturday',4,'1234567890123459','active','full_time','E4','01000000003',10,1,6000.00,'2022-02-01',NULL,'MET'),
(4001,'Eve','TA','eve@guc.edu','passTA','Addr5','F','Saturday',1,'1234567890123460','active','part_time','E5','01000000004',5,1,2000.00,'2024-06-01',NULL,'MET'),
(5001,'Frank','HRLeave','frank@guc.edu','passFR','Addr6','M','Friday',8,'1234567890123461','active','full_time','E6','01000000005',5,1,7000.00,'2022-03-01',NULL,'HR') -- employee to apply leaves
;

SET IDENTITY_INSERT Employee OFF;

--------------------------------------------------------------------------------
-- 4) Employee_Role assignments
--------------------------------------------------------------------------------
INSERT INTO Employee_Role (emp_ID, role_name) VALUES
(1001,'HR_Manager'),
(1002,'HR_Representative_MET'),
(2001,'Dean_MET'),
(3001,'Lecturer_MET'),
(4001,'TA_MET'),
(5001,'Lecturer_MET') -- frank holds lecturer role but belongs to HR dept (edge case for replacement checks)
;

--------------------------------------------------------------------------------
-- 5) Phones (optional)
--------------------------------------------------------------------------------
INSERT INTO Employee_Phone (emp_ID, phone_num) VALUES
(1001,'01111111111'),(1002,'01111111112'),(2001,'01111111113'),(3001,'01111111114'),(4001,'01111111115'),(5001,'01111111116');

--------------------------------------------------------------------------------
-- 6) Create some attendance rows for employee 3001 (Dave) to test missing hours / overtime / compensation
-- Attendance fields: attendance_ID, date, check_in_time, check_out_time, total_duration, status, emp_ID
-- We will set specific IDs via IDENTITY_INSERT
--------------------------------------------------------------------------------
SET IDENTITY_INSERT Attendance ON;

INSERT INTO Attendance (attendance_ID, date, check_in_time, check_out_time, status, emp_ID)
VALUES
(9000, '2025-11-01', '09:00', '10:00',  'attended', 3001), -- normal 
(9001, '2025-11-01', '09:00', '17:00',  'attended', 3001), -- normal 8h
(9002, '2025-11-02', '09:00', '16:00',  'attended', 3001), -- 7h -> missing hours
(9003, '2025-11-03', NULL, NULL, 'Absent', 3001), -- full day absent
(9004, '2025-11-04', '08:00', '19:00', 'attended', 3001)  -- overtime 3h
;

SET IDENTITY_INSERT Attendance OFF;

--------------------------------------------------------------------------------
-- 7) Create leaves to be approved / tested
-- Table: Leave (request_ID identity), Annual_Leave, Accidental_Leave, Unpaid_Leave, Compensation_Leave, Medical_Leave
--------------------------------------------------------------------------------
SET IDENTITY_INSERT [Leave] ON;

INSERT INTO [Leave] (request_ID, date_of_request, start_date, end_date, final_approval_status)
VALUES
(9001, '2025-10-01','2025-11-10','2025-11-15', 'pending'), -- annual leave (6 days)
(9002, '2025-11-15','2025-11-19','2025-11-19', 'pending'), -- accidental leave 1 day
(9003, '2025-11-05','2025-11-25','2025-12-05', 'pending'), -- unpaid spanning two months (11 days)
(9004, '2025-11-10','2025-11-09','2025-11-09', 'pending'), -- compensation leave (single day)
(9005, '2025-11-18','2025-11-18','2025-11-18', 'pending')  -- accidental late
;


SET IDENTITY_INSERT [Leave] OFF;

-- link leaves to specific types
INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) VALUES (9001, 5001, 3001);
INSERT INTO Accidental_Leave (request_ID, emp_ID) VALUES (9002, 5001);
INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES (9003, 5001);
INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, emp_ID, replacement_emp) VALUES (9004, 'Worked during day-off','2025-11-09',5001,3001);
-- For accidental late (9005) created too
INSERT INTO Accidental_Leave (request_ID, emp_ID) VALUES (9005, 4001); -- TA attempting accidental leave (part-time)

--------------------------------------------------------------------------------
-- 8) Documents: add memo for unpaid (9003) and missing memo case for negative test
-- Document fields: document_ID, type, description, file_name, creation_date, expiry_date, status, emp_ID, medical_ID, unpaid_ID
--------------------------------------------------------------------------------
SET IDENTITY_INSERT Document ON;

INSERT INTO Document (document_ID, type, description, file_name, creation_date, expiry_date, status, emp_ID, medical_ID, unpaid_ID)
VALUES
(7001,'memo','unpaid memo','memo9003.pdf','2025-11-05',NULL,'valid',5001,NULL,9003), -- valid memo for unpaid leave
(7002,'memo','missing memo','memo_miss.pdf','2025-11-06',NULL,'valid',4001,NULL,NULL)
;

SET IDENTITY_INSERT Document OFF;

--------------------------------------------------------------------------------
-- 9) Configure Employee_Approve_Leave rows for approval sequence (basic)
-- Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES
(2001,9001,'pending'), -- Dean must approve annual 9001
(1002,9001,'pending'), -- HR rep must approve annual 9001
(2001,9003,'pending'), -- upperboard for unpaid
(1002,9003,'pending')  -- HR rep for unpaid
;


--------------------------------------------------------------------------------
/********************************************************************************
-- START TESTS FOR 2.4.a -> 2.4.i
-- Each test prints result and expected outcome in comments
********************************************************************************/

--------------------------------------------------------------------------------
-- 2.4.a HRLoginValidation function tests
--------------------------------------------------------------------------------
PRINT '--- 2.4.a HRLoginValidation Tests ---';

-- Test A1: valid HR Manager credentials (1001)
SELECT dbo.HRLoginValidation(1001, 'passHR1') AS Result_HRManager; -- Expected: 1

-- Test A2: valid HR Representative (1002)
SELECT dbo.HRLoginValidation(1002, 'passHR2') AS Result_HRRep; -- Expected: 1

-- Test A3: non-HR user tries to login as HR (3001 Lecturer)
SELECT dbo.HRLoginValidation(3001, 'passLect') AS Result_NonHR; -- Expected: 0

-- Test A4: wrong password
SELECT dbo.HRLoginValidation(1002, 'wrong') AS Result_WrongPass; -- Expected: 0

-- Test A5: non-existing employee
SELECT dbo.HRLoginValidation(9999, 'nope') AS Result_NoUser; -- Expected: 0

--------------------------------------------------------------------------------
-- 2.4.b HR_approval_an_acc (annual/accidental)
-- We will attempt to approve annual leave 9001 (emp 5001) by HR rep 1002
--------------------------------------------------------------------------------
PRINT '--- 2.4.b HR_approval_an_acc Tests ---';

-- Pre-check: employee 5001 annual_balance is 5 (from insertion); required days for 9001 = computed earlier (6 days)
SELECT employee_ID, annual_balance FROM Employee WHERE employee_ID = 5001; -- Expected: annual_balance = 5 (insufficient for 6-day leave)

-- Test B1: HR tries to approve annual 9001 (should reject because insufficient balance or replacement conditions)
EXEC dbo.HR_approval_an_acc @request_ID = 9001, @HR_ID = 1002;

-- Check leave final status
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9001; -- Expected: 'rejected' (because insufficient annual_balance)

-- Now set employee 5001 annual_balance to 10 and try approving again using Dean pre-approved path emulation
UPDATE Employee SET annual_balance = 20 WHERE employee_ID = 5001;
-- Mark Dean approval as approved to simulate prior approvals
UPDATE Employee_Approve_Leave SET status = 'approved' WHERE Leave_ID = 9001 AND Emp1_ID = 2001;
-- Reset HR approval entry to pending (if exists) or insert
UPDATE Employee_Approve_Leave SET status = 'pending' WHERE Leave_ID = 9001 AND Emp1_ID = 1002;

-- Test B2: HR approves now (should succeed)
EXEC dbo.HR_approval_an_acc @request_ID = 9001, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9001; -- Expected: 'approved'

-- Accidental leave tests
-- Test B3: Accidental leave 9002 for emp 5001 (should be approved if within 48 hours)
-- Ensure request date is recent relative to start_date per spec (we set earlier so assume OK)
EXEC dbo.HR_approval_an_acc @request_ID = 9002, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9002; -- Expected: 'approved' (if accidental_balance sufficient)

-- Test B4: Accidental leave by part-time TA (9005, emp 4001) -> should be rejected (part-time not eligible)
EXEC dbo.HR_approval_an_acc @request_ID = 9005, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9005; -- Expected: 'rejected'

--------------------------------------------------------------------------------
-- 2.4.c HR_approval_unpaid
-- Test unpaid leave 9003 (emp 5001), has memo document 7001 linked -> should be approvable if annual_balance==0
--------------------------------------------------------------------------------
PRINT '--- 2.4.c HR_approval_unpaid Tests ---';

-- Reset employee annual balance to 0 to meet unpaid eligibility
UPDATE Employee SET annual_balance = 0 WHERE employee_ID = 5001;
SELECT employee_ID, annual_balance FROM Employee WHERE employee_ID = 5001; -- Expected: 0

-- Test C1: HR tries to approve unpaid 9003
EXEC dbo.HR_approval_unpaid @request_ID = 9003, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9003; -- Expected: 'approved' (memo exists & within limits)

-- Test C2: Unapproved unpaid if memo missing
-- Create unpaid leave 9010 with no memo
SET IDENTITY_INSERT [Leave] ON;
INSERT INTO [Leave] (request_ID, date_of_request, start_date, end_date, final_approval_status)
VALUES (9010,'2025-11-20','2025-12-01','2025-12-10','pending');
SET IDENTITY_INSERT [Leave] OFF;
INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES (9010, 3001); -- emp 3001 has >0 annual_balance
INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (2001,9010,'pending'),(1002,9010,'pending');

EXEC dbo.HR_approval_unpaid @request_ID = 9010, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9010; -- Expected: 'rejected' because memo missing or annual_balance > 0

--------------------------------------------------------------------------------
-- 2.4.d HR_approval_comp (compensation leave)
-- We set compensation leave 9004 (emp 5001) with original workday 2025-11-09 and replacement 3001
--------------------------------------------------------------------------------
PRINT '--- 2.4.d HR_approval_comp Tests ---';

-- Pre-check: verify employee 5001 worked >=8h on original_workday (we provided no attendance for 5001 on 2025-11-09, so we will insert one)
SET IDENTITY_INSERT Attendance ON;
INSERT INTO Attendance (attendance_ID, date, check_in_time, check_out_time, status, emp_ID)
VALUES (8010,'2025-11-09','09:00','18:00','attended',5001); -- 9h (>=8)
SET IDENTITY_INSERT Attendance OFF;

-- Test D1: HR approves compensation leave 9004
EXEC dbo.HR_approval_comp @request_ID = 9004, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9004; -- Expected: 'approved'


-- Test D2: compensation where employee did NOT work 8h -> rejection
-- Create compensation request 9020 with no qualifying attendance
SET IDENTITY_INSERT [Leave] ON;
INSERT INTO [Leave] (request_ID, date_of_request, start_date, end_date, final_approval_status)
VALUES (9020,'2025-11-20','2025-11-25','2025-11-25','pending');
SET IDENTITY_INSERT [Leave] OFF;
INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, emp_ID, replacement_emp) VALUES (9020,'NoWork','2025-11-01',3001,5001);
INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (1002,9020,'pending');
EXEC dbo.HR_approval_comp @request_ID = 9020, @HR_ID = 1002;
SELECT request_ID, final_approval_status FROM [Leave] WHERE request_ID = 9020; -- Expected: 'rejected'

--------------------------------------------------------------------------------
-- 2.4.e Deduction_hours
-- For employee 3001 we created attendance 8002 with 7 hours (missing hours) -> test Deduction_hours
--------------------------------------------------------------------------------
PRINT '--- 2.4.e Deduction_hours Tests ---';

-- Ensure no deduction exists yet for that attendance
SELECT * FROM Deduction WHERE attendance_ID = 8002; -- Expected: none

-- Test E1: Add deduction for missing hours (emp 3001)
EXEC dbo.Deduction_hours @employee_ID = 3001;
-- Check Deduction table for a row referencing attendance 8002
SELECT deduction_ID, emp_ID, date, amount, type, attendance_ID, status FROM Deduction WHERE emp_ID = 3001; 
-- Expected: one new deduction row referencing attendance_ID 8002; amount based on rate-per-hour formula

-- Test E2: Calling Deduction_hours again should not duplicate for same month-first-record or should create next missing attendance if exists (depends on impl). Check duplicates:
SELECT COUNT(*) AS Count_Deductions_3001 FROM Deduction WHERE emp_ID = 3001 AND attendance_ID = 8002; -- Expected: 1 (no duplicate)


    
--------------------------------------------------------------------------------
-- 2.4.f Deduction_days
-- Employee 3001 had attendance 8003 = Absent -> should create a missing-day deduction
--------------------------------------------------------------------------------
PRINT '--- 2.4.f Deduction_days Tests ---';

-- Remove any previous deductions for that attendance date to ensure fresh test (only in test DB)
DELETE FROM Deduction WHERE emp_ID = 3001 AND attendance_ID = 8003;

-- Test F1: Add deduction for missing day (emp 3001)
EXEC dbo.Deduction_days @employee_ID = 3001;

-- Verify deduction exists for attendance 8003 or for that date
SELECT deduction_ID, emp_ID, date, amount, type, attendance_ID, status FROM Deduction WHERE emp_ID = 3001 AND (attendance_ID = 8003 OR date = '2025-10-03');
-- Expected: deduction(s) created for full-day absence

--------------------------------------------------------------------------------
-- 2.4.g Deduction_unpaid
-- For unpaid leave 9003 spanning Nov->Dec, we expect two deductions (one per month)
--------------------------------------------------------------------------------
PRINT '--- 2.4.g Deduction_unpaid Tests ---';

-- Remove existing deductions for unpaid 9003 if any
DELETE FROM Deduction WHERE unpaid_ID = 9003;

-- Test G1: Add unpaid deductions for emp 5001
EXEC dbo.Deduction_unpaid @employee_ID = 5001;

-- Verify deductions for unpaid_ID 9003 created and split per month
SELECT deduction_ID, emp_ID, amount, date, type, unpaid_ID FROM Deduction WHERE unpaid_ID = 9003 ORDER BY date;
-- Expected: two deductions (one for Nov 2025 period, one for Dec 2025 period) with type = 'unpaid' and correct amounts

--------------------------------------------------------------------------------
-- 2.4.h Bonus_amount function tests
-- Use employee 3001 who has an attendance with 3 hours overtime on 2025-10-04 (attendance 8004)
--------------------------------------------------------------------------------
PRINT '--- 2.4.h Bonus_amount Tests ---';

-- Test H1: Get bonus for emp 3001
SELECT dbo.Bonus_amount(3001) AS Bonus3001; -- Expected: >0 based on overtime factor and extra_hours

-- Test H2: Employee with no overtime returns 0 (employee 1002 HR rep)
SELECT dbo.Bonus_amount(1002) AS Bonus1002; -- Expected: 0

-- Test H3: Employee with multiple roles uses higher-rank overtime factor
-- Assign an extra high-role to 3001 (simulate multi-role)

-- INSERT INTO Employee_Role (emp_ID, role_name) VALUES (3001,'Dean_MET'); -- now 3001 also has rank 3 role

-- Recalculate bonus (should use highest rank role's overtime factor)
SELECT dbo.Bonus_amount(3001) AS Bonus3001_afterRoleChange; -- Expected: new value >= previous or consistent with higher role factor

    SELECT (ISNULL(SUM(total_duration),0) / 60.0 - 8 * COUNT(*)) -- to be full time each day is 8 hours
    FROM Attendance
    WHERE emp_ID = 300
      AND MONTH(date) = MONTH(GETDATE())
      AND YEAR(date) = YEAR(GETDATE())
SELECT * FROM Attendance

--------------------------------------------------------------------------------
-- 2.4.i Add_Payroll tests
-- Generate payroll for employee 3001 and 5001 for given period
--------------------------------------------------------------------------------
PRINT '--- 2.4.i Add_Payroll Tests ---';

-- Ensure no payroll for period exists
DELETE FROM Payroll WHERE emp_ID IN (3001,5001) AND from_date = '2025-10-01' AND to_date = '2025-10-31';

-- Test I1: Add payroll for emp 3001 for October 2025
EXEC dbo.Add_Payroll @employee_ID = 3001, @from_date = '2025-10-01', @to_date = '2025-10-31';

-- Check inserted payroll row and verify computed final_salary_amount, bonus, deductions
SELECT ID, emp_ID, payment_date, from_date, to_date, final_salary_amount, bonus_amount, deductions_amount, comments FROM Payroll WHERE emp_ID = 3001 AND from_date = '2025-10-01' AND to_date = '2025-10-31';
-- Expected: final_salary_amount = computed salary +/- deduction + bonus; bonus_amount equals dbo.Bonus_amount(3001)

-- Test I2: Add payroll for employee with unpaid deductions (emp 5001) for November 2025
DELETE FROM Payroll WHERE emp_ID = 5001 AND from_date = '2025-11-01' AND to_date = '2025-11-30';
EXEC dbo.Add_Payroll @employee_ID = 5001, @from_date = '2025-11-01', @to_date = '2025-11-30';
SELECT ID, emp_ID, payment_date, from_date, to_date, final_salary_amount, bonus_amount, deductions_amount FROM Payroll WHERE emp_ID = 5001 AND from_date = '2025-11-01' AND to_date = '2025-11-30';
-- Expected: deductions_amount reflects unpaid days created earlier by Deduction_unpaid; bonus may be 0

--------------------------------------------------------------------------------
-- Simple validation queries to help you verify critical relationships
--------------------------------------------------------------------------------
PRINT '--- QUICK VALIDATIONS ---';

-- Validate Deduction entries that reference attendance rows
SELECT d.deduction_ID, d.emp_ID, d.type, d.attendance_ID, a.total_duration, a.date
FROM Deduction d LEFT JOIN Attendance a ON d.attendance_ID = a.attendance_ID
ORDER BY d.deduction_ID;

-- Validate Leaves statuses
SELECT request_ID, start_date, end_date, num_days, final_approval_status FROM [Leave] ORDER BY request_ID;

-- Validate Payroll summary
SELECT emp_ID, COUNT(*) AS Payroll_Count, SUM(final_salary_amount) AS TotalPaid FROM Payroll GROUP BY emp_ID;

--------------------------------------------------------------------------------
-- End of tests. If you want to persist test data, COMMIT. Otherwise ROLLBACK to remove test rows.
--------------------------------------------------------------------------------

-- To keep test data, uncomment the following:
--COMMIT TRANSACTION;

-- To discard test data (recommended after verification), uncomment the following:
ROLLBACK TRANSACTION;

PRINT 'Test script finished. Check the SELECT outputs above and compare with the Expected comments.';
