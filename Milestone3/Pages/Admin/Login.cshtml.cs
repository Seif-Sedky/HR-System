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
         
        }

        
        public IActionResult OnPost(string adminId, string password)
        {
          
            if (adminId == "Yoo" && password == "Yoo is cool")
            {
                return RedirectToPage("/Admin/Dashboard");
            }
            else
            {
                Message = "Invalid Admin ID or Password";
                return Page();
            }
        }
    }
}