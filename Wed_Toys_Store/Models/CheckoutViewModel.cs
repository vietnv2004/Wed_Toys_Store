using System.ComponentModel.DataAnnotations;

namespace Wed_Toys_Store.Models
{
    public class CheckoutViewModel
    {
        [Required(ErrorMessage = "Full name is required")]
        [Display(Name = "Full Name")]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Phone number is required")]
        [Display(Name = "Phone Number")]
        [StringLength(20)]
        [Phone]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Shipping address is required")]
        [Display(Name = "Shipping Address")]
        [StringLength(200)]
        public string ShippingAddress { get; set; } = string.Empty;

        [Display(Name = "Notes (Optional)")]
        [StringLength(500)]
        public string? Notes { get; set; }

        [Required(ErrorMessage = "Payment method is required")]
        [Display(Name = "Payment Method")]
        public string PaymentMethod { get; set; } = string.Empty;

        public List<CartItem> CartItems { get; set; } = new List<CartItem>();
        public decimal Subtotal { get; set; }
        public decimal ShippingFee { get; set; }
        public decimal Total { get; set; }
    }
}



