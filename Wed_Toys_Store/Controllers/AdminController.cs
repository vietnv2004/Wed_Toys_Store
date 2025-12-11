using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;
using Microsoft.AspNetCore.Identity;

namespace Wed_Toys_Store.Controllers
{
    [Authorize(Roles = "Admin")]
    public class AdminController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;

        public AdminController(ApplicationDbContext context, UserManager<ApplicationUser> userManager, RoleManager<IdentityRole> roleManager)
        {
            _context = context;
            _userManager = userManager;
            _roleManager = roleManager;
        }

        // GET: Admin/Dashboard
        public async Task<IActionResult> Dashboard(int? month, int? year)
        {
            // Sử dụng tháng/năm được chọn hoặc mặc định là tháng/năm hiện tại
            var selectedMonth = month ?? DateTime.UtcNow.Month;
            var selectedYear = year ?? DateTime.UtcNow.Year;
            
            // Validate month and year
            if (selectedMonth < 1 || selectedMonth > 12)
                selectedMonth = DateTime.UtcNow.Month;
            if (selectedYear < 2000 || selectedYear > 2100)
                selectedYear = DateTime.UtcNow.Year;
            
            var today = DateTime.UtcNow.Date;
            var selectedMonthStart = new DateTime(selectedYear, selectedMonth, 1);
            var selectedMonthEnd = selectedMonthStart.AddMonths(1).AddDays(-1);

            var viewModel = new DashboardViewModel
            {
                TotalProducts = await _context.Products.CountAsync(),
                TotalOrders = await _context.Orders
                    .Where(o => o.OrderDate >= selectedMonthStart && o.OrderDate <= selectedMonthEnd)
                    .CountAsync(),
                TotalRevenue = await _context.OrderItems
                    .SumAsync(oi => oi.Quantity * oi.Price),
                TotalUsers = await _userManager.Users.CountAsync(),
                PendingOrders = await _context.Orders
                    .Where(o => o.Status == "Pending" && o.OrderDate >= selectedMonthStart && o.OrderDate <= selectedMonthEnd)
                    .CountAsync(),
                ProcessingOrders = await _context.Orders
                    .Where(o => o.Status == "Processing" && o.OrderDate >= selectedMonthStart && o.OrderDate <= selectedMonthEnd)
                    .CountAsync(),
                ShippedOrders = await _context.Orders
                    .Where(o => o.Status == "Shipped" && o.OrderDate >= selectedMonthStart && o.OrderDate <= selectedMonthEnd)
                    .CountAsync(),
                DeliveredOrders = await _context.Orders
                    .Where(o => o.Status == "Delivered" && o.OrderDate >= selectedMonthStart && o.OrderDate <= selectedMonthEnd)
                    .CountAsync(),
                LowStockProducts = await _context.Products.CountAsync(p => p.Stock < 10),
                TodayRevenue = await _context.OrderItems
                    .Join(_context.Orders, oi => oi.OrderId, o => o.Id, (oi, o) => new { oi, o })
                    .Where(x => x.o.OrderDate >= today)
                    .SumAsync(x => x.oi.Quantity * x.oi.Price),
                ThisMonthRevenue = await _context.OrderItems
                    .Join(_context.Orders, oi => oi.OrderId, o => o.Id, (oi, o) => new { oi, o })
                    .Where(x => x.o.OrderDate >= selectedMonthStart && x.o.OrderDate <= selectedMonthEnd)
                    .SumAsync(x => x.oi.Quantity * x.oi.Price),
                RecentOrders = await _context.Orders
                    .Include(o => o.User)
                    .Where(o => o.OrderDate >= selectedMonthStart && o.OrderDate <= selectedMonthEnd)
                    .OrderByDescending(o => o.OrderDate)
                    .Take(5)
                    .ToListAsync(),
                TopSellingProducts = await _context.OrderItems
                    .Include(oi => oi.Product)
                    .Include(oi => oi.Order)
                    .Where(oi => oi.Order != null && oi.Order.OrderDate >= selectedMonthStart && oi.Order.OrderDate <= selectedMonthEnd)
                    .GroupBy(oi => new { oi.ProductId, oi.Product!.Name })
                    .Select(g => new TopSellingProduct
                    {
                        ProductId = g.Key.ProductId,
                        ProductName = g.Key.Name ?? "Unknown",
                        TotalSold = g.Sum(oi => oi.Quantity),
                        TotalRevenue = g.Sum(oi => oi.Quantity * oi.Price)
                    })
                    .OrderByDescending(x => x.TotalSold)
                    .Take(5)
                    .ToListAsync(),
                SelectedMonth = selectedMonth,
                SelectedYear = selectedYear
            };

            return View(viewModel);
        }

        // GET: Admin/Products
        public async Task<IActionResult> Products(int page = 1, int pageSize = 10)
        {
            // Validate pageSize - chỉ cho phép các giá trị hợp lệ
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

            // Lấy tổng số sản phẩm
            var totalItems = await _context.Products.CountAsync();

            // Lấy sản phẩm với pagination
            var products = await _context.Products
                .Include(p => p.Category)
                .OrderByDescending(p => p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var viewModel = new ProductsViewModel
            {
                Products = products,
                CurrentPage = page,
                PageSize = pageSize,
                TotalItems = totalItems
            };

            return View(viewModel);
        }

        // GET: Admin/Create
        public async Task<IActionResult> Create()
        {
            ViewBag.Categories = await _context.Categories.OrderBy(c => c.Name).ToListAsync();
            return View();
        }

        // POST: Admin/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Product product)
        {
            if (ModelState.IsValid)
            {
                product.CreatedAt = DateTime.UtcNow;
                _context.Add(product);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Products));
            }
            ViewBag.Categories = await _context.Categories.OrderBy(c => c.Name).ToListAsync();
            return View(product);
        }

        // GET: Admin/Edit/5
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

            ViewBag.Categories = await _context.Categories.OrderBy(c => c.Name).ToListAsync();
            return View(product);
        }

        // POST: Admin/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Product product)
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
                return RedirectToAction(nameof(Products));
            }
            ViewBag.Categories = await _context.Categories.OrderBy(c => c.Name).ToListAsync();
            return View(product);
        }

        // GET: Admin/Delete/5
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

        // POST: Admin/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product != null)
            {
                _context.Products.Remove(product);
                await _context.SaveChangesAsync();
            }

            return RedirectToAction(nameof(Products));
        }

        // POST: Admin/DeleteSelected
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteSelected(string productIds)
        {
            if (string.IsNullOrEmpty(productIds))
            {
                return RedirectToAction(nameof(Products));
            }

            var ids = productIds.Split(',')
                .Select(id => int.TryParse(id, out var parsedId) ? parsedId : 0)
                .Where(id => id > 0)
                .ToList();

            if (ids.Any())
            {
                var products = await _context.Products
                    .Where(p => ids.Contains(p.Id))
                    .ToListAsync();

                if (products.Any())
                {
                    _context.Products.RemoveRange(products);
                    await _context.SaveChangesAsync();
                }
            }

            return RedirectToAction(nameof(Products));
        }

        // GET: Admin/Orders
        public async Task<IActionResult> Orders(int page = 1, int pageSize = 10, string status = "")
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

            // Build query
            var query = _context.Orders.AsQueryable();

            // Filter by status if provided
            if (!string.IsNullOrEmpty(status))
            {
                var allowedStatuses = new[] { "Pending", "Processing", "Shipped", "Delivered", "Cancelled" };
                if (allowedStatuses.Contains(status))
                {
                    query = query.Where(o => o.Status == status);
                }
            }

            // Get total orders count
            var totalItems = await query.CountAsync();

            // Get orders with pagination
            var orders = await query
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .OrderByDescending(o => o.OrderDate)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var viewModel = new OrdersViewModel
            {
                Orders = orders,
                CurrentPage = page,
                PageSize = pageSize,
                TotalItems = totalItems
            };

            ViewBag.CurrentStatus = status;
            return View(viewModel);
        }

        // GET: Admin/OrderDetails/5
        public async Task<IActionResult> OrderDetails(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var order = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (order == null)
            {
                return NotFound();
            }

            return View(order);
        }

        // POST: Admin/UpdateOrderStatus
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateOrderStatus(int id, string status)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return NotFound();
            }

            // Không cho phép thay đổi trạng thái nếu đã Cancelled hoặc Delivered
            if (order.Status == "Cancelled" || order.Status == "Delivered")
            {
                TempData["ErrorMessage"] = "Cannot update status for cancelled or delivered orders.";
                return RedirectToAction(nameof(Orders));
            }

            var allowedStatuses = new[] { "Pending", "Processing", "Shipped", "Delivered", "Cancelled" };
            if (allowedStatuses.Contains(status))
            {
                order.Status = status;
                await _context.SaveChangesAsync();
            }

            return RedirectToAction(nameof(Orders));
        }

        // POST: Admin/CancelOrder
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CancelOrder(int id)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return NotFound();
            }

            // Không cho phép hủy nếu đã Cancelled hoặc Delivered
            if (order.Status == "Cancelled")
            {
                TempData["ErrorMessage"] = "This order is already cancelled.";
                return RedirectToAction(nameof(Orders));
            }

            if (order.Status == "Delivered")
            {
                TempData["ErrorMessage"] = "Cannot cancel a delivered order.";
                return RedirectToAction(nameof(Orders));
            }

            order.Status = "Cancelled";
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(Orders));
        }

        // POST: Admin/CompleteOrder
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CompleteOrder(int id)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return NotFound();
            }

            // Không cho phép hoàn thành nếu đã Cancelled hoặc Delivered
            if (order.Status == "Delivered")
            {
                TempData["ErrorMessage"] = "This order is already delivered.";
                return RedirectToAction(nameof(Orders));
            }

            if (order.Status == "Cancelled")
            {
                TempData["ErrorMessage"] = "Cannot complete a cancelled order.";
                return RedirectToAction(nameof(Orders));
            }

            order.Status = "Delivered";
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(Orders));
        }

        private bool ProductExists(int id)
        {
            return _context.Products.Any(e => e.Id == id);
        }

        // GET: Admin/Users
        public async Task<IActionResult> Users(int page = 1, int pageSize = 10, string? searchTerm = null)
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

            // Query users
            var usersQuery = _userManager.Users.AsQueryable();

            // Apply search filter
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim();
                usersQuery = usersQuery.Where(u =>
                    u.UserName!.Contains(searchTerm) ||
                    u.Email!.Contains(searchTerm) ||
                    (u.FullName != null && u.FullName.Contains(searchTerm)) ||
                    (u.FirstName != null && u.FirstName.Contains(searchTerm)) ||
                    (u.LastName != null && u.LastName.Contains(searchTerm))
                );
            }

            // Get total count
            var totalItems = await usersQuery.CountAsync();

            // Get users with pagination
            var users = await usersQuery
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            // Get roles for each user
            var usersWithRoles = new List<object>();
            foreach (var user in users)
            {
                var roles = await _userManager.GetRolesAsync(user);
                usersWithRoles.Add(new
                {
                    User = user,
                    Roles = roles
                });
            }

            var viewModel = new UsersViewModel
            {
                Users = users,
                CurrentPage = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                SearchTerm = searchTerm
            };

            ViewBag.UsersWithRoles = usersWithRoles;
            return View(viewModel);
        }

        // GET: Admin/UserDetails
        public async Task<IActionResult> UserDetails(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            // Get user roles
            var roles = await _userManager.GetRolesAsync(user);
            
            // Get user orders
            var orders = await _context.Orders
                .Where(o => o.UserId == id)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .OrderByDescending(o => o.OrderDate)
                .Take(10)
                .ToListAsync();

            ViewBag.UserRoles = roles;
            ViewBag.UserOrders = orders;
            return View(user);
        }

        // POST: Admin/LockUser
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> LockUser(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            // Prevent locking yourself
            var currentUserId = _userManager.GetUserId(User);
            if (id == currentUserId)
            {
                TempData["ErrorMessage"] = "You cannot lock your own account.";
                return RedirectToAction(nameof(Users));
            }

            // Lock account until year 2099 (effectively permanent unless unlocked)
            user.LockoutEnd = DateTimeOffset.UtcNow.AddYears(100);
            var result = await _userManager.UpdateAsync(user);

            if (result.Succeeded)
            {
                TempData["SuccessMessage"] = "User account has been locked successfully.";
            }
            else
            {
                TempData["ErrorMessage"] = "Error locking user: " + string.Join(", ", result.Errors.Select(e => e.Description));
            }

            return RedirectToAction(nameof(Users));
        }

        // POST: Admin/UnlockUser
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UnlockUser(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            // Unlock account
            user.LockoutEnd = null;
            var result = await _userManager.UpdateAsync(user);

            if (result.Succeeded)
            {
                TempData["SuccessMessage"] = "User account has been unlocked successfully.";
            }
            else
            {
                TempData["ErrorMessage"] = "Error unlocking user: " + string.Join(", ", result.Errors.Select(e => e.Description));
            }

            return RedirectToAction(nameof(Users));
        }

        // POST: Admin/ChangeUserRole
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangeUserRole(string id, string role)
        {
            if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(role))
            {
                return NotFound();
            }

            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            // Prevent changing your own role
            var currentUserId = _userManager.GetUserId(User);
            if (id == currentUserId)
            {
                TempData["ErrorMessage"] = "You cannot change your own role.";
                return RedirectToAction(nameof(Users));
            }

            // Validate role exists
            if (!await _roleManager.RoleExistsAsync(role))
            {
                TempData["ErrorMessage"] = $"Role '{role}' does not exist.";
                return RedirectToAction(nameof(Users));
            }

            // Get current roles
            var currentRoles = await _userManager.GetRolesAsync(user);
            
            // Remove all current roles
            if (currentRoles.Any())
            {
                var removeResult = await _userManager.RemoveFromRolesAsync(user, currentRoles);
                if (!removeResult.Succeeded)
                {
                    TempData["ErrorMessage"] = "Error removing current roles: " + string.Join(", ", removeResult.Errors.Select(e => e.Description));
                    return RedirectToAction(nameof(Users));
                }
            }

            // Add new role
            var addResult = await _userManager.AddToRoleAsync(user, role);
            if (addResult.Succeeded)
            {
                TempData["SuccessMessage"] = $"User role has been changed to '{role}' successfully.";
            }
            else
            {
                TempData["ErrorMessage"] = "Error changing role: " + string.Join(", ", addResult.Errors.Select(e => e.Description));
            }

            return RedirectToAction(nameof(Users));
        }
    }
}


