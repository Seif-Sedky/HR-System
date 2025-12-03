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
                await _db.ExecuteQuery(
                    "EXEC Replace_employee @Emp1_ID, @Emp2_ID, @from_date, @to_date",
                    new SqlParameter("@Emp1_ID", emp1Id),
                    new SqlParameter("@Emp2_ID", emp2Id),
                    new SqlParameter("@from_date", fromDate),
                    new SqlParameter("@to_date", toDate));

                TempData["Success"] = "Employee replacement completed.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }

            return Page();
        }
    }
}
