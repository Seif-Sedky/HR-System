using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class OperationsHubModel : PageModel
    {
        private readonly Database _db;

        // View Data
        public DataTable RejectedMedicalLeaves { get; set; }

        public OperationsHubModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // Task 4: Fetch details of all rejected medical leaves
            string query = "SELECT * FROM allRejectedMedicals";
            RejectedMedicalLeaves = await _db.ExecuteQuery(query);
        }

        // --- ACTIONS ---

        // Task 7: Add a new official holiday
        public async Task<IActionResult> OnPostAddHolidayAsync(string name, DateTime start, DateTime end)
        {
            // Define parameters once to reuse
            SqlParameter[] GetParams() => new SqlParameter[] {
                new SqlParameter("@holiday_name", name),
                new SqlParameter("@from_date", start),
                new SqlParameter("@to_date", end)
            };

            try
            {
                // Attempt 1: Try adding the holiday
                await _db.ExecuteNonQuery("Add_Holiday", GetParams());
                TempData["Success"] = $"Holiday '{name}' added successfully.";
            }
            catch (Exception ex)
            {
                // SMART FIX: If table is missing, create it and retry
                if (ex.Message.Contains("Invalid object name 'dbo.Holiday'") || ex.Message.Contains("Holiday"))
                {
                    try
                    {
                        // Run the existing procedure to create the table
                        await _db.ExecuteNonQuery("Create_Holiday");

                        // Attempt 2: Retry adding the holiday
                        await _db.ExecuteNonQuery("Add_Holiday", GetParams());
                        TempData["Success"] = $"Holiday '{name}' added successfully (Table Created).";
                    }
                    catch (Exception retryEx)
                    {
                        TempData["Error"] = "Failed to create holiday table: " + retryEx.Message;
                    }
                }
                else
                {
                    TempData["Error"] = "Error adding holiday: " + ex.Message;
                }
            }
            return RedirectToPage();
        }

        // Task 5: Remove deductions of resigned employees
        public async Task<IActionResult> OnPostRemoveResignedDeductionsAsync()
        {
            try
            {
                await _db.ExecuteNonQuery("Remove_Deductions");
                return new JsonResult(new { success = true, message = "Deductions for resigned employees have been cleared." });
            }
            catch (Exception ex)
            {
                return new JsonResult(new { success = false, message = ex.Message });
            }
        }
    }
}