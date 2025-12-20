using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace Wed_Toys_Store.Models
{
    public class ApplicationUser : IdentityUser
    {
        [StringLength(100)]
        public string? FirstName { get; set; }

        [StringLength(100)]
        public string? LastName { get; set; }

        public DateTime? ChildBirthday { get; set; }

        public string? FullName { get; set; }
        public string? Address { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}

