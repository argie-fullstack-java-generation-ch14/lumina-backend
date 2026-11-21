USE lumina;

-- Roles
INSERT INTO `role` (id, name, description, created_at, updated_at) VALUES
  (1, 'ADMIN', 'Gestiona productos, pedidos y usuarios.', '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
  (2, 'CUSTOMER', 'Compra productos y administra sus pedidos.', '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
  (3, 'STAFF', 'Apoya la gestion de pedidos.', '2026-01-01 09:00:00', '2026-01-01 09:00:00');

-- Usuarios
-- (El usuario admin se crea automáticamente por DataInitializer al arrancar la app:
--  email: admin@lumina.com, password: Admin123, hash BCrypt generado por PasswordEncoder)

-- Productos
INSERT INTO `product` (id, name, slug, image_url, category, scent, weight_grams, color, description, price, stock, available, created_at, updated_at) VALUES
  (1, 'Renacer', 'renacer', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503211/Vela_Lumina_Renacer_entre_flores_y_sombras_%D1%83%D1%87%D0%B0%D1%81%D1%82.png', 'bienestar', 'Floral', 200, 'Blanco con destellos rosa', 'Un momento para renovar tu energía.', 12000.00, 100, TRUE, '2026-01-10 09:00:00', '2026-01-10 09:00:00'),
  (2, 'Relajación', 'relajacion', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503211/Vela_Lumina_en_Serum_Beige.png', 'descanso', 'Lavanda', 200, 'Lila suave', 'Ideal para desconectarte y descansar.', 12000.00, 100, TRUE, '2026-01-11 09:00:00', '2026-01-11 09:00:00'),
  (3, 'Equilibrio', 'equilibrio', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503210/Vela_Lumina_Equilibrio_en_Lavanda.png', 'mindfulness', 'Lavanda - Manzanilla', 200, 'Verde menta pastel', 'Encuentra tu propio centro.', 12000.00, 100, TRUE, '2026-01-12 09:00:00', '2026-01-12 09:00:00'),
  (4, 'Luna Nueva', 'luna-nueva', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503210/Imagen_de_ChatGPT_12_nov_2026_10_51_00_a.m.png', 'intencion', 'Amaderado', 200, 'Plata envejecida', 'Un nuevo comienzo para ti.', 12000.00, 100, TRUE, '2026-01-13 09:00:00', '2026-01-13 09:00:00'),
  (5, 'Pausa', 'pausa', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503209/Vela_Pausa_entre_flores_y_luz.png', 'amor-propio', 'Lavanda - Manzanilla', 200, 'Verde salvia', 'Ideal para desconectarte del ruido del día y crear un ambiente relajante.', 12000.00, 100, TRUE, '2026-01-14 09:00:00', '2026-01-14 09:00:00'),
  (6, 'Conexión', 'conexion', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503210/Vela_Lumina_Conexi%C3%B3n_entre_Flores.png', 'amor-propio', 'Dulce', 200, 'Rosa empolvado', 'Conecta contigo y con tu esencia.', 12000.00, 100, TRUE, '2026-01-15 09:00:00', '2026-01-15 09:00:00'),
  (7, 'Atardecer', 'atardecer', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503209/Vela_Lumina_al_Atardecer.png', 'bienestar', 'Cítrico', 200, 'Melocotón suave', 'Disfruta la tranquilidad del momento.', 12000.00, 100, TRUE, '2026-01-16 09:00:00', '2026-01-16 09:00:00'),
  (8, 'Claridad', 'claridad', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503208/Vela_Lumina_Claridad_entre_eucaliptos.png', 'mindfulness', 'Herbal', 200, 'Verde natural', 'Crea un espacio para tus ideas.', 12000.00, 100, TRUE, '2026-01-17 09:00:00', '2026-01-17 09:00:00'),
  (9, 'Armonía', 'armonia', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503207/Vela_Lumina_Armon%C3%ADa_entre_Rosas.png', 'intencion', 'Floral', 200, 'Rosa pastel', 'Encuentra armonía en tu espacio.', 12000.00, 100, TRUE, '2026-01-18 09:00:00', '2026-01-18 09:00:00'),
  (10, 'Aura', 'aura', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503208/Vela_AURA_con_cristales_y_flores_blancas.png', 'mindfulness', 'Lavanda - Manzanilla', 200, 'Lavanda suave', 'Desconecta del ruido y regálate calma.', 12000.00, 100, TRUE, '2026-01-19 09:00:00', '2026-01-19 09:00:00'),
  (11, 'Noche de Paz', 'noche-de-paz', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503207/Vela_navide%C3%B1a_Noche_de_Paz.png', 'navidad', 'Vainilla', 200, 'Marfil cálido', 'Calma que ilumina tu hogar.', 12000.00, 100, TRUE, '2026-01-20 09:00:00', '2026-01-20 09:00:00'),
  (12, 'Pinos del Bosque', 'pinos-del-bosque', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503206/Vela_Pinos_del_Bosque_en_Navidad.png', 'navidad', 'Pino y cedro', 200, 'Verde pino', 'Un respiro de naturaleza en tu espacio.', 12000.00, 100, TRUE, '2026-01-21 09:00:00', '2026-01-21 09:00:00'),
  (13, 'Magia', 'magia', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503206/Vela_Magia_en_Navidad.png', 'navidad', 'Frutos rojos', 200, 'Rosa frambuesa', 'Pequeños momentos que se sienten grandes.', 12000.00, 100, TRUE, '2026-01-22 09:00:00', '2026-01-22 09:00:00'),
  (14, 'Canela Dorada', 'canela-dorada', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503205/Canela_dorada__tradici%C3%B3n_navide%C3%B1a.png', 'navidad', 'Canela y naranja', 200, 'Oro', 'Tradiciones que abrazan el alma.', 12000.00, 100, TRUE, '2026-01-23 09:00:00', '2026-01-23 09:00:00'),
  (15, 'Brillo', 'brillo', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503203/Vela_Lumina_Brillo_entre_dorados_festivos.png', 'navidad', 'Jazmín y ámbar', 200, 'Ámbar cálido', 'Luz para nuevos comienzos.', 12000.00, 100, TRUE, '2026-01-24 09:00:00', '2026-01-24 09:00:00'),
  (16, 'Celebración', 'celebracion', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503202/Vela_navide%C3%B1a_Lumina_Celebraci%C3%B3n.png', 'navidad', 'Naranja y canela', 200, 'Coral suave', 'Aromas que reúnen lo más importante.', 12000.00, 100, TRUE, '2026-01-25 09:00:00', '2026-01-25 09:00:00'),
  (17, 'Noche de Brujas', 'noche-de-brujas', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503203/Vela_Lumina__Noche_de_Brujas.png', 'halloween', 'Vainilla oscura, sándalo y ámbar', 200, 'Ciruela profundo', 'Un toque de misterio para iluminar tus noches.', 12000.00, 100, TRUE, '2026-01-26 09:00:00', '2026-01-26 09:00:00'),
  (18, 'Calabaza Dorada', 'calabaza-dorada', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503201/Vela_Calabaza_Dorada_de_Halloween.png', 'halloween', 'Calabaza especiada, canela y naranja', 200, 'Naranja terracota', 'Calidez y dulzura para abrazar tus momentos favoritos.', 12000.00, 100, TRUE, '2026-01-27 09:00:00', '2026-01-27 09:00:00'),
  (19, 'Hechizo de Luna', 'hechizo-de-luna', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503202/Vela_Hechizo_de_Luna_y_Lavanda.png', 'halloween', 'Lavanda, cedro y hierbas aromáticas', 200, 'Violeta místico', 'Una pausa mágica para reconectar contigo misma.', 12000.00, 100, TRUE, '2026-01-28 09:00:00', '2026-01-28 09:00:00'),
  (20, 'Rosa de Medianoche', 'rosa-de-medianoche', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503201/Vela_Rosa_de_Medianoche.png', 'halloween', 'Rosa, frutos rojos y pachulí', 200, 'Borgoña profundo', 'Un aroma misterioso para celebrar tu esencia.', 12000.00, 100, TRUE, '2026-01-29 09:00:00', '2026-01-29 09:00:00'),
  (21, 'Bosque Encantado', 'bosque-encantado', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503202/Vela_Bosque_Encantado_en_el_Bosque.png', 'halloween', 'Pino, cedro y tierra húmeda', 200, 'Esmeralda intenso', 'Un respiro de naturaleza en medio de la magia.', 12000.00, 100, TRUE, '2026-01-30 09:00:00', '2026-01-30 09:00:00'),
  (22, 'Último Suspiro', 'ultimo-suspiro', 'https://res.cloudinary.com/zj7mojiw/image/upload/v1794503203/Velo_de_%C3%9Altimo_Suspiro.png', 'halloween', 'Incienso, vainilla y madera ahumada', 200, 'Gris humo', 'Suelta lo que pesa y enciende la luz de un nuevo comienzo.', 12000.00, 100, TRUE, '2026-01-31 09:00:00', '2026-01-31 09:00:00');

-- Velas personalizadas
-- (Omitidas: dependen de app_user_id; se crearán desde la app una vez exista usuario)

-- Pedidos
-- (Omitidos: dependen de app_user_id; se crearán desde la app una vez exista usuario)

-- Items de pedido
-- (Omitidos: dependen de user_order)

