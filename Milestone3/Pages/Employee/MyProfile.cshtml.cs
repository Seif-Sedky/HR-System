using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Http;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Milestone3.Pages.Employee
{
    public class MyProfileModel : PageModel
    {
        private readonly Database _db;

        // Data Containers
        public DataRow EmployeeInfo { get; set; }
        public DataTable PerformanceList { get; set; }
        public DataTable AttendanceList { get; set; }
        public DataTable PayrollData { get; set; }
        public DataTable DeductionsList { get; set; }
        public DataTable LeaveStatusList { get; set; }

        // Filter Inputs
        [BindProperty(SupportsGet = true)]
        public string SelectedSemester { get; set; }

        [BindProperty(SupportsGet = true)]
        public int SelectedDeductionMonth { get; set; }

        // NEW: Remember the active tab
        [BindProperty(SupportsGet = true)]
        public string ActiveTab { get; set; } = "performance";

        public MyProfileModel(Database db)
        {
            _db = db;
        }

        public async Task OnGetAsync()
        {
            int empId = HttpContext.Session.GetInt32("EmpID") ?? 1;

            if (string.IsNullOrEmpty(SelectedSemester)) SelectedSemester = "W23";
            if (SelectedDeductionMonth == 0) SelectedDeductionMonth = DateTime.Now.Month;

            // --- A. Personal Info ---
            var empDt = await _db.ExecuteQuery("SELECT * FROM Employee WHERE employee_id = @id",
                new SqlParameter("@id", empId));
            if (empDt.Rows.Count > 0) EmployeeInfo = empDt.Rows[0];

            // --- B. Performance ---
            SqlParameter[] pPerf = {
                new SqlParameter("@employee_ID", empId),
                new SqlParameter("@period", SelectedSemester)
            };
            PerformanceList = await _db.ExecuteQuery("SELECT * FROM dbo.MyPerformance(@employee_ID, @period)", pPerf);

            // --- C. Attendance ---
            SqlParameter[] pAtt = { new SqlParameter("@employee_ID", empId) };
            AttendanceList = await _db.ExecuteQuery("SELECT * FROM dbo.MyAttendance(@employee_ID)", pAtt);

            // --- D. Payroll ---
            SqlParameter[] pPay = { new SqlParameter("@employee_ID", empId) };
            PayrollData = await _db.ExecuteQuery("SELECT * FROM dbo.Last_month_payroll(@employee_ID)", pPay);

            // --- E. Deductions ---
            SqlParameter[] pDed = {
                new SqlParameter("@employee_ID", empId),
                new SqlParameter("@month", SelectedDeductionMonth)
            };
            DeductionsList = await _db.ExecuteQuery("SELECT * FROM dbo.Deductions_Attendance(@employee_ID, @month)", pDed);

            // --- F. Leave Status ---
            SqlParameter[] pLeave = { new SqlParameter("@employee_ID", empId) };
            LeaveStatusList = await _db.ExecuteQuery("SELECT * FROM dbo.status_leaves(@employee_ID)", pLeave);
        }
    }
}