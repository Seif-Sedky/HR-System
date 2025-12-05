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
            if (targetEmpId <= 0)
            {
                
                return new JsonResult(new
                {
                    success = false,
                    message = "Employee ID must be positive."
                });
            }
            try
            {
                
                var dt = await _db.ExecuteQuery(
                    "EXEC Remove_DayOff @Employee_ID",
                    new SqlParameter("@Employee_ID", targetEmpId)
                );

                if (dt.Rows.Count > 0)
                {
                    string message = dt.Rows[0]["Message"].ToString();
                    string status = dt.Rows[0]["Status"].ToString();

                    if (status == "ERROR")
                    {
                        return new JsonResult(new
                        {
                            success = false,
                            message = message
                        });
                    }
                    else
                    {
                        return new JsonResult(new
                        {
                            success = true,
                            message = message
                        });
                    }
                }
                else
                {
                    return new JsonResult(new
                    {
                        success = false,
                        message = "No message returned from SQL."
                    });
                }
            }
            catch (Exception ex)
            {
                return new JsonResult(new
                {
                    success = false,
                    message = ex.Message
                });
            }
        }

        // 6. Clean Approved Leaves (AJAX Version)
        
        public async Task<IActionResult> OnPostCleanLeavesAsync(int targetEmpId)
        {
            // 1. Check if employeeId is positive AND exists (YOUR LOGIC)
            var existsDt = await _db.ExecuteQuery(
                "SELECT 1 FROM dbo.Employee WHERE employee_id = @Employee_ID",
                new SqlParameter("@Employee_ID", targetEmpId)
            );

            if (targetEmpId <= 0 || existsDt.Rows.Count == 0)
            {
                return new JsonResult(new
                {
                    success = false,
                    message = "Employee ID must be positive and exist in the employees table."
                });
            }

            try
            {
                // 2. Execute stored procedure (YOUR LOGIC)
                await _db.ExecuteQuery(
                    "EXEC Remove_Approved_Leaves @Employee_id",
                    new SqlParameter("@Employee_id", targetEmpId)
                );

                // 3. JSON success (HIS LOGIC)
                return new JsonResult(new
                {
                    success = true,
                    message = $"Approved Leaves of Employee {targetEmpId} removed."
                });
            }
            catch (Exception ex)
            {
                // 4. JSON error
                return new JsonResult(new
                {
                    success = false,
                    message = ex.Message
                });
            }
        }

        // ... inside AttendanceHubModel class ...

        // 7. BULK ACTION: Clean All Day-Offs
        public async Task<IActionResult> OnPostCleanAllDayOffsAsync()
        {
            try
            {
                // 1. Get all Employee IDs
                var empTable = await _db.ExecuteQuery("SELECT employee_id FROM Employee");
                int count = 0;

                // 2. Loop through every employee
                foreach (DataRow row in empTable.Rows)
                {
                    int empId = Convert.ToInt32(row["employee_id"]);

                    // Execute the existing SP for this ID
                    await _db.ExecuteQuery(
                        "EXEC Remove_DayOff @Employee_ID",
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

        // 8. BULK ACTION: Clean All Leaves
        public async Task<IActionResult> OnPostCleanAllLeavesAsync()
        {
            try
            {
                // 1. Get all Employee IDs
                var empTable = await _db.ExecuteQuery("SELECT employee_id FROM Employee");
                int count = 0;

                // 2. Loop through every employee
                foreach (DataRow row in empTable.Rows)
                {
                    int empId = Convert.ToInt32(row["employee_id"]);

                    // Execute the existing SP for this ID
                    await _db.ExecuteQuery(
                        "EXEC Remove_Approved_Leaves @Employee_id",
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