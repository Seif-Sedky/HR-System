using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data; // Needed for DataTable
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class ViewProfilesModel : PageModel
    {
        // 1. The Database Tool
        private readonly Database _db;

        // 2. The Data Container (Your "Excel Sheet")
        public DataTable Employees { get; set; }

        // 3. Constructor: Injects the Database class you set up in Program.cs
        public ViewProfilesModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // 4. The Query
            // We use your exact table name "Employee" from the SQL script
            string query = "SELECT * FROM Employee";

            // 5. Execute and save the result
            Employees = await _db.ExecuteQuery(query);
        }
    }
}