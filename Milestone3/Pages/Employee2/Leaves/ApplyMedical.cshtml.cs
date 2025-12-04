using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Leaves
{
    public class ApplyMedicalModel : PageModel
    {
        private readonly Database _db;

        public ApplyMedicalModel(Database db)
        {
            _db = db;
        }

        [BindProperty]
        public DateTime StartDate { get; set; }

        [BindProperty]
        public DateTime EndDate { get; set; }

        [BindProperty]
        public string MedicalType { get; set; } // sick or maternity

        [BindProperty]
        public bool InsuranceStatus { get; set; }

        [BindProperty]
        public string DisabilityDetails { get; set; } = "N/A";

        [BindProperty]
        public string DocumentDescription { get; set; }

        [BindProperty]
        public string FileName { get; set; }

        public string Message { get; set; }
        public string MessageType { get; set; } // success or error

        public void OnGet()
        {
            // Initialize default values
            StartDate = DateTime.Today;
            EndDate = DateTime.Today;
        }

        public async Task<IActionResult> OnPostAsync()
        {
            try
            {
                int employeeId = 4; // TODO: Replace with logged-in user ID from session

                await _db.ExecuteNonQuery("Submit_medical",
                    new SqlParameter("@employee_ID", employeeId),
                    new SqlParameter("@start_date", StartDate),
                    new SqlParameter("@end_date", EndDate),
                    new SqlParameter("@medical_type", MedicalType),
                    new SqlParameter("@insurance_status", InsuranceStatus),
                    new SqlParameter("@disability_details", DisabilityDetails),
                    new SqlParameter("@document_description", DocumentDescription),
                    new SqlParameter("@file_name", FileName)
                );

                Message = "Medical leave submitted successfully! Your request is pending approval.";
                MessageType = "success";
                
                // Clear form
                ModelState.Clear();
                StartDate = DateTime.Today;
                EndDate = DateTime.Today;
            }
            catch (Exception ex)
            {
                Message = $"Error submitting medical leave: {ex.Message}";
                MessageType = "error";
            }

            return Page();
        }
    }
}
