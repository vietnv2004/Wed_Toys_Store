using System.ComponentModel.DataAnnotations;

namespace Wed_Toys_Store.Models
{
    public class DiscountCode
    {
        public int Id { get; set; }
        [StringLength(20, ErrorMessage = "Discount code cannot exceed 20 characters.")]
        public string Code { get; set; } = string.Empty;
        public decimal DiscountAmount { get; set; }
        public decimal MinOrderAmount { get; set; }
        public string Description { get; set; } = string.Empty;
        public DateTime ExpiryDate { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Maximum number of times this code can be used. 0 = unlimited.
        /// </summary>
        public int MaxUsage { get; set; } = 0;

        /// <summary>
        /// How many times this code has been used.
        /// </summary>
        public int UsedCount { get; set; } = 0;
    }
}


