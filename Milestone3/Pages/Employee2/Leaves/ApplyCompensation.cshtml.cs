using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Leaves
{
    public class ApplyCompensationModel : PageModel
    {
        private readonly Database _db;

        public ApplyCompensationModel(Database db)
        {
            _db = db;
        }

        [BindProperty]
        public DateTime CompensationDate { get; set; }

        [BindProperty]
        public DateTime OriginalWorkday { get; set; }

        [BindProperty]
        public string Reason { get; set; }

        [BindProperty]
        public int ReplacementEmployeeId { get; set; }

        public string Message { get; set; }
        public string MessageType { get; set; }
        public List<EmployeeItem> AvailableEmployees { get; set; } = new List<EmployeeItem>();
        public List<AttendanceRecord> MyAttendanceRecords { get; set; } = new List<AttendanceRecord>();

        public async Task OnGetAsync()
        {
            // Initialize default values
            CompensationDate = DateTime.Today;
            OriginalWorkday = DateTime.Today.AddDays(-1);

            await LoadAvailableEmployees();
            await LoadMyAttendance();
        }

        public async Task<IActionResult> OnPostAsync()
        {
            try
            {
                int employeeId = 1; // TODO: Replace with logged-in user ID from session

                await _db.ExecuteNonQuery("Submit_compensation",
                    new SqlParameter("@employee_ID", employeeId),
                    new SqlParameter("@compensation_date", CompensationDate),
                    new SqlParameter("@reason", Reason),
                    new SqlParameter("@date_of_original_workday", OriginalWorkday),
                    new SqlParameter("@rep_emp_id", ReplacementEmployeeId)
                );

                Message = "Compensation leave submitted successfully! Your request is pending HR approval.";
                MessageType = "success";
                
                // Clear form
                ModelState.Clear();
                CompensationDate = DateTime.Today;
                OriginalWorkday = DateTime.Today.AddDays(-1);
            }
            catch (Exception ex)
            {
                Message = $"Error submitting compensation leave: {ex.Message}";
                MessageType = "error";
            }

            await LoadAvailableEmployees();
            await LoadMyAttendance();
            return Page();
        }

        private async Task LoadAvailableEmployees()
        {
            try
            {
                int employeeId = 1; // TODO: Replace with logged-in user ID
                
                // Get employees from the same department who are not on leave
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
                int employeeId = 1; // TODO: Replace with logged-in user ID
                
                // Get recent attendance records to help user select valid original workday
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

    public class EmployeeItem
    {
        public int EmployeeId { get; set; }
        public string FullName { get; set; }
        public string Status { get; set; }
    }

    public class AttendanceRecord
    {
        public DateTime Date { get; set; }
        public TimeSpan? CheckIn { get; set; }
        public TimeSpan? CheckOut { get; set; }
        public int TotalMinutes { get; set; }
        public string Status { get; set; }
        public double TotalHours => TotalMinutes / 60.0;
    }
}
