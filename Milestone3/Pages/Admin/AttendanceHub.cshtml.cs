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
        public string ActiveTab { get; set; } = "logs";

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

        // --- CORRECTION ACTIONS (AJAX) ---

        // 5. Clean Day Offs (FIXED)
        public async Task<IActionResult> OnPostCleanDayOffAsync(int targetEmpId)
        {
            if (targetEmpId <= 0)
            {
                return new JsonResult(new { success = false, message = "Employee ID must be positive." });
            }

            try
            {
                // FIX: REMOVED "EXEC" keyword. Just pass the name.
                await _db.ExecuteNonQuery(
                    "Remove_DayOff",
                    new SqlParameter("@Employee_ID", targetEmpId)
                );

                return new JsonResult(new
                {
                    success = true,
                    message = $"Day-off records cleaned for Employee #{targetEmpId}"
                });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = "SQL Error: " + ex.Message });
            }
        }

        // 6. Clean Approved Leaves (FIXED)
        public async Task<IActionResult> OnPostCleanLeavesAsync(int targetEmpId)
        {
            var existsDt = await _db.ExecuteQuery(
                "SELECT 1 FROM dbo.Employee WHERE employee_id = @Employee_ID",
                new SqlParameter("@Employee_ID", targetEmpId)
            );

            if (targetEmpId <= 0 || existsDt.Rows.Count == 0)
            {
                return new JsonResult(new { success = false, message = "Employee ID not found." });
            }

            try
            {
                // FIX: REMOVED "EXEC" keyword.
                await _db.ExecuteNonQuery(
                    "Remove_Approved_Leaves",
                    new SqlParameter("@Employee_id", targetEmpId)
                );

                return new JsonResult(new
                {
                    success = true,
                    message = $"Approved Leaves of Employee {targetEmpId} removed."
                });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = ex.Message });
            }
        }

        // 7. BULK ACTION: Clean All Day-Offs (FIXED)
        public async Task<IActionResult> OnPostCleanAllDayOffsAsync()
        {
            try
            {
                var empTable = await _db.ExecuteQuery("SELECT employee_id FROM Employee");
                int count = 0;

                foreach (DataRow row in empTable.Rows)
                {
                    int empId = Convert.ToInt32(row["employee_id"]);

                    // FIX: REMOVED "EXEC" keyword.
                    await _db.ExecuteNonQuery(
                        "Remove_DayOff",
                        new SqlParameter("@Employee_ID", empId)
                    );
                    count++;
                }

                return new JsonResult(new
                {
                    success = true,
                    message = $"Bulk Action Complete: Processed day-offs for {count} employees."
                });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = "Bulk Error: " + ex.Message });
            }
        }

        // 8. BULK ACTION: Clean All Leaves (FIXED)
        public async Task<IActionResult> OnPostCleanAllLeavesAsync()
        {
            try
            {
                var empTable = await _db.ExecuteQuery("SELECT employee_id FROM Employee");
                int count = 0;

                foreach (DataRow row in empTable.Rows)
                {
                    int empId = Convert.ToInt32(row["employee_id"]);

                    // FIX: REMOVED "EXEC" keyword.
                    await _db.ExecuteNonQuery(
                        "Remove_Approved_Leaves",
                        new SqlParameter("@Employee_id", empId)
                    );
                    count++;
                }

                return new JsonResult(new
                {
                    success = true,
                    message = $"Bulk Action Complete: Resolved leaves for {count} employees."
                });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = "Bulk Error: " + ex.Message });
            }
        }
    }
}