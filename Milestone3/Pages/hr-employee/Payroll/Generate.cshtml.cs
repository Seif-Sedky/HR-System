using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.hr_employee.Payroll
{
    public class GenerateModel : PageModel
    {
        private readonly Database _db;

        // This is the ONLY constructor allowed in this file.
        // If you see "public GenerateModel() {}" anywhere else, DELETE IT.
        public GenerateModel(Database db)
        {
            _db = db;
        }

        [BindProperty]
        public int EmpId { get; set; }

        [BindProperty]
        public DateTime FromDate { get; set; }

        [BindProperty]
        public DateTime ToDate { get; set; }

        public DataRow GeneratedPayroll { get; set; }
        public string Message { get; set; }

        public void OnGet()
        {
            // Set default dates (First day of current month to Today)
            FromDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            ToDate = DateTime.Now;
        }

        public async Task<IActionResult> OnPostAsync()
        {
            // Security Check
            if (HttpContext.Session.GetInt32("UserId") == null)
            {
                return RedirectToPage("/hr-employee/Login");
            }

            try
            {
                // 1. Generate Payroll using the Stored Procedure
                await _db.ExecuteStoredProcedure("Add_Payroll",
                    new SqlParameter("@employee_ID", EmpId),
                    new SqlParameter("@from", FromDate),
                    new SqlParameter("@to", ToDate));

                // 2. Fetch the result to show confirmation
                // We select the latest payroll entry for this employee to display it
                string query = "SELECT TOP 1 * FROM Payroll WHERE emp_ID = @id ORDER BY ID DESC";
                DataTable dt = await _db.ExecuteQuery(query, new SqlParameter("@id", EmpId));

                if (dt.Rows.Count > 0)
                {
                    GeneratedPayroll = dt.Rows[0];
                }
            }
            catch (Exception ex)
            {
                Message = "Error: " + ex.Message;
            }

            return Page();
        }
    }
}