using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Controllers.Admin
{
    [Authorize(Roles = "Admin")]
    public class AdminDashboardController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;

        public AdminDashboardController(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // GET: Admin/Dashboard
        public async Task<IActionResult> Index(int? month, int? year, DateTime? fromDate, DateTime? toDate)
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

            return View(viewModel);
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
    }
}

