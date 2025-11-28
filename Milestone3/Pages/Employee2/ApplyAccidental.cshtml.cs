using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Data;

public class ApplyAccidentalModel : PageModel
{
    private readonly Database _db;

    public ApplyAccidentalModel(Database db)
    {
        _db = db;
    }

    [BindProperty]
    public DateTime StartDate { get; set; }

    [BindProperty]
    public DateTime EndDate { get; set; }

    public string Message { get; set; }

    public List<EmployeeProfile> Employees { get; set; } = new List<EmployeeProfile>();

    public async Task OnGetAsync()
    {
        try
        {
            // Query the allEmployeeProfiles view directly
            var result = await _db.ExecuteQuery("SELECT * FROM allEmployeeProfiles");
            
            // Log the number of rows returned
            Console.WriteLine($"Query returned {result.Rows.Count} rows");
            
            // If no employees exist, insert a test employee
            if (result.Rows.Count == 0)
            {
                Console.WriteLine("No employees found. Inserting test data...");
                
                // First, ensure departments exist
                await _db.ExecuteQuery(@"
                    IF NOT EXISTS (SELECT 1 FROM Department WHERE name = 'MET')
                    BEGIN
                        INSERT INTO Department (name, building_location)
                        VALUES ('MET', 'C building')
                    END
                    
                    IF NOT EXISTS (SELECT 1 FROM Department WHERE name = 'BI')
                    BEGIN
                        INSERT INTO Department (name, building_location)
                        VALUES ('BI', 'B building')
                    END
                    
                    IF NOT EXISTS (SELECT 1 FROM Department WHERE name = 'HR')
                    BEGIN
                        INSERT INTO Department (name, building_location)
                        VALUES ('HR', 'N building')
                    END
                    
                    IF NOT EXISTS (SELECT 1 FROM Department WHERE name = 'Medical')
                    BEGIN
                        INSERT INTO Department (name, building_location)
                        VALUES ('Medical', 'B building')
                    END
                ");
                
                Console.WriteLine("Departments created/verified. Inserting test employee...");
                
                // Now insert test employee
                await _db.ExecuteQuery(@"
                    INSERT INTO Employee (first_name, last_name, email, password, address, gender, 
                                         official_day_off, years_of_experience, national_ID, 
                                         employment_status, type_of_contract, emergency_contact_name, 
                                         emergency_contact_phone, annual_balance, accidental_balance, 
                                         hire_date, last_working_date, dept_name)
                    VALUES ('Karim', 'Abdelaziz', 'karim.abdelaziz@guc.edu.eg', 'ka@123', 'New Cairo', 
                            'M', 'Wednesday', 4, '1234567890123461', 'resigned', 'full_time', 
                            'Maged ElKedwany', '01234277761', 0, 0, '2020-09-01', '2025-09-20', 'MET')
                ");
                
                // Query again to get the inserted employee
                result = await _db.ExecuteQuery("SELECT * FROM allEmployeeProfiles");
                Console.WriteLine($"After insert, query returned {result.Rows.Count} rows");
            }
            
            foreach (DataRow row in result.Rows)
            {
                Employees.Add(new EmployeeProfile
                {
                    EmployeeId = Convert.ToInt32(row["employee_ID"]),
                    FirstName = row["first_name"].ToString(),
                    LastName = row["last_name"].ToString(),
                    Gender = row["gender"].ToString(),
                    Email = row["email"].ToString(),
                    Address = row["address"].ToString(),
                    YearsOfExperience = Convert.ToInt32(row["years_of_experience"]),
                    OfficialDayOff = row["official_day_off"].ToString(),
                    TypeOfContract = row["type_of_contract"].ToString(),
                    EmploymentStatus = row["employment_status"].ToString(),
                    AnnualBalance = Convert.ToInt32(row["annual_balance"]),
                    AccidentalBalance = Convert.ToInt32(row["accidental_balance"])
                });
            }
            
            Console.WriteLine($"Added {Employees.Count} employees to list");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error loading employees: {ex.Message}");
            Message = $"Error loading employees: {ex.Message}";
        }
    }

    public async Task<IActionResult> OnPostAsync()
    {
        int employeeId = 4; // Example — replace with logged-in user ID.

        await _db.ExecuteNonQuery("Submit_accidental",
            new SqlParameter("@employee_ID", 8),
            new SqlParameter("@start_date", StartDate),
            new SqlParameter("@end_date", EndDate)
        );

        Message = "Accidental leave submitted successfully!";
        
        // Reload employees after submission
        await OnGetAsync();
        
        return Page();
    }
}

public class EmployeeProfile
{
    public int EmployeeId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Gender { get; set; }
    public string Email { get; set; }
    public string Address { get; set; }
    public int YearsOfExperience { get; set; }
    public string OfficialDayOff { get; set; }
    public string TypeOfContract { get; set; }
    public string EmploymentStatus { get; set; }
    public int AnnualBalance { get; set; }
    public int AccidentalBalance { get; set; }
}
