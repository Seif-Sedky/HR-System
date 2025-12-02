using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Milestone3.Pages.Admin
{
    public class LoginModel : PageModel
    {
      
        [BindProperty]
        public string Message { get; set; }

        public void OnGet()
        {
            // Nothing needed here yet
        }

        // 2. This is the "Mitt" that catches the form submission
        // The parameter names (adminId, password) MUST match the name="..." in your HTML
        public IActionResult OnPost(string adminId, string password)
        {
            // 3. The Hardcoded Check (Per Project Requirement)
            if (adminId == "Yoo" && password == "Yoo is cool")
            {
                // SUCCESS: Redirect to the Homepage (or wherever you want them to go)
                return RedirectToPage("/Index");
            }
            else
            {
                // FAILURE: Set an error message and stay on this page
                Message = "Invalid Admin ID or Password";
                return Page();
            }
        }
    }
}