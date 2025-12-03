//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.RazorPages;

//namespace Milestone3.Pages.Admin
//{
//    public class ReplaceEmployeeModel : PageModel
//    {
//        public void OnGet()
//        {
//        }
//    }
//}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Admin
{
    public class ReplaceEmployeeModel : PageModel
    {
        private readonly Database _db;

        public ReplaceEmployeeModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        public async Task<IActionResult> OnPostAsync(int emp1Id, int emp2Id, string fromDate, string toDate)
        {
            if (emp1Id <= 0 || emp2Id <= 0)
            {
                TempData["Error"] = "Employee IDs must be positive.";
                return Page();
            }

            try
            {
                DataTable dt = await _db.ExecuteStoredProcedure(
                   "Replace_employee",
                   new SqlParameter("@Emp1_ID", emp1Id),
                   new SqlParameter("@Emp2_ID", emp2Id),
                   new SqlParameter("@from_date", fromDate),
                   new SqlParameter("@to_date", toDate)
                );

                if (dt.Rows.Count > 0)
                {
                    string status = dt.Rows[0]["Status"].ToString();
                    string message = dt.Rows[0]["Message"].ToString();

                    if (status == "SUCCESS")
                        TempData["Success"] = message;
                    else
                        TempData["Error"] = message;
                }
                else
                {
                    TempData["Error"] = "No message returned from SQL.";
                }
                return Page();
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }

            return Page();
        }
    }
}
