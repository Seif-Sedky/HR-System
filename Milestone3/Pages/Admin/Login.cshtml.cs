using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Http; // Needed for Session

namespace Milestone3.Pages.Admin
{
    public class LoginModel : PageModel
    {
        [BindProperty]
        public string Message { get; set; }

        public IActionResult OnGet()
        {
            // If already logged in, go straight to Dashboard
            if (!string.IsNullOrEmpty(HttpContext.Session.GetString("AdminName")))
            {
                return RedirectToPage("/Admin/Index");
            }
            return Page();
        }

        public IActionResult OnPost(string adminId, string password)
        {
            // Check credentials (Hardcoded as per your requirement)
            if ((adminId == "Yoo" && password == "Yoo is cool") ||
                (adminId == "Nayer" && password == "Nayer is cool"))
            {
                // 1. LOGIN SUCCESS: Set Session Variable
                HttpContext.Session.SetString("AdminName", adminId);

                // 2. Redirect to Dashboard
                return RedirectToPage("/Admin/Index");
            }
            else
            {
                Message = "Invalid Admin ID or Password";
                return Page();
            }
        }
    }
}