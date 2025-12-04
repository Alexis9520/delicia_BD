-- ==========================================================
-- SCRIPT BASE DE DATOS FINAL - PANADERÍA DELICIA
-- Arquitectura SOA - Estructura Generada por JPA/Hibernate
-- Incluye: Tablas Reales + Historia de Datos (2025)
-- ==========================================================

CREATE DATABASE IF NOT EXISTS delicia_bd;
USE delicia_bd;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------
-- 1. ESTRUCTURA DE TABLAS (TU CÓDIGO REAL)
-- ----------------------------------------------------------

DROP TABLE IF EXISTS `order_item`;
DROP TABLE IF EXISTS `comprobante`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `usuarios`;
DROP TABLE IF EXISTS `inventario_movimientos`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `lotes`;

create table lotes
(
    id          bigint auto_increment primary key,
    codigo      varchar(255) null,
    creado_por  varchar(255) null,
    created_at  datetime(6)  null,
    descripcion varchar(255) null,
    created_by  varchar(255) null,
    constraint idx_lote_codigo unique (codigo)
);

create table products
(
    id          bigint auto_increment primary key,
    available   bit          not null,
    category    varchar(255) null,
    description varchar(255) null,
    image       varchar(255) null,
    name        varchar(255) null,
    price       double       not null,
    stock       int          not null
);

create table inventario_movimientos
(
    id                 bigint auto_increment primary key,
    cantidad           int                                             not null,
    created_at         datetime(6)                                     null,
    motivo             enum ('AJUSTE', 'MERMA', 'PRODUCCION', 'VENTA') null,
    producto_id        bigint                                          null,
    referencia_id      bigint                                          null,
    tipo               enum ('ENTRADA', 'SALIDA')                      null,
    referencia         varchar(255)                                    null,
    referencia_tipo    varchar(255)                                    null,
    referencia_lote_id bigint                                          null,
    lote_id            bigint                                          null,
    constraint FK_lote_inv foreign key (lote_id) references lotes (id),
    constraint FK_prod_inv foreign key (producto_id) references products (id)
);

create table usuarios
(
    id        bigint auto_increment primary key,
    email     varchar(255) not null,
    nombre    varchar(255) null,
    password  varchar(255) not null,
    name      varchar(255) null,
    phone     varchar(255) null,
    role      varchar(255) null,
    documento varchar(255) null,
    constraint UK_email unique (email)
);

create table orders
(
    id                bigint auto_increment primary key,
    city              varchar(255) null,
    country           varchar(255) null,
    phone             varchar(255) null,
    postal_code       varchar(255) null,
    street            varchar(255) null,
    payment_intent_id varchar(255) null,
    payment_method    varchar(255) null,
    total             double       not null,
    usuario_id        bigint       null,
    created_at        datetime(6)  null,
    status            varchar(255) null,
    canal             varchar(255) null,
    documento_cliente varchar(255) null,
    nombre_cliente    varchar(255) null,
    constraint FK_user_order foreign key (usuario_id) references usuarios (id)
);

create table comprobante
(
    id                bigint auto_increment primary key,
    cliente_documento varchar(255) null,
    cliente_nombre    varchar(255) null,
    fecha             datetime(6)  null,
    mensaje           varchar(255) null,
    numero            varchar(255) null,
    pdf_url           varchar(255) null,
    serie             varchar(255) null,
    tipo              varchar(255) null,
    total             double       null,
    xml               text         null,
    order_id          bigint       null,
    constraint FK_order_comp foreign key (order_id) references orders (id)
);

create table order_item
(
    id         bigint auto_increment primary key,
    quantity   int    not null,
    order_id   bigint null,
    product_id bigint null,
    constraint FK_prod_item foreign key (product_id) references products (id),
    constraint FK_order_item foreign key (order_id) references orders (id)
);

-- ----------------------------------------------------------
-- 2. POBLADO DE DATOS (DATA SEEDING)
-- ----------------------------------------------------------

-- Usuarios Base
INSERT INTO usuarios (email, password, role, nombre, phone) VALUES 
('admin@delicia.com', '$2a$10$wcy/y...', 'ADMIN', 'Administrador Principal', '999888777'),
('cliente@gmail.com', '$2a$10$wcy/y...', 'CLIENTE', 'Juan Perez', '999111222');

-- Productos Base
INSERT INTO products (name, price, stock, available, category, description) VALUES 
('Croissant de Mantequilla', 4.50, 100, 1, 'Bollería', 'Clásico francés'),
('Pan de Masa Madre', 6.00, 50, 1, 'Panes', 'Fermentación natural'),
('Cheesecake de Fresa', 12.00, 30, 1, 'Pastelería', 'Con fresas frescas'),
('Pan Ciabatta', 1.50, 200, 1, 'Panes', 'Corteza crujiente'),
('Empanada de Carne', 3.50, 80, 1, 'Salados', 'Relleno de lomo');

-- ----------------------------------------------------------
-- 3. GENERACIÓN DE HISTORIA (SIMULACIÓN 2025)
-- ----------------------------------------------------------

DROP PROCEDURE IF EXISTS GenerarHistoria;
DELIMITER //
CREATE PROCEDURE GenerarHistoria(IN mes INT, IN anio INT, IN num_ventas INT, IN tendencia_digital DECIMAL(5,2))
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE metodo VARCHAR(50);
    DECLARE canal_venta VARCHAR(50);
    DECLARE prod_id INT;
    DECLARE qty INT;
    DECLARE precio DECIMAL(10,2);
    DECLARE order_id BIGINT;
    DECLARE fecha DATETIME;
    
    WHILE i < num_ventas DO
        -- Lógica de canal
        IF (RAND() < tendencia_digital) THEN
            SET metodo = 'stripe';
            SET canal_venta = 'online';
        ELSE
            SET metodo = 'efectivo';
            SET canal_venta = 'mostrador';
        END IF;

        SET fecha = CONCAT(anio, '-', mes, '-', FLOOR(1 + (RAND() * 28)), ' ', FLOOR(9 + (RAND() * 11)), ':', FLOOR(RAND() * 59));
        
        -- Insertar Orden
        INSERT INTO orders (total, status, created_at, payment_method, canal, usuario_id, city, country, nombre_cliente) 
        VALUES (0, 'entregado', fecha, metodo, canal_venta, 1, 'Huancayo', 'Peru', 'Cliente Generico');
        SET order_id = LAST_INSERT_ID();
        
        -- Insertar Item
        SET prod_id = FLOOR(1 + (RAND() * 5));
        SET qty = FLOOR(1 + (RAND() * 3));
        SELECT price INTO precio FROM products WHERE id = prod_id;
        
        INSERT INTO order_item (order_id, product_id, quantity) VALUES (order_id, prod_id, qty);
        UPDATE orders SET total = total + (precio * qty) WHERE id = order_id;
        
        -- Insertar Movimiento (Usando tus ENUMs)
        INSERT INTO inventario_movimientos (cantidad, created_at, motivo, tipo, producto_id, referencia)
        VALUES (qty, fecha, 'VENTA', 'SALIDA', prod_id, CONCAT('ORDER-', order_id));

        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Ejecutar simulación trimestral
CALL GenerarHistoria(1, 2025, 20, 0.2); -- Enero (Poco digital)
CALL GenerarHistoria(4, 2025, 40, 0.5); -- Abril (Crecimiento)
CALL GenerarHistoria(7, 2025, 60, 0.7); -- Julio (Fiestas)
CALL GenerarHistoria(12, 2025, 90, 0.9); -- Diciembre (Éxito digital)

DROP PROCEDURE GenerarHistoria;
SET FOREIGN_KEY_CHECKS = 1;