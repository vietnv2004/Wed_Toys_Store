using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Wed_Toys_Store.Data;
using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Controllers
{
    [Authorize]
    public class FavoriteProductsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public FavoriteProductsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: FavoriteProducts
        public async Task<IActionResult> Index()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login", "Account");
            }

            var favoriteProducts = await _context.FavoriteProducts
                .Include(f => f.Product)
                    .ThenInclude(p => p!.Category)
                .Where(f => f.UserId == userId)
                .OrderByDescending(f => f.AddedAt)
                .ToListAsync();

            return View(favoriteProducts);
        }

        // POST: FavoriteProducts/AddToFavorites
        [HttpPost]
        public async Task<IActionResult> AddToFavorites(int productId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Json(new { success = false, message = "Please login to add favorites" });
            }

            // Check if product exists
            var product = await _context.Products.FindAsync(productId);
            if (product == null)
            {
                return Json(new { success = false, message = "Product not found" });
            }

            // Check if already in favorites
            var existingFavorite = await _context.FavoriteProducts
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId);

            if (existingFavorite != null)
            {
                return Json(new { success = false, message = "Product already in favorites" });
            }

            // Add to favorites
            var favoriteProduct = new FavoriteProduct
            {
                UserId = userId,
                ProductId = productId,
                AddedAt = DateTime.UtcNow
            };

            _context.FavoriteProducts.Add(favoriteProduct);
            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Product added to favorites" });
        }

        // POST: FavoriteProducts/RemoveFromFavorites
        [HttpPost]
        public async Task<IActionResult> RemoveFromFavorites(int productId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Json(new { success = false, message = "Please login" });
            }

            var favoriteProduct = await _context.FavoriteProducts
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId);

            if (favoriteProduct == null)
            {
                return Json(new { success = false, message = "Product not in favorites" });
            }

            _context.FavoriteProducts.Remove(favoriteProduct);
            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Product removed from favorites" });
        }

        // POST: FavoriteProducts/ToggleFavorite
        [HttpPost]
        public async Task<IActionResult> ToggleFavorite(int productId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Json(new { success = false, message = "Please login to manage favorites", isFavorite = false });
            }

            // Check if product exists
            var product = await _context.Products.FindAsync(productId);
            if (product == null)
            {
                return Json(new { success = false, message = "Product not found", isFavorite = false });
            }

            // Check if already in favorites
            var existingFavorite = await _context.FavoriteProducts
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId);

            if (existingFavorite != null)
            {
                // Remove from favorites
                _context.FavoriteProducts.Remove(existingFavorite);
                await _context.SaveChangesAsync();
                return Json(new { success = true, message = "Product removed from favorites", isFavorite = false });
            }
            else
            {
                // Add to favorites
                var favoriteProduct = new FavoriteProduct
                {
                    UserId = userId,
                    ProductId = productId,
                    AddedAt = DateTime.UtcNow
                };

                _context.FavoriteProducts.Add(favoriteProduct);
                await _context.SaveChangesAsync();
                return Json(new { success = true, message = "Product added to favorites", isFavorite = true });
            }
        }

        // POST: FavoriteProducts/RemoveFromFavoritesList
        [HttpPost]
        public async Task<IActionResult> RemoveFromFavoritesList(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Json(new { success = false, message = "Please login" });
            }

            var favoriteProduct = await _context.FavoriteProducts
                .FirstOrDefaultAsync(f => f.Id == id && f.UserId == userId);

            if (favoriteProduct == null)
            {
                return Json(new { success = false, message = "Favorite product not found" });
            }

            _context.FavoriteProducts.Remove(favoriteProduct);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Product removed from favorites";
            return RedirectToAction(nameof(Index));
        }
    }
}

