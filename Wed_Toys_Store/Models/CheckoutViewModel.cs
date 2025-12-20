using System.ComponentModel.DataAnnotations;

namespace Wed_Toys_Store.Models
{
    public class CheckoutViewModel
    {
        [Required(ErrorMessage = "Full name is required")]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Phone number is required")]
        [StringLength(20)]
        [Phone]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Shipping address is required")]
        [StringLength(200)]
        public string ShippingAddress { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Notes { get; set; }

        [Required(ErrorMessage = "Payment method is required")]
        public string PaymentMethod { get; set; } = string.Empty;

        public List<CartItem> CartItems { get; set; } = new();

        public decimal Subtotal { get; set; }
        public decimal ShippingFee { get; set; }
        public decimal Total { get; set; }

        // Mã giảm giá áp dụng (nếu có)
        [StringLength(30)]
        public string? DiscountCode { get; set; }

        public decimal DiscountAmount { get; set; }
    }
}
