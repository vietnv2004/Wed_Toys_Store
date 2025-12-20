using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Controllers
{
    [Authorize]
    public class CheckoutController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CheckoutController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: /Checkout
        public async Task<IActionResult> Index()
        {
            var cart = GetCart();
            if (cart == null || !cart.Any())
            {
                return RedirectToAction("Index", "Cart");
            }

            var subtotal = cart.Sum(item => item.Subtotal);
            var shippingFee = subtotal >= 500000 ? 0 : 30000;
            var total = subtotal + shippingFee;

            var viewModel = new CheckoutViewModel
            {
                CartItems = cart,
                Subtotal = subtotal,
                ShippingFee = shippingFee,
                Total = total,
                DiscountAmount = 0,
                DiscountCode = null
            };

            // Pre-fill user info if available
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
            var userId = userIdClaim?.Value;
            var user = !string.IsNullOrEmpty(userId) ? _context.Users.FirstOrDefault(u => u.Id == userId) : null;
            if (user != null)
            {
                viewModel.Email = user.Email ?? string.Empty;
                viewModel.FullName = $"{user.FirstName} {user.LastName}".Trim();
                viewModel.PhoneNumber = user.PhoneNumber ?? string.Empty;
                viewModel.ShippingAddress = user.Address ?? string.Empty;
            }

            // Load danh sách mã giảm giá phù hợp với subtotal
            var today = DateTime.UtcNow.Date;
            ViewBag.DiscountCodes = await _context.DiscountCodes
                .Where(d => d.IsActive && d.ExpiryDate.Date >= today && d.MinOrderAmount <= subtotal)
                .OrderByDescending(d => d.DiscountAmount)
                .ToListAsync();

            return View(viewModel);
        }

        // POST: /Checkout/ApplyDiscountCode (AJAX)
        [HttpPost]
        public async Task<IActionResult> ApplyDiscountCode(string code, decimal subtotal)
        {
            if (string.IsNullOrWhiteSpace(code))
            {
                return Json(new { success = false, message = "Please enter a discount code." });
            }

            var today = DateTime.UtcNow.Date;
            var codeUpper = code.ToUpper();
            var discountCode = await _context.DiscountCodes
                .FirstOrDefaultAsync(d =>
                    d.Code.ToUpper() == codeUpper &&
                    d.IsActive &&
                    d.ExpiryDate.Date >= today &&
                    (d.MaxUsage == 0 || d.UsedCount < d.MaxUsage));

            if (discountCode == null)
            {
                return Json(new { success = false, message = "This discount code is invalid or has expired." });
            }

            if (discountCode.MinOrderAmount > subtotal)
            {
                var missingAmount = discountCode.MinOrderAmount - subtotal;
                return Json(new
                {
                    success = false,
                    message = $"Minimum order amount to use this code is {discountCode.MinOrderAmount:N0}₫. Add {missingAmount:N0}₫ more to apply it."
                });
            }

            return Json(new
            {
                success = true,
                discountAmount = discountCode.DiscountAmount,
                code = discountCode.Code,
                message = $"Discount applied successfully! You saved {discountCode.DiscountAmount:N0}₫."
            });
        }

        // POST: /Checkout (đặt hàng)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Index(CheckoutViewModel model)
        {
            var cart = GetCart();
            if (cart == null || !cart.Any())
            {
                ModelState.AddModelError("", "Your cart is empty.");
                return RedirectToAction("Index", "Cart");
            }

            if (!ModelState.IsValid)
            {
                model.CartItems = cart;
                var subtotal = cart.Sum(item => item.Subtotal);
                var shippingFee = subtotal >= 500000 ? 0 : 30000;
                model.Subtotal = subtotal;
                model.ShippingFee = shippingFee;

                // vẫn giữ discount người dùng đã nhập (nếu có)
                var discount = model.DiscountAmount;
                if (discount < 0) discount = 0;
                model.Total = subtotal + shippingFee - discount;

                // load lại danh sách mã giảm giá
                var today = DateTime.UtcNow.Date;
                ViewBag.DiscountCodes = await _context.DiscountCodes
                    .Where(d => d.IsActive && d.ExpiryDate.Date >= today && d.MinOrderAmount <= subtotal)
                    .OrderByDescending(d => d.DiscountAmount)
                    .ToListAsync();

                return View(model);
            }

            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login", "Account");
            }

            // Recalculate totals và xác thực discount code lần cuối trên server
            var recalculatedSubtotal = cart.Sum(item => item.Subtotal);
            var recalculatedShippingFee = recalculatedSubtotal >= 500000 ? 0 : 30000;
            decimal validDiscountAmount = 0;
            DiscountCode? appliedCode = null;

            if (!string.IsNullOrWhiteSpace(model.DiscountCode))
            {
                var today = DateTime.UtcNow.Date;
                var codeUpper = model.DiscountCode.ToUpper();
                var discountCode = await _context.DiscountCodes
                    .FirstOrDefaultAsync(d =>
                        d.Code.ToUpper() == codeUpper &&
                        d.IsActive &&
                        d.ExpiryDate.Date >= today &&
                        d.MinOrderAmount <= recalculatedSubtotal &&
                        (d.MaxUsage == 0 || d.UsedCount < d.MaxUsage));

                if (discountCode != null)
                {
                    validDiscountAmount = discountCode.DiscountAmount;
                    appliedCode = discountCode;
                }
            }

            var finalTotal = recalculatedSubtotal + recalculatedShippingFee - validDiscountAmount;

            var order = new Order
            {
                UserId = userId,
                OrderDate = DateTime.UtcNow,
                ShippingAddress = model.ShippingAddress,
                Status = "Pending",
                TotalAmount = finalTotal
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Increase UsedCount for the applied discount code (if any and if limited)
            if (appliedCode != null && appliedCode.MaxUsage > 0)
            {
                appliedCode.UsedCount += 1;
                await _context.SaveChangesAsync();
            }

            foreach (var cartItem in cart)
            {
                var orderItem = new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = cartItem.ProductId,
                    Quantity = cartItem.Quantity,
                    Price = cartItem.Price
                };
                _context.OrderItems.Add(orderItem);

                var product = await _context.Products.FindAsync(cartItem.ProductId);
                if (product != null)
                {
                    product.Stock -= cartItem.Quantity;
                }
            }

            await _context.SaveChangesAsync();

            HttpContext.Session.Remove("Cart");

            return RedirectToAction("OrderConfirmation", "Orders", new { id = order.Id });
        }

        // Helper: đọc giỏ hàng từ session (re-use logic cũ)
        private List<CartItem>? GetCart()
        {
            var cartJson = HttpContext.Session.GetString("Cart");
            if (string.IsNullOrEmpty(cartJson))
            {
                return null;
            }
            return JsonSerializer.Deserialize<List<CartItem>>(cartJson);
        }
    }
}


