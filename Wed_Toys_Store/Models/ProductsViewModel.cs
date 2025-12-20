using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Models
{
    public class ProductsViewModel
    {
        public IEnumerable<Product> Products { get; set; } = new List<Product>();
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);
        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;
        
        // Search and Filter properties
        public string? SearchKeyword { get; set; }
        public int? CategoryId { get; set; }
        public string? Status { get; set; } // "Active" or "Inactive"
        public IEnumerable<Category> Categories { get; set; } = new List<Category>();
    }
}









