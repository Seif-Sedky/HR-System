using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace Milestone3.Pages.Admin
{
    public class AdminDashboardModel : PageModel
    {
        private readonly Database _db;

        public AdminDashboardModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        // === Button Handlers ===

        public async Task<IActionResult> OnPostRemoveHolidayAsync()
        {
            await _db.ExecuteQuery("EXEC Remove_Holiday");
            TempData["Message"] = "Holiday attendance removed.";
            return RedirectToPage();
        }



        public async Task<IActionResult> OnPostRemoveDayOffAsync(int employeeId)
        {
            await _db.ExecuteQuery("EXEC Remove_DayOff @Employee_id",
                new SqlParameter("@Employee_id", employeeId));
            TempData["Message"] = $"Dayoff removed for Employee {employeeId}.";
            return RedirectToPage();
        }

        public async Task<IActionResult> OnPostRemoveApprovedLeavesAsync(int employeeId)
        {
            await _db.ExecuteQuery("EXEC Remove_Approved_Leaves @Employee_id",
                new SqlParameter("@Employee_id", employeeId));
            TempData["Message"] = $"Approved leaves removed for Employee {employeeId}.";
            return RedirectToPage();
        }

        public async Task<IActionResult> OnPostReplaceEmployeeAsync(int emp1Id, int emp2Id, string fromDate, string toDate)
        {
            await _db.ExecuteQuery("EXEC Replace_employee @Emp1_ID, @Emp2_ID, @from_date, @to_date",
                new SqlParameter("@Emp1_ID", emp1Id),
                new SqlParameter("@Emp2_ID", emp2Id),
                new SqlParameter("@from_date", fromDate),
                new SqlParameter("@to_date", toDate));
            TempData["Message"] = $"Employee {emp1Id} replaced with {emp2Id}.";
            return RedirectToPage();
        }
        public async Task<IActionResult> OnPostUpdateEmploymentStatusAsync(int employeeId)
        {
            await _db.ExecuteQuery("EXEC Update_Employment_Status @Employee_ID",
                new SqlParameter("@Employee_ID", employeeId));
            TempData["Message"] = $"Employment status updated for Employee {employeeId}.";
            return RedirectToPage();
        }
    }
}
