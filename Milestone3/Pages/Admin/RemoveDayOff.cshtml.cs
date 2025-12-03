//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.RazorPages;

//namespace Milestone3.Pages.Admin
//{
//    public class RemoveDayOffModel : PageModel
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
    public class RemoveDayOffModel : PageModel
    {
        private readonly Database _db;

        public RemoveDayOffModel(IConfiguration config)
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
                var dt = await _db.ExecuteQuery(
                    "EXEC Remove_DayOff @Employee_ID",
                    new SqlParameter("@Employee_ID", employeeId)
                );

                if (dt.Rows.Count > 0)
                {
                    string message = dt.Rows[0]["Message"].ToString();
                    string status = dt.Rows[0]["Status"].ToString();

                    if (status == "ERROR")
                        TempData["Error"] = message;
                    else
                        TempData["Success"] = message;
                }
                else
                {
                    TempData["Error"] = "No message returned from SQL.";
                }
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }

            return Page();
        }
    }
}
