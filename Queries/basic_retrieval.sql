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
    COUNT(e.employee_ID) 
FROM Department d
LEFT JOIN Employee e ON e.dept_name = d.name --Uses LEFT JOIN so departments with no employees still appear with 0
GROUP BY d.name;
GO 


CREATE VIEW allPerformance AS
SELECT 
    p.performance_ID,
    p.rating,
    p.comments,
    p.semester,
    e.employee_ID -- Just ID ?
FROM Performance p
JOIN Employee e ON p.emp_ID = e.employee_ID
WHERE p.semester LIKE 'W%';
GO
