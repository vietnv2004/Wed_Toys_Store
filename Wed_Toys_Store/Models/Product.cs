using System.ComponentModel.DataAnnotations;

namespace Wed_Toys_Store.Models
{
    public class Product
    {
        public int Id { get; set; }

        [Required]
        [StringLength(200)]
        public string Name { get; set; } = string.Empty;

        [StringLength(1000)]
        public string? Description { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
        public decimal Price { get; set; }

        public int Stock { get; set; } = 0;

        public string? ImageUrl { get; set; }

        public int CategoryId { get; set; }
        public Category? Category { get; set; }

        [StringLength(50)]
        public string? AgeRange { get; set; } // 0-6 Tháng, 6-12 Tháng, 1-2 Tuổi, 3-6 Tuổi, Trên 6 Tuổi

        [StringLength(100)]
        public string? Brand { get; set; } // AVENGERS, BRIGHT STARTS, BARBIE, etc.

        public bool IsNew { get; set; } = false; // Tag "Mới"

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}

