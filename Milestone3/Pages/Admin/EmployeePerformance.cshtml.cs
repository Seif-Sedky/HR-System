//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.RazorPages;
//using System.Data;

//namespace Milestone3.Pages.Admin
//{
//    public class EmployeePerformanceModel : PageModel
//    {
//        public void OnGet()
//        {
//        }
//    }
//}




using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace Milestone3.Pages.Admin
{
    //[Authorize(Roles = "admin")]
    public class EmployeePerformanceModel : PageModel
    {
        private readonly Database _db;

        public DataTable AttendanceData { get; set; }

        public EmployeePerformanceModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        public async Task OnGetAsync()
        {
            AttendanceData = await _db.ExecuteQuery("SELECT * FROM allPerformance");
        }
    }
}

