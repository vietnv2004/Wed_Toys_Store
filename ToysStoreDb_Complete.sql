-- =============================================
-- ToysStore Database - Complete SQL Script
-- Tạo tất cả các bảng cần thiết cho hệ thống
-- Bao gồm dữ liệu mẫu đầy đủ
-- =============================================

USE master;
GO

-- Tạo database nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ToysStoreDb')
BEGIN
    CREATE DATABASE ToysStoreDb;
END
GO

USE ToysStoreDb;
GO

-- =============================================
-- 1. BẢNG BANNERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Banners]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Banners] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Title] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [ImageUrl] NVARCHAR(1000) NOT NULL,
        [LinkUrl] NVARCHAR(500) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- =============================================
-- 2. BẢNG BRANDS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Brands]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Brands] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Name] NVARCHAR(100) NOT NULL,
        [LogoUrl] NVARCHAR(1000) NOT NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1
    );
END
GO

-- =============================================
-- 3. BẢNG CATEGORIES
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Categories]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Categories] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Name] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(MAX) NULL
    );
END
GO

-- =============================================
-- 4. BẢNG PRODUCTS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Products] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Name] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(1000) NULL,
        [Price] DECIMAL(18,2) NOT NULL,
        [Stock] INT NOT NULL DEFAULT 0,
        [ImageUrl] NVARCHAR(MAX) NULL,
        [CategoryId] INT NOT NULL,
        [AgeRange] NVARCHAR(50) NULL,
        [Brand] NVARCHAR(100) NULL,
        [IsNew] BIT NOT NULL DEFAULT 0,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [FK_Products_Categories] FOREIGN KEY ([CategoryId]) 
            REFERENCES [dbo].[Categories]([Id]) ON DELETE NO ACTION
    );
END
GO

-- Tạo index cho Products nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_CategoryId' AND object_id = OBJECT_ID('dbo.Products'))
BEGIN
    DROP INDEX [IX_Products_CategoryId] ON [dbo].[Products];
END
GO

CREATE INDEX [IX_Products_CategoryId] ON [dbo].[Products]([CategoryId]);
GO

-- =============================================
-- 5. BẢNG ASP.NET IDENTITY - AspNetUsers
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUsers] (
        [Id] NVARCHAR(128) NOT NULL PRIMARY KEY,
        [UserName] NVARCHAR(256) NULL,
        [NormalizedUserName] NVARCHAR(256) NULL,
        [Email] NVARCHAR(256) NULL,
        [NormalizedEmail] NVARCHAR(256) NULL,
        [EmailConfirmed] BIT NOT NULL DEFAULT 0,
        [PasswordHash] NVARCHAR(MAX) NULL,
        [SecurityStamp] NVARCHAR(MAX) NULL,
        [ConcurrencyStamp] NVARCHAR(MAX) NULL,
        [PhoneNumber] NVARCHAR(MAX) NULL,
        [PhoneNumberConfirmed] BIT NOT NULL DEFAULT 0,
        [TwoFactorEnabled] BIT NOT NULL DEFAULT 0,
        [LockoutEnd] DATETIMEOFFSET NULL,
        [LockoutEnabled] BIT NOT NULL DEFAULT 1,
        [AccessFailedCount] INT NOT NULL DEFAULT 0,
        [FirstName] NVARCHAR(100) NULL,
        [LastName] NVARCHAR(100) NULL,
        [ChildBirthday] DATETIME2 NULL,
        [FullName] NVARCHAR(MAX) NULL,
        [Address] NVARCHAR(MAX) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- Tạo index cho AspNetUsers nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'EmailIndex' AND object_id = OBJECT_ID('dbo.AspNetUsers'))
BEGIN
    DROP INDEX [EmailIndex] ON [dbo].[AspNetUsers];
END
GO

CREATE INDEX [EmailIndex] ON [dbo].[AspNetUsers]([NormalizedEmail]);
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UserNameIndex' AND object_id = OBJECT_ID('dbo.AspNetUsers'))
BEGIN
    DROP INDEX [UserNameIndex] ON [dbo].[AspNetUsers];
END
GO

CREATE UNIQUE INDEX [UserNameIndex] ON [dbo].[AspNetUsers]([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;
GO

-- =============================================
-- 6. BẢNG ASP.NET IDENTITY - AspNetRoles
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetRoles] (
        [Id] NVARCHAR(128) NOT NULL PRIMARY KEY,
        [Name] NVARCHAR(256) NULL,
        [NormalizedName] NVARCHAR(256) NULL,
        [ConcurrencyStamp] NVARCHAR(MAX) NULL
    );
END
GO

-- Tạo index cho AspNetRoles nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'RoleNameIndex' AND object_id = OBJECT_ID('dbo.AspNetRoles'))
BEGIN
    DROP INDEX [RoleNameIndex] ON [dbo].[AspNetRoles];
END
GO

CREATE UNIQUE INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;
GO

-- =============================================
-- 7. BẢNG ASP.NET IDENTITY - AspNetUserRoles
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserRoles] (
        [UserId] NVARCHAR(128) NOT NULL,
        [RoleId] NVARCHAR(128) NOT NULL,
        PRIMARY KEY ([UserId], [RoleId]),
        CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) 
            REFERENCES [dbo].[AspNetRoles]([Id]) ON DELETE CASCADE
    );
END
GO

-- Tạo index cho AspNetUserRoles nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AspNetUserRoles_RoleId' AND object_id = OBJECT_ID('dbo.AspNetUserRoles'))
BEGIN
    DROP INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles];
END
GO

CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles]([RoleId]);
GO

-- =============================================
-- 8. BẢNG ASP.NET IDENTITY - AspNetUserClaims
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserClaims]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserClaims] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] NVARCHAR(128) NOT NULL,
        [ClaimType] NVARCHAR(MAX) NULL,
        [ClaimValue] NVARCHAR(MAX) NULL,
        CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );
END
GO

-- Tạo index cho AspNetUserClaims nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AspNetUserClaims_UserId' AND object_id = OBJECT_ID('dbo.AspNetUserClaims'))
BEGIN
    DROP INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims];
END
GO

CREATE INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims]([UserId]);
GO

-- =============================================
-- 9. BẢNG ASP.NET IDENTITY - AspNetUserLogins
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserLogins]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserLogins] (
        [LoginProvider] NVARCHAR(128) NOT NULL,
        [ProviderKey] NVARCHAR(128) NOT NULL,
        [ProviderDisplayName] NVARCHAR(MAX) NULL,
        [UserId] NVARCHAR(128) NOT NULL,
        PRIMARY KEY ([LoginProvider], [ProviderKey]),
        CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );
END
GO

-- Tạo index cho AspNetUserLogins nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AspNetUserLogins_UserId' AND object_id = OBJECT_ID('dbo.AspNetUserLogins'))
BEGIN
    DROP INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins];
END
GO

CREATE INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins]([UserId]);
GO

-- =============================================
-- 10. BẢNG ASP.NET IDENTITY - AspNetRoleClaims
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetRoleClaims]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetRoleClaims] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [RoleId] NVARCHAR(128) NOT NULL,
        [ClaimType] NVARCHAR(MAX) NULL,
        [ClaimValue] NVARCHAR(MAX) NULL,
        CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) 
            REFERENCES [dbo].[AspNetRoles]([Id]) ON DELETE CASCADE
    );
END
GO

-- Tạo index cho AspNetRoleClaims nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AspNetRoleClaims_RoleId' AND object_id = OBJECT_ID('dbo.AspNetRoleClaims'))
BEGIN
    DROP INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims];
END
GO

CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims]([RoleId]);
GO

-- =============================================
-- 11. BẢNG ASP.NET IDENTITY - AspNetUserTokens
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserTokens]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserTokens] (
        [UserId] NVARCHAR(128) NOT NULL,
        [LoginProvider] NVARCHAR(128) NOT NULL,
        [Name] NVARCHAR(128) NOT NULL,
        [Value] NVARCHAR(MAX) NULL,
        PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );
END
GO

-- =============================================
-- 12. BẢNG ORDERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Orders] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] NVARCHAR(128) NOT NULL,
        [OrderDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [ShippingAddress] NVARCHAR(200) NOT NULL,
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
        [TotalAmount] DECIMAL(18,2) NOT NULL,
        CONSTRAINT [FK_Orders_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE NO ACTION
    );
END
GO

-- Tạo index cho Orders nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_UserId' AND object_id = OBJECT_ID('dbo.Orders'))
BEGIN
    DROP INDEX [IX_Orders_UserId] ON [dbo].[Orders];
END
GO

CREATE INDEX [IX_Orders_UserId] ON [dbo].[Orders]([UserId]);
GO

-- =============================================
-- 13. BẢNG ORDERITEMS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderItems]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[OrderItems] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [OrderId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        [Quantity] INT NOT NULL,
        [Price] DECIMAL(18,2) NOT NULL,
        CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) 
            REFERENCES [dbo].[Orders]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_OrderItems_Products_ProductId] FOREIGN KEY ([ProductId]) 
            REFERENCES [dbo].[Products]([Id]) ON DELETE NO ACTION
    );
END
GO

-- Tạo index cho OrderItems nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_OrderId' AND object_id = OBJECT_ID('dbo.OrderItems'))
BEGIN
    DROP INDEX [IX_OrderItems_OrderId] ON [dbo].[OrderItems];
END
GO

CREATE INDEX [IX_OrderItems_OrderId] ON [dbo].[OrderItems]([OrderId]);
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_ProductId' AND object_id = OBJECT_ID('dbo.OrderItems'))
BEGIN
    DROP INDEX [IX_OrderItems_ProductId] ON [dbo].[OrderItems];
END
GO

CREATE INDEX [IX_OrderItems_ProductId] ON [dbo].[OrderItems]([ProductId]);
GO

-- =============================================
-- 14. BẢNG DISCOUNT CODES
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DiscountCodes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DiscountCodes] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Code] NVARCHAR(50) NOT NULL,
        [DiscountAmount] DECIMAL(18,2) NOT NULL,
        [MinOrderAmount] DECIMAL(18,2) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [ExpiryDate] DATETIME2 NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [MaxUsage] INT NOT NULL DEFAULT 0, -- 0 = unlimited
        [UsedCount] INT NOT NULL DEFAULT 0
    );
    
    -- Tạo unique index cho Code để đảm bảo mã không trùng lặp
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DiscountCodes_Code' AND object_id = OBJECT_ID('dbo.DiscountCodes'))
    BEGIN
        CREATE UNIQUE INDEX [IX_DiscountCodes_Code] ON [dbo].[DiscountCodes]([Code]);
    END
    
    -- Tạo index cho IsActive và ExpiryDate để filter nhanh hơn
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DiscountCodes_IsActive_ExpiryDate' AND object_id = OBJECT_ID('dbo.DiscountCodes'))
    BEGIN
        CREATE INDEX [IX_DiscountCodes_IsActive_ExpiryDate] ON [dbo].[DiscountCodes]([IsActive], [ExpiryDate]);
    END
END
GO

-- =============================================
-- 15. BẢNG FAVORITE PRODUCTS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FavoriteProducts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[FavoriteProducts] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] NVARCHAR(128) NOT NULL,
        [ProductId] INT NOT NULL,
        [AddedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_FavoriteProducts_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_FavoriteProducts_Products_ProductId] FOREIGN KEY ([ProductId]) 
            REFERENCES [dbo].[Products]([Id]) ON DELETE CASCADE
    );
    
    -- Tạo unique index để đảm bảo mỗi user chỉ có thể thích một sản phẩm một lần
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FavoriteProducts_UserId_ProductId' AND object_id = OBJECT_ID('dbo.FavoriteProducts'))
    BEGIN
        CREATE UNIQUE INDEX [IX_FavoriteProducts_UserId_ProductId] ON [dbo].[FavoriteProducts]([UserId], [ProductId]);
    END
    
    -- Tạo index cho UserId để tìm kiếm favorites của user nhanh hơn
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FavoriteProducts_UserId' AND object_id = OBJECT_ID('dbo.FavoriteProducts'))
    BEGIN
        CREATE INDEX [IX_FavoriteProducts_UserId] ON [dbo].[FavoriteProducts]([UserId]);
    END
    
    -- Tạo index cho ProductId để tìm kiếm users đã thích sản phẩm nhanh hơn
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FavoriteProducts_ProductId' AND object_id = OBJECT_ID('dbo.FavoriteProducts'))
    BEGIN
        CREATE INDEX [IX_FavoriteProducts_ProductId] ON [dbo].[FavoriteProducts]([ProductId]);
    END
END
GO

-- =============================================
-- CẬP NHẬT BẢNG PRODUCTS (Nếu bảng đã tồn tại)
-- Thêm các cột filter nếu chưa có
-- =============================================
USE ToysStoreDb;
GO

-- Thêm cột AgeRange nếu chưa có
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND name = 'AgeRange')
    BEGIN
        ALTER TABLE [dbo].[Products]
        ADD [AgeRange] NVARCHAR(50) NULL;
    END
END
GO

-- Thêm cột Brand nếu chưa có
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND name = 'Brand')
    BEGIN
        ALTER TABLE [dbo].[Products]
        ADD [Brand] NVARCHAR(100) NULL;
    END
END
GO

-- Thêm cột IsNew nếu chưa có
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND name = 'IsNew')
    BEGIN
        ALTER TABLE [dbo].[Products]
        ADD [IsNew] BIT NOT NULL DEFAULT 0;
    END
END
GO

-- =============================================
-- CẬP NHẬT BẢNG ASPNETUSERS (Nếu bảng đã tồn tại)
-- Thêm các cột FirstName, LastName, ChildBirthday nếu chưa có
-- =============================================
USE ToysStoreDb;
GO

-- Thêm cột FirstName nếu chưa có
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND name = 'FirstName')
    BEGIN
        ALTER TABLE [dbo].[AspNetUsers]
        ADD [FirstName] NVARCHAR(100) NULL;
    END
END
GO

-- Thêm cột LastName nếu chưa có
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND name = 'LastName')
    BEGIN
        ALTER TABLE [dbo].[AspNetUsers]
        ADD [LastName] NVARCHAR(100) NULL;
    END
END
GO

-- Thêm cột ChildBirthday nếu chưa có
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND name = 'ChildBirthday')
    BEGIN
        ALTER TABLE [dbo].[AspNetUsers]
        ADD [ChildBirthday] DATETIME2 NULL;
    END
END
GO

-- =============================================
-- SEED SAMPLE BANNERS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Xóa dữ liệu cũ và insert mới
DELETE FROM [dbo].[Banners];
DBCC CHECKIDENT ('[dbo].[Banners]', RESEED, 1);

INSERT INTO [dbo].[Banners] ([Title], [Description], [ImageUrl], [LinkUrl], [DisplayOrder], [IsActive], [CreatedAt])
    VALUES
    (N'Khuyến mãi lớn mùa hè', N'Giảm giá lên đến 50% cho tất cả sản phẩm đồ chơi', N'https://www.mykingdom.com.vn/cdn/shop/files/viber_image_2025-11-17_17-34-27-437.jpg?v=1763433969&width=1200', N'/products', 1, 1, GETUTCDATE()),
    (N'Bộ sưu tập mới 2024', N'Khám phá những món đồ chơi hot nhất năm 2024', N'https://herogame.vn/ad-min/assets/js/libs/kcfinder/upload_img2/images/Vi%E1%BB%87t/T5/Herogame__GundamBreaker4LaunchEdition_01.jpg', N'/products?isNew=true', 2, 1, GETUTCDATE()),
    (N'Đồ chơi giáo dục', N'Phát triển trí tuệ và kỹ năng cho trẻ em', N'https://www.mykingdom.com.vn/cdn/shop/files/viber_image_2025-11-17_17-34-27-437.jpg?v=1763433969&width=1200', N'/categories/1', 3, 1, GETUTCDATE()),
    (N'Siêu anh hùng và Robot', N'Bộ sưu tập action figure đầy đủ', N'https://herogame.vn/ad-min/assets/js/libs/kcfinder/upload_img2/images/Vi%E1%BB%87t/T5/Herogame__GundamBreaker4LaunchEdition_01.jpg', N'/categories/4', 4, 1, GETUTCDATE()),
    (N'Búp bê và Công chúa', N'Thế giới cổ tích dành cho các bé gái', N'https://www.mykingdom.com.vn/cdn/shop/files/viber_image_2025-11-17_17-34-27-437.jpg?v=1763433969&width=1200', N'/categories/5', 5, 1, GETUTCDATE());
GO

-- =============================================
-- SEED SAMPLE BRANDS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Xóa dữ liệu cũ và insert mới
DELETE FROM [dbo].[Brands];
DBCC CHECKIDENT ('[dbo].[Brands]', RESEED, 1);

    INSERT INTO [dbo].[Brands] ([Name], [LogoUrl], [DisplayOrder], [IsActive])
    VALUES
        (N'SKIP*HOP', N'https://file.hstatic.net/1000202622/file/untitled_design__31__b5e4428f3ed1475a87837a417c38245e.png', 1, 1),
        (N'Hape', N'https://file.hstatic.net/1000202622/file/hape_323fe297833947bc8134142092684d1a.png', 2, 1),
        (N'Bright Starts', N'https://file.hstatic.net/1000202622/file/bright_starts_19e06a724b0441029c05a960a107d5aa.png', 3, 1),
        (N'tiNi TOY', N'https://file.hstatic.net/1000202622/file/logo__14__92a07901d90a4d639a5c98bc5faa505c.png', 4, 1),
        (N'MARVEL', N'https://file.hstatic.net/1000202622/file/brands_logo_website-18_bb4e1a6fabec4752bca534c1658af652.png', 5, 1),
        (N'TRANSFORMERS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-tfm_9e493c30b6a943b88f3aa12acc758f16.png', 6, 1),
        (N'Barbie', N'https://file.hstatic.net/1000202622/file/logo__26__a2416b04d6e14ad88e799485d28705cf.png', 7, 1),
        (N'ZURU Sparkle girlz', N'https://file.hstatic.net/1000202622/file/3_4a50931e94a947f38259adbed0613c01.png', 8, 1),
        (N'Baby Einstein', N'https://file.hstatic.net/1000202622/file/baby_einstein_922a00f0de5845198dbcb66e22e86f7c.png', 9, 1),
        (N'Ingenuity', N'https://file.hstatic.net/1000202622/file/ingenuity_3fa5fa7a148c488c963b090f08aca97b.png', 10, 1),
        (N'SwaddleMe by Ingenuity', N'https://file.hstatic.net/1000202622/file/brands_logo_website-108_a53fd8443c7341308af383632788998b.png', 11, 1),
        (N'ZURU SMASHERS', N'https://file.hstatic.net/1000202622/file/logo__20__d0e79bbeef81421888f9dc591172a615.png', 12, 1),
        (N'MARVEL AVENGERS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-avengerred_d619577355084fed9a0ee3b7e351799e.png', 13, 1),
        (N'MARVEL SPIDERMAN', N'https://file.hstatic.net/1000202622/file/logo__2__70b2491f816c48af8858a3313f3ea614.png', 14, 1),
        (N'5 SURPRISE', N'https://file.hstatic.net/1000202622/file/logo__17__dc8417b53c034fd28d5054b8141155a0.png', 15, 1),
        (N'ZURU RainBocorns', N'https://file.hstatic.net/1000202622/file/logo__19__bff5d7157b354609b94e64431ed86b58.png', 16, 1),
        (N'Pets Alive', N'https://file.hstatic.net/1000202622/file/pet_alive_11adb4da66d84067938473d5e338b43b.png', 17, 1),
        (N'TY', N'https://file.hstatic.net/1000202622/file/brands_logo_website-01_082873eca1de45e2bf4703b34d8f610a.png', 18, 1),
        (N'LEGO', N'https://file.hstatic.net/1000202622/file/brands_logo_website-18_bb4e1a6fabec4752bca534c1658af652.png', 19, 1),
        (N'AVENGERS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-avengerred_d619577355084fed9a0ee3b7e351799e.png', 20, 1),
        (N'DISNEY PRINCESS', N'https://file.hstatic.net/1000202622/file/logo__26__a2416b04d6e14ad88e799485d28705cf.png', 21, 1),
        (N'VALUE TOYS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-01_082873eca1de45e2bf4703b34d8f610a.png', 22, 1),
        (N'FISHER PRICE', N'https://file.hstatic.net/1000202622/file/ingenuity_3fa5fa7a148c488c963b090f08aca97b.png', 23, 1),
        (N'PLAY-DOH', N'https://file.hstatic.net/1000202622/file/bright_starts_19e06a724b0441029c05a960a107d5aa.png', 24, 1),
        (N'SPIDER-MAN', N'https://file.hstatic.net/1000202622/file/logo__2__70b2491f816c48af8858a3313f3ea614.png', 25, 1),
        (N'BOBICRAFT', N'https://file.hstatic.net/1000202622/file/logo__14__92a07901d90a4d639a5c98bc5faa505c.png', 26, 1),
        (N'TINITOY', N'https://file.hstatic.net/1000202622/file/logo__19__bff5d7157b354609b94e64431ed86b58.png', 27, 1),
        (N'MESUCA', N'https://file.hstatic.net/1000202622/file/bright_starts_19e06a724b0441029c05a960a107d5aa.png', 28, 1),
        (N'CARTER''S', N'https://file.hstatic.net/1000202622/file/brands_logo_website-01_082873eca1de45e2bf4703b34d8f610a.png', 29, 1);
GO

-- =============================================
-- SEED ROLES DATA
-- =============================================
USE ToysStoreDb;
GO

-- Insert User Role
IF NOT EXISTS (SELECT * FROM [dbo].[AspNetRoles] WHERE [NormalizedName] = 'USER')
BEGIN
    INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp])
    VALUES (NEWID(), 'User', 'USER', NEWID());
END
GO

-- Insert Admin Role
IF NOT EXISTS (SELECT * FROM [dbo].[AspNetRoles] WHERE [NormalizedName] = 'ADMIN')
BEGIN
    INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp])
    VALUES (NEWID(), 'Admin', 'ADMIN', NEWID());
END
GO

-- =============================================
-- SEED SAMPLE CATEGORIES DATA
-- =============================================
USE ToysStoreDb;
GO

-- Xóa dữ liệu cũ và insert mới
DELETE FROM [dbo].[Categories];
DBCC CHECKIDENT ('[dbo].[Categories]', RESEED, 1);

INSERT INTO [dbo].[Categories] ([Name], [Description])
VALUES
    (N'Educational Toys', N'Toys that help children learn and develop skills'),
    (N'Creative Toys', N'Toys that encourage creativity and imagination'),
    (N'Active Toys', N'Toys that promote physical activity and movement'),
    (N'Superheroes & Robots', N'Action figures, superhero toys, and robot toys'),
    (N'Dolls & Princesses', N'Dolls, princess toys, and fashion dolls'),
    (N'Building Blocks & Puzzles', N'Construction toys, building blocks, and puzzles'),
    (N'Cars & Airplanes', N'Vehicle toys including cars, trucks, and airplanes'),
    (N'Dinosaurs & Animals', N'Dinosaur toys and animal figures'),
    (N'Stuffed Animals & Pets', N'Plush toys and pet-related toys'),
    (N'Board Games', N'Educational and fun board games for all ages'),
    (N'Infants & Preschoolers', N'Toys designed for babies and toddlers'),
    (N'Mom & Baby Products', N'Products for mothers and babies'),
    (N'Personal & School Supplies', N'Personal care items and school supplies'),
    (N'tiNi Products', N'Special tiNi brand products');
GO

-- =============================================
-- SEED SAMPLE PRODUCTS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Xóa dữ liệu cũ và insert mới
DELETE FROM [dbo].[Products];
DBCC CHECKIDENT ('[dbo].[Products]', RESEED, 1);

-- Kiểm tra số lượng categories trước khi lấy IDs
DECLARE @CategoryCount INT;
SELECT @CategoryCount = COUNT(*) FROM [dbo].[Categories];
PRINT 'Total Categories in database: ' + CAST(@CategoryCount AS NVARCHAR(10));

IF @CategoryCount = 0
BEGIN
    RAISERROR('ERROR: No categories found in database. Please check if categories were inserted successfully.', 16, 1);
    RETURN;
END

-- Lấy các CategoryId
DECLARE @CatEducational INT, @CatCreative INT, @CatActive INT, @CatSuperhero INT, @CatDolls INT, @CatBuilding INT, @CatCars INT, @CatDino INT, @CatStuffed INT, @CatBoard INT, @CatInfants INT;

SELECT @CatEducational = Id FROM [dbo].[Categories] WHERE [Name] = N'Educational Toys';
SELECT @CatCreative = Id FROM [dbo].[Categories] WHERE [Name] = N'Creative Toys';
SELECT @CatActive = Id FROM [dbo].[Categories] WHERE [Name] = N'Active Toys';
SELECT @CatSuperhero = Id FROM [dbo].[Categories] WHERE [Name] = N'Superheroes & Robots';
SELECT @CatDolls = Id FROM [dbo].[Categories] WHERE [Name] = N'Dolls & Princesses';
SELECT @CatBuilding = Id FROM [dbo].[Categories] WHERE [Name] = N'Building Blocks & Puzzles';
SELECT @CatCars = Id FROM [dbo].[Categories] WHERE [Name] = N'Cars & Airplanes';
SELECT @CatDino = Id FROM [dbo].[Categories] WHERE [Name] = N'Dinosaurs & Animals';
SELECT @CatStuffed = Id FROM [dbo].[Categories] WHERE [Name] = N'Stuffed Animals & Pets';
SELECT @CatBoard = Id FROM [dbo].[Categories] WHERE [Name] = N'Board Games';
SELECT @CatInfants = Id FROM [dbo].[Categories] WHERE [Name] = N'Infants & Preschoolers';

-- Debug output cho Categories
PRINT 'Category IDs found:';
PRINT '  @CatEducational: ' + ISNULL(CAST(@CatEducational AS NVARCHAR(10)), 'NULL');
PRINT '  @CatCreative: ' + ISNULL(CAST(@CatCreative AS NVARCHAR(10)), 'NULL');
PRINT '  @CatActive: ' + ISNULL(CAST(@CatActive AS NVARCHAR(10)), 'NULL');
PRINT '  @CatSuperhero: ' + ISNULL(CAST(@CatSuperhero AS NVARCHAR(10)), 'NULL');
PRINT '  @CatDolls: ' + ISNULL(CAST(@CatDolls AS NVARCHAR(10)), 'NULL');

-- Kiểm tra các CategoryId đã được lấy thành công
IF @CatEducational IS NULL OR @CatCreative IS NULL OR @CatActive IS NULL OR @CatSuperhero IS NULL OR @CatDolls IS NULL OR @CatBuilding IS NULL OR @CatCars IS NULL OR @CatDino IS NULL OR @CatStuffed IS NULL OR @CatBoard IS NULL OR @CatInfants IS NULL
BEGIN
    RAISERROR('ERROR: One or more categories not found. Please ensure categories are inserted first.', 16, 1);
    RETURN;
END
ELSE
BEGIN
    PRINT 'All category IDs retrieved successfully!';
END

INSERT INTO [dbo].[Products] ([Name], [Description], [Price], [Stock], [ImageUrl], [CategoryId], [AgeRange], [Brand], [IsNew], [CreatedAt])
VALUES
    -- Educational Toys
    (N'LEGO Technic Ferrari FXX-K Supercar', N'Build your own Ferrari FXX-K supercar with this detailed LEGO Technic set. Features working steering, suspension, and V12 engine.', 2500000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatEducational, N'3 - 6 Years', N'LEGO', 1, GETUTCDATE()),
    (N'Educational Building Blocks Set', N'Colorful building blocks that help develop creativity and motor skills. Perfect for young children.', 350000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatEducational, N'1 - 2 Years', N'Bright Starts', 0, GETUTCDATE()),
    (N'Educational Puzzle Set - 100 Pieces', N'Colorful jigsaw puzzles that help develop problem-solving skills.', 180000, 35, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatEducational, N'3 - 6 Years', N'Hape', 0, GETUTCDATE()),
    (N'ABC Learning Blocks', N'Wooden alphabet blocks to help children learn letters and words.', 220000, 30, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatEducational, N'1 - 2 Years', N'Hape', 1, GETUTCDATE()),
    (N'Math Learning Board', N'Interactive math board with numbers and operations for early learning.', 280000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatEducational, N'3 - 6 Years', N'Bright Starts', 0, GETUTCDATE()),
    
    -- Creative Toys
    (N'Play-Doh Creative Set', N'Complete Play-Doh set with multiple colors and creative tools for endless fun.', 250000, 28, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCreative, N'3 - 6 Years', N'PLAY-DOH', 0, GETUTCDATE()),
    (N'Art Supplies Creative Kit', N'Complete art supplies kit with crayons, markers, paints, and drawing paper.', 220000, 30, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCreative, N'3 - 6 Years', N'MESUCA', 0, GETUTCDATE()),
    (N'Musical Keyboard for Kids', N'Colorful musical keyboard with multiple sounds and built-in songs.', 680000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCreative, N'3 - 6 Years', N'CARTER''S', 1, GETUTCDATE()),
    (N'Drawing Tablet for Kids', N'Digital drawing tablet designed for children to express their creativity.', 450000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCreative, N'Over 6 Years', N'MESUCA', 0, GETUTCDATE()),
    (N'Clay Modeling Set', N'Non-toxic clay set with various tools and molds for sculpting.', 320000, 22, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCreative, N'3 - 6 Years', N'PLAY-DOH', 1, GETUTCDATE()),
    
    -- Active Toys
    (N'Jump Rope Set', N'Colorful jump rope set for active play and exercise.', 150000, 40, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatActive, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    (N'Balance Bike', N'Pedal-free balance bike to help children learn cycling skills.', 850000, 10, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatActive, N'3 - 6 Years', N'VALUE TOYS', 1, GETUTCDATE()),
    (N'Soccer Ball Set', N'Complete soccer ball set with goal posts for outdoor fun.', 380000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatActive, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    (N'Trampoline Mini', N'Mini trampoline for indoor exercise and fun.', 1200000, 8, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatActive, N'3 - 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    
    -- Superheroes & Robots
    (N'Avengers Action Figure Set', N'Collectible Avengers action figures including Iron Man, Captain America, and Thor.', 450000, 30, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatSuperhero, N'Over 6 Years', N'MARVEL AVENGERS', 0, GETUTCDATE()),
    (N'Transformers Robot Action Figure', N'Transformable robot action figure that converts from vehicle to robot mode.', 650000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatSuperhero, N'Over 6 Years', N'TRANSFORMERS', 1, GETUTCDATE()),
    (N'Spider-Man Web Shooter Set', N'Official Spider-Man web shooter with sound effects and web projectiles.', 420000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatSuperhero, N'Over 6 Years', N'MARVEL SPIDERMAN', 1, GETUTCDATE()),
    (N'Batman Action Figure', N'Detailed Batman action figure with accessories and cape.', 380000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatSuperhero, N'Over 6 Years', N'MARVEL', 0, GETUTCDATE()),
    (N'Robot Remote Control', N'Programmable robot that responds to voice commands and remote control.', 950000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatSuperhero, N'Over 6 Years', N'TRANSFORMERS', 1, GETUTCDATE()),
    (N'Superman Cape Set', N'Complete Superman costume with cape and accessories for role play.', 280000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatSuperhero, N'3 - 6 Years', N'MARVEL', 0, GETUTCDATE()),
    
    -- Dolls & Princesses
    (N'Barbie Dreamhouse Playset', N'Complete dreamhouse playset with furniture and accessories. Hours of imaginative play.', 1800000, 8, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDolls, N'3 - 6 Years', N'Barbie', 1, GETUTCDATE()),
    (N'Disney Princess Doll Collection', N'Beautiful Disney Princess dolls with authentic costumes and accessories.', 550000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDolls, N'3 - 6 Years', N'DISNEY PRINCESS', 1, GETUTCDATE()),
    (N'Princess Castle Playset', N'Magical princess castle with multiple rooms and accessories.', 1200000, 10, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDolls, N'3 - 6 Years', N'DISNEY PRINCESS', 0, GETUTCDATE()),
    (N'Fashion Doll Set', N'Complete fashion doll set with multiple outfits and accessories.', 380000, 22, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDolls, N'3 - 6 Years', N'Barbie', 0, GETUTCDATE()),
    (N'Baby Doll with Stroller', N'Realistic baby doll with stroller and feeding accessories.', 450000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDolls, N'3 - 6 Years', N'ZURU Sparkle girlz', 1, GETUTCDATE()),
    
    -- Building Blocks & Puzzles
    (N'Building Blocks Castle Set', N'Large building blocks set to create amazing castles and structures.', 520000, 14, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBuilding, N'3 - 6 Years', N'BOBICRAFT', 1, GETUTCDATE()),
    (N'LEGO City Set', N'Complete LEGO city set with buildings, vehicles, and mini figures.', 1500000, 8, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBuilding, N'Over 6 Years', N'LEGO', 1, GETUTCDATE()),
    (N'3D Puzzle - Eiffel Tower', N'Challenging 3D puzzle to build the iconic Eiffel Tower.', 280000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBuilding, N'Over 6 Years', N'Hape', 0, GETUTCDATE()),
    (N'Magnetic Building Tiles', N'Colorful magnetic tiles for endless building possibilities.', 680000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBuilding, N'3 - 6 Years', N'BOBICRAFT', 1, GETUTCDATE()),
    (N'Wooden Block Set', N'Classic wooden block set in various shapes and colors.', 320000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBuilding, N'1 - 2 Years', N'Hape', 0, GETUTCDATE()),
    
    -- Cars & Airplanes
    (N'Remote Control Racing Car', N'High-speed remote control car with LED lights and realistic engine sounds.', 750000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCars, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    (N'Remote Control Helicopter', N'Advanced remote control helicopter with gyroscope stabilization and LED lights.', 950000, 8, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCars, N'Over 6 Years', N'TINITOY', 0, GETUTCDATE()),
    (N'Hot Wheels Track Set', N'Complete Hot Wheels track set with loops and jumps.', 450000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCars, N'Over 6 Years', N'VALUE TOYS', 1, GETUTCDATE()),
    (N'Plane Model Kit', N'Detailed model airplane kit for building and display.', 380000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCars, N'Over 6 Years', N'TINITOY', 0, GETUTCDATE()),
    (N'Push Car Toy', N'Classic push car toy for toddlers to develop motor skills.', 280000, 22, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatCars, N'1 - 2 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    
    -- Dinosaurs & Animals
    (N'Dinosaur Action Figure Pack', N'Realistic dinosaur action figures with detailed features and movable parts.', 380000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDino, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    (N'Animal Farm Set', N'Complete farm animal set with barn and accessories.', 450000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDino, N'3 - 6 Years', N'VALUE TOYS', 1, GETUTCDATE()),
    (N'Wildlife Safari Set', N'Collection of wild animal figures for safari adventures.', 320000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDino, N'3 - 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    (N'T-Rex Robot', N'Animated T-Rex robot with sound effects and movement.', 680000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatDino, N'Over 6 Years', N'Pets Alive', 1, GETUTCDATE()),
    
    -- Stuffed Animals & Pets
    (N'Plush Teddy Bear - Large', N'Soft and cuddly large teddy bear perfect for bedtime cuddles.', 280000, 40, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatStuffed, N'0 - 6 Months', N'TINI', 0, GETUTCDATE()),
    (N'Stuffed Animal Collection - 5 Pack', N'Set of 5 adorable stuffed animals including bear, bunny, elephant, and more.', 320000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatStuffed, N'0 - 6 Months', N'TINI', 0, GETUTCDATE()),
    (N'Interactive Pet Dog', N'Realistic interactive pet dog that responds to touch and voice.', 550000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatStuffed, N'3 - 6 Years', N'Pets Alive', 1, GETUTCDATE()),
    (N'Unicorn Plush Toy', N'Magical unicorn plush toy with rainbow mane.', 250000, 30, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatStuffed, N'0 - 6 Months', N'TY', 0, GETUTCDATE()),
    
    -- Board Games
    (N'Board Game - Family Fun Pack', N'Collection of classic board games for the whole family to enjoy together.', 280000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBoard, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    (N'Chess Set for Kids', N'Colorful chess set designed for children to learn strategy.', 350000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBoard, N'Over 6 Years', N'VALUE TOYS', 1, GETUTCDATE()),
    (N'Monopoly Junior', N'Junior version of the classic Monopoly game.', 420000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatBoard, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
    
    -- Infants & Preschoolers
    (N'Baby Einstein Musical Toy', N'Interactive musical toy that plays melodies and helps with sensory development.', 320000, 22, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatInfants, N'0 - 6 Months', N'Baby Einstein', 0, GETUTCDATE()),
    (N'Fisher Price Activity Center', N'Multi-activity center with lights, sounds, and interactive features for babies.', 480000, 10, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatInfants, N'6 - 12 Months', N'FISHER PRICE', 0, GETUTCDATE()),
    (N'Teething Ring Set', N'Set of safe teething rings in various textures and colors.', 150000, 35, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatInfants, N'0 - 6 Months', N'Bright Starts', 0, GETUTCDATE()),
    (N'Baby Gym Playmat', N'Interactive playmat with hanging toys for tummy time.', 380000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatInfants, N'0 - 6 Months', N'Bright Starts', 1, GETUTCDATE()),
    (N'Stacking Rings Toy', N'Classic stacking rings toy to develop hand-eye coordination.', 180000, 28, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @CatInfants, N'6 - 12 Months', N'Bright Starts', 0, GETUTCDATE());
GO

-- =============================================
-- SEED SAMPLE USERS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Xóa dữ liệu cũ và insert mới
DELETE FROM [dbo].[OrderItems];
DELETE FROM [dbo].[Orders];
DELETE FROM [dbo].[AspNetUserRoles];
DELETE FROM [dbo].[AspNetUsers];
DBCC CHECKIDENT ('[dbo].[Orders]', RESEED, 1);
DBCC CHECKIDENT ('[dbo].[OrderItems]', RESEED, 1);

-- Lấy Role IDs
DECLARE @UserRoleId NVARCHAR(128), @AdminRoleId NVARCHAR(128);
SELECT @UserRoleId = Id FROM [dbo].[AspNetRoles] WHERE [NormalizedName] = 'USER';
SELECT @AdminRoleId = Id FROM [dbo].[AspNetRoles] WHERE [NormalizedName] = 'ADMIN';

-- Insert sample users
DECLARE @UserId1 NVARCHAR(128) = CAST(NEWID() AS NVARCHAR(128));
DECLARE @UserId2 NVARCHAR(128) = CAST(NEWID() AS NVARCHAR(128));
DECLARE @UserId3 NVARCHAR(128) = CAST(NEWID() AS NVARCHAR(128));
DECLARE @UserId4 NVARCHAR(128) = CAST(NEWID() AS NVARCHAR(128));
DECLARE @UserId5 NVARCHAR(128) = CAST(NEWID() AS NVARCHAR(128));
DECLARE @AdminUserId NVARCHAR(128) = CAST(NEWID() AS NVARCHAR(128));

-- User 1: Nguyễn Văn An
INSERT INTO [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount], [FirstName], [LastName], [FullName], [Address], [ChildBirthday], [CreatedAt])
VALUES (@UserId1, N'nguyenvanan', N'NGUYENVANAN', N'nguyenvanan@email.com', N'NGUYENVANAN@EMAIL.COM', 1, NULL, NEWID(), NEWID(), N'0912345678', 1, 0, 1, 0, N'Văn An', N'Nguyễn', N'Nguyễn Văn An', N'123 Đường ABC, Quận 1, TP.HCM', '2018-05-15', GETUTCDATE());

-- User 2: Trần Thị Bình
INSERT INTO [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount], [FirstName], [LastName], [FullName], [Address], [ChildBirthday], [CreatedAt])
VALUES (@UserId2, N'tranthibinh', N'TRANTHIBINH', N'tranthibinh@email.com', N'TRANTHIBINH@EMAIL.COM', 1, NULL, NEWID(), NEWID(), N'0923456789', 1, 0, 1, 0, N'Thị Bình', N'Trần', N'Trần Thị Bình', N'456 Đường XYZ, Quận 3, TP.HCM', '2019-08-20', GETUTCDATE());

-- User 3: Lê Minh Cường
INSERT INTO [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount], [FirstName], [LastName], [FullName], [Address], [ChildBirthday], [CreatedAt])
VALUES (@UserId3, N'leminhcuong', N'LEMINHCUONG', N'leminhcuong@email.com', N'LEMINHCUONG@EMAIL.COM', 1, NULL, NEWID(), NEWID(), N'0934567890', 1, 0, 1, 0, N'Minh Cường', N'Lê', N'Lê Minh Cường', N'789 Đường DEF, Quận 7, TP.HCM', '2020-03-10', GETUTCDATE());

-- User 4: Phạm Thị Dung
INSERT INTO [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount], [FirstName], [LastName], [FullName], [Address], [ChildBirthday], [CreatedAt])
VALUES (@UserId4, N'phamthidung', N'PHAMTHIDUNG', N'phamthidung@email.com', N'PHAMTHIDUNG@EMAIL.COM', 1, NULL, NEWID(), NEWID(), N'0945678901', 1, 0, 1, 0, N'Thị Dung', N'Phạm', N'Phạm Thị Dung', N'321 Đường GHI, Quận 10, TP.HCM', '2017-11-25', GETUTCDATE());

-- User 5: Hoàng Văn Em
INSERT INTO [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount], [FirstName], [LastName], [FullName], [Address], [ChildBirthday], [CreatedAt])
VALUES (@UserId5, N'hoangvanem', N'HOANGVANEM', N'hoangvanem@email.com', N'HOANGVANEM@EMAIL.COM', 1, NULL, NEWID(), NEWID(), N'0956789012', 1, 0, 1, 0, N'Văn Em', N'Hoàng', N'Hoàng Văn Em', N'654 Đường JKL, Quận Bình Thạnh, TP.HCM', '2021-01-05', GETUTCDATE());

-- Lưu ý: Admin user sẽ được tạo tự động bởi DbInitializer với password "Admin@123"
-- Không tạo admin user ở đây để tránh xung đột với PasswordHash

-- Assign roles to users
INSERT INTO [dbo].[AspNetUserRoles] ([UserId], [RoleId])
VALUES
    (@UserId1, @UserRoleId),
    (@UserId2, @UserRoleId),
    (@UserId3, @UserRoleId),
    (@UserId4, @UserRoleId),
    (@UserId5, @UserRoleId);
GO

-- =============================================
-- SEED SAMPLE ORDERS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Lấy User IDs và Product IDs
DECLARE @U1 NVARCHAR(128), @U2 NVARCHAR(128), @U3 NVARCHAR(128), @U4 NVARCHAR(128), @U5 NVARCHAR(128);
SELECT TOP 1 @U1 = Id FROM [dbo].[AspNetUsers] WHERE [UserName] = N'nguyenvanan';
SELECT TOP 1 @U2 = Id FROM [dbo].[AspNetUsers] WHERE [UserName] = N'tranthibinh';
SELECT TOP 1 @U3 = Id FROM [dbo].[AspNetUsers] WHERE [UserName] = N'leminhcuong';
SELECT TOP 1 @U4 = Id FROM [dbo].[AspNetUsers] WHERE [UserName] = N'phamthidung';
SELECT TOP 1 @U5 = Id FROM [dbo].[AspNetUsers] WHERE [UserName] = N'hoangvanem';

-- Kiểm tra số lượng products trước khi lấy IDs
DECLARE @ProductCount INT;
SELECT @ProductCount = COUNT(*) FROM [dbo].[Products];
PRINT 'Total Products in database: ' + CAST(@ProductCount AS NVARCHAR(10));

-- Declare Product ID variables
DECLARE @P1 INT, @P2 INT, @P3 INT, @P4 INT, @P5 INT, @P6 INT, @P7 INT, @P8 INT, @P9 INT, @P10 INT;

IF @ProductCount = 0
BEGIN
    PRINT 'ERROR: No products found in database. Please check if products were inserted successfully.';
    PRINT 'Order items will NOT be inserted.';
END
ELSE
BEGIN
    -- Lấy Product IDs
    SELECT TOP 1 @P1 = Id FROM [dbo].[Products] WHERE [Name] = N'LEGO Technic Ferrari FXX-K Supercar';
    SELECT TOP 1 @P2 = Id FROM [dbo].[Products] WHERE [Name] = N'Barbie Dreamhouse Playset';
    SELECT TOP 1 @P3 = Id FROM [dbo].[Products] WHERE [Name] = N'Avengers Action Figure Set';
    SELECT TOP 1 @P4 = Id FROM [dbo].[Products] WHERE [Name] = N'Disney Princess Doll Collection';
    SELECT TOP 1 @P5 = Id FROM [dbo].[Products] WHERE [Name] = N'Remote Control Racing Car';
    SELECT TOP 1 @P6 = Id FROM [dbo].[Products] WHERE [Name] = N'Plush Teddy Bear - Large';
    SELECT TOP 1 @P7 = Id FROM [dbo].[Products] WHERE [Name] = N'Transformers Robot Action Figure';
    SELECT TOP 1 @P8 = Id FROM [dbo].[Products] WHERE [Name] = N'Spider-Man Web Shooter Set';
    SELECT TOP 1 @P9 = Id FROM [dbo].[Products] WHERE [Name] = N'Building Blocks Castle Set';
    SELECT TOP 1 @P10 = Id FROM [dbo].[Products] WHERE [Name] = N'Baby Einstein Musical Toy';
    
    -- Debug output
    PRINT 'Product IDs found:';
    PRINT '  @P1 (LEGO Ferrari): ' + ISNULL(CAST(@P1 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P2 (Barbie Dreamhouse): ' + ISNULL(CAST(@P2 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P3 (Avengers): ' + ISNULL(CAST(@P3 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P4 (Disney Princess): ' + ISNULL(CAST(@P4 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P5 (RC Car): ' + ISNULL(CAST(@P5 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P6 (Teddy Bear): ' + ISNULL(CAST(@P6 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P7 (Transformers): ' + ISNULL(CAST(@P7 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P8 (Spider-Man): ' + ISNULL(CAST(@P8 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P9 (Building Blocks): ' + ISNULL(CAST(@P9 AS NVARCHAR(10)), 'NULL');
    PRINT '  @P10 (Baby Einstein): ' + ISNULL(CAST(@P10 AS NVARCHAR(10)), 'NULL');
    
    -- Kiểm tra các ProductId đã được lấy thành công
    IF @P1 IS NULL OR @P2 IS NULL OR @P3 IS NULL OR @P4 IS NULL OR @P5 IS NULL OR @P6 IS NULL OR @P7 IS NULL OR @P8 IS NULL OR @P9 IS NULL OR @P10 IS NULL
    BEGIN
        PRINT 'Warning: One or more products not found. Some order items may not be inserted.';
    END
    ELSE
    BEGIN
        PRINT 'All product IDs retrieved successfully!';
    END
END

-- Order 1: Nguyễn Văn An - Completed
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U1, DATEADD(DAY, -10, GETUTCDATE()), N'123 Đường ABC, Quận 1, TP.HCM', N'Completed', 3050000);

DECLARE @OrderId1 INT = SCOPE_IDENTITY();
IF @P1 IS NOT NULL AND @P6 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId1, @P1, 1, 2500000),
        (@OrderId1, @P6, 2, 280000);
END

-- Order 2: Trần Thị Bình - Processing
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U2, DATEADD(DAY, -5, GETUTCDATE()), N'456 Đường XYZ, Quận 3, TP.HCM', N'Processing', 2350000);

DECLARE @OrderId2 INT = SCOPE_IDENTITY();
IF @P2 IS NOT NULL AND @P4 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId2, @P2, 1, 1800000),
        (@OrderId2, @P4, 1, 550000);
END

-- Order 3: Lê Minh Cường - Pending
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U3, DATEADD(DAY, -2, GETUTCDATE()), N'789 Đường DEF, Quận 7, TP.HCM', N'Pending', 1070000);

DECLARE @OrderId3 INT = SCOPE_IDENTITY();
IF @P3 IS NOT NULL AND @P8 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId3, @P3, 2, 450000),
        (@OrderId3, @P8, 1, 420000);
END

-- Order 4: Phạm Thị Dung - Completed
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U4, DATEADD(DAY, -15, GETUTCDATE()), N'321 Đường GHI, Quận 10, TP.HCM', N'Completed', 1600000);

DECLARE @OrderId4 INT = SCOPE_IDENTITY();
IF @P7 IS NOT NULL AND @P9 IS NOT NULL AND @P5 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId4, @P7, 1, 650000),
        (@OrderId4, @P9, 1, 520000),
        (@OrderId4, @P5, 1, 750000);
END

-- Order 5: Hoàng Văn Em - Shipped
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U5, DATEADD(DAY, -7, GETUTCDATE()), N'654 Đường JKL, Quận Bình Thạnh, TP.HCM', N'Shipped', 640000);

DECLARE @OrderId5 INT = SCOPE_IDENTITY();
IF @P10 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId5, @P10, 2, 320000);
END

-- Order 6: Nguyễn Văn An - Another order
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U1, DATEADD(DAY, -1, GETUTCDATE()), N'123 Đường ABC, Quận 1, TP.HCM', N'Pending', 900000);

DECLARE @OrderId6 INT = SCOPE_IDENTITY();
IF @P5 IS NOT NULL AND @P6 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId6, @P5, 1, 750000),
        (@OrderId6, @P6, 1, 280000);
END

-- Order 7: Trần Thị Bình - Cancelled
INSERT INTO [dbo].[Orders] ([UserId], [OrderDate], [ShippingAddress], [Status], [TotalAmount])
VALUES (@U2, DATEADD(DAY, -3, GETUTCDATE()), N'456 Đường XYZ, Quận 3, TP.HCM', N'Cancelled', 450000);

DECLARE @OrderId7 INT = SCOPE_IDENTITY();
IF @P3 IS NOT NULL
BEGIN
    INSERT INTO [dbo].[OrderItems] ([OrderId], [ProductId], [Quantity], [Price])
    VALUES
        (@OrderId7, @P3, 1, 450000);
END
GO

-- =============================================
-- SEED SAMPLE DISCOUNT CODES DATA
-- =============================================
USE ToysStoreDb;
GO

-- Insert 10 sample discount codes
IF NOT EXISTS (SELECT * FROM [dbo].[DiscountCodes] WHERE [Code] = 'WELCOME10')
BEGIN
    INSERT INTO [dbo].[DiscountCodes] ([Code], [DiscountAmount], [MinOrderAmount], [Description], [ExpiryDate], [IsActive], [CreatedAt], [MaxUsage], [UsedCount])
    VALUES 
        (N'WELCOME10', 100000, 1000000, N'Welcome discount for orders from 1,000K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'SAVE50K', 50000, 500000, N'Save 50K for orders from 500K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'DEC20', 20000, 399000, N'December special - orders from 399K (Only Online)', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'NEWYEAR2026', 150000, 1500000, N'New Year 2026 special discount', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'KIDS50', 50000, 300000, N'Special discount for kids toys - orders from 300K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'SUMMER25', 25000, 250000, N'Summer sale discount - orders from 250K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'VIP100', 100000, 800000, N'VIP customer discount - orders from 800K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'FLASH30', 30000, 400000, N'Flash sale - orders from 400K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'BIRTHDAY15', 150000, 1200000, N'Birthday special - orders from 1,200K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0),
        (N'TOYLOVE', 75000, 600000, N'Love toys discount - orders from 600K', DATEADD(YEAR, 1, GETUTCDATE()), 1, GETUTCDATE(), 0, 0);
END
GO
