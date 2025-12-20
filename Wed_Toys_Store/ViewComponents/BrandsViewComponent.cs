using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Wed_Toys_Store.Data;

namespace Wed_Toys_Store.ViewComponents
{
    public class BrandsViewComponent : ViewComponent
    {
        private readonly ApplicationDbContext _context;

        public BrandsViewComponent(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            var brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .ToListAsync();
            
            return View(brands);
        }
    }
}









