using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data; // Needed for DataTable
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class RemoveDeductionsModel : PageModel
    {
        private readonly Database _db;

        [BindProperty]
        public string Message { get; set; }

        // We add this to hold the list of deductions "To Be Deleted"
        public DataTable ResignedDeductions { get; set; }

        public RemoveDeductionsModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // We run a query that matches the logic of your "Remove_Deductions" stored procedure
            // Logic: Find deductions for employees who are 'resigned' AND their last working date has passed
            string query = @"
                SELECT * FROM Deduction 
                WHERE emp_ID IN (
                    SELECT employee_id 
                    FROM Employee 
                    WHERE employment_status = 'resigned' 
                    AND last_working_date < GETDATE()
                )";

            ResignedDeductions = await _db.ExecuteQuery(query);
        }

        public async Task<IActionResult> OnPostAsync()
        {
            // Execute the deletion
            await _db.ExecuteNonQuery("Remove_Deductions");

            Message = "Success! Deductions for resigned employees have been removed.";

            // Re-run the OnGet logic so the table updates (it should be empty now)
            await OnGetAsync();

            return Page();
        }
    }
}