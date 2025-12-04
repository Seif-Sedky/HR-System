using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class IndexModel : PageModel
    {
        private readonly Database _db;

        public string AdminName { get; set; } = "Admin";
        public string Greeting { get; set; }
        public string CurrentDate { get; set; }

        public IndexModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // 1. Set Date
            CurrentDate = DateTime.Now.ToString("dddd, MMMM d, yyyy");

            // 2. Set Dynamic Greeting
            var hour = DateTime.Now.Hour;
            if (hour < 12) Greeting = "Good Morning";
            else if (hour < 18) Greeting = "Good Afternoon";
            else Greeting = "Good Evening";

            // 3. Fetch Admin Name (Simulated for ID = 1 until Login is built)
            // LATER: int id = HttpContext.Session.GetInt32("UserId");
            int mockId = 1;

            string query = "SELECT first_name FROM Employee WHERE employee_id = @id";
            SqlParameter[] p = { new SqlParameter("@id", mockId) };

            var dt = await _db.ExecuteQuery(query, p);
            if (dt.Rows.Count > 0)
            {
                AdminName = dt.Rows[0]["first_name"].ToString();
            }
        }
    }
}