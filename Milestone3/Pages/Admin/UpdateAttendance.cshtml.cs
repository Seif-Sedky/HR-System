using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient; // Needed for SQL Parameters
using System;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class UpdateAttendanceModel : PageModel
    {
        private readonly Database _db;

        [BindProperty]
        public string Message { get; set; }

        public UpdateAttendanceModel(Database db)
        {
            _db = db;
        }

        public void OnGet()
        {
        }

        public async Task<IActionResult> OnPostAsync(int employeeId, DateTime startTime, DateTime endTime)
        {
            // 1. Prepare the parameters for the Stored Procedure "Update_Attendance"
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@Employee_id", employeeId),
                // We send TimeOfDay because SQL expects a TIME type (HH:MM:SS), not a full Date
                new SqlParameter("@check_in_time", startTime.TimeOfDay),
                new SqlParameter("@check_out_time", endTime.TimeOfDay)
            };

            try
            {
                // 2. Execute the update
                // This calls the stored procedure your team wrote in the final implementation
                await _db.ExecuteNonQuery("Update_Attendance", parameters);
                Message = "Success! Attendance updated.";
            }
            catch (Exception ex)
            {
                Message = "Error: " + ex.Message;
            }

            return Page();
        }
    }
}