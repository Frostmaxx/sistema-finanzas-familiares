const mysql = require('mysql2/promise');
require('dotenv').config();

async function inicializarBaseDeDatos() {
    try {
        console.log("1. Conectando al servidor MySQL...");
        const conexion = await mysql.createConnection({
            host: process.env.DB_HOST,
            port: process.env.DB_PORT,
            user: process.env.DB_ROOT_USER,
            password: process.env.DB_ROOT_PASSWORD
        });

        const nombreBD = process.env.DB_NAME;
        console.log(`2. Reseteando la base de datos '${nombreBD}' para la nueva arquitectura...`);
        // OJO: Esto borra los datos de prueba anteriores para crear la estructura limpia
        await conexion.query(`DROP DATABASE IF EXISTS \`${nombreBD}\`;`);
        await conexion.query(`CREATE DATABASE \`${nombreBD}\`;`);
        await conexion.query(`USE \`${nombreBD}\`;`);

        console.log("3. Creando tablas principales e insertando roles...");

        // Roles y Usuarios
        await conexion.query(`CREATE TABLE Roles (id_rol INT AUTO_INCREMENT PRIMARY KEY, nombre_rol VARCHAR(50) NOT NULL);`);
        await conexion.query(`INSERT INTO Roles (id_rol, nombre_rol) VALUES (1, 'Administrador Familiar'), (2, 'Miembro Familia'), (3, 'Administrador Ministerial');`);
        await conexion.query(`
            CREATE TABLE Usuarios (
                id_usuario INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL, password VARCHAR(255) NOT NULL,
                id_rol INT, fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
            );
        `);

        console.log("4. Creando estructura de Fuentes de Ingreso y bimonetariedad...");

        // NUEVA TABLA: Fuentes de Ingreso
        await conexion.query(`
            CREATE TABLE Fuentes_Ingreso (
                id_fuente INT AUTO_INCREMENT PRIMARY KEY,
                id_usuario INT,
                nombre VARCHAR(100) NOT NULL,
                descripcion VARCHAR(255),
                periodicidad VARCHAR(50) NOT NULL, -- 'Diario', 'Semanal', 'Mensual', 'Trimestral', 'Semestral', 'Anual', 'Ocasional', 'Unico'
                es_activa BOOLEAN DEFAULT TRUE, -- TRUE (1) para Activa, FALSE (0) para Pasiva
                fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
            );
        `);

        // TABLA INGRESOS ACTUALIZADA (Ahora vinculada a la fuente y con Bs/USD)
        await conexion.query(`
            CREATE TABLE Ingresos (
                id_ingreso INT AUTO_INCREMENT PRIMARY KEY,
                id_usuario INT,
                id_fuente INT,
                monto_usd DECIMAL(12,2) DEFAULT 0.00,
                monto_bs DECIMAL(15,2) DEFAULT 0.00,
                fecha_recepcion DATE NOT NULL,
                FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
                FOREIGN KEY (id_fuente) REFERENCES Fuentes_Ingreso(id_fuente)
            );
        `);

        // TABLA DIEZMOS ACTUALIZADA (Calcula ambas monedas)
        await conexion.query(`
            CREATE TABLE Diezmos (
                id_diezmo INT AUTO_INCREMENT PRIMARY KEY,
                id_ingreso INT UNIQUE,
                diezmo_usd DECIMAL(12,2) DEFAULT 0.00,
                diezmo_bs DECIMAL(15,2) DEFAULT 0.00,
                estado VARCHAR(20) DEFAULT 'Por Entregar',
                FOREIGN KEY (id_ingreso) REFERENCES Ingresos(id_ingreso) ON DELETE CASCADE
            );
        `);

        // Tablas del Mercado (Igual que antes)
        await conexion.query(`CREATE TABLE Gastos_Fijos (id_gasto INT AUTO_INCREMENT PRIMARY KEY, id_usuario INT, categoria VARCHAR(50), descripcion VARCHAR(150), monto_planificado DECIMAL(10,2), monto_pagado DECIMAL(10,2) DEFAULT 0.00, fecha_vencimiento DATE, estado VARCHAR(20) DEFAULT 'Pendiente', FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario));`);
        await conexion.query(`CREATE TABLE Presupuestos_Mercado (id_presupuesto INT AUTO_INCREMENT PRIMARY KEY, id_usuario INT, mes INT NOT NULL, anio INT NOT NULL, monto_planificado DECIMAL(10,2) NOT NULL, monto_ejecutado DECIMAL(10,2) DEFAULT 0.00, FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario));`);
        await conexion.query(`CREATE TABLE Articulos_Mercado (id_articulo INT AUTO_INCREMENT PRIMARY KEY, id_presupuesto INT, nombre_producto VARCHAR(100) NOT NULL, cantidad DECIMAL(10,2) DEFAULT 1.00, precio_unitario DECIMAL(10,2) DEFAULT 0.00, subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED, comprado BOOLEAN DEFAULT FALSE, FOREIGN KEY (id_presupuesto) REFERENCES Presupuestos_Mercado(id_presupuesto) ON DELETE CASCADE);`);

        console.log("✅ ¡Éxito! Nueva arquitectura de datos construida correctamente.");
        await conexion.end();
    } catch (error) {
        console.error("❌ Error al configurar la base de datos:", error);
    }
}
inicializarBaseDeDatos();