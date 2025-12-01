# Quick Start Guide - Employee Portal

## ?? Getting Started in 3 Steps

### Step 1: Verify Your Setup ?

Make sure you have:
- SQL Server running
- Database created using `Data/final_implementation.sql`
- Connection string configured in `appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=University_HR_ManagementSystem;Trusted_Connection=True;TrustServerCertificate=True"
  }
}
```

### Step 2: Run the Application ??

```bash
dotnet run
```

Or press **F5** in Visual Studio.

### Step 3: Navigate to Employee Portal ??

Open your browser and go to:
```
http://localhost:PORT/Employee2/Index
```

---

## ?? Quick Access URLs

Copy and paste these URLs directly:

### Dashboard
```
/Employee2/Index
```

### Leave Applications
```
/Employee2/ApplyAccidental           # Accidental Leave
/Employee2/Leaves/ApplyMedical       # Medical Leave
/Employee2/Leaves/ApplyUnpaid        # Unpaid Leave
/Employee2/Leaves/ApplyCompensation  # Compensation Leave
```

### Approvals (Dean/President)
```
/Employee2/Approvals/ApproveAnnualLeaves   # Annual Leaves
/Employee2/Approvals/ApproveUnpaidLeaves   # Unpaid Leaves
```

### Evaluation (Dean)
```
/Employee2/Evaluation/EvaluateEmployees
```

---

## ?? Quick Test Scenarios

### Test 1: Apply for Accidental Leave
1. Go to `/Employee2/ApplyAccidental`
2. Select today's date for Start Date
3. Select today's date for End Date
4. Click "Submit Accidental Leave"
5. ? Should see success message

### Test 2: Apply for Medical Leave
1. Go to `/Employee2/Leaves/ApplyMedical`
2. Fill in dates
3. Select "sick" or "maternity"
4. Check insurance if applicable
5. Fill in document details
6. Click "Submit Medical Leave"
7. ? Should see success message

### Test 3: Approve Leaves (as Dean/President)
1. First apply for a leave (using test above)
2. Go to `/Employee2/Approvals/ApproveUnpaidLeaves` or `ApproveAnnualLeaves`
3. You should see your request in a card
4. Click "Approve" or "Reject"
5. ? Status should update

### Test 4: Evaluate Employee (as Dean)
1. Go to `/Employee2/Evaluation/EvaluateEmployees`
2. You should see a list of employees
3. Click "Evaluate" on any employee
4. Fill in:
   - Semester (e.g., W24)
   - Rating (1-5)
   - Comment (optional)
5. Click "Submit Evaluation"
6. ? Should see success message

---

## ?? Common First-Time Issues

### Issue: "Database connection failed"
**Fix:**
1. Make sure SQL Server is running
2. Update connection string in `appsettings.json`
3. Verify database name matches: `University_HR_ManagementSystem`

### Issue: "Stored procedure not found"
**Fix:**
1. Run `Data/final_implementation.sql` in SQL Server
2. Verify all stored procedures are created:
   ```sql
   SELECT name FROM sys.procedures WHERE name LIKE 'Submit%'
   ```

### Issue: "Page not found (404)"
**Fix:**
1. Make sure you're using correct URLs (see list above)
2. Verify all .cshtml files are in Pages/Employee2/ directory
3. Try rebuilding: `dotnet build`

### Issue: "Bootstrap Icons not showing"
**Fix:**
1. Check internet connection (icons loaded from CDN)
2. Verify this line in `_Layout.cshtml`:
   ```html
   <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" />
   ```

---

## ?? Testing Data

### Sample Employee IDs for Testing
The code currently uses `employeeId = 1` for testing. You can:
1. Insert test employees using SQL
2. Modify the hardcoded ID to match your test employee
3. Implement session management (see TODO comments)

### Sample Test Data SQL
```sql
-- Insert test employee
INSERT INTO Employee (first_name, last_name, email, password, address, gender, 
                     official_day_off, years_of_experience, national_ID, 
                     employment_status, type_of_contract, emergency_contact_name, 
                     emergency_contact_phone, annual_balance, accidental_balance, 
                     hire_date, dept_name)
VALUES ('Test', 'Employee', 'test@guc.edu.eg', 'test123', 'Cairo', 
        'M', 'Friday', 5, '1234567890123456', 'active', 'full_time', 
        'Emergency Contact', '01234567890', 21, 7, '2020-01-01', 'MET');

-- Get the employee ID
SELECT employee_id, first_name, last_name FROM Employee WHERE email = 'test@guc.edu.eg';
```

---

## ?? UI Overview

### Dashboard Features
- **Welcome Card:** Shows your name and role
- **Balance Cards:** Annual and Accidental leave balances
- **Leave Application Cards:** 4 cards for different leave types
- **Approval Section:** Only visible to Dean/President
- **Evaluation Section:** Only visible to Dean

### Leave Application Forms
- Clean, card-based design
- Color-coded by leave type
- Required fields marked with *
- Help text and validation
- Success/error messages

### Approval Pages
- Card layout for each request
- Validation checklist with color coding
- Employee details clearly displayed
- One-click approve/reject buttons

### Evaluation Page
- Two-column layout
- Employee list on left
- Evaluation form on right
- Rating system with labels (1-5)
- Previous evaluation history shown

---

## ?? Where to Find Things

### Source Code
```
Pages/
??? Employee2/
    ??? Index.cshtml                    # Dashboard
    ??? ApplyAccidental.cshtml          # Accidental leave
    ??? Leaves/
    ?   ??? ApplyMedical.cshtml
    ?   ??? ApplyUnpaid.cshtml
    ?   ??? ApplyCompensation.cshtml
    ??? Approvals/
    ?   ??? ApproveAnnualLeaves.cshtml
    ?   ??? ApproveUnpaidLeaves.cshtml
    ??? Evaluation/
        ??? EvaluateEmployees.cshtml
```

### Documentation
```
Pages/Employee2/README.md           # Detailed documentation
IMPLEMENTATION_SUMMARY.md           # Implementation summary
QUICK_START.md                      # This file
```

### Database
```
Data/
??? final_implementation.sql        # All stored procedures
??? Database.cs                     # Database helper class
```

---

## ?? Pro Tips

1. **Use the Navigation Menu:** Click "Employee Portal" in the navbar for quick access to all features

2. **Check Success Messages:** Always look for the green/red alert at the top of the page after submitting

3. **Validation Checklists:** On approval pages, use the color-coded checklist to quickly see if a request meets requirements

4. **Dashboard First:** Always start at `/Employee2/Index` to get an overview of your balances and available features

5. **Role-Based Access:** Some features only show if you have the right role (Dean, President, etc.)

---

## ?? Feature Hierarchy

```
All Employees
??? Apply Accidental Leave
??? Apply Medical Leave
??? Apply Unpaid Leave
??? Apply Compensation Leave

Dean / Vice-Dean / President
??? (All above features)
??? Approve Annual Leaves
??? Approve Unpaid Leaves

Dean Only
??? (All above features)
??? Evaluate Employees
```

---

## ?? Need Help?

1. **Check the README:** `Pages/Employee2/README.md` has detailed information
2. **Check SQL:** Verify stored procedures exist and work
3. **Check Console:** Look at browser console (F12) for JavaScript errors
4. **Check Logs:** Look at Visual Studio output window for server errors
5. **Check Database:** Query the database directly to see if data is being saved

---

## ? Verification Checklist

Before reporting issues, verify:

- [ ] SQL Server is running
- [ ] Database exists and has all stored procedures
- [ ] Connection string is correct
- [ ] Application builds successfully (`dotnet build`)
- [ ] Application runs without errors (`dotnet run`)
- [ ] Can access the dashboard (`/Employee2/Index`)
- [ ] Bootstrap icons are showing (check internet connection)

---

## ?? You're Ready!

Everything is set up and ready to use. Start by visiting:

**http://localhost:YOUR_PORT/Employee2/Index**

Enjoy using the Employee Portal! ??

---

**Last Updated:** January 2025  
**Version:** 1.0
