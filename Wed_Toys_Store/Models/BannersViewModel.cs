using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Models
{
    public class BannersViewModel
    {
        public IEnumerable<Banner> Banners { get; set; } = new List<Banner>();
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);
        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;
        
        // Search and Filter properties
        public string? SearchKeyword { get; set; }
        public string? Status { get; set; }
    }
}

