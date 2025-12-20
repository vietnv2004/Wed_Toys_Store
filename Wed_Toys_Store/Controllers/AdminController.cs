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

        // GET: /Admin
        // Điều hướng mặc định vào Dashboard
        public IActionResult Index()
        {
            return RedirectToAction(nameof(Dashboard));
        }

        // GET: Admin/Dashboard
        public async Task<IActionResult> Dashboard(int? month, int? year, DateTime? fromDate, DateTime? toDate)
        {
            var today = DateTime.UtcNow.Date;
            DateTime startDate, endDate;
            int? selectedMonth = null;
            int? selectedYear = null;
            
            // Ưu tiên filter theo khoảng thời gian (fromDate - toDate)
            if (fromDate.HasValue && toDate.HasValue)
            {
                startDate = fromDate.Value.Date;
                endDate = toDate.Value.Date.AddDays(1).AddSeconds(-1); // Đến cuối ngày
                
                // Validate: fromDate phải <= toDate
                if (startDate > endDate)
                {
                    // Nếu fromDate > toDate, đổi chỗ
                    var temp = startDate;
                    startDate = endDate;
                    endDate = temp;
                }
            }
            else
            {
                // Mặc định: từ đầu tháng hiện tại đến hôm nay
                var now = DateTime.UtcNow;
                startDate = new DateTime(now.Year, now.Month, 1);
                endDate = today.AddDays(1).AddSeconds(-1); // Đến cuối ngày hôm nay
                
                // Set giá trị mặc định cho FromDate và ToDate
                fromDate = startDate;
                toDate = today;
            }

            var viewModel = new DashboardViewModel
            {
                TotalProducts = await _context.Products.CountAsync(),
                TotalOrders = await _context.Orders
                    .Where(o => o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .CountAsync(),
                // Doanh thu chỉ tính đơn đã giao/hoàn tất (tính phía client để tránh lỗi aggregate lồng nhau)
                TotalRevenue = (await _context.Orders
                    .Where(o => o.Status == "Completed" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .Include(o => o.OrderItems)
                    .Select(o => new
                    {
                        o.TotalAmount,
                        OrderItems = o.OrderItems.Select(oi => new { oi.Quantity, oi.Price })
                    })
                    .ToListAsync())
                    .Sum(x => x.TotalAmount > 0
                        ? x.TotalAmount
                        : x.OrderItems.Sum(oi => oi.Quantity * oi.Price)),
                TotalUsers = await _userManager.Users.CountAsync(),
                PendingOrders = await _context.Orders
                    .Where(o => o.Status == "Pending" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .CountAsync(),
                ProcessingOrders = await _context.Orders
                    .Where(o => o.Status == "Processing" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .CountAsync(),
                ShippedOrders = await _context.Orders
                    .Where(o => o.Status == "Shipped" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .CountAsync(),
                DeliveredOrders = await _context.Orders
                    .Where(o => o.Status == "Completed" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .CountAsync(),
                LowStockProducts = await _context.Products.CountAsync(p => p.Stock < 10),
                TodayRevenue = (await _context.Orders
                    .Where(o => o.Status == "Completed" && o.OrderDate >= today && o.OrderDate < today.AddDays(1))
                    .Include(o => o.OrderItems)
                    .Select(o => new
                    {
                        o.TotalAmount,
                        OrderItems = o.OrderItems.Select(oi => new { oi.Quantity, oi.Price })
                    })
                    .ToListAsync())
                    .Sum(x => x.TotalAmount > 0
                        ? x.TotalAmount
                        : x.OrderItems.Sum(oi => oi.Quantity * oi.Price)),
                ThisMonthRevenue = (await _context.Orders
                    .Where(o => o.Status == "Completed" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .Include(o => o.OrderItems)
                    .Select(o => new
                    {
                        o.TotalAmount,
                        OrderItems = o.OrderItems.Select(oi => new { oi.Quantity, oi.Price })
                    })
                    .ToListAsync())
                    .Sum(x => x.TotalAmount > 0
                        ? x.TotalAmount
                        : x.OrderItems.Sum(oi => oi.Quantity * oi.Price)),
                RecentOrders = await _context.Orders
                    .Include(o => o.User)
                    .Include(o => o.OrderItems)
                    .Where(o => o.OrderDate >= startDate && o.OrderDate <= endDate)
                    .OrderByDescending(o => o.OrderDate)
                    .Take(5)
                    .ToListAsync(),
                TopSellingProducts = await _context.OrderItems
                    .Include(oi => oi.Product)
                    .Include(oi => oi.Order)
                    .Where(oi => oi.Order != null && oi.Order.OrderDate >= startDate && oi.Order.OrderDate <= endDate)
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
                SelectedYear = selectedYear,
                FromDate = fromDate,
                ToDate = toDate,
                // Tính doanh thu theo từng ngày trong khoảng thời gian
                DailyRevenues = await GetDailyRevenues(startDate, endDate)
            };

            return View("Dashboard/Index", viewModel);
        }

        private async Task<List<DailyRevenue>> GetDailyRevenues(DateTime startDate, DateTime endDate)
        {
            var orders = await _context.Orders
                .Where(o => o.Status == "Completed" && o.OrderDate >= startDate && o.OrderDate <= endDate)
                .Include(o => o.OrderItems)
                .ToListAsync();

            var dailyRevenues = new List<DailyRevenue>();
            var currentDate = startDate;

            while (currentDate <= endDate)
            {
                var dayOrders = orders.Where(o => o.OrderDate.Date == currentDate.Date).ToList();
                var revenue = dayOrders.Sum(o => o.TotalAmount > 0
                    ? o.TotalAmount
                    : o.OrderItems.Sum(oi => oi.Quantity * oi.Price));

                dailyRevenues.Add(new DailyRevenue
                {
                    Date = currentDate,
                    Revenue = revenue
                });

                currentDate = currentDate.AddDays(1);
            }

            return dailyRevenues;
        }

        // GET: Admin/Products
        public async Task<IActionResult> Products(int page = 1, int pageSize = 10, string? searchKeyword = null, int? categoryId = null, string? status = null)
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

            // Bắt đầu với query cơ bản
            var query = _context.Products.Include(p => p.Category).AsQueryable();

            // Filter by Search Keyword
            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                var keyword = searchKeyword.Trim();
                query = query.Where(p => 
                    p.Name.Contains(keyword) ||
                    (p.Description != null && p.Description.Contains(keyword)) ||
                    (p.Brand != null && p.Brand.Contains(keyword)) ||
                    (p.Category != null && p.Category.Name.Contains(keyword))
                );
            }

            // Filter by Category
            if (categoryId.HasValue && categoryId.Value > 0)
            {
                query = query.Where(p => p.CategoryId == categoryId.Value);
            }

            // Filter by Status (Active = Stock > 0, Inactive = Stock <= 0)
            if (!string.IsNullOrWhiteSpace(status))
            {
                if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(p => p.Stock > 0);
                }
                else if (status.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(p => p.Stock <= 0);
                }
            }

            // Lấy tổng số sản phẩm sau khi filter
            var totalItems = await query.CountAsync();

            // Lấy sản phẩm với pagination và sắp xếp
            var products = await query
                .OrderByDescending(p => p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            // Lấy danh sách categories để populate dropdown
            var categories = await _context.Categories
                .OrderBy(c => c.Name)
                .ToListAsync();

            var viewModel = new ProductsViewModel
            {
                Products = products,
                CurrentPage = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                SearchKeyword = searchKeyword,
                CategoryId = categoryId,
                Status = status,
                Categories = categories
            };

            return View("Products/Index", viewModel);
        }

        // GET: Admin/Create
        public async Task<IActionResult> Create()
        {
            ViewBag.Categories = await _context.Categories.OrderBy(c => c.Name).ToListAsync();
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View("Products/Create");
        }

        // POST: Admin/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
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
                return RedirectToAction(nameof(Products));
            }
            ViewBag.Categories = await _context.Categories.OrderBy(c => c.Name).ToListAsync();
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View("Products/Create", product);
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
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View("Products/Edit", product);
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
            ViewBag.Brands = await _context.Brands
                .Where(b => b.IsActive)
                .OrderBy(b => b.DisplayOrder)
                .ThenBy(b => b.Name)
                .Select(b => b.Name)
                .ToListAsync();
            return View("Products/Edit", product);
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

            return View("Products/Delete", product);
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
        public async Task<IActionResult> Orders(int page = 1, int pageSize = 10, string? status = null, string? searchKeyword = null, DateTime? dateFrom = null, DateTime? dateTo = null)
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
            var query = _context.Orders.Include(o => o.User).AsQueryable();

            // Filter by search keyword (Order ID or Customer name/email)
            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                var keyword = searchKeyword.Trim();
                // Try to parse as order ID
                if (int.TryParse(keyword, out int orderId))
                {
                    query = query.Where(o => o.Id == orderId);
                }
                else
                {
                    // Search by customer name or email
                    query = query.Where(o => 
                        (o.User != null && o.User.Email != null && o.User.Email.Contains(keyword)) ||
                        (o.User != null && o.User.FullName != null && o.User.FullName.Contains(keyword))
                    );
                }
            }

            // Filter by status if provided
            if (!string.IsNullOrEmpty(status))
            {
                var allowedStatuses = new[] { "Pending", "Processing", "Shipped", "Completed", "Cancelled" };
                if (allowedStatuses.Contains(status))
                {
                    query = query.Where(o => o.Status == status);
                }
            }

            // Filter by date range
            if (dateFrom.HasValue)
            {
                query = query.Where(o => o.OrderDate.Date >= dateFrom.Value.Date);
            }

            if (dateTo.HasValue)
            {
                query = query.Where(o => o.OrderDate.Date <= dateTo.Value.Date);
            }

            // Get total orders count
            var totalItems = await query.CountAsync();

            // Get orders with pagination
            var orders = await query
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
                TotalItems = totalItems,
                SearchKeyword = searchKeyword,
                Status = status,
                DateFrom = dateFrom,
                DateTo = dateTo
            };

            return View("Orders/Index", viewModel);
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

            return View("Orders/Details", order);
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

            // Không cho phép thay đổi trạng thái nếu đã Cancelled hoặc Completed
            if (order.Status == "Cancelled" || order.Status == "Completed")
            {
                TempData["ErrorMessage"] = "Cannot update status for cancelled or completed orders.";
                return RedirectToAction(nameof(Orders));
            }

            var allowedStatuses = new[] { "Pending", "Processing", "Shipped", "Completed", "Cancelled" };
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

            // Không cho phép hủy nếu đã Cancelled hoặc Completed
            if (order.Status == "Cancelled")
            {
                TempData["ErrorMessage"] = "This order is already cancelled.";
                return RedirectToAction(nameof(Orders));
            }

            if (order.Status == "Completed")
            {
                TempData["ErrorMessage"] = "Cannot cancel a completed order.";
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

            // Không cho phép hoàn thành nếu đã Cancelled hoặc Completed
            if (order.Status == "Completed")
            {
                TempData["ErrorMessage"] = "This order is already completed.";
                return RedirectToAction(nameof(Orders));
            }

            if (order.Status == "Cancelled")
            {
                TempData["ErrorMessage"] = "Cannot complete a cancelled order.";
                return RedirectToAction(nameof(Orders));
            }

            order.Status = "Completed";
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
            return View("Users/Index", viewModel);
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
            return View("Users/Details", user);
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
            try
            {
                if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(role))
                {
                    TempData["ErrorMessage"] = "Invalid user ID or role.";
                    return RedirectToAction(nameof(Users));
                }

                var user = await _userManager.FindByIdAsync(id);
                if (user == null)
                {
                    TempData["ErrorMessage"] = "User not found.";
                    return RedirectToAction(nameof(Users));
                }

                // Prevent changing your own role
                var currentUserId = _userManager.GetUserId(User);
                if (id == currentUserId)
                {
                    TempData["ErrorMessage"] = "You cannot change your own role.";
                    return RedirectToAction(nameof(Users));
                }

                // Ensure role exists, create if not
                if (!await _roleManager.RoleExistsAsync(role))
                {
                    var createRoleResult = await _roleManager.CreateAsync(new IdentityRole(role));
                    if (!createRoleResult.Succeeded)
                    {
                        TempData["ErrorMessage"] = $"Failed to create role '{role}': " + string.Join(", ", createRoleResult.Errors.Select(e => e.Description));
                        return RedirectToAction(nameof(Users));
                    }
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
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = $"An error occurred: {ex.Message}";
            }

            return RedirectToAction(nameof(Users));
        }
    }
}


