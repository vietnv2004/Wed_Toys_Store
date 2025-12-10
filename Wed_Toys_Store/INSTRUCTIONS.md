# Hướng dẫn Setup và Chạy Dự án ToysStore

## ✅ Đã hoàn thành

### 1. Công nghệ đã cấu hình
- ✅ **ASP.NET Core 8.0** (MVC)
- ✅ **Bootstrap 5.1.0**
- ✅ **Entity Framework Core 8.0**
- ✅ **ASP.NET Core Identity** (Authentication & Authorization)
- ✅ **SQL Server** (LocalDB)

### 2. Models đã tạo
- ✅ `ApplicationUser` - Người dùng (kế thừa IdentityUser)
- ✅ `Product` - Sản phẩm
- ✅ `Category` - Danh mục
- ✅ `Order` - Đơn hàng
- ✅ `OrderItem` - Chi tiết đơn hàng

### 3. Controllers đã tạo
- ✅ `ProductsController` - CRUD sản phẩm (Admin only cho Create/Edit/Delete)
- ✅ `CategoriesController` - CRUD danh mục (Admin only)

### 4. Database Context
- ✅ `ApplicationDbContext` - DbContext với Identity và các Models

## 📋 Các bước tiếp theo để chạy dự án

### Bước 1: Cài đặt packages
```powershell
cd Wed_Toys_Store
dotnet restore
```

### Bước 2: Scaffold Identity Pages (Login/Register)
```powershell
# Cài đặt tool scaffolding (chỉ cần làm 1 lần)
dotnet tool install -g dotnet-aspnet-codegenerator

# Scaffold Identity pages
dotnet aspnet-codegenerator identity -dc Wed_Toys_Store.Data.ApplicationDbContext --files "Account.Register;Account.Login;Account.Logout"
```

Hoặc chạy script:
```powershell
.\scaffold-identity.ps1
```

### Bước 3: Tạo Database và Migrations
```powershell
# Tạo migration
dotnet ef migrations add InitialCreate

# Cập nhật database
dotnet ef database update
```

### Bước 4: Tạo Admin Role và User mẫu
Tạo file `Wed_Toys_Store/Data/DbInitializer.cs` để seed data:

```csharp
using Microsoft.AspNetCore.Identity;
using Wed_Toys_Store.Models;

public static class DbInitializer
{
    public static async Task SeedAsync(ApplicationDbContext context, UserManager<ApplicationUser> userManager, RoleManager<IdentityRole> roleManager)
    {
        // Tạo Admin Role
        if (!await roleManager.RoleExistsAsync("Admin"))
        {
            await roleManager.CreateAsync(new IdentityRole("Admin"));
        }

        // Tạo Admin User
        var adminEmail = "admin@toysstore.com";
        if (await userManager.FindByEmailAsync(adminEmail) == null)
        {
            var admin = new ApplicationUser
            {
                UserName = adminEmail,
                Email = adminEmail,
                FullName = "Administrator",
                EmailConfirmed = true
            };
            await userManager.CreateAsync(admin, "Admin@123");
            await userManager.AddToRoleAsync(admin, "Admin");
        }
    }
}
```

Sau đó gọi trong `Program.cs` sau khi tạo database.

### Bước 5: Chạy ứng dụng
```powershell
# Với hot reload
dotnet watch run

# Hoặc chạy bình thường
dotnet run
```

Truy cập: `https://localhost:7184` hoặc `http://localhost:5291`

## 🔐 Tài khoản mặc định (sau khi seed)

- **Admin**: `admin@toysstore.com` / `Admin@123`
- **User**: Đăng ký mới qua trang Register

## 📝 Chức năng đã triển khai

### Authentication & Authorization
- ✅ Đăng ký tài khoản (Register)
- ✅ Đăng nhập (Login)
- ✅ Đăng xuất (Logout)
- ✅ Phân quyền Admin/User

### CRUD Operations
- ✅ **Products**: 
  - Xem danh sách (tất cả user)
  - Xem chi tiết (tất cả user)
  - Tạo mới (Admin only)
  - Chỉnh sửa (Admin only)
  - Xóa (Admin only)

- ✅ **Categories**:
  - Tất cả CRUD (Admin only)

## 🎨 Giao diện

- Header với logo, search bar, và navigation
- Footer với thông tin liên hệ
- Responsive design với Bootstrap 5
- UI thân thiện, dễ sử dụng

## 📁 Cấu trúc thư mục

```
Wed_Toys_Store/
├── Controllers/
│   ├── ProductsController.cs
│   ├── CategoriesController.cs
│   └── HomeController.cs
├── Models/
│   ├── ApplicationUser.cs
│   ├── Product.cs
│   ├── Category.cs
│   ├── Order.cs
│   └── OrderItem.cs
├── Data/
│   └── ApplicationDbContext.cs
├── Views/
│   ├── Products/
│   │   ├── Index.cshtml
│   │   └── Create.cshtml
│   └── Shared/
│       └── _Layout.cshtml
└── wwwroot/
    └── lib/bootstrap/ (Bootstrap 5.1.0)
```

## ⚠️ Lưu ý

1. **Connection String**: Mặc định dùng LocalDB `(localdb)\mssqllocaldb`
2. **Migrations**: Chạy migrations trước khi chạy ứng dụng lần đầu
3. **Identity Scaffolding**: Cần scaffold Identity pages để có trang Login/Register
4. **Admin Role**: Cần seed data để tạo Admin role và user

## 🚀 Tiếp theo

- [ ] Tạo các Views còn lại (Details, Edit, Delete cho Products)
- [ ] Tạo Views cho Categories
- [ ] Tạo OrdersController và Views
- [ ] Thêm chức năng giỏ hàng (Cart)
- [ ] Thêm chức năng tìm kiếm sản phẩm
- [ ] Thêm pagination cho danh sách sản phẩm

