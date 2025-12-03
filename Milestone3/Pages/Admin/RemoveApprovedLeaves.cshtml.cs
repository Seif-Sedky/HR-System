//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.RazorPages;

//namespace Milestone3.Pages.Admin
//{
//    public class RemoveApprovedLeavesModel : PageModel
//    {
//        public void OnGet()
//        {
//        }
//    }
//}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Data.SqlClient;

namespace Milestone3.Pages.Admin
{
    public class RemoveApprovedLeavesModel : PageModel
    {
        private readonly Database _db;

        public RemoveApprovedLeavesModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        public async Task<IActionResult> OnPostAsync(int employeeId)
        {
            // Check if employeeId is positive AND exists
            var existsDt = await _db.ExecuteQuery(
                "SELECT 1 FROM dbo.Employee WHERE employee_id = @Employee_ID",
                new SqlParameter("@Employee_ID", employeeId)
            );

            if (employeeId <= 0 || existsDt.Rows.Count == 0)
            {
                TempData["Error"] = "Employee ID must be positive and exist in the employees table.";
                return Page();
            }

            try
            {
                await _db.ExecuteQuery(
                    "EXEC Remove_Approved_Leaves @Employee_id",
                    new SqlParameter("@Employee_id", employeeId));

                TempData["Success"] = $"Approved Leaves of Employee {employeeId} removed.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }

            return Page();
        }
    }
}
