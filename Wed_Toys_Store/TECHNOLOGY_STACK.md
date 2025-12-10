# Technology Stack - ToysStore Project

## ✅ Công nghệ đã sử dụng

### 1. Nền tảng phát triển: ASP.NET Core MVC ✅
- **Version**: .NET 8.0
- **Framework**: `Microsoft.NET.Sdk.Web`
- **File**: `Wed_Toys_Store.csproj`
- **Kiến trúc**: MVC (Model-View-Controller)
- **Controllers**: 
  - `HomeController.cs`
  - `ProductsController.cs`
  - `CategoriesController.cs`
  - `BannersController.cs`

### 2. Giao diện người dùng: Razor View ✅
- **Technology**: Razor Views (.cshtml)
- **Location**: `Views/` folder
- **Layout**: `Views/Shared/_Layout.cshtml`
- **Views đã tạo**:
  - `Views/Home/Index.cshtml` - Trang chủ với banner carousel
  - `Views/Products/Index.cshtml` - Danh mục sản phẩm với filter
  - `Views/Products/Create.cshtml` - Tạo sản phẩm
  - `Views/Products/Edit.cshtml` - Chỉnh sửa sản phẩm
  - `Views/Banners/Index.cshtml` - Quản lý banner
  - `Views/Banners/Create.cshtml` - Tạo banner
  - `Views/Banners/Edit.cshtml` - Chỉnh sửa banner

### 3. Hệ quản trị cơ sở dữ liệu: SQL Server ✅
- **Database**: SQL Server (LocalDB)
- **Connection String**: `Server=(localdb)\mssqllocaldb;Database=ToysStoreDb`
- **File cấu hình**: `appsettings.json`
- **SQL Scripts**: `Scripts/ToysStoreDb_Complete.sql`
- **Tables**:
  - `Banners` - Quản lý banner
  - `Categories` - Danh mục sản phẩm
  - `Products` - Sản phẩm
  - `Orders` - Đơn hàng
  - `OrderItems` - Chi tiết đơn hàng
  - `AspNetUsers` - Người dùng (Identity)
  - `AspNetRoles` - Vai trò (Identity)
  - Các bảng Identity khác

### 4. Công nghệ truy xuất dữ liệu: Entity Framework Core ✅
- **Version**: 8.0.0
- **Package**: `Microsoft.EntityFrameworkCore.SqlServer`
- **DbContext**: `ApplicationDbContext` (kế thừa `IdentityDbContext`)
- **Location**: `Data/ApplicationDbContext.cs`
- **Models**:
  - `Product` - Sản phẩm
  - `Category` - Danh mục
  - `Banner` - Banner
  - `Order` - Đơn hàng
  - `OrderItem` - Chi tiết đơn hàng
  - `ApplicationUser` - Người dùng (kế thừa IdentityUser)
- **Migrations**: Sử dụng EF Core Migrations
- **Code First**: Sử dụng Code First approach

### 5. Quản lý mã nguồn: Git ✅
- **Repository**: Cần khởi tạo Git repository
- **File**: `.gitignore` (cần tạo)
- **Lịch sử commit**: Sẽ được tạo khi commit code

## 📦 Packages đã cài đặt

```xml
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Identity.EntityFrameworkCore" Version="8.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Identity.UI" Version="8.0.0" />
```

## 🏗️ Kiến trúc Project

```
Wed_Toys_Store/
├── Controllers/          # MVC Controllers
│   ├── HomeController.cs
│   ├── ProductsController.cs
│   ├── CategoriesController.cs
│   └── BannersController.cs
├── Models/               # Entity Models
│   ├── Product.cs
│   ├── Category.cs
│   ├── Banner.cs
│   ├── Order.cs
│   ├── OrderItem.cs
│   └── ApplicationUser.cs
├── Data/                 # Data Access Layer
│   ├── ApplicationDbContext.cs
│   └── DbInitializer.cs
├── Views/                 # Razor Views
│   ├── Home/
│   ├── Products/
│   ├── Categories/
│   ├── Banners/
│   └── Shared/
├── wwwroot/              # Static Files
│   ├── css/
│   ├── js/
│   └── lib/bootstrap/   # Bootstrap 5.1.0
├── Scripts/               # SQL Scripts
│   └── ToysStoreDb_Complete.sql
└── Program.cs            # Application Entry Point
```

## ✅ Tính năng đã triển khai

### Authentication & Authorization
- ✅ ASP.NET Core Identity
- ✅ Đăng ký/Đăng nhập
- ✅ Phân quyền Admin/User
- ✅ Role-based authorization

### CRUD Operations
- ✅ Products (CRUD)
- ✅ Categories (CRUD - Admin only)
- ✅ Banners (CRUD - Admin only)

### Database
- ✅ Entity Framework Core Code First
- ✅ SQL Server LocalDB
- ✅ Migrations support
- ✅ Seed data (Admin user, roles)

### UI/UX
- ✅ Bootstrap 5.1.0
- ✅ Bootstrap Icons
- ✅ Responsive design
- ✅ Product filtering & sorting
- ✅ Banner carousel
- ✅ Modern UI/UX

## 🔧 Cấu hình

### Connection String
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ToysStoreDb;Trusted_Connection=true;MultipleActiveResultSets=true"
  }
}
```

### Database Setup
1. Chạy SQL script: `Scripts/ToysStoreDb_Complete.sql`
2. Hoặc sử dụng EF Core Migrations:
   ```powershell
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

## 📝 Lưu ý

- ✅ Tất cả công nghệ đã được sử dụng đúng theo yêu cầu
- ✅ Code tuân thủ best practices của ASP.NET Core MVC
- ✅ Sử dụng Entity Framework Core Code First approach
- ✅ Razor Views cho giao diện người dùng
- ✅ SQL Server làm database
- ⚠️ Cần khởi tạo Git repository và commit code để có lịch sử commit

