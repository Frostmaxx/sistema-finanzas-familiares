const mysql = require('mysql2/promise');
require('dotenv').config();

// Agrega esto temporalmente para depurar:
console.log("Usuario que intenta entrar:", process.env.DB_ROOT_USER);
console.log("Contraseña que intenta usar:", process.env.DB_ROOT_PASSWORD);

async function inicializarBaseDeDatos() {
    try {
        console.log("1. Conectando al servidor MySQL...");
        // Nos conectamos al servidor, SIN especificar una base de datos todavía
        const conexion = await mysql.createConnection({
            host: process.env.DB_HOST,
            port: process.env.DB_PORT,
            user: process.env.DB_ROOT_USER,
            password: process.env.DB_ROOT_PASSWORD
        });

        console.log("2. Creando la base de datos (si no existe)...");
        const nombreBD = process.env.DB_NAME;
        await conexion.query(`CREATE DATABASE IF NOT EXISTS \`${nombreBD}\`;`);
        
        console.log(`3. Seleccionando la base de datos '${nombreBD}'...`);
        await conexion.query(`USE \`${nombreBD}\`;`);

        console.log("4. Creando tablas...");

        // Tabla Roles
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Roles (
                id_rol INT AUTO_INCREMENT PRIMARY KEY,
                nombre_rol VARCHAR(50) NOT NULL
            );
        `);

        // Insertar roles por defecto (Ignora si ya existen usando IGNORE)
        await conexion.query(`
            INSERT IGNORE INTO Roles (id_rol, nombre_rol) VALUES 
            (1, 'Administrador Familiar'), 
            (2, 'Miembro Familia'), 
            (3, 'Administrador Ministerial');
        `);

        // Tabla Usuarios
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Usuarios (
                id_usuario INT AUTO_INCREMENT PRIMARY KEY,
                nombre VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                id_rol INT,
                fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
            );
        `);

        // Tabla Ingresos
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Ingresos (
                id_ingreso INT AUTO_INCREMENT PRIMARY KEY,
                id_usuario INT,
                monto DECIMAL(10,2) NOT NULL,
                fuente VARCHAR(150) NOT NULL,
                fecha DATE NOT NULL,
                FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
            );
        `);

        // Tabla Diezmos automatizados
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Diezmos (
                id_diezmo INT AUTO_INCREMENT PRIMARY KEY,
                id_ingreso INT UNIQUE,
                monto_calculado DECIMAL(10,2) NOT NULL,
                estado VARCHAR(20) DEFAULT 'Por Entregar',
                fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (id_ingreso) REFERENCES Ingresos(id_ingreso) ON DELETE CASCADE
            );
        `);

console.log("5. Creando tablas de Gastos Fijos y Mercado...");

        // Tabla Gastos Fijos (Para Servicios Básicos, Suscripciones, Seguros y Apoyo Familiar)
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Gastos_Fijos (
                id_gasto INT AUTO_INCREMENT PRIMARY KEY,
                id_usuario INT,
                categoria VARCHAR(50) NOT NULL, -- 'Servicio Básico', 'Suscripción', 'Seguro', 'Apoyo Familiar'
                descripcion VARCHAR(150) NOT NULL, -- Ej: 'Electricidad', 'Netflix', 'Remesa a Mamá'
                monto_planificado DECIMAL(10,2) NOT NULL,
                monto_pagado DECIMAL(10,2) DEFAULT 0.00,
                fecha_vencimiento DATE,
                estado VARCHAR(20) DEFAULT 'Pendiente', -- 'Pendiente' o 'Pagado'
                FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
            );
        `);

        // Tabla Presupuesto Mercado (El "Maestro" que guarda el límite mensual)
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Presupuestos_Mercado (
                id_presupuesto INT AUTO_INCREMENT PRIMARY KEY,
                id_usuario INT,
                mes INT NOT NULL,
                anio INT NOT NULL,
                monto_planificado DECIMAL(10,2) NOT NULL,
                monto_ejecutado DECIMAL(10,2) DEFAULT 0.00, -- Lo que realmente se ha gastado
                fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
            );
        `);

        // Tabla Artículos Mercado (El "Detalle": la lista de compras de ese mes)
        await conexion.query(`
            CREATE TABLE IF NOT EXISTS Articulos_Mercado (
                id_articulo INT AUTO_INCREMENT PRIMARY KEY,
                id_presupuesto INT,
                nombre_producto VARCHAR(100) NOT NULL,
                cantidad DECIMAL(10,2) DEFAULT 1.00,
                precio_unitario DECIMAL(10,2) DEFAULT 0.00,
                -- MySQL calculará el subtotal automáticamente (Cantidad x Precio):
                subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED, 
                comprado BOOLEAN DEFAULT FALSE, -- Cambia a TRUE cuando lo echas al carrito
                FOREIGN KEY (id_presupuesto) REFERENCES Presupuestos_Mercado(id_presupuesto) ON DELETE CASCADE
            );
        `);

        console.log("¡Éxito! Base de datos y tablas principales creadas correctamente.");
        
        // Cerramos la conexión
        await conexion.end();

    } catch (error) {
        console.error("Error al configurar la base de datos:", error);
    }
}

// Ejecutamos la función
inicializarBaseDeDatos();