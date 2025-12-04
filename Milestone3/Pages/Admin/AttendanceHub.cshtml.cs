using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class AttendanceHubModel : PageModel
    {
        private readonly Database _db;

        public DataTable AttendanceRecords { get; set; }

        [BindProperty(SupportsGet = true)]
        public string ViewDate { get; set; } = "today"; // Default to today

        public AttendanceHubModel(Database db)
        {
            _db = db;
        }

        // 1. GET: Fetch Records (Toggle Today/Yesterday)
        public async Task OnGetAsync()
        {
            string query;

            // Logic for Milestone Requirement: "Fetch attendance for yesterday" vs Today
            if (ViewDate == "yesterday")
            {
                // Fetch Yesterday
                query = "SELECT * FROM Attendance WHERE date = CAST(DATEADD(day, -1, GETDATE()) AS DATE)";
            }
            else
            {
                // Fetch Today (Default)
                query = "SELECT * FROM Attendance WHERE date = CAST(GETDATE() AS DATE)";
            }

            AttendanceRecords = await _db.ExecuteQuery(query);
        }

        // 2. ACTION: Initiate Attendance (Milestone Req: 8)
        public async Task<IActionResult> OnPostInitiateAsync()
        {
            try
            {
                await _db.ExecuteNonQuery("Initiate_Attendance");
                TempData["Success"] = "Attendance records initiated for all active employees.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }
            return RedirectToPage(new { ViewDate });
        }

        // 3. ACTION: Remove Holidays (Milestone Req: Part 2.3)
        public async Task<IActionResult> OnPostRemoveHolidaysAsync()
        {
            try
            {
                await _db.ExecuteNonQuery("Remove_Holiday");
                TempData["Success"] = "Cleared attendance records falling on official holidays.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }
            return RedirectToPage(new { ViewDate });
        }

        // 4. ACTION: Update Single Record (Milestone Req: 6)
        public async Task<IActionResult> OnPostUpdateRecordAsync(int empId, DateTime checkIn, DateTime checkOut)
        {
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@Employee_id", empId),
                    new SqlParameter("@check_in_time", checkIn), // Ensure your HTML sends full DateTime or TimeSpan
                    new SqlParameter("@check_out_time", checkOut)
                };
                await _db.ExecuteNonQuery("Update_Attendance", p);
                TempData["Success"] = $"Record updated for Employee #{empId}";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }
            return RedirectToPage(new { ViewDate });
        }

        // 5. ACTION: Clean Day Offs (Milestone Req: Part 2.4)
        public async Task<IActionResult> OnPostCleanDayOffAsync(int targetEmpId)
        {
            try
            {
                SqlParameter[] p = { new SqlParameter("@employee_ID", targetEmpId) };
                await _db.ExecuteNonQuery("Remove_DayOff", p);
                TempData["Success"] = $"Unattended day-offs cleared for Employee #{targetEmpId}";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }
            return RedirectToPage(new { ViewDate });
        }

        // 6. ACTION: Clean Approved Leaves (Milestone Req: Part 2.5)
        public async Task<IActionResult> OnPostCleanLeavesAsync(int targetEmpId)
        {
            try
            {
                SqlParameter[] p = { new SqlParameter("@employee_id", targetEmpId) };
                await _db.ExecuteNonQuery("Remove_Approved_Leaves", p);
                TempData["Success"] = $"Attendance cleared for approved leaves for Employee #{targetEmpId}";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }
            return RedirectToPage(new { ViewDate });
        }
    }
}