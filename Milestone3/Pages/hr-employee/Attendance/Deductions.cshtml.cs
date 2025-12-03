using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;

namespace Milestone3.Pages.hr_employee.Attendance
{
    public class DeductionsModel : PageModel
    {
        private readonly Database _db;
        public DeductionsModel(Database db) { _db = db; }

        [BindProperty]
        public int TargetEmployeeId { get; set; }

        public string Message { get; set; }
        public bool IsSuccess { get; set; }

        public void OnGet() { }

        public async Task<IActionResult> OnPostMissingHoursAsync()
        {
            return await ApplyDeduction("Deduction_hours", "@employee_ID");
        }

        public async Task<IActionResult> OnPostMissingDaysAsync()
        {
            return await ApplyDeduction("Deduction_days", "@employee_id");
        }

        public async Task<IActionResult> OnPostUnpaidAsync()
        {
            return await ApplyDeduction("Deduction_unpaid", "@employee_ID");
        }

        private async Task<IActionResult> ApplyDeduction(string procName, string paramName)
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");

            try
            {
                await _db.ExecuteStoredProcedure(procName, new SqlParameter(paramName, TargetEmployeeId));
                Message = $"Successfully applied {procName} for Employee {TargetEmployeeId}.";
                IsSuccess = true;
            }
            catch (Exception ex)
            {
                Message = "Error: " + ex.Message;
                IsSuccess = false;
            }
            return Page();
        }
    }
}