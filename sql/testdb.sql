CREATE DATABASE mobile_test_db;
GO

USE mobile_test_db;
GO

CREATE TABLE dbo.users (
  id INT IDENTITY(1,1) PRIMARY KEY,
  email NVARCHAR(255) NOT NULL UNIQUE,
  password_hash NVARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE dbo.categories (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name NVARCHAR(255) NOT NULL,
  description NVARCHAR(500),
  created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE dbo.products (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name NVARCHAR(255) NOT NULL,
  description NVARCHAR(500),
  price DECIMAL(10,2) NOT NULL,
  image_url NVARCHAR(255),
  category_id INT NOT NULL,
  created_at DATETIME DEFAULT GETDATE()
);

ALTER TABLE dbo.products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id)
REFERENCES dbo.categories(id);