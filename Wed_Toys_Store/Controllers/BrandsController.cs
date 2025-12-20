using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Controllers
{
    [Authorize(Roles = "Admin")]
    public class BrandsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public BrandsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Brands
        public async Task<IActionResult> Index(int page = 1, int pageSize = 10, string? searchKeyword = null, string? status = null)
        {
            // Validate pageSize
            var allowedPageSizes = new[] { 10, 20, 50, 100 };
            if (!allowedPageSizes.Contains(pageSize))
            {
                pageSize = 10;
            }

            // Validate page
            if (page < 1)
            {
                page = 1;
            }

            var query = _context.Brands.AsQueryable();

            // Filter by Search Keyword (Name)
            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                var keyword = searchKeyword.Trim();
                query = query.Where(b => b.Name.Contains(keyword));
            }

            // Filter by Status (IsActive)
            if (!string.IsNullOrWhiteSpace(status))
            {
                if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(b => b.IsActive == true);
                }
                else if (status.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(b => b.IsActive == false);
                }
            }

            // Get total count
            var totalItems = await query.CountAsync();

            // Get brands with pagination
            var brands = await query
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var viewModel = new BrandsViewModel
            {
                Brands = brands,
                CurrentPage = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                SearchKeyword = searchKeyword,
                Status = status
            };

            return View(viewModel);
        }

        // GET: Brands/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            var brand = await GetBrandAsync(id);
            if (brand == null)
            {
                return NotFound();
            }

            return View(brand);
        }

        // GET: Brands/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Brands/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Name,LogoUrl,DisplayOrder,IsActive")] Brand brand)
        {
            if (ModelState.IsValid)
            {
                _context.Add(brand);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Brand created successfully.";
                return RedirectToAction(nameof(Index));
            }
            return View(brand);
        }

        // GET: Brands/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            var brand = await GetBrandAsync(id);
            if (brand == null)
            {
                return NotFound();
            }
            return View(brand);
        }

        // POST: Brands/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Name,LogoUrl,DisplayOrder,IsActive")] Brand brand)
        {
            if (id != brand.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(brand);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Brand updated successfully.";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!BrandExists(brand.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(brand);
        }

        // GET: Brands/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            var brand = await GetBrandAsync(id);
            if (brand == null)
            {
                return NotFound();
            }

            return View(brand);
        }

        // POST: Brands/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var brand = await GetBrandAsync(id);
            if (brand != null)
            {
                _context.Brands.Remove(brand);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Brand deleted successfully.";
            }

            return RedirectToAction(nameof(Index));
        }

        private async Task<Brand?> GetBrandAsync(int? id)
        {
            if (id == null)
            {
                return null;
            }
            return await _context.Brands.FindAsync(id);
        }

        private async Task<Brand?> GetBrandAsync(int id)
        {
            return await _context.Brands.FindAsync(id);
        }

        private bool BrandExists(int id)
        {
            return _context.Brands.Any(e => e.Id == id);
        }
    }
}





