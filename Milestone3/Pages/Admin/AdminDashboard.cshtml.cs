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
            try
            {
                await _db.ExecuteQuery("EXEC Remove_Holiday");
                TempData["Success"] = "Holiday records removed successfully.";
                return RedirectToPage();
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error removing holidays: " + ex.Message;
                return RedirectToPage();
            }
        }

        public async Task<IActionResult> OnPostRemoveDayOffAsync(int employeeId)
        {
            
            if (employeeId <= 0)
            {
                TempData["Error"] = "Employee ID must be positive.";
                return RedirectToPage();
            }

            try
            {
                await _db.ExecuteQuery("EXEC Remove_DayOff @Employee_id",
                    new SqlParameter("@Employee_id", employeeId));
                TempData["Success"] = "Unattended Day off of employee " + employeeId+"  in this month have been removed.";
                return RedirectToPage();
            }
            catch (Exception ex) 
            {
                TempData["Error"] = "Unexpected error occurred " + ex.Message;
                return RedirectToPage();
            }


        }

        public async Task<IActionResult> OnPostRemoveApprovedLeavesAsync(int employeeId)
        {

            if (employeeId <= 0)
            {
                TempData["Error"] = "Employee ID must be positive.";
                return RedirectToPage();
            }

            try
            {
                await _db.ExecuteQuery("EXEC Remove_Approved_Leaves @Employee_id",
                new SqlParameter("@Employee_id", employeeId));
                TempData["Success"] = "Approved Leaves of Emplyoee " + employeeId + " have been removed successfully";
                return RedirectToPage();
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Unexpected error occurred " + ex.Message;
                return RedirectToPage();
            }



        }

        public async Task<IActionResult> OnPostReplaceEmployeeAsync(int emp1Id, int emp2Id, string fromDate, string toDate)
        {

            if (emp1Id <= 0 || emp2Id <= 0)
            {
                TempData["Error"] = "Employee IDs must be positive.";
                return RedirectToPage();
            }

            try
            {
                await _db.ExecuteQuery("EXEC Replace_employee @Emp1_ID, @Emp2_ID, @from_date, @to_date",
                new SqlParameter("@Emp1_ID", emp1Id),
                new SqlParameter("@Emp2_ID", emp2Id),
                new SqlParameter("@from_date", fromDate),
                new SqlParameter("@to_date", toDate));

                TempData["Success"] = "Employee replacement completed.";
                return RedirectToPage();
            }
            catch
            {
                TempData["Error"] = "Error replacing employee.";
                return RedirectToPage();
            }

        }

        public async Task<IActionResult> OnPostUpdateEmploymentStatusAsync(int employeeId)
        {


            if (employeeId <= 0)
            {
                TempData["Error"] = "Employee ID must be positive.";
                return RedirectToPage();
            }

            try
            {
                await _db.ExecuteQuery("EXEC Update_Employment_Status @Employee_ID",
                new SqlParameter("@Employee_ID", employeeId));
                TempData["Success"] = "Emplyoee " + employeeId + " status have been updated successfully" ;
                return RedirectToPage();
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Unexpected error occurred " + ex.Message;
                return RedirectToPage();
            }
        }
    }
}
