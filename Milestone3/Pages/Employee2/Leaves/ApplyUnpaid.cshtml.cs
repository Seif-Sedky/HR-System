using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Leaves
{
    public class ApplyUnpaidModel : PageModel
    {
        private readonly Database _db;

        public ApplyUnpaidModel(Database db)
        {
            _db = db;
        }

        [BindProperty]
        public DateTime StartDate { get; set; }

        [BindProperty]
        public DateTime EndDate { get; set; }

        [BindProperty]
        public string DocumentDescription { get; set; }

        [BindProperty]
        public string FileName { get; set; }

        public string Message { get; set; }
        public string MessageType { get; set; }
        public EmployeeInfo CurrentEmployee { get; set; }

        public async Task OnGetAsync()
        {
            // Initialize default values
            StartDate = DateTime.Today;
            EndDate = DateTime.Today;

            // Load current employee info
            await LoadEmployeeInfo();
        }

        public async Task<IActionResult> OnPostAsync()
        {
            try
            {
                int employeeId = 1; // TODO: Replace with logged-in user ID from session

                await _db.ExecuteNonQuery("Submit_unpaid",
                    new SqlParameter("@employee_ID", employeeId),
                    new SqlParameter("@start_date", StartDate),
                    new SqlParameter("@end_date", EndDate),
                    new SqlParameter("@document_description", DocumentDescription),
                    new SqlParameter("@file_name", FileName)
                );

                Message = "Unpaid leave submitted successfully! Your request is pending approval from your supervisor, President, and HR.";
                MessageType = "success";
                
                // Clear form
                ModelState.Clear();
                StartDate = DateTime.Today;
                EndDate = DateTime.Today;
            }
            catch (Exception ex)
            {
                Message = $"Error submitting unpaid leave: {ex.Message}";
                MessageType = "error";
            }

            await LoadEmployeeInfo();
            return Page();
        }

        private async Task LoadEmployeeInfo()
        {
            try
            {
                int employeeId = 3; // TODO: Replace with logged-in user ID
                var result = await _db.ExecuteQuery(
                    "SELECT annual_balance, accidental_balance, type_of_contract FROM Employee WHERE employee_id = @empId",
                    new SqlParameter("@empId", employeeId)
                );
                if (result.Rows.Count > 0)
                {
                    var row = result.Rows[0];
                    CurrentEmployee = new EmployeeInfo
                    {
                        AnnualBalance = Convert.ToInt32(row["annual_balance"]),
                        AccidentalBalance = Convert.ToInt32(row["accidental_balance"]),
                        ContractType = row["type_of_contract"].ToString()
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading employee info: {ex.Message}");


            }
        }
    }

    public class EmployeeInfo
    {
        public int AnnualBalance { get; set; }
        public int AccidentalBalance { get; set; }
        public string ContractType { get; set; }
    }
}
