-- =============================================
-- ToysStore Database - Complete SQL Script
-- Tạo tất cả các bảng cần thiết cho hệ thống
-- Không có dữ liệu mẫu (banner mặc định)
-- =============================================

USE master;
GO

-- Tạo database nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ToysStoreDb')
BEGIN
    CREATE DATABASE ToysStoreDb;
    PRINT 'Database ToysStoreDb created successfully.';
END
ELSE
BEGIN
    PRINT 'Database ToysStoreDb already exists.';
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
    PRINT 'Table Banners created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Banners already exists.';
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
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table Brands created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Brands already exists.';
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
        [Description] NVARCHAR(MAX) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table Categories created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Categories already exists.';
END
GO

-- =============================================
-- 3. BẢNG PRODUCTS
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
    CREATE INDEX [IX_Products_CategoryId] ON [dbo].[Products]([CategoryId]);
    PRINT 'Table Products created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Products already exists.';
END
GO

-- =============================================
-- 4. BẢNG ASP.NET IDENTITY - AspNetUsers
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUsers] (
        [Id] NVARCHAR(450) NOT NULL PRIMARY KEY,
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
    CREATE INDEX [EmailIndex] ON [dbo].[AspNetUsers]([NormalizedEmail]);
    CREATE UNIQUE INDEX [UserNameIndex] ON [dbo].[AspNetUsers]([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;
    PRINT 'Table AspNetUsers created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetUsers already exists.';
END
GO

-- =============================================
-- 5. BẢNG ASP.NET IDENTITY - AspNetRoles
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetRoles] (
        [Id] NVARCHAR(450) NOT NULL PRIMARY KEY,
        [Name] NVARCHAR(256) NULL,
        [NormalizedName] NVARCHAR(256) NULL,
        [ConcurrencyStamp] NVARCHAR(MAX) NULL
    );
    CREATE UNIQUE INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;
    PRINT 'Table AspNetRoles created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetRoles already exists.';
END
GO

-- =============================================
-- 6. BẢNG ASP.NET IDENTITY - AspNetUserRoles
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserRoles] (
        [UserId] NVARCHAR(450) NOT NULL,
        [RoleId] NVARCHAR(450) NOT NULL,
        PRIMARY KEY ([UserId], [RoleId]),
        CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) 
            REFERENCES [dbo].[AspNetRoles]([Id]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles]([RoleId]);
    PRINT 'Table AspNetUserRoles created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetUserRoles already exists.';
END
GO

-- =============================================
-- 7. BẢNG ASP.NET IDENTITY - AspNetUserClaims
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserClaims]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserClaims] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] NVARCHAR(450) NOT NULL,
        [ClaimType] NVARCHAR(MAX) NULL,
        [ClaimValue] NVARCHAR(MAX) NULL,
        CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims]([UserId]);
    PRINT 'Table AspNetUserClaims created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetUserClaims already exists.';
END
GO

-- =============================================
-- 8. BẢNG ASP.NET IDENTITY - AspNetUserLogins
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserLogins]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserLogins] (
        [LoginProvider] NVARCHAR(128) NOT NULL,
        [ProviderKey] NVARCHAR(128) NOT NULL,
        [ProviderDisplayName] NVARCHAR(MAX) NULL,
        [UserId] NVARCHAR(450) NOT NULL,
        PRIMARY KEY ([LoginProvider], [ProviderKey]),
        CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins]([UserId]);
    PRINT 'Table AspNetUserLogins created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetUserLogins already exists.';
END
GO

-- =============================================
-- 9. BẢNG ASP.NET IDENTITY - AspNetRoleClaims
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetRoleClaims]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetRoleClaims] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [RoleId] NVARCHAR(450) NOT NULL,
        [ClaimType] NVARCHAR(MAX) NULL,
        [ClaimValue] NVARCHAR(MAX) NULL,
        CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) 
            REFERENCES [dbo].[AspNetRoles]([Id]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims]([RoleId]);
    PRINT 'Table AspNetRoleClaims created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetRoleClaims already exists.';
END
GO

-- =============================================
-- 10. BẢNG ASP.NET IDENTITY - AspNetUserTokens
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserTokens]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AspNetUserTokens] (
        [UserId] NVARCHAR(450) NOT NULL,
        [LoginProvider] NVARCHAR(128) NOT NULL,
        [Name] NVARCHAR(128) NOT NULL,
        [Value] NVARCHAR(MAX) NULL,
        PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );
    PRINT 'Table AspNetUserTokens created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AspNetUserTokens already exists.';
END
GO

-- =============================================
-- 11. BẢNG ORDERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Orders] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] NVARCHAR(450) NOT NULL,
        [OrderDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [ShippingAddress] NVARCHAR(200) NOT NULL,
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
        [TotalAmount] DECIMAL(18,2) NOT NULL,
        CONSTRAINT [FK_Orders_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE NO ACTION
    );
    CREATE INDEX [IX_Orders_UserId] ON [dbo].[Orders]([UserId]);
    PRINT 'Table Orders created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Orders already exists.';
END
GO

-- =============================================
-- 12. BẢNG ORDERITEMS
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
    CREATE INDEX [IX_OrderItems_OrderId] ON [dbo].[OrderItems]([OrderId]);
    CREATE INDEX [IX_OrderItems_ProductId] ON [dbo].[OrderItems]([ProductId]);
    PRINT 'Table OrderItems created successfully.';
END
ELSE
BEGIN
    PRINT 'Table OrderItems already exists.';
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
        PRINT 'Column AgeRange added to Products table.';
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
        PRINT 'Column Brand added to Products table.';
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
        PRINT 'Column IsNew added to Products table.';
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
        PRINT 'Column FirstName added to AspNetUsers table.';
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
        PRINT 'Column LastName added to AspNetUsers table.';
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
        PRINT 'Column ChildBirthday added to AspNetUsers table.';
    END
END
GO

-- =============================================
-- SEED SAMPLE BANNERS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Insert sample banners if table is empty
IF NOT EXISTS (SELECT * FROM [dbo].[Banners])
BEGIN
    INSERT INTO [dbo].[Banners] ([Title], [ImageUrl], [LinkUrl], [DisplayOrder], [IsActive], [CreatedAt])
    VALUES
        (N'Banner 1', N'https://www.mykingdom.com.vn/cdn/shop/files/viber_image_2025-11-17_17-34-27-437.jpg?v=1763433969&width=1200', N'#', 1, 1, GETUTCDATE()),
        (N'Banner 2', N'https://herogame.vn/ad-min/assets/js/libs/kcfinder/upload_img2/images/Vi%E1%BB%87t/T5/Herogame__GundamBreaker4LaunchEdition_01.jpg', N'#', 2, 1, GETUTCDATE());
    
    PRINT '2 sample banners inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Banners table already has data. Skipping seed.';
END
GO

-- =============================================
-- SEED SAMPLE BRANDS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Insert sample brands if table is empty
IF NOT EXISTS (SELECT * FROM [dbo].[Brands])
BEGIN
    INSERT INTO [dbo].[Brands] ([Name], [LogoUrl], [DisplayOrder], [IsActive], [CreatedAt])
    VALUES
        (N'SKIP*HOP', N'https://file.hstatic.net/1000202622/file/untitled_design__31__b5e4428f3ed1475a87837a417c38245e.png', 1, 1, GETUTCDATE()),
        (N'Hape', N'https://file.hstatic.net/1000202622/file/hape_323fe297833947bc8134142092684d1a.png', 2, 1, GETUTCDATE()),
        (N'Bright Starts', N'https://file.hstatic.net/1000202622/file/bright_starts_19e06a724b0441029c05a960a107d5aa.png', 3, 1, GETUTCDATE()),
        (N'tiNi TOY', N'https://file.hstatic.net/1000202622/file/logo__14__92a07901d90a4d639a5c98bc5faa505c.png', 4, 1, GETUTCDATE()),
        (N'MARVEL', N'https://file.hstatic.net/1000202622/file/brands_logo_website-18_bb4e1a6fabec4752bca534c1658af652.png', 5, 1, GETUTCDATE()),
        (N'TRANSFORMERS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-tfm_9e493c30b6a943b88f3aa12acc758f16.png', 6, 1, GETUTCDATE()),
        (N'Barbie', N'https://file.hstatic.net/1000202622/file/logo__26__a2416b04d6e14ad88e799485d28705cf.png', 7, 1, GETUTCDATE()),
        (N'ZURU Sparkle girlz', N'https://file.hstatic.net/1000202622/file/3_4a50931e94a947f38259adbed0613c01.png', 8, 1, GETUTCDATE()),
        (N'Baby Einstein', N'https://file.hstatic.net/1000202622/file/baby_einstein_922a00f0de5845198dbcb66e22e86f7c.png', 9, 1, GETUTCDATE()),
        (N'Ingenuity', N'https://file.hstatic.net/1000202622/file/ingenuity_3fa5fa7a148c488c963b090f08aca97b.png', 10, 1, GETUTCDATE()),
        (N'SwaddleMe by Ingenuity', N'https://file.hstatic.net/1000202622/file/brands_logo_website-108_a53fd8443c7341308af383632788998b.png', 11, 1, GETUTCDATE()),
        (N'ZURU SMASHERS', N'https://file.hstatic.net/1000202622/file/logo__20__d0e79bbeef81421888f9dc591172a615.png', 12, 1, GETUTCDATE()),
        (N'MARVEL AVENGERS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-avengerred_d619577355084fed9a0ee3b7e351799e.png', 13, 1, GETUTCDATE()),
        (N'MARVEL SPIDERMAN', N'https://file.hstatic.net/1000202622/file/logo__2__70b2491f816c48af8858a3313f3ea614.png', 14, 1, GETUTCDATE()),
        (N'5 SURPRISE', N'https://file.hstatic.net/1000202622/file/logo__17__dc8417b53c034fd28d5054b8141155a0.png', 15, 1, GETUTCDATE()),
        (N'ZURU RainBocorns', N'https://file.hstatic.net/1000202622/file/logo__19__bff5d7157b354609b94e64431ed86b58.png', 16, 1, GETUTCDATE()),
        (N'Pets Alive', N'https://file.hstatic.net/1000202622/file/pet_alive_11adb4da66d84067938473d5e338b43b.png', 17, 1, GETUTCDATE()),
        (N'TY', N'https://file.hstatic.net/1000202622/file/brands_logo_website-01_082873eca1de45e2bf4703b34d8f610a.png', 18, 1, GETUTCDATE()),
        (N'LEGO', N'https://file.hstatic.net/1000202622/file/brands_logo_website-18_bb4e1a6fabec4752bca534c1658af652.png', 19, 1, GETUTCDATE()),
        (N'AVENGERS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-avengerred_d619577355084fed9a0ee3b7e351799e.png', 20, 1, GETUTCDATE()),
        (N'DISNEY PRINCESS', N'https://file.hstatic.net/1000202622/file/logo__26__a2416b04d6e14ad88e799485d28705cf.png', 21, 1, GETUTCDATE()),
        (N'VALUE TOYS', N'https://file.hstatic.net/1000202622/file/brands_logo_website-01_082873eca1de45e2bf4703b34d8f610a.png', 22, 1, GETUTCDATE()),
        (N'FISHER PRICE', N'https://file.hstatic.net/1000202622/file/ingenuity_3fa5fa7a148c488c963b090f08aca97b.png', 23, 1, GETUTCDATE()),
        (N'PLAY-DOH', N'https://file.hstatic.net/1000202622/file/bright_starts_19e06a724b0441029c05a960a107d5aa.png', 24, 1, GETUTCDATE()),
        (N'SPIDER-MAN', N'https://file.hstatic.net/1000202622/file/logo__2__70b2491f816c48af8858a3313f3ea614.png', 25, 1, GETUTCDATE()),
        (N'BOBICRAFT', N'https://file.hstatic.net/1000202622/file/logo__14__92a07901d90a4d639a5c98bc5faa505c.png', 26, 1, GETUTCDATE()),
        (N'TINITOY', N'https://file.hstatic.net/1000202622/file/logo__19__bff5d7157b354609b94e64431ed86b58.png', 27, 1, GETUTCDATE()),
        (N'MESUCA', N'https://file.hstatic.net/1000202622/file/bright_starts_19e06a724b0441029c05a960a107d5aa.png', 28, 1, GETUTCDATE()),
        (N'CARTER''S', N'https://file.hstatic.net/1000202622/file/brands_logo_website-01_082873eca1de45e2bf4703b34d8f610a.png', 29, 1, GETUTCDATE());
    
    PRINT '30 sample brands inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Brands table already has data. Skipping seed.';
END
GO

-- =============================================
-- SEED SAMPLE CATEGORIES DATA
-- =============================================
USE ToysStoreDb;
GO

-- Insert sample categories if table is empty
IF NOT EXISTS (SELECT * FROM [dbo].[Categories])
BEGIN
    INSERT INTO [dbo].[Categories] ([Name], [Description], [CreatedAt])
    VALUES
        (N'Educational Toys', N'Toys that help children learn and develop skills', GETUTCDATE()),
        (N'Creative Toys', N'Toys that encourage creativity and imagination', GETUTCDATE()),
        (N'Active Toys', N'Toys that promote physical activity and movement', GETUTCDATE()),
        (N'Superheroes & Robots', N'Action figures, superhero toys, and robot toys', GETUTCDATE()),
        (N'Dolls & Princesses', N'Dolls, princess toys, and fashion dolls', GETUTCDATE()),
        (N'Building Blocks & Puzzles', N'Construction toys, building blocks, and puzzles', GETUTCDATE()),
        (N'Cars & Airplanes', N'Vehicle toys including cars, trucks, and airplanes', GETUTCDATE()),
        (N'Dinosaurs & Animals', N'Dinosaur toys and animal figures', GETUTCDATE()),
        (N'Stuffed Animals & Pets', N'Plush toys and pet-related toys', GETUTCDATE()),
        (N'Board Games', N'Educational and fun board games for all ages', GETUTCDATE()),
        (N'Infants & Preschoolers', N'Toys designed for babies and toddlers', GETUTCDATE()),
        (N'Mom & Baby Products', N'Products for mothers and babies', GETUTCDATE()),
        (N'Personal & School Supplies', N'Personal care items and school supplies', GETUTCDATE()),
        (N'tiNi Products', N'Special tiNi brand products', GETUTCDATE());
    
    PRINT 'Sample categories inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Categories table already has data. Skipping seed.';
END
GO

-- =============================================
-- SEED SAMPLE PRODUCTS DATA
-- =============================================
USE ToysStoreDb;
GO

-- Insert sample products if table is empty
IF NOT EXISTS (SELECT * FROM [dbo].[Products])
BEGIN
    -- Get first category ID for products
    DECLARE @FirstCategoryId INT;
    SELECT TOP 1 @FirstCategoryId = Id FROM [dbo].[Categories] ORDER BY Id;
    
    -- If no categories exist, create a default one
    IF @FirstCategoryId IS NULL
    BEGIN
        INSERT INTO [dbo].[Categories] ([Name], [Description], [CreatedAt])
        VALUES (N'General Toys', N'General toy category', GETUTCDATE());
        SET @FirstCategoryId = SCOPE_IDENTITY();
    END
    
    -- Insert 20 sample products
    INSERT INTO [dbo].[Products] ([Name], [Description], [Price], [Stock], [ImageUrl], [CategoryId], [AgeRange], [Brand], [IsNew], [CreatedAt])
    VALUES
        (N'LEGO Technic Ferrari FXX-K Supercar', N'Build your own Ferrari FXX-K supercar with this detailed LEGO Technic set. Features working steering, suspension, and V12 engine.', 2500000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'LEGO', 1, GETUTCDATE()),
        (N'Educational Building Blocks Set', N'Colorful building blocks that help develop creativity and motor skills. Perfect for young children.', 350000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'1 - 2 Years', N'Bright Starts', 0, GETUTCDATE()),
        (N'Barbie Dreamhouse Playset', N'Complete dreamhouse playset with furniture and accessories. Hours of imaginative play.', 1800000, 8, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'Barbie', 1, GETUTCDATE()),
        (N'Avengers Action Figure Set', N'Collectible Avengers action figures including Iron Man, Captain America, and Thor.', 450000, 30, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'MARVEL AVENGERS', 0, GETUTCDATE()),
        (N'Disney Princess Doll Collection', N'Beautiful Disney Princess dolls with authentic costumes and accessories.', 550000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'DISNEY PRINCESS', 1, GETUTCDATE()),
        (N'Remote Control Racing Car', N'High-speed remote control car with LED lights and realistic engine sounds.', 750000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
        (N'Plush Teddy Bear - Large', N'Soft and cuddly large teddy bear perfect for bedtime cuddles.', 280000, 40, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'0 - 6 Months', N'TINI', 0, GETUTCDATE()),
        (N'Educational Puzzle Set - 100 Pieces', N'Colorful jigsaw puzzles that help develop problem-solving skills.', 180000, 35, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'Hape', 0, GETUTCDATE()),
        (N'Transformers Robot Action Figure', N'Transformable robot action figure that converts from vehicle to robot mode.', 650000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'TRANSFORMERS', 1, GETUTCDATE()),
        (N'Baby Einstein Musical Toy', N'Interactive musical toy that plays melodies and helps with sensory development.', 320000, 22, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'0 - 6 Months', N'Baby Einstein', 0, GETUTCDATE()),
        (N'Spider-Man Web Shooter Set', N'Official Spider-Man web shooter with sound effects and web projectiles.', 420000, 15, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'MARVEL SPIDERMAN', 1, GETUTCDATE()),
        (N'Fisher Price Activity Center', N'Multi-activity center with lights, sounds, and interactive features for babies.', 480000, 10, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'6 - 12 Months', N'FISHER PRICE', 0, GETUTCDATE()),
        (N'Play-Doh Creative Set', N'Complete Play-Doh set with multiple colors and creative tools for endless fun.', 250000, 28, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'PLAY-DOH', 0, GETUTCDATE()),
        (N'Dinosaur Action Figure Pack', N'Realistic dinosaur action figures with detailed features and movable parts.', 380000, 20, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
        (N'Building Blocks Castle Set', N'Large building blocks set to create amazing castles and structures.', 520000, 14, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'BOBICRAFT', 1, GETUTCDATE()),
        (N'Remote Control Helicopter', N'Advanced remote control helicopter with gyroscope stabilization and LED lights.', 950000, 8, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'TINITOY', 0, GETUTCDATE()),
        (N'Stuffed Animal Collection - 5 Pack', N'Set of 5 adorable stuffed animals including bear, bunny, elephant, and more.', 320000, 25, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'0 - 6 Months', N'TINI', 0, GETUTCDATE()),
        (N'Board Game - Family Fun Pack', N'Collection of classic board games for the whole family to enjoy together.', 280000, 18, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'Over 6 Years', N'VALUE TOYS', 0, GETUTCDATE()),
        (N'Art Supplies Creative Kit', N'Complete art supplies kit with crayons, markers, paints, and drawing paper.', 220000, 30, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'MESUCA', 0, GETUTCDATE()),
        (N'Musical Keyboard for Kids', N'Colorful musical keyboard with multiple sounds and built-in songs.', 680000, 12, N'https://www.mykingdom.com.vn/cdn/shop/files/do-choi-lap-rap-sieu-xe-ferrari-fxx-k-v29-lego-technic-42212-lg_5.jpg?v=1753159470&width=990', @FirstCategoryId, N'3 - 6 Years', N'CARTER''S', 1, GETUTCDATE());
    
    PRINT '20 sample products inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Products table already has data. Skipping seed.';
END
GO

-- =============================================
-- HOÀN TẤT
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Database setup completed successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Tables created/updated:';
PRINT '  - Banners';
PRINT '  - Categories';
PRINT '  - Products (with AgeRange, Brand, IsNew columns)';
PRINT '  - Orders';
PRINT '  - OrderItems';
PRINT '  - AspNetUsers (Identity with FirstName, LastName, ChildBirthday)';
PRINT '  - AspNetRoles (Identity)';
PRINT '  - AspNetUserRoles (Identity)';
PRINT '  - AspNetUserClaims (Identity)';
PRINT '  - AspNetUserLogins (Identity)';
PRINT '  - AspNetRoleClaims (Identity)';
PRINT '  - AspNetUserTokens (Identity)';
PRINT '';
PRINT 'Columns updated automatically:';
PRINT '  - Products: AgeRange, Brand, IsNew';
PRINT '  - AspNetUsers: FirstName, LastName, ChildBirthday';
PRINT '';
PRINT 'Sample data:';
PRINT '  - Brands: 30 sample brands inserted (if table was empty)';
PRINT '  - Banners: 2 sample banners inserted (if table was empty)';
PRINT '  - Categories: 14 sample categories inserted (if table was empty)';
PRINT '  - Products: 20 sample products inserted (if table was empty)';
PRINT '';
PRINT 'Note: Banners, Categories and Products can be managed via SQL or Admin panel.';
PRINT 'You can add users manually.';
PRINT '';
PRINT 'This script can be run multiple times safely.';
PRINT 'It will create missing tables/columns without errors.';
GO

