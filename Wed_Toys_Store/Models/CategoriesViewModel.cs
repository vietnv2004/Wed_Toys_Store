using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Models
{
    public class CategoriesViewModel
    {
        public IEnumerable<Category> Categories { get; set; } = new List<Category>();
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);
        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;
        
        // Search property
        public string? SearchKeyword { get; set; }
    }
}

