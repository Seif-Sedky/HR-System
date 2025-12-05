using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee
{
    public class IndexModel : PageModel
    {
        private readonly Database _db;

        public IndexModel(Database db)
        {
            _db = db;
        }

        public EmployeeInfo CurrentEmployee { get; set; }
        public bool IsUpperboard { get; set; }
        public bool IsDean { get; set; }
        public bool IsHR { get; set; }

        public async Task OnGetAsync()
        {
            await LoadCurrentEmployeeInfo();
        }

        private async Task LoadCurrentEmployeeInfo()
        {
            if (HttpContext.Session.GetInt32("EmpID") == null)
            {
                Response.Redirect("/Employee/Login");
            }
            try
            {
                int? employeeId = HttpContext.Session.GetInt32("EmpID"); // TODO: Replace with logged-in user ID from session

                // Get employee basic info
                var empResult = await _db.ExecuteQuery(@"
                    SELECT e.employee_id, e.first_name, e.last_name, e.email, 
                           e.dept_name, e.employment_status, e.annual_balance, e.accidental_balance,
                           r.role_name, r.title
                    FROM Employee e
                    LEFT JOIN Employee_Role er ON e.employee_id = er.emp_ID
                    LEFT JOIN Role r ON er.role_name = r.role_name
                    WHERE e.employee_id = @empId",
                    new SqlParameter("@empId", employeeId)
                );

                if (empResult.Rows.Count > 0)
                {
                    var row = empResult.Rows[0];
                    CurrentEmployee = new EmployeeInfo
                    {
                        EmployeeId = Convert.ToInt32(row["employee_id"]),
                        FirstName = row["first_name"].ToString(),
                        LastName = row["last_name"].ToString(),
                        Email = row["email"].ToString(),
                        Department = row["dept_name"].ToString(),
                        EmploymentStatus = row["employment_status"].ToString(),
                        AnnualBalance = Convert.ToInt32(row["annual_balance"]),
                        AccidentalBalance = Convert.ToInt32(row["accidental_balance"]),
                        RoleName = row["role_name"] != DBNull.Value ? row["role_name"].ToString() : "Employee",
                        Title = row["title"] != DBNull.Value ? row["title"].ToString() : "Staff"
                    };

                    // Check if user has special roles
                    string role = CurrentEmployee.RoleName.ToLower();
                    IsUpperboard = role.Contains("dean") || role.Contains("president");
                    IsDean = role.Contains("dean");
                    IsHR = role.Contains("hr");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading employee info: {ex.Message}");
            }
        }
    }

    public class EmployeeInfo
    {
        public int EmployeeId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string FullName => $"{FirstName} {LastName}";
        public string Email { get; set; }
        public string Department { get; set; }
        public string EmploymentStatus { get; set; }
        public int AnnualBalance { get; set; }
        public int AccidentalBalance { get; set; }
        public string RoleName { get; set; }
        public string Title { get; set; }
        public string ContractType { get; set; }
    }
}
