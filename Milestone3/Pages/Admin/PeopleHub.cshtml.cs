using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    public class PeopleHubModel : AdminBasePageModel
    {
        private readonly Database _db;

        public DataTable Employees { get; set; }
        public DataTable DepartmentStats { get; set; }
        public DataTable PerformanceRecords { get; set; }

        public PeopleHubModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            string empQuery = "SELECT * FROM Employee";
            Employees = await _db.ExecuteQuery(empQuery);

            string statsQuery = "SELECT * FROM NoEmployeeDept";
            DepartmentStats = await _db.ExecuteQuery(statsQuery);

            string perfQuery = "SELECT * FROM allPerformance";
            PerformanceRecords = await _db.ExecuteQuery(perfQuery);
        }
    }
}