const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json()); 

// Pool de conexiones reutilizable (optimizado vs conexión por request)
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_ROOT_USER,
    password: process.env.DB_ROOT_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// ==========================================
// 1. USUARIOS
// ==========================================
app.post('/api/usuarios', async (req, res) => {
    const { nombre, email, password, id_rol } = req.body;
    try {
        const [resultado] = await pool.query(
            `INSERT INTO Usuarios (nombre, email, password, id_rol) VALUES (?, ?, ?, ?)`,
            [nombre, email, password, id_rol]
        );
        res.status(201).json({ mensaje: "Usuario creado", id_usuario: resultado.insertId });
    } catch (error) {
        console.error('Error al crear usuario:', error);
        res.status(500).json({ error: "Error al crear el usuario." });
    }
});

// ==========================================
// 2. FUENTES DE INGRESO
// ==========================================
// A) Crear una nueva fuente
app.post('/api/fuentes', async (req, res) => {
    const { id_usuario, nombre, descripcion, periodicidad, es_activa } = req.body;
    try {
        const [resultado] = await pool.query(
            `INSERT INTO Fuentes_Ingreso (id_usuario, nombre, descripcion, periodicidad, es_activa) VALUES (?, ?, ?, ?, ?)`,
            [id_usuario, nombre, descripcion, periodicidad, es_activa]
        );
        res.status(201).json({ mensaje: "Fuente de ingreso creada", id_fuente: resultado.insertId });
    } catch (error) {
        console.error('Error al crear fuente de ingreso:', error);
        res.status(500).json({ error: "Error al crear la fuente de ingreso." });
    }
});

// B) Obtener la lista de fuentes (Para el menú desplegable)
app.get('/api/fuentes/:id_usuario', async (req, res) => {
    try {
        const [fuentes] = await pool.query(
            `SELECT * FROM Fuentes_Ingreso WHERE id_usuario = ?`,
            [req.params.id_usuario]
        );
        res.status(200).json(fuentes);
    } catch (error) {
        console.error('Error al obtener fuentes:', error);
        res.status(500).json({ error: "Error al obtener las fuentes de ingreso." });
    }
});

// ==========================================
// 3. INGRESOS Y DIEZMOS (Bimonetario)
// ==========================================
app.post('/api/ingresos', async (req, res) => {
    const { id_usuario, id_fuente, monto_usd, monto_bs, fecha_recepcion } = req.body;
    let conexion;

    try {
        conexion = await pool.getConnection();
        await conexion.beginTransaction();

        // Guardar el ingreso con USD y Bs
        const [resIngreso] = await conexion.query(
            `INSERT INTO Ingresos (id_usuario, id_fuente, monto_usd, monto_bs, fecha_recepcion) VALUES (?, ?, ?, ?, ?)`,
            [id_usuario, id_fuente, monto_usd || 0, monto_bs || 0, fecha_recepcion]
        );
        const id_ingreso_nuevo = resIngreso.insertId;

        // Calcular el 10% exacto para ambas monedas
        const diezmo_usd = ((monto_usd || 0) * 0.10).toFixed(2);
        const diezmo_bs = ((monto_bs || 0) * 0.10).toFixed(2);

        // Guardar el diezmo automatizado
        await conexion.query(
            `INSERT INTO Diezmos (id_ingreso, diezmo_usd, diezmo_bs) VALUES (?, ?, ?)`,
            [id_ingreso_nuevo, diezmo_usd, diezmo_bs]
        );

        await conexion.commit();
        res.status(201).json({ mensaje: "Ingreso registrado. Diezmos apartados en Bs y $." });
    } catch (error) {
        if (conexion) await conexion.rollback();
        console.error('Error al registrar ingreso:', error);
        res.status(500).json({ error: "Fallo al registrar el ingreso." });
    } finally {
        if (conexion) conexion.release();
    }
});

// ==========================================
// 4. MERCADO
// ==========================================
app.post('/api/mercado/presupuesto', async (req, res) => {
    const { id_usuario, mes, anio, monto_planificado } = req.body;
    try {
        const [resultado] = await pool.query(
            `INSERT INTO Presupuestos_Mercado (id_usuario, mes, anio, monto_planificado) VALUES (?, ?, ?, ?)`,
            [id_usuario, mes, anio, monto_planificado]
        );
        res.status(201).json({ mensaje: "Presupuesto creado", id_presupuesto: resultado.insertId });
    } catch (error) {
        console.error('Error al crear presupuesto:', error);
        res.status(500).json({ error: "Error al crear el presupuesto." });
    }
});

app.post('/api/mercado/compras', async (req, res) => {
    const { id_presupuesto, articulos } = req.body;
    let conexion;
    try {
        conexion = await pool.getConnection();
        await conexion.beginTransaction();
        let totalCompra = 0;
        for (const articulo of articulos) {
            const { nombre_producto, cantidad, precio_unitario } = articulo;
            totalCompra += (cantidad * precio_unitario);
            await conexion.query(
                `INSERT INTO Articulos_Mercado (id_presupuesto, nombre_producto, cantidad, precio_unitario, comprado) VALUES (?, ?, ?, ?, TRUE)`,
                [id_presupuesto, nombre_producto, cantidad, precio_unitario]
            );
        }
        await conexion.query(
            `UPDATE Presupuestos_Mercado SET monto_ejecutado = monto_ejecutado + ? WHERE id_presupuesto = ?`,
            [totalCompra, id_presupuesto]
        );
        await conexion.commit();
        res.status(201).json({ mensaje: "Compra procesada", total_gastado_hoy: totalCompra.toFixed(2) });
    } catch (error) {
        if (conexion) await conexion.rollback();
        console.error('Error al registrar compra:', error);
        res.status(500).json({ error: "Fallo al registrar la compra." });
    } finally {
        if (conexion) conexion.release();
    }
});

// ==========================================
// 5. DASHBOARD (Lee ambas monedas)
// ==========================================
app.get('/api/dashboard/:id_usuario', async (req, res) => {
    const id_usuario = req.params.id_usuario;
    const mesActual = new Date().getMonth() + 1; 
    const anioActual = new Date().getFullYear();

    try {
        // Obtener ingresos (USD y Bs)
        const [resIngresos] = await pool.query(
            `SELECT SUM(monto_usd) as total_usd, SUM(monto_bs) as total_bs FROM Ingresos WHERE id_usuario = ?`,
            [id_usuario]
        );

        // Obtener diezmos (USD y Bs)
        const [resDiezmos] = await pool.query(
            `SELECT SUM(d.diezmo_usd) as diezmos_usd, SUM(d.diezmo_bs) as diezmos_bs 
             FROM Diezmos d JOIN Ingresos i ON d.id_ingreso = i.id_ingreso 
             WHERE i.id_usuario = ? AND d.estado = 'Por Entregar'`,
            [id_usuario]
        );

        // Obtener mercado
        const [resMercado] = await pool.query(
            `SELECT monto_planificado, monto_ejecutado FROM Presupuestos_Mercado WHERE id_usuario = ? AND mes = ? AND anio = ?`,
            [id_usuario, mesActual, anioActual]
        );

        res.status(200).json({
            ingresos: resIngresos[0],
            diezmos: resDiezmos[0],
            mercado: resMercado.length > 0 ? resMercado[0] : null
        });

    } catch (error) {
        console.error('Error al obtener dashboard:', error);
        res.status(500).json({ error: "Fallo al obtener los datos." });
    }
});

// Encender el servidor
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
});