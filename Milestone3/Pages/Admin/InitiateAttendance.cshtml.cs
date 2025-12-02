using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class InitiateAttendanceModel : PageModel
    {
        private readonly Database _db;

        [BindProperty]
        public string Message { get; set; }

        public InitiateAttendanceModel(Database db)
        {
            _db = db;
        }

        public void OnGet()
        {
        }

        public async Task<IActionResult> OnPostAsync()
        {
            try
            {
                // 1. Call the stored procedure "Initiate_Attendance"
                // This logic is critical: you can't Update attendance (Task 6) 
                // until you Initiate it (Task 8).
                await _db.ExecuteNonQuery("Initiate_Attendance");

                Message = "Success! Attendance sheets for today have been created.";
            }
            catch (Exception ex)
            {
                Message = "Error: " + ex.Message;
            }

            return Page();
        }
    }
}