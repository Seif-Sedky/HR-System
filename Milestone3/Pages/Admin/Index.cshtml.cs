using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Http; // Needed for Session
using System;
using System.Threading.Tasks;

namespace Milestone3.Pages.Admin
{
    // INHERIT FROM GATEKEEPER (AdminBasePageModel) instead of PageModel
    public class IndexModel : AdminBasePageModel
    {
        private readonly Database _db;

        public string AdminName { get; set; }
        public string Greeting { get; set; }
        public string CurrentDate { get; set; }

        public IndexModel(Database db)
        {
            _db = db;
        }

        public void OnGet()
        {
            // 1. Get Name directly from Session (Set in Login page)
            AdminName = HttpContext.Session.GetString("AdminName");

            // 2. Set Date
            CurrentDate = DateTime.Now.ToString("dddd, MMMM d, yyyy");

            // 3. Set Dynamic Greeting
            var hour = DateTime.Now.Hour;
            if (hour < 12) Greeting = "Good Morning";
            else if (hour < 18) Greeting = "Good Afternoon";
            else Greeting = "Good Evening";
        }
    }
}