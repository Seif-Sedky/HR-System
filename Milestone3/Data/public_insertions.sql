
USE University_HR_ManagementSystem;
go

------
insert into Department (name,building_location)
values ('MET','C building')
insert into Department (name,building_location)
values ('BI','B building')
insert into Department (name,building_location)
values ('HR','N building')
insert into Department (name,building_location)
values ('Medical','B building')

select * from Department
----------------------
insert into Employee (first_name,last_name,email,
password,address,gender,official_day_off,years_of_experience,
national_ID,employment_status, type_of_contract,emergency_contact_name,
emergency_contact_phone,annual_balance,accidental_balance,hire_date,
last_working_date,dept_name)
values  ('Jack','John','jack.john@guc.edu.eg','123','new cairo',
'M','Saturday',0,'1234567890123456','active','full_time',
'Sarah','01234567892',
30,6,'09-01-2025',null,'MET'),

('Ahmed','Zaki','ahmed.zaki@guc.edu.eg','345',
'New Giza',
'M','Saturday',2,'1234567890123457','active','full_time',
'Mona Zaki','01234567893',
27,0,'09-01-2020',NULL,'BI'),

('Sarah','Sabry','sarah.sabry@guc.edu.eg','567',
'Korba',
'F','Thursday',5,'1234567890123458','active','full_time',
'Hanen Turk','01234567894',
0,4,'09-01-2020',NULL,'MET'),

 ('Ahmed','Helmy','ahmed.helmy@guc.edu.eg','908',
'new Cairo',
'M','Thursday',2,'1234567890123459','active','full_time',
'Mona Zaki','01234567895',
8,4,'09-01-2019',NULL,'HR'),

('Menna','Shalaby','menna.shalaby@guc.edu.eg','670',
'Heliopolis',
'F','Saturday',0,'1234567890123451','active','full_time',
'Mayan Samir','01234567896',
6,2,'09-01-2018',NULL,'HR'), 

('Mohamed','Ahmed','mohamed.ahmedy@guc.edu.eg','9087',
'Nasr City',
'M','Saturday',7,'1234567890123452','active','part_time',
'Marwan Samir','01234567897',
NULL,6,'09-01-2025',NULL,'BI'),

('Esraa','Ahmed','esraa.ahmedy@guc.edu.eg','5690',
'New Cairo',
'F','Saturday',2,'1234567890123453','active','full_time',
'Magy Ahmed','01234567898',
36,6,'09-01-2024',NULL,'Medical'),

 ('Magy','Zaki','magy.zaki@guc.edu.eg','3790',
'6th of October city',
'F','Thursday',4,'1234567890123454','onleave','full_time',
'Mariam Ahmed','01234567899',
0,6,'01-01-2023',NULL,'BI'),

('Amr','Diab','amr.diab@guc.edu.eg','8954',
'Heliopolis',
'M','Saturday',4,'1234567890123450','active','full_time',
'Dina','01234567891',
10,10,'09-01-2023',NULL,'MET'),

 ('Marwan','Khaled','marwan.Khaled@guc.edu.eg','9023',
'New Cairo',
'M','Saturday',12,'1234567890123455','active','full_time',
'Omar Ahmed','01234567840',
NULL,NULL,'09-01-2024',NULL,'HR') ,

('Hazem','Ali','hazem.ali@guc.edu.eg','h@123',
'New Giza',
'M','Saturday',30,'1234567890123420','active','full_time',
'Fatma Alaa','01234567871',
55,25,'09-01-2008',NULL,'MET'),

('Hadeel','Adel','hadeel.adel@guc.edu.eg','ha@123',
'Korba',
'F','Saturday',20,'1234567890123220','active','full_time',
'Mariam Alaa','01234567861',
3,12,'09-01-2010',NULL,'MET'),

('Ali','Mohamed','ali.mohamed@guc.edu.eg','am@123',
'New Cairo',
'M','Saturday',35,'1234567890123460','active','full_time',
'Hesham Ali','01234567761',
null,null,'09-01-2002',null,null),

 ('Donia','Tarek','donia.tarek@guc.edu.eg','dt@123',
'New Cairo',
'F','Saturday',22,'1234567891123120','active','full_time',
'Yasmine Tarek','01234267761',
null,null,'09-01-2006',null,null), 

('Karim','Abdelaziz','karim.abdelaziz@guc.edu.eg',
'ka@123','New Cairo','M','Wednesday',4,'1234567890123461','resigned','full_time',
'Maged ElKedwany','01234277761',
0,0,'09-01-2020','09-20-2025','MET'),

('Ghada','Adel','ghada.adel@guc.edu.eg','ga@123',
'Korba',
'F','Saturday',2,'1234567811123120','notice_period','full_time',
'Taha Hussein','01234277761',
0,4,'01-01-2024',NULL,'BI') 




SELECT * FROM Employee
----------------------------
insert into Employee_Phone (emp_id,phone_num) values (1,'01234567890')
insert into Employee_Phone (emp_id,phone_num) values (2,'01234567891')
insert into Employee_Phone (emp_id,phone_num) values (3,'01234567892')
insert into Employee_Phone (emp_id,phone_num) values (4,'01234567893')
insert into Employee_Phone (emp_id,phone_num) values (5,'01234567894')
insert into Employee_Phone (emp_id,phone_num) values (6,'01234567895')
insert into Employee_Phone (emp_id,phone_num) values (7,'01234567896')
insert into Employee_Phone (emp_id,phone_num) values (8,'01234567897')
insert into Employee_Phone (emp_id,phone_num) values (9,'01234567898')
insert into Employee_Phone (emp_id,phone_num) values (10,'01234567899')
insert into Employee_Phone (emp_id,phone_num) values (11,'01234567880')
insert into Employee_Phone (emp_id,phone_num) values (11,'01234567881')
insert into Employee_Phone (emp_id,phone_num) values (12,'01234567882')
insert into Employee_Phone (emp_id,phone_num) values (13,'01234567883')
insert into Employee_Phone (emp_id,phone_num) values (14,'01234567884')
insert into Employee_Phone (emp_id,phone_num) values (15,'01234567885')
insert into Employee_Phone (emp_id,phone_num) values (16,'01234567886')


select * from Employee_Phone
------------------
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('President','Upper Board','Manage University',
1,100000,25.00,25.00,NULL,NULL)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('Vice President','Upper Board','Helps the president.',
2,75000,20.00,20.00,NULL,NULL)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('Dean','PHD Holder','Manage the Academic Department.',
3,60000,18.00,18.00,40,12)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('Vice Dean','PHD Holder','Helps the Dean.',
4,55000,15.00,15.00,35,12)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('HR Manager','Manager','Manage the HR Department.',
3,60000,18.00,18.00,40,12)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('HR_Representative_MET','Representative','Assigned to MET department',
4,50000,15.00,15.00,35,12)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('HR_Representative_BI','Representative','Assigned to BI department',
4,50000,15.00,15.00,35,12)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('Lecturer','PHD Holder','Delivering Academic Courses.',
5,45000,12.00,12.00,30,12)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('Teaching Assistant','Master Holder','Assists the Lecturer.',
6,40000,10.00,10.00,30,6)
insert into role (role_name,title,description,rank,base_salary,
percentage_YOE,percentage_overtime,annual_balance,
accidental_balance)
values ('Medical Doctor','Dr','Diagnosing and managing patients’health conditions',
null,35000,10.00,10.00,30,6)
select * from Role
select * from Department
select * from Employee
--------------------------------
insert into Employee_Role (emp_ID,role_name)
values (1,'Teaching Assistant')
insert into Employee_Role (emp_ID,role_name)
values (2,'Teaching Assistant')
insert into Employee_Role (emp_ID,role_name)
values (3,'Lecturer') 
insert into Employee_Role (emp_ID,role_name)
values (4,'HR_Representative_BI')
insert into Employee_Role (emp_ID,role_name)
values (5,'HR_Representative_MET')
insert into Employee_Role (emp_ID,role_name)
values (6,'Lecturer')
insert into Employee_Role (emp_ID,role_name)
values (7,'Medical Doctor')
insert into Employee_Role (emp_ID,role_name)
values (8,'Teaching Assistant')
insert into Employee_Role (emp_ID,role_name)
values (9,'Teaching Assistant')
insert into Employee_Role (emp_ID,role_name)
values (10,'HR Manager') 
insert into Employee_Role (emp_ID,role_name)
values (11,'Dean')
insert into Employee_Role (emp_ID,role_name)
values (11,'Lecturer')
insert into Employee_Role (emp_ID,role_name)
values (12,'Vice Dean')
insert into Employee_Role (emp_ID,role_name)
values (12,'Lecturer')
insert into Employee_Role (emp_ID,role_name)
values (13,'Dean')
insert into Employee_Role (emp_ID,role_name)
values (13,'Lecturer')
insert into Employee_Role (emp_ID,role_name)
values (14,'Vice Dean')
insert into Employee_Role (emp_ID,role_name)
values (14,'Lecturer') 
insert into Employee_Role (emp_ID,role_name)
values (15,'President')
insert into Employee_Role (emp_ID,role_name)
values (16,'Vice President')

select * from Employee_Role
select * from Employee
---------------------------------------------
insert into Role_existsIn_Department (department_name,Role_name)
values ('BI','Dean')
insert into Role_existsIn_Department (department_name,Role_name)
values ('BI','Vice Dean')
insert into Role_existsIn_Department (department_name,Role_name)
values ('BI','Lecturer')
insert into Role_existsIn_Department (department_name,Role_name)
values ('BI','Teaching Assistant')
insert into Role_existsIn_Department (department_name,Role_name)
values ('MET','Dean')
insert into Role_existsIn_Department (department_name,Role_name)
values ('MET','Vice Dean')
insert into Role_existsIn_Department (department_name,Role_name)
values ('MET','Lecturer')
insert into Role_existsIn_Department (department_name,Role_name)
values ('MET','Teaching Assistant')
insert into Role_existsIn_Department (department_name,Role_name)
values ('HR','HR_Representative_BI')
insert into Role_existsIn_Department (department_name,Role_name)
values ('HR','HR_Representative_MET')
insert into Role_existsIn_Department (department_name,Role_name)
values ('HR','HR Manager')
insert into Role_existsIn_Department (department_name,Role_name)
values ('Medical','Medical Doctor')

select * from Role_existsIn_Department
------------------------------------------------------

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-10-2025','10-26-2025','11-01-2025','approved') 

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('09-15-2025','10-19-2025','10-30-2025','approved') 

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-09-2025','10-28-2025','10-28-2025','PENDING')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-15-2025','10-30-2025','11-01-2025','pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-26-2025','10-28-2025','10-30-2025','pending') 

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-27-2025','10-26-2025','10-26-2025','pending') 

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-27-2025','10-26-2025','10-26-2025','pending') 

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-26-2025','10-22-2025','10-22-2025','pending')


insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-28-2025','10-30-2025','10-30-2025','pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('09-13-2022','11-21-2022','03-21-2023','approved')
insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('01-12-2024','02-13-2024','06-13-2024','approved')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('09-13-2025','11-13-2025','03-13-2026','pending')


insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('07-13-2025','08-13-2025','09-09-2025','approved')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('08-13-2025','11-02-2025','12-13-2025','Pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('11-15-2025','11-27-2025','12-02-2025','Pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-15-2025','11-20-2025','12-02-2025','Pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-05-2025','10-06-2025','10-06-2025','approved') 

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-26-2025','10-29-2025','10-29-2025','pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('10-10-2025','11-03-2025','11-03-2025','pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status) 
values ('10-27-2025','10-30-2025','10-30-2025','pending')

insert into leave (date_of_request,start_date,end_date
,final_approval_status)
values ('09-13-2025','11-13-2025','03-13-2026','rejected')

select * from Leave
----------------------------------------
insert into Annual_Leave (request_ID,emp_ID,replacement_emp)
values (1,8,2)
insert into Annual_Leave (request_ID,emp_ID,replacement_emp)
values (2,12,11)
insert into Annual_Leave (request_ID,emp_ID,replacement_emp)
values (3,3,10)
insert into Annual_Leave (request_ID,emp_ID,replacement_emp)
values (4,11,12)
insert into Annual_Leave (request_ID,emp_ID,replacement_emp)
values (5,5,4)

select * from Annual_Leave
---------------
insert into Accidental_Leave (request_ID,emp_ID) 
values (6,1)
insert into Accidental_Leave (request_ID,emp_ID) 
values (8,3)

select * from Accidental_Leave
------------------
insert into Medical_Leave (request_ID,insurance_status,disability_details,type,Emp_ID)
values (10,1,null,'maternity',3)
insert into Medical_Leave (request_ID,insurance_status,disability_details,type,Emp_ID)
values (11,1,null,'maternity',3)
insert into Medical_Leave (request_ID,insurance_status,disability_details,type,Emp_ID)
values (12,1,null,'maternity',3)

insert into Medical_Leave (request_ID,insurance_status,disability_details,type,Emp_ID)
values (21,1,null,'sick',8)

select * from Medical_Leave
-----------------
insert into Unpaid_Leave (request_id,Emp_ID)
values (13,2)
insert into Unpaid_Leave (request_id,Emp_ID)
values (14,1)
insert into Unpaid_Leave (request_id,Emp_ID)
values (15,2)
insert into Unpaid_Leave (request_id,Emp_ID)
values (16,8)

select * from Unpaid_Leave
-------------------
insert into Compensation_Leave (request_ID,reason, date_of_original_workday,emp_ID,
replacement_emp)
values (18, 'proctoring','10-04-2025',1,9)
insert into Compensation_Leave (request_ID,reason, date_of_original_workday,emp_ID,
replacement_emp)
values (19, 'Grading','09-04-2025',3,1)
select * from Compensation_Leave
-----------------------------------------------
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('contract','Contract of employee','Contract1','09-01-2025','08-31-2026','valid',1,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Memo','memo for unpaid','memo1','08-13-2025','11-01-2025','valid',1,null,14)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract2','09-01-2025','08-31-2026','valid',2,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Memo','memo for unpaid','memo_21','07-13-2025','08-12-2025','expired',2,null,13)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Memo','memo for unpaid','memo_22','11-15-2025','11-26-2025','valid',2,null,15)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract3','09-01-2025','08-31-2026','valid',3,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Medical','Medical Document','Medical_31','09-13-2022','11-20-2022','expired',3,10,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Medical','Medical Document','Medical_32','01-12-2024','02-12-2024','expired',3,11,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Medical','Medical Document','Medical_33','09-13-2025','11-12-2025','valid',3,12,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract4','09-01-2025','08-31-2026','valid',4,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract5','09-01-2025','08-31-2026','valid',5,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract6','09-01-2025','08-31-2026','valid',6,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract7','09-01-2025','08-31-2026','valid',7,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract8','01-01-2025','12-31-2026','valid',8,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Memo','Memo for Unpaid','Memo 8','10-15-2025','11-20-2025','valid',8,null,15)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract9','09-01-2025','08-31-2026','valid',9,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract10','09-01-2025','08-31-2026','valid',10,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract11','09-01-2025','08-31-2026','valid',11,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract12','09-01-2025','08-31-2026','valid',12,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract13','01-01-2025','12-31-2026','valid',13,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract14','09-01-2025','08-31-2026','valid',14,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract15','09-01-2025','08-31-2026','valid',15,null,null)
insert into document  (type,description,file_name,creation_date,expiry_date,status,emp_ID,medical_ID,unpaid_ID)
values ('Contract','Contract of employee','Contract16','09-01-2025','08-31-2026','valid',16,null,null)


select * from Document
----------------------------
insert into Attendance (date,check_in_time,check_out_time,status,emp_ID)
values ('09-04-2025','08:30','17:30','attended',3)
insert into Attendance (date,check_in_time,check_out_time,status,emp_ID)
values ('10-02-2025','08:30','16:30','attended',8)
insert into Attendance (date,check_in_time,check_out_time,status,emp_ID)
values ('10-04-2025','08:30','14:30','attended',1) 
insert into Attendance (date,check_in_time,check_out_time,status,emp_ID)
values ('10-27-2025',null,null,'absent',1)
insert into Attendance (date,check_in_time,check_out_time,status,emp_ID)
values ('09-8-2025',null,null,'absent',1)
insert into Attendance (date,check_in_time,check_out_time,status,emp_ID)
values ('10-15-2025','08:30','16:00','attended',1)

select * from Attendance
-----------------------------------------
insert into Employee_Replace_Employee (Emp1_ID,Emp2_ID,from_date, to_date)
values (8,2,'10-26-2025','11-01-2025')
insert into Employee_Replace_Employee (Emp1_ID,Emp2_ID,from_date, to_date)
values (12,11,'10-19-2025','10-30-2025')


select * from Employee_Replace_Employee
-------------------------------------------
INSERT INTO Performance (rating,comments,semester,emp_ID)
values (4,'Very Good','W24',2)
INSERT INTO Performance (rating,comments,semester,emp_ID)
values (3,'Good','S25',2)
INSERT INTO Performance (rating,comments,semester,emp_ID)
values (4,'Very Good','W24',10)
INSERT INTO Performance (rating,comments,semester,emp_ID)
values (5,'Excellent','S25',10)

select * from Performance
------------------------------------------------
insert into Deduction (emp_ID,date,amount,type,
status,unpaid_ID,attendance_ID)
values (1,'10-01-2025',1333.33,'missing_days','finalized',null,7)

insert into Deduction (emp_ID,date,amount,type,
status,unpaid_ID,attendance_ID)
values (1,'10-28-2025',1333.33,'missing_days','pending',null,5)

insert into Deduction (emp_ID,date,amount,type,
status,unpaid_ID,attendance_ID)
values (2,'09-01-2025',30400,'unpaid','finalized',13,null)

insert into Deduction (emp_ID,date,amount,type,
status,unpaid_ID,attendance_ID)
values (2,'10-01-2025',14400,'unpaid','finalized',13,null)

insert into Deduction (emp_ID,date,amount,type,
status,unpaid_ID,attendance_ID)
values (10,'10-01-2025',3266.66,'missing_hours','finalized',null,null)

select * from Deduction



------------------
insert into Payroll (payment_date,final_salary_amount,from_date,to_date,comments,bonus_amount,deductions_amount,emp_ID)
values ('10-01-2025',38666.67,'09-01-2025','09-30-2025','Has deduction',0,1333.33,1)
insert into Payroll (payment_date,final_salary_amount,from_date,to_date,comments,bonus_amount,deductions_amount,emp_ID)
values ('09-01-2025',17600 ,'08-01-2025','08-31-2025','unpaid Leave',0,30400,2)
insert into Payroll (payment_date,final_salary_amount,from_date,to_date,comments,bonus_amount,deductions_amount,emp_ID)
values ('10-01-2025',33600 ,'09-01-2025','09-30-2025','unpaid Leave',0,14400,2)
insert into Payroll (payment_date,final_salary_amount,from_date,to_date,comments,bonus_amount,deductions_amount,emp_ID)
values ('10-01-2025',52733.34,'09-01-2025','09-30-2025','Missing Hours',0,3266.66,9)
insert into Payroll (payment_date,final_salary_amount,from_date,to_date,comments,bonus_amount,deductions_amount,emp_ID)
values ('04-01-2025',276540,'03-01-2025','03-31-2025','Overtime Factor',540,0,11)


select * from Payroll

-------------------------------- 

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (11,1,'approved') 
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,1,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (15,2,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,2,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (13,3,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,3,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (15,4,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,4,'PENDING') 
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (9,5,'PENDING')

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,6,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,7,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,8,'PENDING')


insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,9,'PENDING')  
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (7,9,'PENDING') 

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,10,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (7,10,'approved')

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,11,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (7,11,'approved')

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,12,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (7,12,'PENDING')


insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (15,13,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (11,13,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,13,'approved')

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (15,14,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (13,14,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,14,'PENDING')


insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (15,15,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (11,15,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,15,'PENDING')

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (15,16,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (11,16,'PENDING')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,16,'PENDING') 

insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (4,17,'approved')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,18,'pending')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,19,'pending')
insert into Employee_Approve_Leave (Emp1_ID,leave_ID,status)
values (5,20,'pending')
------------------------------------------------------


UPDATE Employee 
SET dept_name = 'BI'
WHERE employee_id = 13;

UPDATE Employee 
SET dept_name = 'BI'
WHERE employee_id = 14;

-- Insert a fake deduction for the resigned employee (ID 15)
INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
VALUES (15, GETDATE(), 500.00, 'missing_hours', 'pending', NULL, NULL);

-- Create a dummy "Absent" record for Employee ID 1 for TODAY
INSERT INTO Attendance (date, emp_ID, status) 
VALUES (CAST(GETDATE() AS DATE), 1, 'Absent');

SELECT * FROM Employee e WHERE e.dept_name = 'HR'

SELECT * FROM Employee e WHERE e.employee_id=5

SELECT * FROM Medical_Leave ml INNER JOIN Leave l ON l.request_ID=ml.request_ID
SELECT * FROM Compensation_Leave
SELECT * FROM Leave WHERE Leave.final_approval_status='Pending'

SELECT * FROM Deduction 


SELECT * FROM Employee
select * from Leave INNER JOIN Compensation_Leave ON Leave.request_ID = Compensation_Leave.request_ID
EXEC clearAllTables


-------- DEDUCTION UI TESTING --------------
 
 
-- 2. Setup Departments and Roles
INSERT INTO Department (name, building_location) VALUES 
('CS', 'C3'), 
('HR', 'Admin'), 
('Eng', 'B4');

INSERT INTO Role (role_name, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES 
('Lecturer', 5, 10000, 10, 20, 30, 7),
('HR Manager', 1, 15000, 15, 10, 30, 7);

-- 3. Insert Employees (1 HR Admin + 3 Targets)
-- NOTE: 'salary' column removed because it is a Computed Column in your schema.
-- Added 'type_of_contract', 'annual_balance', and 'accidental_balance' to satisfy constraints and logic.

-- HR Admin (Login with ID: 1, Password: 123)
INSERT INTO Employee (first_name, last_name, password, email, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('Sarah', 'Connor', '123', 'sarah@guc.edu', 'HR', 'active', 5, 'full_time', 30, 7);

-- Target 1: John (Has Missing HOURS)
-- He worked 6 hours instead of 8 yesterday
INSERT INTO Employee (first_name, last_name, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('John', 'Doe', 'CS', 'active', 2, 'full_time', 30, 7);

-- Target 2: Jane (Has Missing DAYS)
-- She was absent yesterday
INSERT INTO Employee (first_name, last_name, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('Jane', 'Smith', 'CS', 'active', 3, 'full_time', 30, 7);

-- Target 3: Mark (Has Unpaid LEAVE)
-- He has an approved unpaid leave for today
INSERT INTO Employee (first_name, last_name, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('Mark', 'Wilson', 'Eng', 'active', 4, 'full_time', 30, 7);

-- 4. Assign Roles (Required for salary calculations in some procs)
INSERT INTO Employee_Role (emp_ID, role_name) SELECT employee_id, 'HR Manager' FROM Employee WHERE dept_name = 'HR';
INSERT INTO Employee_Role (emp_ID, role_name) SELECT employee_id, 'Lecturer' FROM Employee WHERE dept_name <> 'HR';

-- 5. Create Scenarios (The Trigger Data)

-- Scenario A: Missing Hours for John
-- Attended from 9:00 to 15:00 (6 hours) yesterday
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID)
VALUES (DATEADD(day, -1, GETDATE()), '09:00:00', '15:00:00', 'Attended', (SELECT employee_id FROM Employee WHERE first_name = 'John'));

-- Scenario B: Missing Day for Jane
-- Absent yesterday
INSERT INTO Attendance (date, status, emp_ID)
VALUES (DATEADD(day, -1, GETDATE()), 'Absent', (SELECT employee_id FROM Employee WHERE first_name = 'Jane'));

-- Scenario C: Unpaid Leave for Mark
-- 1. Create the Leave Request
-- CHANGED: Start date set to GETDATE() (Today) to ensure it falls in the current month.
-- This fixes the issue where DATEADD(day, -5, GETDATE()) could fall in the previous month.
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
VALUES (GETDATE(), GETDATE(), DATEADD(day, 5, GETDATE()), 'Approved'); 

-- 2. Link it to Unpaid_Leave
INSERT INTO Unpaid_Leave (request_ID, Emp_ID)
VALUES (SCOPE_IDENTITY(), (SELECT employee_id FROM Employee WHERE first_name = 'Mark'));

-- 6. Verification
PRINT 'Data Inserted Successfully.'
SELECT * FROM Employee;





EXEC clearAllTables



---- LEAVES TESTING DATA 


-- 2. Setup Departments & Roles
INSERT INTO Department (name, building_location) VALUES ('CS', 'C3'), ('HR', 'Admin'), ('Eng', 'B4');

INSERT INTO Role (role_name, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES 
('Lecturer', 5, 10000, 10, 20, 30, 7),
('HR Manager', 1, 15000, 15, 10, 30, 7);

-- 3. Insert Employees
-- HR Admin (Sarah)
INSERT INTO Employee (first_name, last_name, password, email, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('Sarah', 'Connor', '123', 'sarah@guc.edu', 'HR', 'active', 5, 'full_time', 30, 7);

-- Employee 1: Alice (CS) - Has sufficient balance
INSERT INTO Employee (first_name, last_name, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('Alice', 'Wonder', 'CS', 'active', 2, 'full_time', 15, 5);

-- Employee 2: Bob (Eng) - Has ZERO balance (Should be Rejected by System)
INSERT INTO Employee (first_name, last_name, dept_name, employment_status, years_of_experience, type_of_contract, annual_balance, accidental_balance) 
VALUES ('Bob', 'Builder', 'Eng', 'active', 5, 'full_time', 0, 0);

-- 4. Insert PENDING Leaves (The Trigger Data)

-- A. Annual Leave (Alice) - Should be APPROVED (Has Balance)
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), DATEADD(day, 1, GETDATE()), DATEADD(day, 3, GETDATE()), 'Pending');
INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) VALUES (SCOPE_IDENTITY(), (SELECT employee_id FROM Employee WHERE first_name='Alice'), (SELECT employee_id FROM Employee WHERE first_name='Sarah'));

-- B. Annual Leave (Bob) - Should be REJECTED (No Balance)
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), DATEADD(day, 5, GETDATE()), DATEADD(day, 6, GETDATE()), 'Pending');
INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) VALUES (SCOPE_IDENTITY(), (SELECT employee_id FROM Employee WHERE first_name='Bob'), (SELECT employee_id FROM Employee WHERE first_name='Sarah'));

-- C. Unpaid Leave (Alice) - Should be APPROVED
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), DATEADD(day, 10, GETDATE()), DATEADD(day, 12, GETDATE()), 'Pending');
INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES (SCOPE_IDENTITY(), (SELECT employee_id FROM Employee WHERE first_name='Alice'));

-- D. Compensation Leave (Bob) - Should be APPROVED (If logic passes)
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), DATEADD(day, 15, GETDATE()), DATEADD(day, 15, GETDATE()), 'Pending');
INSERT INTO Compensation_Leave (request_ID, emp_ID, reason, date_of_original_workday, replacement_emp) 
VALUES (SCOPE_IDENTITY(), (SELECT employee_id FROM Employee WHERE first_name='Bob'), 'Worked on Friday', DATEADD(day, -5, GETDATE()), (SELECT employee_id FROM Employee WHERE first_name='Sarah'));

PRINT 'Pending Data Inserted. You can now test the Review Page.'

SELECT * FROM Annual_Leave INNER JOIN Leave l ON l.request_ID = Annual_Leave.request_ID
SELECT * FROM Employee



------------------- PAYEROLL TESTS ------------------------
EXEC clearAllTables




-- 1. Setup Departments
INSERT INTO Department (name, building_location) VALUES 
('Computer Science', 'Building C4'),
('HR', 'Admin Building');

-- 2. Setup Roles (Crucial for Base Salary Calculation)
-- Rank 1 = High salary, Rank 5 = Lower salary
INSERT INTO Role (role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES 
('Professor', 'Prof.', 'Senior Faculty', 1, 10000.00, 15.00, 20.00, 30, 7),
('Lecturer', 'Dr.', 'Junior Faculty', 3, 5000.00, 10.00, 15.00, 30, 7),
('HR Specialist', 'HR', 'Payroll Admin', 4, 4000.00, 5.00, 10.00, 21, 7);

-- 3. Insert Employees
-- NOTE: 'salary' column is Computed, so we do not insert it.
INSERT INTO Employee (first_name, last_name, email, password, address, gender, official_day_off, years_of_experience, national_ID, employment_status, type_of_contract, annual_balance, accidental_balance, hire_date, dept_name) VALUES 
('Alice', 'Wonder', 'alice@uni.edu', '123', '101 Logic Lane', 'F', 'Saturday', 10, '1111111111111111', 'active', 'full_time', 30, 7, '2015-01-01', 'Computer Science'),
('Bob', 'Builder', 'bob@uni.edu', '123', '202 Tool St', 'M', 'Friday', 2, '2222222222222222', 'active', 'full_time', 30, 7, '2021-06-01', 'Computer Science'),
('Charlie', 'Check', 'charlie@uni.edu', '123', '303 Payroll Pl', 'M', 'Sunday', 5, '3333333333333333', 'active', 'full_time', 25, 5, '2019-03-15', 'HR');

-- 4. Assign Roles (Links Employee to Salary)
INSERT INTO Employee_Role (emp_ID, role_name)
SELECT employee_id, 'Professor' FROM Employee WHERE email = 'alice@uni.edu';

INSERT INTO Employee_Role (emp_ID, role_name)
SELECT employee_id, 'Lecturer' FROM Employee WHERE email = 'bob@uni.edu';

INSERT INTO Employee_Role (emp_ID, role_name)
SELECT employee_id, 'HR Specialist' FROM Employee WHERE email = 'charlie@uni.edu';

-- =============================================
-- SCENARIO SETUP
-- =============================================

-- Scenario A: Alice (High Salary, No Bonus, Small Deduction)
-- ---------------------------------------------------------
DECLARE @AliceID INT = (SELECT employee_id FROM Employee WHERE email = 'alice@uni.edu');

-- Insert a manually calculated deduction (e.g., damaged equipment)
INSERT INTO Deduction (emp_ID, date, amount, type, status) 
VALUES (@AliceID, GETDATE(), 150.00, 'missing_hours', 'pending');


-- Scenario B: Bob (Medium Salary, HUGE Bonus due to Overtime)
-- ---------------------------------------------------------
DECLARE @BobID INT = (SELECT employee_id FROM Employee WHERE email = 'bob@uni.edu');

-- Bob works 10 hours a day for 5 days (2 hours overtime per day = 10 hours total bonus)
-- Note: Logic requires check_in/out to calculate bonus via dbo.Bonus_amount function
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID) VALUES 
(GETDATE(), '08:00:00', '18:00:00', 'Attended', @BobID), -- 2 hrs OT
(DATEADD(day, -1, GETDATE()), '08:00:00', '18:00:00', 'Attended', @BobID), -- 2 hrs OT
(DATEADD(day, -2, GETDATE()), '08:00:00', '18:00:00', 'Attended', @BobID), -- 2 hrs OT
(DATEADD(day, -3, GETDATE()), '08:00:00', '18:00:00', 'Attended', @BobID), -- 2 hrs OT
(DATEADD(day, -4, GETDATE()), '08:00:00', '18:00:00', 'Attended', @BobID); -- 2 hrs OT


-- Scenario C: Charlie (Lower Salary, Significant Deduction for Absence)
-- ---------------------------------------------------------
DECLARE @CharlieID INT = (SELECT employee_id FROM Employee WHERE email = 'charlie@uni.edu');

-- Charlie missed 2 days (deduction logic usually inserts this, but we force it here for preview test)
INSERT INTO Deduction (emp_ID, date, amount, type, status) 
VALUES (@CharlieID, GETDATE(), 500.00, 'missing_days', 'pending');

-- No attendance records for Charlie implies potential absence if run through deduction procedures,
-- but for payroll preview, we just need the deduction record above.

GO

SELECT * FROM Payroll


SELECT * FROM Employee

Select * from leave
select * from compensation_leave

SELECT * FROM Performance
SELECT * FROM Employee_Approve_Leave inner join Unpaid_Leave on Employee_Approve_Leave.leave_ID = Unpaid_Leave.request_ID

SELECT * FROM Employee_Approve_Leave inner join Annual_Leave on Employee_Approve_Leave.leave_ID = Annual_Leave.request_ID

SELECT 
                        l.request_ID,
                        l.date_of_request,
                        l.start_date,
                        l.end_date,
                        l.num_days,
                        l.final_approval_status,
                        e.employee_id,
                        e.first_name,
                        e.last_name,
                        e.dept_name,
                        e.type_of_contract,
                        e.annual_balance,
                        al.replacement_emp,
                        rep.first_name as rep_first_name,
                        rep.last_name as rep_last_name,
                        rep.employment_status as rep_status,
                        rep.dept_name as rep_dept,
                        eal.status as my_approval_status
                    FROM Leave l
                    INNER JOIN Annual_Leave al ON l.request_ID = al.request_ID
                    INNER JOIN Employee e ON al.emp_ID = e.employee_id
                    LEFT JOIN Employee rep ON al.replacement_emp = rep.employee_id
                    INNER JOIN Employee_Approve_Leave eal ON eal.leave_ID = l.request_ID
                    WHERE eal.Emp1_ID = 15

                    ORDER BY l.date_of_request DESC

UPDATE Employee_Approve_Leave SET status = 'pending'