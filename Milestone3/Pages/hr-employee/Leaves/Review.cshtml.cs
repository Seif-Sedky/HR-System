using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.hr_employee.Leaves
{
    public class ReviewModel : PageModel
    {
        private readonly Database _db;
        public ReviewModel(Database db) { _db = db; }

        public List<DataRow> AnnualAccidentalLeaves { get; set; } = new();
        public List<DataRow> UnpaidLeaves { get; set; } = new();
        public List<DataRow> CompLeaves { get; set; } = new();

        public async Task<IActionResult> OnGetAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");

            // 1. Fetch Annual and Accidental Pending Leaves
            string queryAA = @"
                SELECT L.request_ID, L.start_date, L.end_date, L.num_days, E.first_name, E.last_name, AL.emp_ID, 'Annual' as type 
                FROM Leave L JOIN Annual_Leave AL ON L.request_ID = AL.request_ID JOIN Employee E ON AL.emp_ID = E.employee_id 
                WHERE L.final_approval_status = 'Pending'
                UNION
                SELECT L.request_ID, L.start_date, L.end_date, L.num_days, E.first_name, E.last_name, ACL.emp_ID, 'Accidental' as type 
                FROM Leave L JOIN Accidental_Leave ACL ON L.request_ID = ACL.request_ID JOIN Employee E ON ACL.emp_ID = E.employee_id 
                WHERE L.final_approval_status = 'Pending'";

            DataTable dtAA = await _db.ExecuteQuery(queryAA);
            foreach (DataRow row in dtAA.Rows) AnnualAccidentalLeaves.Add(row);

            // 2. Fetch Unpaid Pending Leaves
            string queryUnpaid = @"
                SELECT L.request_ID, L.start_date, L.end_date, L.num_days, E.first_name, E.last_name, UL.Emp_ID as emp_ID
                FROM Leave L JOIN Unpaid_Leave UL ON L.request_ID = UL.request_ID JOIN Employee E ON UL.Emp_ID = E.employee_id
                WHERE L.final_approval_status = 'Pending'";

            DataTable dtU = await _db.ExecuteQuery(queryUnpaid);
            foreach (DataRow row in dtU.Rows) UnpaidLeaves.Add(row);

            // 3. Fetch Compensation Pending Leaves
            string queryComp = @"
                SELECT L.request_ID, CL.reason, CL.date_of_original_workday, E.first_name, E.last_name, CL.emp_ID
                FROM Leave L JOIN Compensation_Leave CL ON L.request_ID = CL.request_ID JOIN Employee E ON CL.emp_ID = E.employee_id
                WHERE L.final_approval_status = 'Pending'";

            DataTable dtC = await _db.ExecuteQuery(queryComp);
            foreach (DataRow row in dtC.Rows) CompLeaves.Add(row);

            return Page();
        }

        public async Task<IActionResult> OnPostApproveAsync(int RequestId, string LeaveType)
        {
            return await ProcessLeave(RequestId, LeaveType, true);
        }

        public async Task<IActionResult> OnPostRejectAsync(int RequestId, string LeaveType)
        {
            return await ProcessLeave(RequestId, LeaveType, false);
        }

        private async Task<IActionResult> ProcessLeave(int reqId, string type, bool approve)
        {
            int? hrId = HttpContext.Session.GetInt32("UserId");
            if (hrId == null) return RedirectToPage("/hr-employee/Login");

            try
            {
                if (!approve)
                {
                    // If rejecting, we manually update status to Rejected (procedures might assume approval logic)
                    await _db.ExecuteQuery($"UPDATE Leave SET final_approval_status = 'Rejected' WHERE request_ID = {reqId}");
                    // Also update Employee_Approve_Leave if needed
                    await _db.ExecuteQuery($"UPDATE Employee_Approve_Leave SET status = 'Rejected' WHERE leave_ID = {reqId} AND Emp1_ID = {hrId}");
                }
                else
                {
                    // Call specific procedure based on type
                    string procName = "";
                    if (type == "AA") procName = "HR_approval_an_acc";
                    else if (type == "Unpaid") procName = "HR_approval_unpaid";
                    else if (type == "Comp") procName = "HR_approval_comp";

                    if (!string.IsNullOrEmpty(procName))
                    {
                        await _db.ExecuteStoredProcedure(procName,
                            new SqlParameter("@request_ID", reqId),
                            new SqlParameter("@HR_ID", hrId));
                    }
                }
                return RedirectToPage();
            }
            catch (Exception ex)
            {
                // In a real app, log error. For now, redirect.
                return RedirectToPage();
            }
        }
    }
}