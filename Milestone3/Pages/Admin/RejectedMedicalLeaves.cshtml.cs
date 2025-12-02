using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class RejectedMedicalLeavesModel : PageModel
    {
        private readonly Database _db;

        public DataTable RejectedLeaves { get; set; }

        public RejectedMedicalLeavesModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            // Query the specific VIEW created for this task
            string query = "SELECT * FROM allRejectedMedicals";

            RejectedLeaves = await _db.ExecuteQuery(query);
        }
    }
}