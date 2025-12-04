using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.hr_employee.Leaves
{
    public class ReviewModel : PageModel
    {
        private readonly Database _db;
        public ReviewModel(Database db) { _db = db; }

        // --- UI Bindings ---
        [BindProperty]
        public string SelectedLeaveType { get; set; } // "AA" (Annual/Accidental), "Unpaid", "Comp"

        [BindProperty]
        public string SelectedScope { get; set; } // "All", "Department", "Specific"

        [BindProperty]
        public string SelectedAction { get; set; } // "Approve", "Reject"

        [BindProperty]
        public int? SpecificReqId { get; set; }

        [BindProperty]
        public string SelectedDept { get; set; }

        public List<SelectListItem> Departments { get; set; } = new();

        // --- Results ---
        public bool RunComplete { get; set; } = false;
        public List<ReviewResult> Results { get; set; } = new();
        public int ProcessedCount { get; set; }
        public int SuccessCount { get; set; } // Approved count
        public int RejectedCount { get; set; }
        public string ErrorMessage { get; set; }

        public class ReviewResult
        {
            public int RequestId { get; set; }
            public string EmployeeName { get; set; }
            public string Type { get; set; }
            public string FinalStatus { get; set; }
            public string ActionAttempted { get; set; }
            public string RemainingBalance { get; set; } // Added for Balance display
        }

        public async Task<IActionResult> OnGetAsync()
        {
            if (HttpContext.Session.GetInt32("UserId") == null) return RedirectToPage("/hr-employee/Login");
            await LoadDepartments();
            return Page();
        }

        public async Task<IActionResult> OnPostRunAsync()
        {
            int? hrId = HttpContext.Session.GetInt32("UserId");
            if (hrId == null) return RedirectToPage("/hr-employee/Login");
            await LoadDepartments();

            // 1. Validation
            if (string.IsNullOrEmpty(SelectedLeaveType)) { ErrorMessage = "Please select a Leave Type."; return Page(); }
            if (string.IsNullOrEmpty(SelectedAction)) { ErrorMessage = "Please select an Action."; return Page(); }

            // 2. Build Query to fetch PENDING requests based on Scope and Type
            string query = BuildFetchQuery();
            SqlParameter[] queryParams = BuildQueryParams();

            DataTable requests;
            try
            {
                requests = await _db.ExecuteQuery(query, queryParams);
            }
            catch (Exception ex)
            {
                ErrorMessage = "Error fetching requests: " + ex.Message;
                return Page();
            }

            if (requests.Rows.Count == 0)
            {
                ErrorMessage = "No pending requests found matching your criteria.";
                return Page();
            }

            // 3. Process Requests
            ProcessedCount = requests.Rows.Count;
            Results = new List<ReviewResult>();

            foreach (DataRow row in requests.Rows)
            {
                int reqId = Convert.ToInt32(row["request_ID"]);
                // We need ID to fetch balance
                int empId = Convert.ToInt32(row["employee_id"]);
                string empName = $"{row["first_name"]} {row["last_name"]}";
                string leaveType = row["type_label"].ToString(); // "Annual", "Accidental", "Unpaid", etc.

                string finalStatus = "Pending";
                string balanceDisplay = "-";

                try
                {
                    if (SelectedAction == "Reject")
                    {
                        // Force Reject
                        string rejectQuery = $"UPDATE Leave SET final_approval_status = 'Rejected' WHERE request_ID = {reqId}; " +
                                             $"UPDATE Employee_Approve_Leave SET status = 'Rejected' WHERE leave_ID = {reqId} AND Emp1_ID = {hrId}";
                        await _db.ExecuteQuery(rejectQuery);
                        finalStatus = "Rejected";
                    }
                    else // Approve
                    {
                        // Call specific procedure
                        string procName = "";
                        // Note: Stored Proc "HR_approval_an_acc" handles both Annual and Accidental
                        if (SelectedLeaveType == "AA") procName = "HR_approval_an_acc";
                        else if (SelectedLeaveType == "Unpaid") procName = "HR_approval_unpaid";
                        else if (SelectedLeaveType == "Comp") procName = "HR_approval_comp";

                        if (!string.IsNullOrEmpty(procName))
                        {
                            await _db.ExecuteStoredProcedure(procName,
                                new SqlParameter("@request_ID", reqId),
                                new SqlParameter("@HR_ID", hrId));
                        }

                        // Check status after procedure execution
                        DataTable dtStatus = await _db.ExecuteQuery($"SELECT final_approval_status FROM Leave WHERE request_ID = {reqId}");
                        if (dtStatus.Rows.Count > 0)
                        {
                            finalStatus = dtStatus.Rows[0][0].ToString();
                        }
                    }

                    // --- NEW LOGIC: Get Remaining Balance for AA types ---
                    if (leaveType == "Annual" || leaveType == "Accidental")
                    {
                        string balQuery = "SELECT annual_balance, accidental_balance FROM Employee WHERE employee_id = @eid";
                        DataTable balDt = await _db.ExecuteQuery(balQuery, new SqlParameter("@eid", empId));
                        if (balDt.Rows.Count > 0)
                        {
                            if (leaveType == "Annual")
                                balanceDisplay = balDt.Rows[0]["annual_balance"].ToString();
                            else if (leaveType == "Accidental")
                                balanceDisplay = balDt.Rows[0]["accidental_balance"].ToString();
                        }
                    }

                    // Add to results
                    Results.Add(new ReviewResult
                    {
                        RequestId = reqId,
                        EmployeeName = empName,
                        Type = leaveType,
                        ActionAttempted = SelectedAction,
                        FinalStatus = finalStatus,
                        RemainingBalance = balanceDisplay
                    });

                    if (finalStatus == "Approved") SuccessCount++;
                    if (finalStatus == "Rejected") RejectedCount++;
                }
                catch (Exception)
                {
                    Results.Add(new ReviewResult
                    {
                        RequestId = reqId,
                        EmployeeName = empName,
                        Type = leaveType,
                        ActionAttempted = SelectedAction,
                        FinalStatus = "Error",
                        RemainingBalance = "-"
                    });
                }
            }

            RunComplete = true;
            return Page();
        }

        private string BuildFetchQuery()
        {
            string baseSql = "";

            if (SelectedLeaveType == "AA")
            {
                // Modified to select Employee ID and specific type
                baseSql = @"
                    SELECT L.request_ID, E.employee_id, E.first_name, E.last_name, E.dept_name, 
                    CASE 
                        WHEN AL.request_ID IS NOT NULL THEN 'Annual' 
                        ELSE 'Accidental' 
                    END as type_label
                    FROM Leave L 
                    LEFT JOIN Annual_Leave AL ON L.request_ID = AL.request_ID 
                    LEFT JOIN Accidental_Leave ACL ON L.request_ID = ACL.request_ID
                    JOIN Employee E ON (AL.emp_ID = E.employee_id OR ACL.emp_ID = E.employee_id)
                    WHERE (AL.request_ID IS NOT NULL OR ACL.request_ID IS NOT NULL) 
                    AND L.final_approval_status = 'Pending'";
            }
            else if (SelectedLeaveType == "Unpaid")
            {
                baseSql = @"
                    SELECT L.request_ID, E.employee_id, E.first_name, E.last_name, E.dept_name, 'Unpaid' as type_label
                    FROM Leave L 
                    JOIN Unpaid_Leave UL ON L.request_ID = UL.request_ID
                    JOIN Employee E ON UL.Emp_ID = E.employee_id
                    WHERE L.final_approval_status = 'Pending'";
            }
            else if (SelectedLeaveType == "Comp")
            {
                baseSql = @"
                    SELECT L.request_ID, E.employee_id, E.first_name, E.last_name, E.dept_name, 'Compensation' as type_label
                    FROM Leave L 
                    JOIN Compensation_Leave CL ON L.request_ID = CL.request_ID
                    JOIN Employee E ON CL.emp_ID = E.employee_id
                    WHERE L.final_approval_status = 'Pending'";
            }

            // Apply Scope
            if (SelectedScope == "Specific")
            {
                baseSql += " AND L.request_ID = @id";
            }
            else if (SelectedScope == "Department")
            {
                baseSql += " AND E.dept_name = @dept";
            }

            return baseSql;
        }

        private SqlParameter[] BuildQueryParams()
        {
            List<SqlParameter> p = new List<SqlParameter>();
            if (SelectedScope == "Specific" && SpecificReqId.HasValue)
            {
                p.Add(new SqlParameter("@id", SpecificReqId.Value));
            }
            if (SelectedScope == "Department" && !string.IsNullOrEmpty(SelectedDept))
            {
                p.Add(new SqlParameter("@dept", SelectedDept));
            }
            return p.ToArray();
        }

        private async Task LoadDepartments()
        {
            Departments = new List<SelectListItem>();
            try
            {
                DataTable dt = await _db.ExecuteQuery("SELECT name FROM Department");
                foreach (DataRow row in dt.Rows)
                {
                    Departments.Add(new SelectListItem(row["name"].ToString(), row["name"].ToString()));
                }
            }
            catch { }
        }
    }
}