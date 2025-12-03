
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Authorization;

namespace Milestone3.Pages.Admin
{
    //[Authorize(Roles = "admin")]
    public class AttendanceYesterdayModel : PageModel
    {
        
        private readonly Database _db;

        public DataTable AttendanceData { get; set; }

        public AttendanceYesterdayModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        public async Task OnGetAsync()
        {
            AttendanceData = await _db.ExecuteQuery("SELECT * FROM allEmployeeAttendance");
        }
    }
}

