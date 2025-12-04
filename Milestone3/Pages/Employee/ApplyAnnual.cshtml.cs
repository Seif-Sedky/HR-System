using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering; // For SelectListItem
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Employee.Leaves
{
    public class ApplyAnnualModel : PageModel
    {
        private readonly Database _db;

        [BindProperty]
        public DateTime StartDate { get; set; } = DateTime.Today;

        [BindProperty]
        public DateTime EndDate { get; set; } = DateTime.Today;

        [BindProperty]
        public int ReplacementId { get; set; }

        // Dropdown data
        public List<SelectListItem> ReplacementOptions { get; set; }

        public ApplyAnnualModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // 1. Get Current User
            int empId = HttpContext.Session.GetInt32("EmpID") ?? 1;

            // 2. Load Replacement Options (All employees except self)
            ReplacementOptions = new List<SelectListItem>();

            string query = "SELECT employee_id, first_name, last_name, dept_name FROM Employee WHERE employee_id != @id ORDER BY first_name";
            SqlParameter[] p = { new SqlParameter("@id", empId) };

            var dt = await _db.ExecuteQuery(query, p);

            foreach (DataRow row in dt.Rows)
            {
                ReplacementOptions.Add(new SelectListItem
                {
                    Value = row["employee_id"].ToString(),
                    Text = $"{row["first_name"]} {row["last_name"]} ({row["dept_name"]})"
                });
            }
        }

        public async Task<IActionResult> OnPostAsync()
        {
            int empId = HttpContext.Session.GetInt32("EmpID") ?? 1;

            // Basic Validation
            if (EndDate < StartDate)
            {
                TempData["Error"] = "End date cannot be before start date.";
                return await ReloadPage();
            }

            try
            {
                // Call the provided Procedure: Submit_annual
                SqlParameter[] p = {
                    new SqlParameter("@employee_ID", empId),
                    new SqlParameter("@replacement_emp", ReplacementId),
                    new SqlParameter("@start_date", StartDate),
                    new SqlParameter("@end_date", EndDate)
                };

                await _db.ExecuteNonQuery("Submit_annual", p);

                TempData["Success"] = "Annual leave request submitted successfully.";
                return RedirectToPage("/Employee/MyProfile"); // Go back to profile to see the request
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Submission failed: " + ex.Message;
                return await ReloadPage();
            }
        }

        // Helper to reload dropdowns if submission fails
        private async Task<IActionResult> ReloadPage()
        {
            await OnGetAsync();
            return Page();
        }
    }
}