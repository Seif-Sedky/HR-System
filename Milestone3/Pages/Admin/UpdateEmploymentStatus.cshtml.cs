//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.RazorPages;

//namespace Milestone3.Pages.Admin
//{
//    public class UpdateEmploymentStatusModel : PageModel
//    {
//        public void OnGet()
//        {
//        }
//    }
//}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace Milestone3.Pages.Admin
{
    public class UpdateEmploymentStatusModel : PageModel
    {
        private readonly Database _db;

        public UpdateEmploymentStatusModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        public async Task<IActionResult> OnPostAsync(int employeeId)
        {
            if (employeeId <= 0)
            {
                TempData["Error"] = "Employee ID must be positive.";
                return Page();
            }

            try
            {
                await _db.ExecuteQuery(
                    "EXEC Update_Employment_Status @Employee_ID",
                    new SqlParameter("@Employee_ID", employeeId));

                TempData["Success"] = $"Employee {employeeId} status updated.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }

            return Page();
        }
    }
}
