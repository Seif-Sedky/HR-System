using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class AttendanceHubModel : AdminBasePageModel
    {
        private readonly Database _db;

        // Data Tables
        public DataTable AttendanceRecords { get; set; }
        public DataTable StatsList { get; set; }

        // Filters & State
        [BindProperty(SupportsGet = true)]
        public string ViewDate { get; set; } = "today";

        [BindProperty(SupportsGet = true)]
        public string ActiveTab { get; set; } = "logs"; // Default tab

        public AttendanceHubModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // 1. Fetch Raw Logs
            string logQuery = (ViewDate == "yesterday")
                ? "SELECT * FROM Attendance WHERE date = CAST(DATEADD(day, -1, GETDATE()) AS DATE)"
                : "SELECT * FROM Attendance WHERE date = CAST(GETDATE() AS DATE)";

            AttendanceRecords = await _db.ExecuteQuery(logQuery);

            // 2. Fetch Employee Stats
            string statsQuery = @"
                SELECT 
                    E.employee_id, 
                    E.first_name, 
                    E.last_name, 
                    E.dept_name,
                    (SELECT COUNT(*) FROM Attendance A 
                     WHERE A.emp_ID = E.employee_id 
                     AND A.status = 'Attended' 
                     AND MONTH(A.date) = MONTH(GETDATE()) 
                     AND YEAR(A.date) = YEAR(GETDATE())) AS AttendedCount,
                    (SELECT COUNT(*) FROM Attendance A 
                     WHERE A.emp_ID = E.employee_id 
                     AND A.status = 'Absent' 
                     AND MONTH(A.date) = MONTH(GETDATE()) 
                     AND YEAR(A.date) = YEAR(GETDATE())) AS AbsentCount
                FROM Employee E";

            StatsList = await _db.ExecuteQuery(statsQuery);
        }

        // --- GLOBAL ACTIONS ---
        // (Redirect to 'logs' tab by default)

        public async Task<IActionResult> OnPostInitiateAsync()
        {
            try
            {
                await _db.ExecuteNonQuery("Initiate_Attendance");
                TempData["Success"] = "Attendance records initiated for all active employees.";
            }
            catch (Exception ex) { TempData["Error"] = ex.Message; }
            return RedirectToPage(new { ViewDate, ActiveTab = "logs" });
        }

        public async Task<IActionResult> OnPostRemoveHolidaysAsync()
        {
            try
            {
                await _db.ExecuteNonQuery("Remove_Holiday");
                TempData["Success"] = "Cleared attendance records falling on official holidays.";
            }
            catch (Exception ex) { TempData["Error"] = ex.Message; }
            return RedirectToPage(new { ViewDate, ActiveTab = "logs" });
        }

        public async Task<IActionResult> OnPostUpdateRecordAsync(int empId, DateTime checkIn, DateTime checkOut)
        {
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@Employee_id", empId),
                    new SqlParameter("@check_in_time", checkIn),
                    new SqlParameter("@check_out_time", checkOut)
                };
                await _db.ExecuteNonQuery("Update_Attendance", p);
                TempData["Success"] = $"Record updated for Employee #{empId}";
            }
            catch (Exception ex) { TempData["Error"] = ex.Message; }
            return RedirectToPage(new { ViewDate, ActiveTab = "logs" });
        }

        // --- CORRECTION ACTIONS ---
        // (Redirect to 'corrections' tab so user stays there)

        // 5. Clean Day Offs (AJAX Version)
        public async Task<IActionResult> OnPostCleanDayOffAsync(int targetEmpId)
        {
            try
            {
                SqlParameter[] p = { new SqlParameter("@employee_ID", targetEmpId) };
                await _db.ExecuteNonQuery("Remove_DayOff", p);
                // Return JSON for the JavaScript to handle
                return new JsonResult(new { success = true, message = $"Day-off conflicts resolved for Employee #{targetEmpId}" });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = ex.Message });
            }
        }

        // 6. Clean Approved Leaves (AJAX Version)
        public async Task<IActionResult> OnPostCleanLeavesAsync(int targetEmpId)
        {
            try
            {
                SqlParameter[] p = { new SqlParameter("@employee_id", targetEmpId) };
                await _db.ExecuteNonQuery("Remove_Approved_Leaves", p);
                // Return JSON for the JavaScript to handle
                return new JsonResult(new { success = true, message = $"Leave conflicts resolved for Employee #{targetEmpId}" });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = ex.Message });
            }
        }
    }
}