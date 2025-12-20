using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Wed_Toys_Store.Data;

namespace Wed_Toys_Store.ViewComponents
{
    public class CategoriesViewComponent : ViewComponent
    {
        private readonly ApplicationDbContext _context;

        public CategoriesViewComponent(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            var categories = await _context.Categories
                .OrderBy(c => c.Name)
                .ToListAsync();
            
            return View(categories);
        }
    }
}












