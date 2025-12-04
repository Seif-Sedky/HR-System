using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Http;

namespace Milestone3.Pages.Admin
{
    // This class checks for login on every request
    public class AdminBasePageModel : PageModel
    {
        public override void OnPageHandlerExecuting(PageHandlerExecutingContext context)
        {
            // Check if the "AdminName" session variable exists
            string adminName = HttpContext.Session.GetString("AdminName");

            if (string.IsNullOrEmpty(adminName))
            {
                // If not logged in, kick them back to the Login page
                context.Result = new RedirectToPageResult("/Admin/Login");
            }

            base.OnPageHandlerExecuting(context);
        }
    }
}