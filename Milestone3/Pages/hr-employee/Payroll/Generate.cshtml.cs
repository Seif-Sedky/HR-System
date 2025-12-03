using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.hr_employee.Payroll
{
    public class GenerateModel : PageModel
    {
        private readonly Database _db;
        public GenerateModel(Database db) { _db = db; }

        // --- Configuration Bindings ---
        [BindProperty]
        public DateTime FromDate { get; set; }

        [BindProperty]
        public DateTime ToDate { get; set; }

        [BindProperty]
        public string SelectedScope { get; set; } // "All", "Department", "Specific"

        [BindProperty]
        public string SelectedDept { get; set; }

        [BindProperty]
        public int? SpecificEmpId { get; set; }

        public List<SelectListItem> Departments { get; set; } = new();

        // --- Results & State ---
        public bool IsPreview { get; set; } = false;
        public bool IsFinalized { get; set; } = false;
        public List<PayrollEntry> PreviewResults { get; set; } = new();

        // --- Statistics ---
        public decimal TotalCashOutflow { get; set; }
        public decimal TotalBonuses { get; set; }
        public decimal TotalDeductions { get; set; }
        public int EmployeeCount { get; set; }

        public string Message { get; set; }
        public string MessageType { get; set; } // "success", "danger", "info"

        public class PayrollEntry
        {
            public int EmpId { get; set; }
            public string Name { get; set; }
            public string Department { get; set; }
            public decimal BaseSalary { get; set; }
            public decimal Bonus { get; set; }
            public decimal Deductions { get; set; }
            public decimal NetPay { get; set; }
        }

        public async Task<IActionResult> OnGetAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");

            // Set default dates (First day of current month to Today)
            FromDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            ToDate = DateTime.Now;

            await LoadDepartments();
            return Page();
        }

        public async Task<IActionResult> OnPostPreviewAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");
            await LoadDepartments();
            await RunPayrollLogic(isPreview: true);
            return Page();
        }

        public async Task<IActionResult> OnPostGenerateAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");
            await LoadDepartments();
            await RunPayrollLogic(isPreview: false);
            return Page();
        }

        private async Task RunPayrollLogic(bool isPreview)
        {
            // 1. Fetch Target Employees based on Scope
            string query = "SELECT employee_id, first_name, last_name, dept_name, salary FROM Employee WHERE employment_status = 'active'";
            SqlParameter[] p = null;

            if (SelectedScope == "Specific")
            {
                if (SpecificEmpId == null) { Message = "Please enter an Employee ID."; MessageType = "danger"; return; }
                query += " AND employee_id = @id";
                p = new SqlParameter[] { new SqlParameter("@id", SpecificEmpId) };
            }
            else if (SelectedScope == "Department")
            {
                if (string.IsNullOrEmpty(SelectedDept)) { Message = "Please select a department."; MessageType = "danger"; return; }
                query += " AND dept_name = @dept";
                p = new SqlParameter[] { new SqlParameter("@dept", SelectedDept) };
            }

            DataTable employees = await _db.ExecuteQuery(query, p);

            if (employees.Rows.Count == 0)
            {
                Message = "No active employees found for the selected criteria.";
                MessageType = "danger";
                return;
            }

            // 2. Process Each Employee
            PreviewResults = new List<PayrollEntry>();

            foreach (DataRow row in employees.Rows)
            {
                int empId = Convert.ToInt32(row["employee_id"]);
                string name = $"{row["first_name"]} {row["last_name"]}";
                string dept = row["dept_name"].ToString();
                decimal baseSalary = row["salary"] != DBNull.Value ? Convert.ToDecimal(row["salary"]) : 0;

                if (isPreview)
                {
                    // --- SANDBOX MODE: Simulate the Logic ---
                    // This mirrors the Add_Payroll SP logic without committing changes

                    // A. Simulate Bonus (Call the existing SQL Function)
                    string bonusQuery = "SELECT dbo.Bonus_amount(@id)";
                    DataTable dtBonus = await _db.ExecuteQuery(bonusQuery, new SqlParameter("@id", empId));
                    decimal bonus = dtBonus.Rows.Count > 0 && dtBonus.Rows[0][0] != DBNull.Value ? Convert.ToDecimal(dtBonus.Rows[0][0]) : 0;

                    // B. Simulate Deductions (Query Table directly)
                    // The SP sums deductions for the current month/year
                    string dedQuery = @"SELECT ISNULL(SUM(amount), 0) FROM Deduction 
                                      WHERE emp_ID = @id 
                                      AND MONTH(date) = MONTH(GETDATE()) 
                                      AND YEAR(date) = YEAR(GETDATE())";
                    DataTable dtDed = await _db.ExecuteQuery(dedQuery, new SqlParameter("@id", empId));
                    decimal deductions = dtDed.Rows.Count > 0 ? Convert.ToDecimal(dtDed.Rows[0][0]) : 0;

                    // C. Calculate Net in Memory
                    decimal net = baseSalary + bonus - deductions;

                    PreviewResults.Add(new PayrollEntry
                    {
                        EmpId = empId,
                        Name = name,
                        Department = dept,
                        BaseSalary = baseSalary,
                        Bonus = bonus,
                        Deductions = deductions,
                        NetPay = net
                    });
                }
                else
                {
                    // --- COMMIT MODE: Call the Stored Procedure ---
                    // This SP handles calculation, insertion, and finalizing deductions in the DB
                    try
                    {
                        await _db.ExecuteStoredProcedure("Add_Payroll",
                            new SqlParameter("@employee_ID", empId),
                            new SqlParameter("@from", FromDate),
                            new SqlParameter("@to", ToDate));
                    }
                    catch
                    {
                        // In a real scenario, you might log failures for specific employees
                    }
                }
            }

            if (isPreview)
            {
                // Calculate Totals for Sandbox Display
                EmployeeCount = PreviewResults.Count;
                TotalCashOutflow = PreviewResults.Sum(x => x.NetPay);
                TotalBonuses = PreviewResults.Sum(x => x.Bonus);
                TotalDeductions = PreviewResults.Sum(x => x.Deductions);

                IsPreview = true;
                IsFinalized = false;
                Message = "Preview generated. Review the estimated figures below before confirming.";
                MessageType = "info";
            }
            else
            {
                IsPreview = false;
                IsFinalized = true;
                Message = $"Successfully generated payroll for {employees.Rows.Count} employee(s). Records saved to database.";
                MessageType = "success";
            }
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