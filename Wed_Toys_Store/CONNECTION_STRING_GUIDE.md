# Connection String Configuration Guide

## Current Configuration

The application is configured to connect to SQL Server on server **"PC"**.

## Connection String Location

File: `appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=PC;Database=ToysStoreDb;Trusted_Connection=true;MultipleActiveResultSets=true;Encrypt=True;TrustServerCertificate=True"
  }
}
```

## How to Change Connection String

### Option 1: SQL Server LocalDB (Default)
```json
"DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ToysStoreDb;Trusted_Connection=true;MultipleActiveResultSets=true"
```

### Option 2: SQL Server Named Instance
```json
"DefaultConnection": "Server=PC\\SQLEXPRESS;Database=ToysStoreDb;Trusted_Connection=true;MultipleActiveResultSets=true"
```

### Option 3: SQL Server with SQL Authentication
```json
"DefaultConnection": "Server=PC;Database=ToysStoreDb;User Id=your_username;Password=your_password;MultipleActiveResultSets=true;Encrypt=True;TrustServerCertificate=True"
```

### Option 4: SQL Server with Windows Authentication (Current)
```json
"DefaultConnection": "Server=PC;Database=ToysStoreDb;Trusted_Connection=true;MultipleActiveResultSets=true;Encrypt=True;TrustServerCertificate=True"
```

## Connection String Parameters

- **Server**: Server name or instance name
  - `PC` - Your current server
  - `(localdb)\mssqllocaldb` - LocalDB instance
  - `PC\SQLEXPRESS` - Named instance SQLEXPRESS on PC
  
- **Database**: Database name (`ToysStoreDb`)

- **Trusted_Connection=true**: Use Windows Authentication

- **MultipleActiveResultSets=true**: Allow multiple active result sets

- **Encrypt=True**: Enable encryption (required for newer SQL Server versions)

- **TrustServerCertificate=True**: Trust the server certificate (for development)

## Troubleshooting

### Error: "Cannot open database"
- Make sure database `ToysStoreDb` exists
- Run `Scripts/ToysStoreDb_Complete.sql` to create database and tables

### Error: "Login failed"
- Check Windows Authentication is enabled
- Verify you have permission to access SQL Server
- Try using SQL Authentication instead

### Error: "Invalid column name"
- Run `Scripts/ToysStoreDb_Complete.sql` to add missing columns
- The script will automatically add missing columns if tables already exist

## Testing Connection

1. Open SQL Server Management Studio (SSMS)
2. Connect to your server (PC)
3. Verify database `ToysStoreDb` exists
4. Run the application and check if connection works

