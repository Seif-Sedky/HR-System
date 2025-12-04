using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class EmployeeProfileModel : AdminBasePageModel
    {
        private readonly Database _db;

        // Data to display in the View
        public DataTable EmployeeData { get; set; }
        public DataTable EmployeePerformance { get; set; }

        public EmployeeProfileModel(Database db)
        {
            _db = db;
        }

        // 1. GET: Fetch Data
        public async Task<IActionResult> OnGetAsync(int id)
        {
            if (id <= 0) return RedirectToPage("/Admin/PeopleHub");

            // Use ExecuteQuery for raw SQL SELECTs
            string query = "SELECT * FROM Employee WHERE employee_id = @id";
            SqlParameter[] p = { new SqlParameter("@id", id) };
            EmployeeData = await _db.ExecuteQuery(query, p);

            if (EmployeeData.Rows.Count == 0)
            {
                EmployeeData = null;
                return Page();
            }

            // Fetch Performance History
            string perfQuery = "SELECT * FROM allPerformance WHERE emp_ID = @id";
            SqlParameter[] p2 = { new SqlParameter("@id", id) };
            EmployeePerformance = await _db.ExecuteQuery(perfQuery, p2);

            return Page();
        }

        // 2. POST: Auto-Update Status (FIXED)
        public async Task<IActionResult> OnPostUpdateStatusAsync(int id)
        {
            try
            {
                // FIX: We pass the Procedure Name only. 
                // Your Database class sets CommandType.StoredProcedure automatically.
                string procedureName = "Update_Employment_Status";
                SqlParameter[] p = {
                    new SqlParameter("@Employee_ID", id)
                };

                await _db.ExecuteNonQuery(procedureName, p);

                // Use the new Generic Toast system
                TempData["Success"] = "Status updated based on active leaves.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
            }

            // Refresh the page
            return RedirectToPage(new { id = id });
        }

        // 3. POST: Replace Employee
        public async Task<IActionResult> OnPostReplaceAsync(int id, int replacementId, DateTime fromDate, DateTime toDate)
        {
            try
            {
                string procedureName = "Replace_employee";
                SqlParameter[] p = {
                    new SqlParameter("@Emp1_ID", id),
                    new SqlParameter("@Emp2_ID", replacementId),
                    new SqlParameter("@from_date", fromDate),
                    new SqlParameter("@to_date", toDate)
                };

                await _db.ExecuteNonQuery(procedureName, p);

                TempData["Success"] = "Replacement assigned successfully.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
            }

            return RedirectToPage(new { id = id });
        }
    }
}