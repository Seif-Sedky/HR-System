//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.RazorPages;

//namespace Milestone3.Pages.Admin
//{
//    public class RemoveHolidayModel : PageModel
//    {
//        public void OnGet()
//        {
//        }
//    }
//}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;

namespace Milestone3.Pages.Admin
{
    public class RemoveHolidayModel : PageModel
    {
        private readonly Database _db;

        public RemoveHolidayModel(IConfiguration config)
        {
            _db = new Database(config);
        }

        public async Task<IActionResult> OnPostAsync()
        {
            try
            {
                await _db.ExecuteQuery("EXEC Remove_Holiday");
                TempData["Success"] = "Holiday records removed successfully.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }

            return Page();
        }
    }
}
