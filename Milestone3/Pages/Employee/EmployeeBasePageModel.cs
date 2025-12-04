using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Http;

namespace Milestone3.Pages.Employee
{
    // Security Guard for Employee Pages
    public class EmployeeBasePageModel : PageModel
    {
        public override void OnPageHandlerExecuting(PageHandlerExecutingContext context)
        {
            // Check if "EmpID" is in the session
            var empId = HttpContext.Session.GetInt32("EmpID");

            if (empId == null)
            {
                // Not logged in? Go to Login
                context.Result = new RedirectToPageResult("/Employee/Login");
            }

            base.OnPageHandlerExecuting(context);
        }
    }
}