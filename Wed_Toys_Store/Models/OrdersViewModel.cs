using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Models
{
    public class OrdersViewModel
    {
        public IEnumerable<Order> Orders { get; set; } = new List<Order>();
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);
        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;
        
        // Search and Filter properties
        public string? SearchKeyword { get; set; }
        public string? Status { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
    }
}









