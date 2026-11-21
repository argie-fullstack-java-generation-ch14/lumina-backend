CREATE DATABASE IF NOT EXISTS lumina;

USE lumina;

CREATE TABLE IF NOT EXISTS `role` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80),
  description VARCHAR(255),
  created_at DATETIME,
  updated_at DATETIME
);

CREATE TABLE IF NOT EXISTS `app_user` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(150),
  password_hash VARCHAR(255),
  role_id BIGINT,
  created_at DATETIME,
  updated_at DATETIME,
  FOREIGN KEY (role_id) REFERENCES `role` (id)
);

CREATE TABLE IF NOT EXISTS `product` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120),
  slug VARCHAR(140),
  image_url VARCHAR(500),
  category VARCHAR(80),
  scent VARCHAR(120),
  weight_grams INT,
  color VARCHAR(120),
  description TEXT,
  price DECIMAL(12, 2),
  stock INT,
  available BOOLEAN,
  created_at DATETIME,
  updated_at DATETIME
);

CREATE TABLE IF NOT EXISTS `custom_candle` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  app_user_id BIGINT,
  intention VARCHAR(80),
  scent VARCHAR(120),
  design_color VARCHAR(120),
  message VARCHAR(255),
  preview_image_url VARCHAR(500),
  price DECIMAL(12, 2),
  created_at DATETIME,
  FOREIGN KEY (app_user_id) REFERENCES `app_user` (id)
);

CREATE TABLE IF NOT EXISTS `user_order` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(30),
  app_user_id BIGINT,
  status VARCHAR(20),
  subtotal DECIMAL(12, 2),
  discount_total DECIMAL(12, 2),
  tax_total DECIMAL(12, 2),
  total DECIMAL(12, 2),
  created_at DATETIME,
  updated_at DATETIME,
  FOREIGN KEY (app_user_id) REFERENCES `app_user` (id)
);

CREATE TABLE IF NOT EXISTS `order_item` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT,
  product_id BIGINT,
  custom_candle_id BIGINT NULL,
  product_name VARCHAR(120),
  unit_price DECIMAL(12, 2),
  quantity INT,
  line_total DECIMAL(12, 2),
  FOREIGN KEY (order_id) REFERENCES `user_order` (id),
  FOREIGN KEY (product_id) REFERENCES `product` (id),
  FOREIGN KEY (custom_candle_id) REFERENCES `custom_candle` (id)
);
