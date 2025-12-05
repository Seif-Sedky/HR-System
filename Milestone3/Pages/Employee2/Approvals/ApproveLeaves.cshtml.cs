using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Approvals
{
    public class ApproveLeavesModel : PageModel
    {
        private readonly Database _db;

        public ApproveLeavesModel(Database db)
        {
            _db = db;
        }

        public List<AnnualLeaveRequest> AnnualRequests { get; set; } = new List<AnnualLeaveRequest>();
        public List<UnpaidLeaveRequest> UnpaidRequests { get; set; } = new List<UnpaidLeaveRequest>();
        public string Message { get; set; }
        public string MessageType { get; set; }
        public string UserRole { get; set; }
        public bool HasAccess { get; set; } = false;
        
        [BindProperty]
        public string ActiveTab { get; set; } = "annual";

        public async Task OnGetAsync()
        {
            await CheckAccessAndLoadRequests();
        }

        // Annual Leave Handlers
        public async Task<IActionResult> OnPostApproveAnnualAsync(int requestId, int replacementId)
        {

            if (HttpContext.Session.GetInt32("EmpID") == null)
            {
                Response.Redirect("/Employee/Login");
            }
            await CheckAccessAndLoadRequests();
            if (!HasAccess)
            {
                return Page();
            }

            try
            {
                int? upperboardId = HttpContext.Session.GetInt32("EmpID"); // TODO: Replace with logged-in user ID (President/Dean/Vice-Dean)

                await _db.ExecuteNonQuery("Upperboard_approve_annual",
                    new SqlParameter("@request_ID", requestId),
                    new SqlParameter("@Upperboard_ID", upperboardId),
                    new SqlParameter("@replacement_ID", replacementId)
                );

                // Check the actual status after procedure execution
                var statusResult = await _db.ExecuteQuery(@"
                    SELECT eal.status 
                    FROM Employee_Approve_Leave eal
                    WHERE eal.leave_ID = @requestId AND eal.Emp1_ID = @upperboardId",
                    new SqlParameter("@requestId", requestId),
                    new SqlParameter("@upperboardId", upperboardId)
                );

                if (statusResult.Rows.Count > 0)
                {
                    string status = statusResult.Rows[0]["status"].ToString();
                    if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                    {
                        Message = $"Annual leave request #{requestId} has been approved.";
                        MessageType = "success";
                    }
                    else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                    {
                        Message = $"Annual leave request #{requestId} has been rejected (validation failed).";
                        MessageType = "warning";
                    }
                    else
                    {
                        Message = $"Annual leave request #{requestId} status: {status}";
                        MessageType = "info";
                    }
                }
                else
                {
                    Message = $"Annual leave request #{requestId} has been processed.";
                    MessageType = "success";
                }
            }
            catch (Exception ex)
            {
                Message = $"Error approving request: {ex.Message}";
                MessageType = "error";
            }

            await CheckAccessAndLoadRequests();
            return Page();
        }

        public async Task<IActionResult> OnPostRejectAnnualAsync(int requestId)
        {
            if (HttpContext.Session.GetInt32("EmpID") == null)
            {
                Response.Redirect("/Employee/Login");
            }

            await CheckAccessAndLoadRequests();
            if (!HasAccess)
            {
                return Page();
            }

            try
            {
                int? upperboardId = HttpContext.Session.GetInt32("EmpID"); // TODO: Replace with logged-in user ID

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

            await CheckAccessAndLoadRequests();
            return Page();
        }

        // Unpaid Leave Handlers
        public async Task<IActionResult> OnPostApproveUnpaidAsync(int requestId)
        {
            if (HttpContext.Session.GetInt32("EmpID") == null)
            {
                Response.Redirect("/Employee/Login");
            }
            await CheckAccessAndLoadRequests();
            if (!HasAccess)
            {
                return Page();
            }

            try
            {
                int? upperboardId = HttpContext.Session.GetInt32("EmpID"); // TODO: Replace with logged-in user ID (President/Vice-President)

                await _db.ExecuteNonQuery("Upperboard_approve_unpaids",
                    new SqlParameter("@request_ID", requestId),
                    new SqlParameter("@upperboard_ID", upperboardId)
                );

                // Check the actual status after procedure execution
                var statusResult = await _db.ExecuteQuery(@"
                    SELECT eal.status 
                    FROM Employee_Approve_Leave eal
                    WHERE eal.leave_ID = @requestId AND eal.Emp1_ID = @upperboardId",
                    new SqlParameter("@requestId", requestId),
                    new SqlParameter("@upperboardId", upperboardId)
                );

                if (statusResult.Rows.Count > 0)
                {
                    string status = statusResult.Rows[0]["status"].ToString();
                    if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                    {
                        Message = $"Unpaid leave request #{requestId} has been approved.";
                        MessageType = "success";
                    }
                    else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                    {
                        Message = $"Unpaid leave request #{requestId} has been rejected (validation failed).";
                        MessageType = "warning";
                    }
                    else
                    {
                        Message = $"Unpaid leave request #{requestId} status: {status}";
                        MessageType = "info";
                    }
                }
                else
                {
                    Message = $"Unpaid leave request #{requestId} has been processed.";
                    MessageType = "success";
                }
            }
            catch (Exception ex)
            {
                Message = $"Error approving request: {ex.Message}";
                MessageType = "error";
            }

            await CheckAccessAndLoadRequests();
            return Page();
        }

        public async Task<IActionResult> OnPostRejectUnpaidAsync(int requestId)
        {

            if (HttpContext.Session.GetInt32("EmpID") == null)
            {
                Response.Redirect("/Employee/Login");
            }

            await CheckAccessAndLoadRequests();
            if (!HasAccess)
            {
                return Page();
            }

            try
            {
                int? upperboardId = HttpContext.Session.GetInt32("EmpID"); // TODO: Replace with logged-in user ID

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

            await CheckAccessAndLoadRequests();
            return Page();
        }

        private async Task CheckAccessAndLoadRequests()
        {

            if (HttpContext.Session.GetInt32("EmpID") == null)
            {
                Response.Redirect("/Employee/Login");
            }
            try
            {
                // Clear existing lists to prevent duplicates on page reloads
                AnnualRequests.Clear();
                UnpaidRequests.Clear();
                
                int? upperboardId = HttpContext.Session.GetInt32("EmpID"); // TODO: Replace with logged-in user ID
                
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
                    
                    // Check if user has access (Dean, Vice Dean, or President)
                    HasAccess = UserRole == "Dean" || UserRole == "Vice Dean" || UserRole == "President";
                    
                    if (!HasAccess)
                    {
                        Message = "Access Denied: Only Deans, Vice Deans, and Presidents can approve leave requests.";
                        MessageType = "error";
                        return;
                    }
                }
                else
                {
                    Message = "Access Denied: Unable to determine your role.";
                    MessageType = "error";
                    return;
                }

                // Load both annual and unpaid requests
                await LoadAnnualRequests(upperboardId);
                await LoadUnpaidRequests(upperboardId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking access: {ex.Message}");
                Message = $"Error loading requests: {ex.Message}";
                MessageType = "error";
            }
        }

        private async Task LoadAnnualRequests(int? upperboardId)
        {
            try
            {
                var result = await _db.ExecuteQuery(@"
                    SELECT DISTINCT
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
                        rep.dept_name as rep_dept,
                        eal.status as my_approval_status
                    FROM Leave l
                    INNER JOIN Annual_Leave al ON l.request_ID = al.request_ID
                    INNER JOIN Employee e ON al.emp_ID = e.employee_id
                    LEFT JOIN Employee rep ON al.replacement_emp = rep.employee_id
                    INNER JOIN Employee_Approve_Leave eal ON eal.leave_ID = l.request_ID
                    WHERE eal.Emp1_ID = @upperboardId
                    AND eal.status = 'pending'
                    ORDER BY l.date_of_request DESC",
                    new SqlParameter("@upperboardId", upperboardId)
                );

                // Use a HashSet to track already processed request IDs
                var processedRequestIds = new HashSet<int>();

                foreach (DataRow row in result.Rows)
                {
                    int requestId = Convert.ToInt32(row["request_ID"]);
                    
                    // Skip if this request has already been added
                    if (processedRequestIds.Contains(requestId))
                    {
                        continue;
                    }

                    var startDate = Convert.ToDateTime(row["start_date"]);
                    var endDate = Convert.ToDateTime(row["end_date"]);
                    var replacementId = row["replacement_emp"] != DBNull.Value ? Convert.ToInt32(row["replacement_emp"]) : 0;
                    var employeeDept = row["dept_name"].ToString();
                    var replacementDept = row["rep_dept"] != DBNull.Value ? row["rep_dept"].ToString() : "";
                    
                    bool isReplacementOnLeave = false;
                    if (replacementId > 0)
                    {
                        var leaveCheckResult = await _db.ExecuteQuery(@"
                            SELECT dbo.Is_On_Leave(@replacementId, @startDate, @endDate) as is_on_leave",
                            new SqlParameter("@replacementId", replacementId),
                            new SqlParameter("@startDate", startDate),
                            new SqlParameter("@endDate", endDate)
                        );

                        if (leaveCheckResult.Rows.Count > 0)
                        {
                            isReplacementOnLeave = Convert.ToBoolean(leaveCheckResult.Rows[0]["is_on_leave"]);
                        }
                    }

                    AnnualRequests.Add(new AnnualLeaveRequest
                    {
                        RequestId = requestId,
                        EmployeeId = Convert.ToInt32(row["employee_id"]),
                        EmployeeName = $"{row["first_name"]} {row["last_name"]}",
                        Department = employeeDept,
                        DateOfRequest = Convert.ToDateTime(row["date_of_request"]),
                        StartDate = startDate,
                        EndDate = endDate,
                        NumDays = Convert.ToInt32(row["num_days"]),
                        ContractType = row["type_of_contract"].ToString(),
                        AnnualBalance = row["annual_balance"] != DBNull.Value? Convert.ToInt32(row["annual_balance"]) : 0,
                        ReplacementEmployeeId = replacementId,
                        ReplacementName = row["rep_first_name"] != DBNull.Value 
                            ? $"{row["rep_first_name"]} {row["rep_last_name"]}" 
                            : "Not assigned",
                        ReplacementStatus = row["rep_status"] != DBNull.Value ? row["rep_status"].ToString() : "N/A",
                        MyApprovalStatus = row["my_approval_status"].ToString(),
                        FinalStatus = row["final_approval_status"].ToString(),
                        IsReplacementOnLeave = isReplacementOnLeave,
                        IsReplacementSameDepartment = !string.IsNullOrEmpty(replacementDept) && replacementDept == employeeDept
                    });
                    
                    // Mark this request ID as processed
                    processedRequestIds.Add(requestId);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading annual requests: {ex.Message}");
            }
        }

        private async Task LoadUnpaidRequests(int? upperboardId)
        {
            try
            {
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
                        d.document_id,
                        d.description as document_description,
                        d.file_name,
                        d.type as document_type,
                        d.creation_date,
                        eal.status as my_approval_status,
                        (SELECT TOP 1 er.role_name FROM Employee_Role er 
                         JOIN Role r ON er.role_name = r.role_name 
                         WHERE er.emp_ID = e.employee_id 
                         ORDER BY r.rank ASC) as employee_role
                    FROM Leave l
                    INNER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID
                    INNER JOIN Employee e ON ul.Emp_ID = e.employee_id
                    LEFT JOIN Document d ON d.unpaid_ID = l.request_ID
                    INNER JOIN Employee_Approve_Leave eal ON eal.leave_ID = l.request_ID
                    WHERE eal.Emp1_ID = @upperboardId
                    AND eal.status = 'Pending'
                    ORDER BY l.date_of_request DESC, d.document_id ASC",
                    new SqlParameter("@upperboardId", upperboardId)
                );

                // Group documents by request
                var requestsDict = new Dictionary<int, UnpaidLeaveRequest>();

                foreach (DataRow row in result.Rows)
                {
                    int requestId = Convert.ToInt32(row["request_ID"]);

                    // Create or get existing request
                    if (!requestsDict.ContainsKey(requestId))
                    {
                        var employeeRole = row["employee_role"] != DBNull.Value ? row["employee_role"].ToString() : "";
                        var startDate = Convert.ToDateTime(row["start_date"]);
                        var endDate = Convert.ToDateTime(row["end_date"]);
                        var department = row["dept_name"] != DBNull.Value ? row["dept_name"].ToString() : "N/A";
                        var empId = Convert.ToInt32(row["employee_id"]);
                        
                        bool isCounterpartOnLeave = false;
                        if (employeeRole == "Dean" || employeeRole == "Vice Dean")
                        {
                            isCounterpartOnLeave = await CheckCounterpartLeaveStatus(empId, employeeRole, department, startDate, endDate);
                        }

                        requestsDict[requestId] = new UnpaidLeaveRequest
                        {
                            RequestId = requestId,
                            EmployeeId = empId,
                            EmployeeName = $"{row["first_name"]} {row["last_name"]}",
                            Department = department,
                            DateOfRequest = Convert.ToDateTime(row["date_of_request"]),
                            StartDate = startDate,
                            EndDate = endDate,
                            NumDays = Convert.ToInt32(row["num_days"]),
                            ContractType = row["type_of_contract"] != DBNull.Value ? row["type_of_contract"].ToString() : "N/A",
                            AnnualBalance = row["annual_balance"] != DBNull.Value ? Convert.ToInt32(row["annual_balance"]) : 0,
                            MyApprovalStatus = row["my_approval_status"] != DBNull.Value ? row["my_approval_status"].ToString() : "Pending",
                            FinalStatus = row["final_approval_status"] != DBNull.Value ? row["final_approval_status"].ToString() : "Pending",
                            EmployeeRole = employeeRole,
                            IsCounterpartOnLeave = isCounterpartOnLeave
                        };
                    }

                    // Add document if exists
                    if (row["document_id"] != DBNull.Value)
                    {
                        var document = new DocumentInfo
                        {
                            DocumentId = Convert.ToInt32(row["document_id"]),
                            Description = row["document_description"] != DBNull.Value ? row["document_description"].ToString() : "",
                            FileName = row["file_name"] != DBNull.Value ? row["file_name"].ToString() : "",
                            Type = row["document_type"] != DBNull.Value ? row["document_type"].ToString() : "Memo",
                            CreationDate = row["creation_date"] != DBNull.Value ? Convert.ToDateTime(row["creation_date"]) : (DateTime?)null
                        };

                        requestsDict[requestId].Documents.Add(document);
                    }
                }

                // Convert dictionary to list
                UnpaidRequests = requestsDict.Values.ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading unpaid requests: {ex.Message}");
            }
        }

        private async Task<bool> CheckCounterpartLeaveStatus(int employeeId, string employeeRole, string department, DateTime startDate, DateTime endDate)
        {
            try
            {
                string counterpartRole = employeeRole == "Dean" ? "Vice Dean" : "Dean";
                
                var result = await _db.ExecuteQuery(@"
                    SELECT employee_id 
                    FROM Employee e
                    INNER JOIN Employee_Role er ON e.employee_id = er.emp_ID
                    WHERE er.role_name = @counterpartRole 
                    AND e.dept_name = @department",
                    new SqlParameter("@counterpartRole", counterpartRole),
                    new SqlParameter("@department", department)
                );

                if (result.Rows.Count > 0)
                {
                    int counterpartId = Convert.ToInt32(result.Rows[0]["employee_id"]);
                    
                    // Check if counterpart is on leave using Is_On_Leave function
                    var leaveCheckResult = await _db.ExecuteQuery(@"
                        SELECT dbo.Is_On_Leave(@counterpartId, @startDate, @endDate) as is_on_leave",
                        new SqlParameter("@counterpartId", counterpartId),
                        new SqlParameter("@startDate", startDate),
                        new SqlParameter("@endDate", endDate)
                    );

                    if (leaveCheckResult.Rows.Count > 0)
                    {
                        return Convert.ToBoolean(leaveCheckResult.Rows[0]["is_on_leave"]);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking counterpart leave status: {ex.Message}");
            }

            return false;
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
        public bool IsReplacementOnLeave { get; set; }
        public bool IsReplacementSameDepartment { get; set; }
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
        public List<DocumentInfo> Documents { get; set; } = new List<DocumentInfo>();
        public string MyApprovalStatus { get; set; }
        public string FinalStatus { get; set; }
        public string EmployeeRole { get; set; }
        public bool IsCounterpartOnLeave { get; set; }
    }

    public class DocumentInfo
    {
        public int DocumentId { get; set; }
        public string Description { get; set; }
        public string FileName { get; set; }
        public string Type { get; set; }
        public DateTime? CreationDate { get; set; }
    }


}

