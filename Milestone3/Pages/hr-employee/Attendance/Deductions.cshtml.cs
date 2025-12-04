using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.hr_employee.Attendance
{
    public class DeductionsModel : PageModel
    {
        private readonly Database _db;
        public DeductionsModel(Database db) { _db = db; }

        // --- UI Bindings ---
        [BindProperty]
        public string SelectedType { get; set; } // "Hours", "Days", "Unpaid"

        [BindProperty]
        public string SelectedScope { get; set; } // "Specific", "Department", "All"

        [BindProperty]
        public int? SpecificEmpId { get; set; }

        [BindProperty]
        public string SelectedDept { get; set; }

        public List<SelectListItem> Departments { get; set; } = new();

        // --- Results ---
        public bool RunComplete { get; set; } = false;
        public List<DeductionResult> Results { get; set; } = new();
        public int ProcessedCount { get; set; }
        public int AppliedCount { get; set; }
        public string ErrorMessage { get; set; }

        public class DeductionResult
        {
            public int EmpId { get; set; }
            public string Name { get; set; }
            public string Dept { get; set; }
            public decimal Amount { get; set; }
        }

        public async Task<IActionResult> OnGetAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");
            await LoadDepartments();
            return Page();
        }

        public async Task<IActionResult> OnPostRunAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");
            await LoadDepartments(); // Reload for dropdowns

            // 1. Determine Configuration based on Selection
            string procName = "";
            string dbType = "";
            string spParamName = "@employee_ID";

            switch (SelectedType)
            {
                case "Hours":
                    procName = "Deduction_hours";
                    dbType = "missing_hours";
                    break;
                case "Days":
                    procName = "Deduction_days";
                    dbType = "missing_days";
                    spParamName = "@employee_id"; // Backend inconsistency handled
                    break;
                case "Unpaid":
                    procName = "Deduction_unpaid";
                    dbType = "unpaid";
                    break;
                default:
                    ErrorMessage = "Please select a valid Deduction Type.";
                    return Page();
            }

            // 2. Fetch Target Employees
            DataTable employees = new DataTable();
            try
            {
                string query = "";
                SqlParameter[] p = null;

                if (SelectedScope == "Specific")
                {
                    if (SpecificEmpId == null || SpecificEmpId <= 0) { ErrorMessage = "Invalid Employee ID"; return Page(); }
                    query = "SELECT employee_id, first_name, last_name, dept_name FROM Employee WHERE employee_id = @id AND employment_status = 'active'";
                    p = new SqlParameter[] { new SqlParameter("@id", SpecificEmpId) };
                }
                else if (SelectedScope == "Department")
                {
                    if (string.IsNullOrEmpty(SelectedDept)) { ErrorMessage = "Please select a department"; return Page(); }
                    query = "SELECT employee_id, first_name, last_name, dept_name FROM Employee WHERE dept_name = @d AND employment_status = 'active'";
                    p = new SqlParameter[] { new SqlParameter("@d", SelectedDept) };
                }
                else // All
                {
                    query = "SELECT employee_id, first_name, last_name, dept_name FROM Employee WHERE employment_status = 'active'";
                }

                employees = await _db.ExecuteQuery(query, p);
            }
            catch (Exception ex) { ErrorMessage = "Error fetching employees: " + ex.Message; return Page(); }

            if (employees.Rows.Count == 0)
            {
                ErrorMessage = "No active employees found matching your criteria.";
                return Page();
            }

            // 3. Process Logic (Check -> Act -> Verify)
            ProcessedCount = employees.Rows.Count;
            Results = new List<DeductionResult>();

            foreach (DataRow emp in employees.Rows)
            {
                int empId = Convert.ToInt32(emp["employee_id"]);
                string empName = $"{emp["first_name"]} {emp["last_name"]}";
                string empDept = emp["dept_name"].ToString();

                try
                {
                    // A. Check count BEFORE
                    string countQuery = "SELECT COUNT(*) FROM Deduction WHERE emp_ID = @id AND type = @t AND CAST(date AS DATE) = CAST(GETDATE() AS DATE)";
                    DataTable dtBefore = await _db.ExecuteQuery(countQuery,
                        new SqlParameter("@id", empId),
                        new SqlParameter("@t", dbType));
                    int before = Convert.ToInt32(dtBefore.Rows[0][0]);

                    // B. Run Procedure
                    await _db.ExecuteStoredProcedure(procName, new SqlParameter(spParamName, empId));

                    // C. Check count AFTER
                    DataTable dtAfter = await _db.ExecuteQuery(countQuery,
                        new SqlParameter("@id", empId),
                        new SqlParameter("@t", dbType));
                    int after = Convert.ToInt32(dtAfter.Rows[0][0]);

                    // D. If Increased, add to list
                    if (after > before)
                    {
                        // Optional: Get the amount just inserted
                        string amountQuery = "SELECT TOP 1 amount FROM Deduction WHERE emp_ID = @id AND type = @t ORDER BY deduction_ID DESC";
                        DataTable dtAmount = await _db.ExecuteQuery(amountQuery,
                            new SqlParameter("@id", empId),
                            new SqlParameter("@t", dbType));
                        decimal amt = dtAmount.Rows.Count > 0 ? Convert.ToDecimal(dtAmount.Rows[0][0]) : 0;

                        Results.Add(new DeductionResult
                        {
                            EmpId = empId,
                            Name = empName,
                            Dept = empDept,
                            Amount = amt
                        });
                    }
                }
                catch
                {
                    // If an individual fails, we continue the loop (robustness)
                }
            }

            AppliedCount = Results.Count;
            RunComplete = true;
            return Page();
        }

        private async Task LoadDepartments()
        {
            Departments = new List<SelectListItem>();
            try
            {
                DataTable dt = await _db.ExecuteQuery("SELECT name FROM Department");
                foreach (DataRow row in dt.Rows)
                {
                    Departments.Add(new SelectListItem(row["name"].ToString(), row["name"].ToString()));
                }
            }
            catch { }
        }
    }
}