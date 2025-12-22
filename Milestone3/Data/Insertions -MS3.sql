USE University_HR_ManagementSystem;


INSERT INTO Department (name, building_location) VALUES
('MET', 'C Building'),
('BI', 'B Building'),
('HR', 'N Building'),
('Medical', 'B Building');
GO



INSERT INTO Role (role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES
('President', 'Upper board', 'manages the university', 1, 100000, 25.00, 25.00, NULL, NULL),
('Vice President', 'Upper board', 'helps the president', 2, 75000, 20.00, 20.00, NULL, NULL),
('Dean', 'Phd holder', 'manages an academic department', 3, 60000, 18.00, 18.00, 40, 12),
('Vice Dean', 'Phd holder', 'helps the dean', 4, 55000, 15.00, 15.00, 35, 12),
('HR Manager', 'Manager', 'manages the HR', 3, 60000, 18.00, 18.00, NULL, NULL),
('HR_Representative_MET', 'Representative', 'assigned to MET academic department', 4, 50000, 15.00, 15.00, 35, 12),
('HR_Representative_BI', 'Representative', 'assigned to BI academic department', 4, 50000, 15.00, 15.00, 35, 12),
('Lecturer', 'Phd Holder', 'delivering academic courses', 5, 45000, 12.00, 12.00, 30, 12),
('Teaching Assistant', 'Master Holder', 'assists the lecturer', 6, 40000, 10.00, 10.00, 30, 6),
('Medical Doctor', 'Doctor', 'diagnoses and treats patients', NULL, 35000, 10.00, 10.00, 30, 6);
GO


INSERT INTO Role_existsIn_Department (department_name, Role_name) VALUES
('MET', 'Dean'),
('MET', 'Vice Dean'),
('MET', 'Lecturer'),
('MET', 'Teaching Assistant'),
('BI', 'Lecturer'),
('BI', 'Teaching Assistant'),
('HR', 'HR Manager'),
('HR', 'HR_Representative_MET'),
('HR', 'HR_Representative_BI'),
('Medical', 'Medical Doctor');
go



--------- 🔴⚠️ You must change the day off of the emp_1 to be any other day rather than Current day ⚠️🔴

INSERT INTO Employee (first_name, last_name, email, password, address, gender, official_day_off, years_of_experience, national_ID, 
employment_status, type_of_contract, emergency_contact_name, emergency_contact_phone, annual_balance, accidental_balance, hire_date, last_working_date, dept_name) VALUES
('Ahmed', 'Ali', 'ahmedali@gmail.com', '123', 'New Cairo', 'M', 'Thursday', 3, '1234567890123456', 'active', 'full_time', 'Mohamed', '01010005002', 24, 6, '2022-09-01', NULL, 'MET'),
('Omar', 'Mohamed', 'omarMoh@gmail.com', 'password1', 'Heliopolis', 'M', 'Saturday', 5, '1224567890123456', 'active', 'full_time', 'Ahmed', '01010005003', 30, 6, '2020-09-01', NULL, 'BI'),
('Alaa', 'Abdellatif', 'alaa@gmail.com', 'pass_1544', 'Mohandseen', 'F', 'Thursday', 3, '1034427970103259', 'resigned', 'full_time', 'Malak', '01550023004', 0, 0, '2023-09-01', '2025-08-30', 'BI'),
('Ghada', 'Mohamed', 'ghadaMoh@gmail.com', 'password12', 'Nasr City', 'F', 'Saturday', 1, '1224567890123457', 'active', 'full_time', 'Ali', '01010005004', 25, 0, '2024-09-01', NULL, 'HR'), --> hr met
('Hazem', 'Ismail', 'hazemismail@gmail.com', 'password121', 'New Giza', 'M', 'Thursday', 20, '1134467870123459', 'active', 'full_time', 'Yomna', '01110123004', 40, 5, '2005-09-01', NULL, 'MET'),
('Mariam', 'Eissa', 'mariameissa@gmail.com', 'pass1234', 'New Cairo', 'F', 'Thursday', 3, '1234567860123459', 'active', 'full_time', 'Ahmed', '01210126004', 20, 6, '2022-09-01', NULL, 'MET'),--> another ta
('Hazem', 'Ismail', 'hazemismail@gmail.com', 'password121', 'New Giza', 'M', 'Thursday', 20, '1134467870123459', 'active', 'full_time', 'Yomna', '01110123004', 40, 5, '2005-09-01', NULL, 'MET'),-- Dean MET
('Fatma', 'Alaa', 'fatmaalaa@gmail.com', 'pass1223', 'Madinty', 'F', 'Saturday', 10, '1134447870123459', 'active', 'full_time', 'Habiba', '01150123004', 35, 12, '2015-09-01', NULL, 'MET'),-- Vice Dean MET
('Alaa', 'Walieldeen', 'alaawalieldeen@gmail.com', 'pass_1233', 'Heliopolis', 'M', 'Saturday', 30, '1134427970123459', 'active', 'full_time', 'Mohamed', '01570123004', NULL, NULL, '2002-09-01', NULL, NULL),-- President
('Donia', 'Tarek', 'donia@gmail.com', 'pass1233', 'New Cairo', 'F', 'Saturday', 15, '1134427870123459', 'active', 'full_time', 'Yasmine', '01170123004', NULL, NULL, '2010-09-01', NULL, NULL),-- vice president
('Sherif', 'Ahmed', 'sherifahmed@gmail.com', 'pass12', 'New Cairo', 'M', 'Saturday', 3, '1234567870123459', 'active', 'full_time', 'Salma', '01210125004', 30, 6, '2022-09-01', NULL, 'Medical');--Medical Doctor
go


INSERT INTO Employee_Role (emp_ID, role_name) VALUES
(1, 'Teaching Assistant'),
(2, 'Lecturer'),
(3, 'Lecturer'),
(4, 'HR_Representative_MET'),
(5,'Teaching Assistant'),
(6,'Teaching Assistant'),-- should be a TA
(7,'Dean'), 
(8,'Vice Dean'),
(9,'President'),
(10,'Vice President'),
(11,'Medical Doctor')
go


INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES
('2025-06-08', '2025-06-11', '2025-06-13', 'Rejected') ----------> rejected medical
go

INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID) VALUES
(1,1,'details', 'sick', 1) ---------> rejected medical
go

INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID) VALUES
(3, '2025-08-25', 1733, 'missing_days', 'finalized', NULL, NULL); ------------> deduction to be removed by the admin for the resigned employee 3
go

select * from Deduction

DECLARE @Yesterday DATETIME = DATEADD(DAY, -1, GETDATE())
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID) VALUES
(@Yesterday, '08:30:00', '16:00:00', 'Attended', 1) ---------> insert attendance for yesterday
go


INSERT INTO Performance (rating, comments, semester, emp_ID) VALUES
(4, 'Very Good', 'W24', 2),
(5, 'Excellent', 'W23', 1);
go

---------------- insert a holiday for yesterday
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Holiday')
BEGIN
    EXEC dbo.Create_Holiday
END

DECLARE @Yesterday DATETIME = DATEADD(DAY, -1, GETDATE())
exec Add_Holiday 'Holiday', @Yesterday, @Yesterday

go


----------- insert dayoff attendance record for emp 1
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID) VALUES
('12/25/2025', NULL, NULL, 'Absent', 1)
go 


---------------- insert an approved leave and attendance record in the same period of that leave
DECLARE @Yesterday DATETIME = DATEADD(DAY, -1, GETDATE())
declare @afterTwoDays DATETIME = DATEADD(DAY, 2, GETDATE())
declare @dayBeforeYesterday DATETIME = DATEADD(DAY, -2, GETDATE())
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES
(@dayBeforeYesterday, @Yesterday, @afterTwoDays, 'Approved')

INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES
(2, 2);


INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID) VALUES
(@Yesterday, NULL, NULL, 'Absent', 2)
go


--------------- insert a payroll for last month for emp 1
INSERT INTO Payroll (payment_date, final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount, emp_ID) VALUES
(DATEADD(MONTH, -1, GETDATE()), 38666.7, '2025-09-01', '2025-09-30', 'Has deduction', 0.00, 1333.33, 1);


-------------- insert a deduction caused by attendance unpaid
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID) VALUES
('11/1/2025', NULL, NULL, 'Absent', 1)

INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID) VALUES
(1, '11/1/2025', 1733, 'missing_days', 'pending', NULL, 4);



SELECT * FROM Employee

