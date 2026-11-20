USE lumina;

-- Roles
INSERT INTO `role` (id, name, description, created_at, updated_at) VALUES
  (1, 'ADMIN', 'Gestiona productos, pedidos y usuarios.', '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
  (2, 'CUSTOMER', 'Compra productos y administra sus pedidos.', '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
  (3, 'STAFF', 'Apoya la gestion de pedidos.', '2026-01-01 09:00:00', '2026-01-01 09:00:00');

-- Usuarios
INSERT INTO `app_user` (id, full_name, phone, email, password_hash, role_id, created_at, updated_at) VALUES
  (1, 'Admin Lumina', '3001000001', 'admin@lumina.test', 'demo-hash-admin', 1, '2026-01-02 09:00:00', '2026-01-02 09:00:00'),
  (2, 'Laura Gomez', '3001000002', 'laura@lumina.test', 'demo-hash-laura', 2, '2026-01-03 09:00:00', '2026-01-03 09:00:00'),
  (3, 'Carlos Rojas', '3001000003', 'carlos@lumina.test', 'demo-hash-carlos', 2, '2026-01-04 09:00:00', '2026-01-04 09:00:00'),
  (4, 'Maria Torres', '3001000004', 'maria@lumina.test', 'demo-hash-maria', 2, '2026-01-05 09:00:00', '2026-01-05 09:00:00'),
  (5, 'Diego Perez', '3001000005', 'diego@lumina.test', 'demo-hash-diego', 3, '2026-01-06 09:00:00', '2026-01-06 09:00:00');

-- Productos
INSERT INTO `product` (id, name, slug, image_url, category, scent, weight_grams, color, description, price, stock, available, created_at, updated_at) VALUES
  (1, 'Renacer', 'renacer', 'https://example.com/renacer.png', 'bienestar', 'Floral', 200, 'Blanco con destellos rosa', 'Un momento para renovar tu energia.', 12000.00, 25, TRUE, '2026-01-10 09:00:00', '2026-01-10 09:00:00'),
  (2, 'Relajacion', 'relajacion', 'https://example.com/relajacion.png', 'descanso', 'Lavanda', 200, 'Lila suave', 'Ideal para desconectarte y descansar.', 12000.00, 20, TRUE, '2026-01-11 09:00:00', '2026-01-11 09:00:00'),
  (3, 'Equilibrio', 'equilibrio', 'https://example.com/equilibrio.png', 'mindfulness', 'Lavanda - Manzanilla', 200, 'Verde menta pastel', 'Encuentra tu propio centro.', 12000.00, 18, TRUE, '2026-01-12 09:00:00', '2026-01-12 09:00:00'),
  (4, 'Noche de Paz', 'noche-de-paz', 'https://example.com/noche-de-paz.png', 'navidad', 'Vainilla', 200, 'Marfil calido', 'Calma que ilumina tu hogar.', 14000.00, 15, TRUE, '2026-01-13 09:00:00', '2026-01-13 09:00:00'),
  (5, 'Noche de Brujas', 'noche-de-brujas', 'https://example.com/noche-de-brujas.png', 'halloween', 'Vainilla oscura', 200, 'Ciruela profundo', 'Un toque de misterio para tus noches.', 15000.00, 10, TRUE, '2026-01-14 09:00:00', '2026-01-14 09:00:00');

-- Velas personalizadas
INSERT INTO `custom_candle` (id, app_user_id, intention, scent, design_color, message, preview_image_url, price, created_at) VALUES
  (1, 2, 'Calma', 'Lavanda', 'Azul claro', 'Respira y vuelve a ti.', 'https://example.com/custom-1.png', 18000.00, '2026-02-05 14:00:00'),
  (2, 3, 'Amor', 'Rosas', 'Rosa pastel', 'Celebra lo que eres.', 'https://example.com/custom-2.png', 19000.00, '2026-02-06 15:00:00'),
  (3, 4, 'Abundancia', 'Canela', 'Dorado', 'Todo lo bueno encuentra su camino.', 'https://example.com/custom-3.png', 20000.00, '2026-02-07 16:00:00');

-- Pedidos
INSERT INTO `user_order` (id, order_number, app_user_id, status, subtotal, discount_total, tax_total, total, created_at, updated_at) VALUES
  (1, 'L-1001', 2, 'COMPLETED', 24000.00, 0.00, 0.00, 24000.00, '2026-02-12 09:00:00', '2026-02-13 09:00:00'),
  (2, 'L-1002', 3, 'PREPARING', 12000.00, 0.00, 0.00, 12000.00, '2026-02-12 10:00:00', '2026-02-12 12:00:00'),
  (3, 'L-1003', 4, 'CONFIRMED', 14000.00, 0.00, 0.00, 14000.00, '2026-02-12 11:00:00', '2026-02-12 11:30:00'),
  (4, 'L-1004', 5, 'CANCELLED', 15000.00, 0.00, 0.00, 15000.00, '2026-02-12 12:00:00', '2026-02-12 13:00:00'),
  (5, 'L-1005', 2, 'PENDING', 18000.00, 0.00, 0.00, 18000.00, '2026-02-12 13:00:00', '2026-02-12 13:30:00');

-- Items de pedido
INSERT INTO `order_item` (id, order_id, product_id, custom_candle_id, product_name, unit_price, quantity, line_total) VALUES
  (1, 1, 1, NULL, 'Renacer', 12000.00, 2, 24000.00),
  (2, 2, 2, NULL, 'Relajacion', 12000.00, 1, 12000.00),
  (3, 3, 4, NULL, 'Noche de Paz', 14000.00, 1, 14000.00),
  (4, 4, 5, NULL, 'Noche de Brujas', 15000.00, 1, 15000.00),
  (5, 5, NULL, 2, 'Vela personalizada de Amor', 18000.00, 1, 18000.00);

