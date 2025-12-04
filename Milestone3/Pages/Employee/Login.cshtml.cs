using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Http; // Required for Session
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Employee
{
    public class LoginModel : PageModel
    {
        private readonly Database _db;

        [BindProperty]
        public string Message { get; set; }

        public LoginModel(Database db)
        {
            _db = db;
        }

        public void OnGet()
        {
            // If already logged in, redirect to the Employee Dashboard
            if (HttpContext.Session.GetInt32("EmpID") != null)
            {
                Response.Redirect("/Employee/Index");
            }
        }

        public async Task<IActionResult> OnPostAsync(int employeeId, string password)
        {
            if (employeeId <= 0 || string.IsNullOrEmpty(password))
            {
                Message = "Please enter valid credentials.";
                return Page();
            }

            // 1. Validate Login using the SQL Function
            string query = "SELECT dbo.EmployeeLoginValidation(@id, @pass)";
            SqlParameter[] p = {
                new SqlParameter("@id", employeeId),
                new SqlParameter("@pass", password)
            };

            var dt = await _db.ExecuteQuery(query, p);

            // Check if result is True (1)
            if (dt.Rows.Count > 0 && (dt.Rows[0][0].ToString() == "True" || dt.Rows[0][0].ToString() == "1"))
            {
                // 2. Fetch Name for the Welcome Message
                string nameQuery = "SELECT first_name FROM Employee WHERE employee_id = @id";
                SqlParameter[] p2 = { new SqlParameter("@id", employeeId) };
                var nameDt = await _db.ExecuteQuery(nameQuery, p2);

                string firstName = nameDt.Rows.Count > 0 ? nameDt.Rows[0]["first_name"].ToString() : "Employee";

                // 3. Set Session Variables
                HttpContext.Session.SetInt32("EmpID", employeeId);
                HttpContext.Session.SetString("EmpName", firstName);

                // 4. Redirect to Dashboard
                return RedirectToPage("/Employee/Index");
            }
            else
            {
                Message = "Invalid ID or Password.";
                return Page();
            }
        }
    }
}