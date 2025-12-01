using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Approvals
{
    public class ApproveUnpaidLeavesModel : PageModel
    {
        private readonly Database _db;

        public ApproveUnpaidLeavesModel(Database db)
        {
            _db = db;
        }

        public List<UnpaidLeaveRequest> PendingRequests { get; set; } = new List<UnpaidLeaveRequest>();
        public string Message { get; set; }
        public string MessageType { get; set; }
        public string UserRole { get; set; }

        public async Task OnGetAsync()
        {
            await LoadPendingRequests();
        }

        public async Task<IActionResult> OnPostApproveAsync(int requestId)
        {
            try
            {
                int upperboardId = 1; // TODO: Replace with logged-in user ID (President/Vice-President)

                await _db.ExecuteNonQuery("Upperboard_approve_unpaids",
                    new SqlParameter("@request_ID", requestId),
                    new SqlParameter("@upperboard_ID", upperboardId)
                );

                Message = $"Unpaid leave request #{requestId} has been processed.";
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

                Message = $"Unpaid leave request #{requestId} has been rejected.";
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

                // Get pending unpaid leave requests that require this user's approval
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
                        d.description as document_description,
                        d.file_name,
                        eal.status as my_approval_status
                    FROM Leave l
                    INNER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID
                    INNER JOIN Employee e ON ul.Emp_ID = e.employee_id
                    LEFT JOIN Document d ON d.unpaid_ID = l.request_ID
                    INNER JOIN Employee_Approve_Leave eal ON eal.leave_ID = l.request_ID
                    WHERE eal.Emp1_ID = @upperboardId
                    AND l.final_approval_status = 'Pending'
                    ORDER BY l.date_of_request DESC",
                    new SqlParameter("@upperboardId", upperboardId)
                );

                foreach (DataRow row in result.Rows)
                {
                    PendingRequests.Add(new UnpaidLeaveRequest
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
                        DocumentDescription = row["document_description"].ToString(),
                        FileName = row["file_name"].ToString(),
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

    public class UnpaidLeaveRequest
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
        public string DocumentDescription { get; set; }
        public string FileName { get; set; }
        public string MyApprovalStatus { get; set; }
        public string FinalStatus { get; set; }
    }
}
