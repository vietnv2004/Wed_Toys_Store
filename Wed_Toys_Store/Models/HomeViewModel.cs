using Wed_Toys_Store.Models;

namespace Wed_Toys_Store.Models
{
    public class HomeViewModel
    {
        public IEnumerable<Banner> Banners { get; set; } = new List<Banner>();
        public IEnumerable<Category> HotCategories { get; set; } = new List<Category>();
        public IEnumerable<Product> NewArrivals { get; set; } = new List<Product>();
        public IEnumerable<Product> BestSellers { get; set; } = new List<Product>();
        public IEnumerable<Product> FeaturedProducts { get; set; } = new List<Product>();
    }
}












