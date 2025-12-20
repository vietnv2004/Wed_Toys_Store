using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;
using System.Security.Claims;

namespace Wed_Toys_Store.Controllers
{
    [Authorize]
    public class ProductsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public ProductsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Products
        [AllowAnonymous]
        public async Task<IActionResult> Index(string? ageRange, string? brand, string? priceRange, string? sortBy, int? categoryId, string? searchTerm)
        {
            var query = _context.Products.Include(p => p.Category).AsQueryable();

            // Filter by Search Term
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim();
                query = query.Where(p => 
                    p.Name.Contains(searchTerm) ||
                    (p.Description != null && p.Description.Contains(searchTerm)) ||
                    (p.Brand != null && p.Brand.Contains(searchTerm)) ||
                    (p.Category != null && p.Category.Name.Contains(searchTerm))
                );
            }

            // Filter by Category
            if (categoryId.HasValue && categoryId.Value > 0)
            {
                query = query.Where(p => p.CategoryId == categoryId.Value);
            }

            // Filter by Age Range
            if (!string.IsNullOrEmpty(ageRange))
            {
                query = query.Where(p => p.AgeRange == ageRange);
            }

            // Filter by Brand
            if (!string.IsNullOrEmpty(brand))
            {
                query = query.Where(p => p.Brand == brand);
            }

            // Filter by Price Range
            if (!string.IsNullOrEmpty(priceRange))
            {
                switch (priceRange)
                {
                    case "under300":
                        query = query.Where(p => p.Price < 300000);
                        break;
                    case "300-500":
                        query = query.Where(p => p.Price >= 300000 && p.Price <= 500000);
                        break;
                    case "500-700":
                        query = query.Where(p => p.Price > 500000 && p.Price <= 700000);
                        break;
                    case "700-1000":
                        query = query.Where(p => p.Price > 700000 && p.Price <= 1000000);
                        break;
                    case "over1000":
                        query = query.Where(p => p.Price > 1000000);
                        break;
                }
            }

            // Sort
            switch (sortBy)
            {
                case "name":
                    query = query.OrderBy(p => p.Name);
                    break;
                case "price-asc":
                    query = query.OrderBy(p => p.Price);
                    break;
                case "price-desc":
                    query = query.OrderByDescending(p => p.Price);
                    break;
                case "newest":
                    query = query.OrderByDescending(p => p.CreatedAt);
                    break;
                default:
                    query = query.OrderBy(p => p.Name);
                    break;
            }

            var products = await query.ToListAsync();

            // Get distinct values for filters
            ViewBag.AgeRanges = await _context.Products
                .Where(p => !string.IsNullOrEmpty(p.AgeRange))
                .Select(p => p.AgeRange)
                .Distinct()
                .OrderBy(a => a)
                .ToListAsync();

            // Get brands from Brands table (active brands only)
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();

            ViewBag.SelectedAgeRange = ageRange;
            ViewBag.SelectedBrand = brand;
            ViewBag.SelectedPriceRange = priceRange;
            ViewBag.SelectedCategoryId = categoryId;
            ViewBag.SortBy = sortBy;
            ViewBag.SearchTerm = searchTerm;
            ViewBag.TotalProducts = products.Count;

            return View(products);
        }

        // GET: Products/Details/5
        [AllowAnonymous]
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var product = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (product == null)
            {
                return NotFound();
            }

            // Check if this product is in the favorites list from database
            bool isFavorite = false;
            if (User.Identity?.IsAuthenticated == true)
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (!string.IsNullOrEmpty(userId))
                {
                    isFavorite = await _context.FavoriteProducts
                        .AnyAsync(f => f.UserId == userId && f.ProductId == product.Id);
                }
            }

            ViewBag.IsFavorite = isFavorite;

            // Lấy sản phẩm liên quan: cùng thương hiệu hoặc cùng thể loại (không bao gồm sản phẩm hiện tại)
            var relatedProducts = await _context.Products
                .Include(p => p.Category)
                .Where(p => p.Id != product.Id && 
                    ((!string.IsNullOrEmpty(product.Brand) && p.Brand == product.Brand) || 
                     (product.CategoryId > 0 && p.CategoryId == product.CategoryId)))
                .OrderByDescending(p => p.CreatedAt)
                .Take(8)
                .ToListAsync();

            ViewBag.RelatedProducts = relatedProducts;

            return View(product);
        }

        // GET: Products/Create
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Create()
        {
            ViewData["CategoryId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Categories, "Id", "Name");
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View();
        }

        // POST: Products/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Create([Bind("Name,Description,Price,Stock,ImageUrl,CategoryId,AgeRange,Brand,IsNew")] Product product)
        {
            if (ModelState.IsValid)
            {
                // Tạo Product mới hoàn toàn để tránh tracking issues
                var newProduct = new Product
                {
                    Name = product.Name,
                    Description = product.Description,
                    Price = product.Price,
                    Stock = product.Stock,
                    ImageUrl = product.ImageUrl,
                    CategoryId = product.CategoryId,
                    AgeRange = product.AgeRange,
                    Brand = product.Brand,
                    IsNew = product.IsNew,
                    CreatedAt = DateTime.UtcNow
                };
                
                _context.Add(newProduct);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["CategoryId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Categories, "Id", "Name", product.CategoryId);
            return View(product);
        }

        // GET: Products/Edit/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound();
            }
            ViewData["CategoryId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Categories, "Id", "Name", product.CategoryId);
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View(product);
        }

        // POST: Products/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Name,Description,Price,Stock,ImageUrl,CategoryId,AgeRange,Brand,IsNew,CreatedAt")] Product product)
        {
            if (id != product.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    var existingProduct = await _context.Products.FindAsync(id);
                    if (existingProduct == null)
                    {
                        return NotFound();
                    }

                    existingProduct.Name = product.Name;
                    existingProduct.Description = product.Description;
                    existingProduct.Price = product.Price;
                    existingProduct.Stock = product.Stock;
                    existingProduct.ImageUrl = product.ImageUrl;
                    existingProduct.CategoryId = product.CategoryId;
                    existingProduct.AgeRange = product.AgeRange;
                    existingProduct.Brand = product.Brand;
                    existingProduct.IsNew = product.IsNew;
                    existingProduct.CreatedAt = product.CreatedAt;
                    existingProduct.UpdatedAt = DateTime.UtcNow;

                    _context.Update(existingProduct);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ProductExists(product.Id))
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
            ViewData["CategoryId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Categories, "Id", "Name", product.CategoryId);
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View(product);
        }

        // GET: Products/Delete/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var product = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(m => m.Id == id);
            
            if (product == null)
            {
                return NotFound();
            }

            return View(product);
        }

        // POST: Products/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product != null)
            {
                _context.Products.Remove(product);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool ProductExists(int id)
        {
            return _context.Products.Any(e => e.Id == id);
        }
    }
}

