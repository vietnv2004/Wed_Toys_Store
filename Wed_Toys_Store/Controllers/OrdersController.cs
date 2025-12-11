using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;
using System.Linq;
using System.Threading.Tasks;

namespace Wed_Toys_Store.Controllers
{
    [Authorize]
    public class OrdersController : Controller
    {
        private readonly ApplicationDbContext _context;

        public OrdersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Orders/Checkout
        public IActionResult Checkout()
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
                Total = total
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

            return View(viewModel);
        }

        // POST: Orders/Checkout
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Checkout(CheckoutViewModel model)
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
                model.Total = subtotal + shippingFee;
                return View(model);
            }

            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login", "Account");
            }

            // Create order
            var order = new Order
            {
                UserId = userId,
                OrderDate = DateTime.UtcNow,
                ShippingAddress = model.ShippingAddress,
                Status = "Pending",
                TotalAmount = model.Total
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Create order items
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

                // Update product stock
                var product = await _context.Products.FindAsync(cartItem.ProductId);
                if (product != null)
                {
                    product.Stock -= cartItem.Quantity;
                }
            }

            await _context.SaveChangesAsync();

            // Clear cart
            HttpContext.Session.Remove("Cart");

            return RedirectToAction("OrderConfirmation", new { id = order.Id });
        }

        // GET: Orders/OrderConfirmation
        public async Task<IActionResult> OrderConfirmation(int id)
        {
            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == id && o.UserId == userId);

            if (order == null)
            {
                return NotFound();
            }

            return View(order);
        }

        // GET: Orders/History
        public async Task<IActionResult> History()
        {
            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login", "Account");
            }

            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();

            return View(orders);
        }

        // Helper methods
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



