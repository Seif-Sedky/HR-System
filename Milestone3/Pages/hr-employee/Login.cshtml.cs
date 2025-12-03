using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;
using System.ComponentModel.DataAnnotations;

namespace Milestone3.Pages.hr_employee
{
    public class LoginModel : PageModel
    {
        private readonly Database _db;

        public LoginModel(Database db)
        {
            _db = db;
        }

        [BindProperty]
        [Required(ErrorMessage = "ID is required")]
        public int EmployeeID { get; set; }

        [BindProperty]
        [Required(ErrorMessage = "Password is required")]
        public string Password { get; set; }

        public string ErrorMessage { get; set; }

        public void OnGet()
        {
            // Clear any existing error messages on load
            ErrorMessage = "";
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            try
            {
                // Prepare query to call the scalar function dbo.HRLoginValidation
                // Note: Functions in SELECT must be called with schema prefix dbo.
                string query = "SELECT dbo.HRLoginValidation(@id, @pass)";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@id", EmployeeID),
                    new SqlParameter("@pass", Password)
                };

                DataTable result = await _db.ExecuteQuery(query, parameters);

                if (result.Rows.Count > 0 && result.Rows[0][0] != DBNull.Value)
                {
                    bool isValid = Convert.ToBoolean(result.Rows[0][0]);

                    if (isValid)
                    {
                        // Login Success
                        // NOTE: In a real app, use HttpContext.Session.SetInt32("UserId", EmployeeID);
                        // For now, we will redirect to the Dashboard.
                        return RedirectToPage("/hr-employee/Dashboard");
                    }
                }

                ErrorMessage = "Invalid ID or Password, or you are not an HR employee.";
                return Page();
            }
            catch (Exception ex)
            {
                ErrorMessage = "Database Error: " + ex.Message;
                return Page();
            }
        }
    }
}