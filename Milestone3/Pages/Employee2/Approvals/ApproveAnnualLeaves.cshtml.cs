using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Approvals
{
    public class ApproveAnnualLeavesModel : PageModel
    {
        private readonly Database _db;

        public ApproveAnnualLeavesModel(Database db)
        {
            _db = db;
        }

        public List<AnnualLeaveRequest> PendingRequests { get; set; } = new List<AnnualLeaveRequest>();
        public string Message { get; set; }
        public string MessageType { get; set; }
        public string UserRole { get; set; }

        [BindProperty]
        public int ReplacementEmployeeId { get; set; }

        public async Task OnGetAsync()
        {
            await LoadPendingRequests();
        }

        public async Task<IActionResult> OnPostApproveAsync(int requestId, int replacementId)
        {
            try
            {
                int upperboardId = 1; // TODO: Replace with logged-in user ID (President/Dean/Vice-Dean)

                await _db.ExecuteNonQuery("Upperboard_approve_annual",
                    new SqlParameter("@request_ID", requestId),
                    new SqlParameter("@Upperboard_ID", upperboardId),
                    new SqlParameter("@replacement_ID", replacementId)
                );

                Message = $"Annual leave request #{requestId} has been processed.";
                MessageType = "success";
            }
            catch (Exception ex)
            {
                Message = $"Error approving request: {ex.Message}";
                MessageType = "error";
            }

            await LoadPendingRequests();
            return Page();
        }

        public async Task<IActionResult> OnPostRejectAsync(int requestId)
        {
            try
            {
                int upperboardId = 1; // TODO: Replace with logged-in user ID

                // Update the approval status to rejected
                await _db.ExecuteQuery(@"
                    UPDATE Employee_Approve_Leave
                    SET status = 'Rejected'
                    WHERE leave_ID = @requestId AND Emp1_ID = @upperboardId;
                    
                    UPDATE Leave
                    SET final_approval_status = 'Rejected'
                    WHERE request_ID = @requestId",
                    new SqlParameter("@requestId", requestId),
                    new SqlParameter("@upperboardId", upperboardId)
                );

                Message = $"Annual leave request #{requestId} has been rejected.";
                MessageType = "success";
            }
            catch (Exception ex)
            {
                Message = $"Error rejecting request: {ex.Message}";
                MessageType = "error";
            }

            await LoadPendingRequests();
            return Page();
        }

        private async Task LoadPendingRequests()
        {
            try
            {
                int upperboardId = 1; // TODO: Replace with logged-in user ID
                
                // Get role of current user
                var roleResult = await _db.ExecuteQuery(@"
                    SELECT TOP 1 r.role_name
                    FROM Employee_Role er
                    JOIN Role r ON er.role_name = r.role_name
                    WHERE er.emp_ID = @empId
                    ORDER BY r.rank ASC",
                    new SqlParameter("@empId", upperboardId)
                );

                if (roleResult.Rows.Count > 0)
                {
                    UserRole = roleResult.Rows[0]["role_name"].ToString();
                }

                // Get pending annual leave requests that require this user's approval
                var result = await _db.ExecuteQuery(@"
                    SELECT 
                        l.request_ID,
                        l.date_of_request,
                        l.start_date,
                        l.end_date,
                        l.num_days,
                        l.final_approval_status,
                        e.employee_id,
                        e.first_name,
                        e.last_name,
                        e.dept_name,
                        e.type_of_contract,
                        e.annual_balance,
                        al.replacement_emp,
                        rep.first_name as rep_first_name,
                        rep.last_name as rep_last_name,
                        rep.employment_status as rep_status,
                        eal.status as my_approval_status
                    FROM Leave l
                    INNER JOIN Annual_Leave al ON l.request_ID = al.request_ID
                    INNER JOIN Employee e ON al.emp_ID = e.employee_id
                    LEFT JOIN Employee rep ON al.replacement_emp = rep.employee_id
                    INNER JOIN Employee_Approve_Leave eal ON eal.leave_ID = l.request_ID
                    WHERE eal.Emp1_ID = @upperboardId
                    AND l.final_approval_status = 'Pending'
                    ORDER BY l.date_of_request DESC",
                    new SqlParameter("@upperboardId", upperboardId)
                );

                foreach (DataRow row in result.Rows)
                {
                    PendingRequests.Add(new AnnualLeaveRequest
                    {
                        RequestId = Convert.ToInt32(row["request_ID"]),
                        EmployeeId = Convert.ToInt32(row["employee_id"]),
                        EmployeeName = $"{row["first_name"]} {row["last_name"]}",
                        Department = row["dept_name"].ToString(),
                        DateOfRequest = Convert.ToDateTime(row["date_of_request"]),
                        StartDate = Convert.ToDateTime(row["start_date"]),
                        EndDate = Convert.ToDateTime(row["end_date"]),
                        NumDays = Convert.ToInt32(row["num_days"]),
                        ContractType = row["type_of_contract"].ToString(),
                        AnnualBalance = Convert.ToInt32(row["annual_balance"]),
                        ReplacementEmployeeId = row["replacement_emp"] != DBNull.Value ? Convert.ToInt32(row["replacement_emp"]) : 0,
                        ReplacementName = row["rep_first_name"] != DBNull.Value 
                            ? $"{row["rep_first_name"]} {row["rep_last_name"]}" 
                            : "Not assigned",
                        ReplacementStatus = row["rep_status"] != DBNull.Value ? row["rep_status"].ToString() : "N/A",
                        MyApprovalStatus = row["my_approval_status"].ToString(),
                        FinalStatus = row["final_approval_status"].ToString()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading requests: {ex.Message}");
                Message = $"Error loading requests: {ex.Message}";
                MessageType = "error";
            }
        }
    }

    public class AnnualLeaveRequest
    {
        public int RequestId { get; set; }
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string Department { get; set; }
        public DateTime DateOfRequest { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int NumDays { get; set; }
        public string ContractType { get; set; }
        public int AnnualBalance { get; set; }
        public int ReplacementEmployeeId { get; set; }
        public string ReplacementName { get; set; }
        public string ReplacementStatus { get; set; }
        public string MyApprovalStatus { get; set; }
        public string FinalStatus { get; set; }
    }
}
