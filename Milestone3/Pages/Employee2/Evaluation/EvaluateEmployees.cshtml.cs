using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Milestone3.Pages.Employee2.Evaluation
{
    public class EvaluateEmployeesModel : PageModel
    {
        private readonly Database _db;

        public EvaluateEmployeesModel(Database db)
        {
            _db = db;
        }

        public List<EmployeeToEvaluate> Employees { get; set; } = new List<EmployeeToEvaluate>();
        public string Message { get; set; }
        public string MessageType { get; set; }
        public string DeanDepartment { get; set; }
        public string UserRole { get; set; }

        [BindProperty]
        public int EmployeeId { get; set; }

        [BindProperty]
        public int Rating { get; set; }

        [BindProperty]
        public string Comment { get; set; }

        [BindProperty]
        public string Semester { get; set; }

        public async Task OnGetAsync()
        {
            await LoadDepartmentEmployees();
        }

        public async Task<IActionResult> OnPostEvaluateAsync()
        {
            try
            {
                int deanId = 1; // TODO: Replace with logged-in Dean ID from session

                // Validate rating
                if (Rating < 1 || Rating > 5)
                {
                    Message = "Rating must be between 1 and 5.";
                    MessageType = "error";
                    await LoadDepartmentEmployees();
                    return Page();
                }

                // Validate semester format
                if (string.IsNullOrEmpty(Semester) || Semester.Length != 3)
                {
                    Message = "Semester must be in format like 'W24', 'S24', 'F24'.";
                    MessageType = "error";
                    await LoadDepartmentEmployees();
                    return Page();
                }

                await _db.ExecuteNonQuery("Dean_andHR_Evaluation",
                    new SqlParameter("@employee_ID", EmployeeId),
                    new SqlParameter("@rating", Rating),
                    new SqlParameter("@comment", Comment ?? ""),
                    new SqlParameter("@semester", Semester)
                );

                Message = $"Evaluation submitted successfully for employee #{EmployeeId} for semester {Semester}!";
                MessageType = "success";
                
                // Clear form
                ModelState.Clear();
                Rating = 3; // Default to middle rating
                Comment = "";
            }
            catch (Exception ex)
            {
                Message = $"Error submitting evaluation: {ex.Message}";
                MessageType = "error";
            }

            await LoadDepartmentEmployees();
            return Page();
        }

        private async Task LoadDepartmentEmployees()
        {
            try
            {
                int deanId = 1; // TODO: Replace with logged-in user ID
                
                // Get Dean's role and department
                var roleResult = await _db.ExecuteQuery(@"
                    SELECT TOP 1 r.role_name, e.dept_name
                    FROM Employee_Role er
                    JOIN Role r ON er.role_name = r.role_name
                    JOIN Employee e ON er.emp_ID = e.employee_id
                    WHERE er.emp_ID = @deanId
                    ORDER BY r.rank ASC",
                    new SqlParameter("@deanId", deanId)
                );

                if (roleResult.Rows.Count > 0)
                {
                    UserRole = roleResult.Rows[0]["role_name"].ToString();
                    DeanDepartment = roleResult.Rows[0]["dept_name"].ToString();

                    // Verify user is Dean or HR
                    if (UserRole != "Dean" && !UserRole.Contains("HR"))
                    {
                        Message = "Only Deans and HR can evaluate employees.";
                        MessageType = "error";
                        return;
                    }
                }

                // Get all employees in the same department (excluding the dean themselves)
                var result = await _db.ExecuteQuery(@"
                    SELECT 
                        e.employee_id,
                        e.first_name,
                        e.last_name,
                        e.email,
                        e.years_of_experience,
                        e.employment_status,
                        e.hire_date,
                        r.role_name,
                        r.title,
                        (SELECT TOP 1 p.rating 
                         FROM Performance p 
                         WHERE p.emp_ID = e.employee_id 
                         ORDER BY p.performance_ID DESC) as last_rating,
                        (SELECT TOP 1 p.semester 
                         FROM Performance p 
                         WHERE p.emp_ID = e.employee_id 
                         ORDER BY p.performance_ID DESC) as last_semester
                    FROM Employee e
                    LEFT JOIN Employee_Role er ON e.employee_id = er.emp_ID
                    LEFT JOIN Role r ON er.role_name = r.role_name
                    WHERE e.dept_name = @dept
                    AND e.employee_id != @deanId
                    AND e.employment_status = 'active'
                    ORDER BY e.first_name, e.last_name",
                    new SqlParameter("@dept", DeanDepartment),
                    new SqlParameter("@deanId", deanId)
                );

                foreach (DataRow row in result.Rows)
                {
                    Employees.Add(new EmployeeToEvaluate
                    {
                        EmployeeId = Convert.ToInt32(row["employee_id"]),
                        FirstName = row["first_name"].ToString(),
                        LastName = row["last_name"].ToString(),
                        Email = row["email"].ToString(),
                        YearsOfExperience = Convert.ToInt32(row["years_of_experience"]),
                        EmploymentStatus = row["employment_status"].ToString(),
                        HireDate = Convert.ToDateTime(row["hire_date"]),
                        RoleName = row["role_name"] != DBNull.Value ? row["role_name"].ToString() : "N/A",
                        Title = row["title"] != DBNull.Value ? row["title"].ToString() : "N/A",
                        LastRating = row["last_rating"] != DBNull.Value ? Convert.ToInt32(row["last_rating"]) : (int?)null,
                        LastSemester = row["last_semester"] != DBNull.Value ? row["last_semester"].ToString() : null
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading employees: {ex.Message}");
                Message = $"Error loading employees: {ex.Message}";
                MessageType = "error";
            }
        }
    }

    public class EmployeeToEvaluate
    {
        public int EmployeeId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string FullName => $"{FirstName} {LastName}";
        public string Email { get; set; }
        public int YearsOfExperience { get; set; }
        public string EmploymentStatus { get; set; }
        public DateTime HireDate { get; set; }
        public string RoleName { get; set; }
        public string Title { get; set; }
        public int? LastRating { get; set; }
        public string LastSemester { get; set; }
    }
}
