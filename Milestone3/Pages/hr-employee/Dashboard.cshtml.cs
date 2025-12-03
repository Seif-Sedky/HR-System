using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;

namespace Milestone3.Pages.hr_employee
{
    public class DashboardModel : PageModel
    {
        private readonly Database _db;

        public DashboardModel(Database db)
        {
            _db = db;
        }

        public int EmployeeCount { get; set; }
        public int PendingLeavesCount { get; set; }
        public int PendingDeductionsCount { get; set; }

        public async Task<IActionResult> OnGetAsync()
        {
            // CRITICAL CHECK: If session is empty, go to Login
            if (HttpContext.Session.GetInt32("UserId") == null)
            {
                return RedirectToPage("/hr-employee/Login");
            }

            try
            {
                // 1. Get Total Active Employees
                DataTable dtEmp = await _db.ExecuteQuery("SELECT COUNT(*) FROM Employee WHERE employment_status = 'active'");
                if (dtEmp.Rows.Count > 0)
                    EmployeeCount = Convert.ToInt32(dtEmp.Rows[0][0]);

                // 2. Get Pending Leaves
                DataTable dtLeaves = await _db.ExecuteQuery("SELECT COUNT(*) FROM Leave WHERE final_approval_status = 'Pending'");
                if (dtLeaves.Rows.Count > 0)
                    PendingLeavesCount = Convert.ToInt32(dtLeaves.Rows[0][0]);

                // 3. Get Pending Deductions
                DataTable dtDed = await _db.ExecuteQuery("SELECT COUNT(*) FROM Deduction WHERE status = 'pending'");
                if (dtDed.Rows.Count > 0)
                    PendingDeductionsCount = Convert.ToInt32(dtDed.Rows[0][0]);
            }
            catch (Exception)
            {
                EmployeeCount = 0;
                PendingLeavesCount = 0;
                PendingDeductionsCount = 0;
            }

            return Page();
        }
    }
}