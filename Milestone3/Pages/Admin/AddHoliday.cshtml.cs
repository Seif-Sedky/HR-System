using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient; // For SqlParameter
using System;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class AddHolidayModel : PageModel
    {
        private readonly Database _db;

        [BindProperty]
        public string Message { get; set; }

        public AddHolidayModel(Database db)
        {
            _db = db;
        }

        public void OnGet()
        {
        }

        public async Task<IActionResult> OnPostAsync(string holidayName, DateTime startDate, DateTime endDate)
        {
            // 1. Prepare parameters for "Add_Holiday"
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@holiday_name", holidayName),
                new SqlParameter("@from_date", startDate),
                new SqlParameter("@to_date", endDate)
            };

            try
            {
                // 2. Execute the procedure
                await _db.ExecuteNonQuery("Add_Holiday", parameters);
                Message = "Success! New holiday added.";
            }
            catch (Exception ex)
            {
                Message = "Error adding holiday: " + ex.Message;
            }

            return Page();
        }
    }
}