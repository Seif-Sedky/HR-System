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


    public void OnGet()
    {
        // Initialize default values
        StartDate = DateTime.Today;
        EndDate = DateTime.Today;

    }

    public async Task<IActionResult> OnPostAsync()
    {
        try
        {
            int employeeId = 1; // TODO: Replace with logged-in user ID from session

            await _db.ExecuteNonQuery("Submit_accidental",
                new SqlParameter("@employee_ID", employeeId),
                new SqlParameter("@start_date", StartDate),
                new SqlParameter("@end_date", EndDate)
            );

            Message = "Accidental leave submitted successfully! Your request is pending HR approval.";
            
        }
        catch (Exception ex)
        {
            Message = $"Error submitting accidental leave: {ex.Message}";
        }
        
        return Page();
    }
}

//public class EmployeeProfile
//{
//    public int EmployeeId { get; set; }
//    public string FirstName { get; set; }
//    public string LastName { get; set; }
//    public string Gender { get; set; }
//    public string Email { get; set; }
//    public string Address { get; set; }
//    public int YearsOfExperience { get; set; }
//    public string OfficialDayOff { get; set; }
//    public string TypeOfContract { get; set; }
//    public string EmploymentStatus { get; set; }
//    public int AnnualBalance { get; set; }
//    public int AccidentalBalance { get; set; }
//}
