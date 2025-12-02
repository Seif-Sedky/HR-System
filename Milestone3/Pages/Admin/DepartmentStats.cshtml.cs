using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data; // For DataTable
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class DepartmentStatsModel : PageModel
    {
        private readonly Database _db;

        // Container for the data
        public DataTable Stats { get; set; }

        public DepartmentStatsModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // We select from the VIEW your team created
            string query = "SELECT * FROM NoEmployeeDept";

            Stats = await _db.ExecuteQuery(query);
        }
    }
}