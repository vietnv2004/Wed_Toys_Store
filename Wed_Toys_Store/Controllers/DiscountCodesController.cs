using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Controllers
{
    public class DiscountCodesController : Controller
    {
        private readonly ApplicationDbContext _context;

        public DiscountCodesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: DiscountCodes/Public - Public view for all users
        [AllowAnonymous]
        public async Task<IActionResult> Public()
        {
            // Lấy mã giảm giá từ database (chỉ mã đang active và chưa hết hạn)
            // So sánh theo ngày để đảm bảo mã còn hiệu lực đến cuối ngày hết hạn
            var today = DateTime.UtcNow.Date;
            var discountCodes = await _context.DiscountCodes
                .Where(d => d.IsActive && d.ExpiryDate.Date >= today)
                .OrderBy(d => d.CreatedAt)
                .ToListAsync();

            return View(discountCodes);
        }

        // GET: DiscountCodes - Admin view
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Index(int page = 1, int pageSize = 10, string? searchKeyword = null)
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

            var query = _context.DiscountCodes.AsQueryable();

            // Filter by Search Keyword
            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                var keyword = searchKeyword.Trim();
                query = query.Where(d => 
                    d.Code.Contains(keyword) ||
                    (d.Description != null && d.Description.Contains(keyword))
                );
            }

            // Get total count
            var totalItems = await query.CountAsync();

            // Get discount codes with pagination
            // Sắp xếp: mã còn hiệu lực trước (theo CreatedAt mới nhất), mã hết hạn sau
            var today = DateTime.UtcNow.Date;
            var discountCodes = await query
                .OrderByDescending(d => d.ExpiryDate.Date >= today) // Mã còn hiệu lực trước (true = 1, false = 0)
                .ThenByDescending(d => d.CreatedAt) // Trong cùng nhóm, sắp xếp theo CreatedAt
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var viewModel = new DiscountCodesViewModel
            {
                DiscountCodes = discountCodes,
                CurrentPage = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                SearchKeyword = searchKeyword
            };

            return View(viewModel);
        }

        // GET: DiscountCodes/Create
        [Authorize(Roles = "Admin")]
        public IActionResult Create()
        {
            return View();
        }

        // POST: DiscountCodes/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Create([Bind("Code,DiscountAmount,MinOrderAmount,Description,ExpiryDate,IsActive")] DiscountCode discountCode)
        {
            if (ModelState.IsValid)
            {
                // Chuẩn hoá mã về UPPER để tránh phân biệt hoa/thường
                if (!string.IsNullOrWhiteSpace(discountCode.Code))
                {
                    discountCode.Code = discountCode.Code.Trim().ToUpper();
                }

                // Check if code already exists
                if (await _context.DiscountCodes.AnyAsync(d => d.Code == discountCode.Code))
                {
                    ModelState.AddModelError("Code", "This discount code already exists.");
                    return View(discountCode);
                }

                discountCode.CreatedAt = DateTime.UtcNow;
                _context.Add(discountCode);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Discount code created successfully.";
                return RedirectToAction(nameof(Index));
            }
            return View(discountCode);
        }

        // GET: DiscountCodes/Edit/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var discountCode = await _context.DiscountCodes.FindAsync(id);
            if (discountCode == null)
            {
                return NotFound();
            }

            return View(discountCode);
        }

        // POST: DiscountCodes/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Code,DiscountAmount,MinOrderAmount,Description,ExpiryDate,IsActive,CreatedAt")] DiscountCode discountCode)
        {
            if (id != discountCode.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Chuẩn hoá mã về UPPER để tránh phân biệt hoa/thường
                    if (!string.IsNullOrWhiteSpace(discountCode.Code))
                    {
                        discountCode.Code = discountCode.Code.Trim().ToUpper();
                    }

                    _context.Update(discountCode);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Discount code updated successfully.";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!DiscountCodeExists(discountCode.Id))
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
            return View(discountCode);
        }

        // GET: DiscountCodes/Delete/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var discountCode = await _context.DiscountCodes.FindAsync(id);
            if (discountCode == null)
            {
                return NotFound();
            }

            return View(discountCode);
        }

        // POST: DiscountCodes/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var discountCode = await _context.DiscountCodes.FindAsync(id);
            if (discountCode != null)
            {
                _context.DiscountCodes.Remove(discountCode);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Discount code deleted successfully.";
            }

            return RedirectToAction(nameof(Index));
        }

        private bool DiscountCodeExists(int id)
        {
            return _context.DiscountCodes.Any(e => e.Id == id);
        }
    }
}



