using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
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

        public string FirstName { get; set; }
        public string TimeGreeting { get; set; }
        public string GreetingSubtitle { get; set; } // New Property

        public async Task<IActionResult> OnGetAsync()
        {
            int? userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToPage("/hr-employee/Login");
            }

            try
            {
                // 0. Set Greeting Logic
                int currentHour = DateTime.Now.Hour;
                if (currentHour < 12) TimeGreeting = "Good Morning";
                else if (currentHour < 18) TimeGreeting = "Good Afternoon";
                else TimeGreeting = "Good Evening";

                // Random Subtitle Logic
                string[] subtitles = new string[]
                {
                    "Let’s hope today doesn’t require a full table scan.",
                    "May your coffee be strong and your inbox be kind.",
                    "The Guardian of Payroll and Protector of Peace has logged in!",
                    "Your daily quest: keeping the workplace sane."
                };
                Random rnd = new Random();
                GreetingSubtitle = subtitles[rnd.Next(subtitles.Length)];

                // 1. Fetch Employee Name
                DataTable dtName = await _db.ExecuteQuery("SELECT first_name FROM Employee WHERE employee_id = @id", new SqlParameter("@id", userId));
                if (dtName.Rows.Count > 0)
                {
                    FirstName = dtName.Rows[0]["first_name"].ToString();
                }
                else
                {
                    FirstName = "HR Admin";
                }

                // 2. Get Total Active Employees
                DataTable dtEmp = await _db.ExecuteQuery("SELECT COUNT(*) FROM Employee WHERE employment_status = 'active'");
                if (dtEmp.Rows.Count > 0)
                    EmployeeCount = Convert.ToInt32(dtEmp.Rows[0][0]);

                // 3. Get Pending Leaves
                DataTable dtLeaves = await _db.ExecuteQuery("SELECT COUNT(*) FROM Leave WHERE final_approval_status = 'Pending'");
                if (dtLeaves.Rows.Count > 0)
                    PendingLeavesCount = Convert.ToInt32(dtLeaves.Rows[0][0]);

                // 4. Get Pending Deductions
                DataTable dtDed = await _db.ExecuteQuery("SELECT COUNT(*) FROM Deduction WHERE status = 'pending'");
                if (dtDed.Rows.Count > 0)
                    PendingDeductionsCount = Convert.ToInt32(dtDed.Rows[0][0]);
            }
            catch (Exception)
            {
                EmployeeCount = 0;
                PendingLeavesCount = 0;
                PendingDeductionsCount = 0;
                FirstName = "User";
                GreetingSubtitle = "Welcome to the system.";
            }

            return Page();
        }
    }
}