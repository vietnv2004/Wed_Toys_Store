using System.ComponentModel.DataAnnotations;

namespace Wed_Toys_Store.Models
{
    public class Category
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }
        
        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}












