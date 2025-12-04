using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Leaves
{
    public class ApplyLeaveModel : PageModel
    {
        private readonly Database _db;

        public ApplyLeaveModel(Database db)
        {
            _db = db;
        }

        [BindProperty]
        public string LeaveType { get; set; } = "annual";

        // Common fields
        [BindProperty]
        public DateTime StartDate { get; set; }

        [BindProperty]
        public DateTime EndDate { get; set; }

        // Annual Leave fields
        [BindProperty]
        public int ReplacementEmployeeId { get; set; }

        // Unpaid Leave fields
        [BindProperty]
        public string DocumentDescription { get; set; }

        [BindProperty]
        public string FileName { get; set; }

        // Medical Leave fields
        [BindProperty]
        public string MedicalType { get; set; }

        [BindProperty]
        public bool InsuranceStatus { get; set; }

        [BindProperty]
        public string DisabilityDetails { get; set; } = "N/A";

        // Compensation Leave fields
        [BindProperty]
        public DateTime CompensationDate { get; set; }

        [BindProperty]
        public DateTime OriginalWorkday { get; set; }

        [BindProperty]
        public string Reason { get; set; }

        public string Message { get; set; }
        public string MessageType { get; set; }
        public EmployeeInfo CurrentEmployee { get; set; }
        public List<EmployeeItem> AvailableEmployees { get; set; } = new List<EmployeeItem>();
        public List<AttendanceRecord> MyAttendanceRecords { get; set; } = new List<AttendanceRecord>();

        public async Task OnGetAsync(string leaveType = "annual")
        {
            LeaveType = leaveType;
            StartDate = DateTime.Today;
            EndDate = DateTime.Today;
            CompensationDate = DateTime.Today;
            OriginalWorkday = DateTime.Today.AddDays(-1);

            await LoadEmployeeInfo();
            await LoadAvailableEmployees();
            await LoadMyAttendance();
        }

        public async Task<IActionResult> OnPostAsync()
        {
            // Update the hidden field value to match the selected type
            // This ensures the correct form is displayed after submission
            
            try
            {
                int employeeId = 4; // TODO: Replace with logged-in user ID from session

                switch (LeaveType.ToLower())
                {
                    case "annual":
                        await SubmitAnnualLeave(employeeId);
                        break;
                    case "unpaid":
                        await SubmitUnpaidLeave(employeeId);
                        break;
                    case "medical":
                        await SubmitMedicalLeave(employeeId);
                        break;
                    case "accidental":
                        await SubmitAccidentalLeave(employeeId);
                        break;
                    case "compensation":
                        await SubmitCompensationLeave(employeeId);
                        break;
                    default:
                        Message = "Invalid leave type selected.";
                        MessageType = "error";
                        break;
                }
            }
            catch (SqlException ex) when (ex.Message.Contains("SqlDateTime overflow"))
            {
                Message = "Please ensure all date fields are filled in correctly.";
                MessageType = "error";
            }
            catch (Exception ex)
            {
                Message = $"Error submitting leave: {ex.Message}";
                MessageType = "error";
            }



            // Redirect to the same page without the fragment to return to top
            return Page();
        }

        private async Task SubmitAnnualLeave(int employeeId)
        {
            await _db.ExecuteNonQuery("Submit_annual",
                new SqlParameter("@employee_ID", employeeId),
                new SqlParameter("@start_date", StartDate),
                new SqlParameter("@end_date", EndDate),
                new SqlParameter("@replacement_emp", ReplacementEmployeeId)
            );

            Message = "Annual leave submitted successfully! Your request is pending approval.";
            MessageType = "success";
            ClearForm();
        }

        private async Task SubmitUnpaidLeave(int employeeId)
        {
            await _db.ExecuteNonQuery("Submit_unpaid",
                new SqlParameter("@employee_ID", employeeId),
                new SqlParameter("@start_date", StartDate),
                new SqlParameter("@end_date", EndDate),
                new SqlParameter("@document_description", DocumentDescription),
                new SqlParameter("@file_name", FileName)
            );

            Message = "Unpaid leave submitted successfully! Your request is pending approval from your supervisor, President, and HR.";
            MessageType = "success";
            ClearForm();
        }

        private async Task SubmitMedicalLeave(int employeeId)
        {
            await _db.ExecuteNonQuery("Submit_medical",
                new SqlParameter("@employee_ID", employeeId),
                new SqlParameter("@start_date", StartDate),
                new SqlParameter("@end_date", EndDate),
                new SqlParameter("@medical_type", MedicalType),
                new SqlParameter("@insurance_status", InsuranceStatus),
                new SqlParameter("@disability_details", DisabilityDetails),
                new SqlParameter("@document_description", DocumentDescription),
                new SqlParameter("@file_name", FileName)
            );

            Message = "Medical leave submitted successfully! Your request is pending Medical Doctor approval.";
            MessageType = "success";
            ClearForm();
        }

        private async Task SubmitAccidentalLeave(int employeeId)
        {
            await _db.ExecuteNonQuery("Submit_accidental",
                new SqlParameter("@employee_ID", employeeId),
                new SqlParameter("@start_date", StartDate),
                new SqlParameter("@end_date", EndDate)
            );

            Message = "Accidental leave submitted successfully! Your request is pending HR approval.";
            MessageType = "success";
            ClearForm();
        }

        private async Task SubmitCompensationLeave(int employeeId)
        {
            await _db.ExecuteNonQuery("Submit_compensation",
                new SqlParameter("@employee_ID", employeeId),
                new SqlParameter("@compensation_date", CompensationDate),
                new SqlParameter("@reason", Reason),
                new SqlParameter("@date_of_original_workday", OriginalWorkday),
                new SqlParameter("@rep_emp_id", ReplacementEmployeeId)
            );

            Message = "Compensation leave submitted successfully! Your request is pending HR approval.";
            MessageType = "success";
            ClearForm();
        }

        private void ClearForm()
        {
            ModelState.Clear();
            StartDate = DateTime.Today;
            EndDate = DateTime.Today;
            CompensationDate = DateTime.Today;
            OriginalWorkday = DateTime.Today.AddDays(-1);
            ReplacementEmployeeId = 0;
            DocumentDescription = null;
            FileName = null;
            DisabilityDetails = "N/A";
            InsuranceStatus = false;
        }

        private async Task LoadEmployeeInfo()
        {
            try
            {
                int employeeId = 4; // TODO: Replace with logged-in user ID
                var result = await _db.ExecuteQuery(
                    "SELECT annual_balance, accidental_balance, type_of_contract FROM Employee WHERE employee_id = @empId",
                    new SqlParameter("@empId", employeeId)
                );
                if (result.Rows.Count > 0)
                {
                    var row = result.Rows[0];
                    CurrentEmployee = new EmployeeInfo
                    {
                        AnnualBalance = Convert.ToInt32(row["annual_balance"]),
                        AccidentalBalance = Convert.ToInt32(row["accidental_balance"]),
                        ContractType = row["type_of_contract"].ToString()
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading employee info: {ex.Message}");
            }
        }

        private async Task LoadAvailableEmployees()
        {
            try
            {
                int employeeId = 4; // TODO: Replace with logged-in user ID
                
                var result = await _db.ExecuteQuery(@"
                    SELECT e.employee_id, e.first_name, e.last_name, e.employment_status
                    FROM Employee e
                    WHERE e.dept_name = (SELECT dept_name FROM Employee WHERE employee_id = @empId)
                    AND e.employee_id != @empId
                    AND e.employment_status = 'active'
                    ORDER BY e.first_name, e.last_name",
                    new SqlParameter("@empId", employeeId)
                );

                foreach (DataRow row in result.Rows)
                {
                    AvailableEmployees.Add(new EmployeeItem
                    {
                        EmployeeId = Convert.ToInt32(row["employee_id"]),
                        FullName = $"{row["first_name"]} {row["last_name"]}",
                        Status = row["employment_status"].ToString()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading employees: {ex.Message}");
            }
        }

        private async Task LoadMyAttendance()
        {
            try
            {
                int employeeId = 4; // TODO: Replace with logged-in user ID
                
                var result = await _db.ExecuteQuery(@"
                    SELECT TOP 10 date, check_in_time, check_out_time, total_duration, status
                    FROM Attendance
                    WHERE emp_ID = @empId
                    AND date <= CAST(GETDATE() AS DATE)
                    ORDER BY date DESC",
                    new SqlParameter("@empId", employeeId)
                );

                foreach (DataRow row in result.Rows)
                {
                    MyAttendanceRecords.Add(new AttendanceRecord
                    {
                        Date = Convert.ToDateTime(row["date"]),
                        CheckIn = row["check_in_time"] != DBNull.Value ? TimeSpan.Parse(row["check_in_time"].ToString()) : (TimeSpan?)null,
                        CheckOut = row["check_out_time"] != DBNull.Value ? TimeSpan.Parse(row["check_out_time"].ToString()) : (TimeSpan?)null,
                        TotalMinutes = row["total_duration"] != DBNull.Value ? Convert.ToInt32(row["total_duration"]) : 0,
                        Status = row["status"].ToString()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading attendance: {ex.Message}");
            }
        }
    }
}
