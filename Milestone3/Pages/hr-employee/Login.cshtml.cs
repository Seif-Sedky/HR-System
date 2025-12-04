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
            ErrorMessage = "";
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid) return Page();

            try
            {
                string query = "SELECT dbo.HRLoginValidation(@id, @pass)";
                SqlParameter[] parameters = {
                    new SqlParameter("@id", EmployeeID),
                    new SqlParameter("@pass", Password)
                };

                DataTable result = await _db.ExecuteQuery(query, parameters);

                if (result.Rows.Count > 0 && result.Rows[0][0] != DBNull.Value)
                {
                    bool isValid = Convert.ToBoolean(result.Rows[0][0]);
                    if (isValid)
                    {
                        // CRITICAL: This line saves the user's ID to memory
                        HttpContext.Session.SetInt32("UserId", EmployeeID);
                        return RedirectToPage("/hr-employee/Dashboard");
                    }
                }

                ErrorMessage = "Invalid Credentials or Access Denied.";
                return Page();
            }
            catch (Exception ex)
            {
                ErrorMessage = "Error: " + ex.Message;
                return Page();
            }
        }
    }
}