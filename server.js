const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json()); // Permite al servidor entender datos en formato JSON

// Función para conectar a la base de datos
async function conectarBD() {
    return await mysql.createConnection({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_ROOT_USER,
        password: process.env.DB_ROOT_PASSWORD,
        database: process.env.DB_NAME // Ahora sí especificamos a qué base entrar
    });
}

// 1. Ruta rápida para crear un usuario de prueba (Necesitamos uno antes de registrar ingresos)
app.post('/api/usuarios', async (req, res) => {
    const { nombre, email, password, id_rol } = req.body;
    try {
        const conexion = await conectarBD();
        const [resultado] = await conexion.query(
            `INSERT INTO Usuarios (nombre, email, password, id_rol) VALUES (?, ?, ?, ?)`,
            [nombre, email, password, id_rol]
        );
        await conexion.end();
        res.status(201).json({ mensaje: "Usuario creado", id_usuario: resultado.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 2. LA RUTA MÁGICA: Registrar Ingreso y apartar Diezmo automáticamente
app.post('/api/ingresos', async (req, res) => {
    const { id_usuario, monto, fuente, fecha } = req.body;
    let conexion;

    try {
        conexion = await conectarBD();
        
        // INICIAMOS TRANSACCIÓN: O se guardan ingreso y diezmo juntos, o ninguno.
        await conexion.beginTransaction();

        // A) Guardar el ingreso general
        const [resIngreso] = await conexion.query(
            `INSERT INTO Ingresos (id_usuario, monto, fuente, fecha) VALUES (?, ?, ?, ?)`,
            [id_usuario, monto, fuente, fecha]
        );
        const id_ingreso_nuevo = resIngreso.insertId;

        // B) Calcular el 10% exacto para el fondo ministerial
        const monto_diezmo = (monto * 0.10).toFixed(2);

        // C) Guardar el diezmo automatizado
        await conexion.query(
            `INSERT INTO Diezmos (id_ingreso, monto_calculado) VALUES (?, ?)`,
            [id_ingreso_nuevo, monto_diezmo]
        );

        // CONFIRMAMOS TRANSACCIÓN (Guardar permanentemente)
        await conexion.commit();

        res.status(201).json({
            mensaje: "¡Éxito! Ingreso registrado y 10% de diezmo apartado automáticamente.",
            detalle: {
                ingreso_registrado: monto,
                diezmo_calculado: monto_diezmo,
                estado_diezmo: 'Por Entregar'
            }
        });

    } catch (error) {
        // SI ALGO FALLA, DESHACEMOS TODO PARA EVITAR DATOS INCOMPLETOS
        if (conexion) await conexion.rollback();
        console.error("Error al procesar el ingreso:", error);
        res.status(500).json({ error: "Fallo en el servidor al registrar el ingreso." });
    } finally {
        if (conexion) await conexion.end();
    }
});

// 3. Ruta para crear el "Presupuesto Mensual" del Mercado (El Maestro)
app.post('/api/mercado/presupuesto', async (req, res) => {
    const { id_usuario, mes, anio, monto_planificado } = req.body;
    try {
        const conexion = await conectarBD();
        const [resultado] = await conexion.query(
            `INSERT INTO Presupuestos_Mercado (id_usuario, mes, anio, monto_planificado) VALUES (?, ?, ?, ?)`,
            [id_usuario, mes, anio, monto_planificado]
        );
        await conexion.end();
        res.status(201).json({ mensaje: "Presupuesto creado", id_presupuesto: resultado.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 4. LA RUTA INTELIGENTE: Recibir la lista de compras y descontar del presupuesto
app.post('/api/mercado/compras', async (req, res) => {
    const { id_presupuesto, articulos } = req.body;
    let conexion;

    try {
        conexion = await conectarBD();
        
        // Iniciamos la transacción: O se guarda toda la lista y se actualiza el total, o no se guarda nada.
        await conexion.beginTransaction();

        let totalCompra = 0;

        // Recorremos la lista de artículos que envía el teléfono
        for (const articulo of articulos) {
            const { nombre_producto, cantidad, precio_unitario } = articulo;
            
            // Sumamos al total de esta factura
            totalCompra += (cantidad * precio_unitario);

            // Guardamos el producto individual
            await conexion.query(
                `INSERT INTO Articulos_Mercado (id_presupuesto, nombre_producto, cantidad, precio_unitario, comprado) 
                 VALUES (?, ?, ?, ?, TRUE)`,
                [id_presupuesto, nombre_producto, cantidad, precio_unitario]
            );
        }

        // Magia financiera: Actualizamos el presupuesto maestro sumando el total de esta compra
        await conexion.query(
            `UPDATE Presupuestos_Mercado 
             SET monto_ejecutado = monto_ejecutado + ? 
             WHERE id_presupuesto = ?`,
            [totalCompra, id_presupuesto]
        );

        // Confirmamos y guardamos todo permanentemente
        await conexion.commit();

        res.status(201).json({
            mensaje: "¡Factura de mercado procesada con éxito!",
            articulos_registrados: articulos.length,
            total_gastado_hoy: totalCompra.toFixed(2)
        });

    } catch (error) {
        if (conexion) await conexion.rollback();
        console.error("Error al procesar el mercado:", error);
        res.status(500).json({ error: "Fallo en el servidor al registrar la compra." });
    } finally {
        if (conexion) await conexion.end();
    }
});

// 5. RUTA DE LECTURA: Obtener el resumen para el Dashboard
app.get('/api/dashboard/:id_usuario', async (req, res) => {
    const id_usuario = req.params.id_usuario;
    const mesActual = new Date().getMonth() + 1; // Meses en JS van de 0 a 11
    const anioActual = new Date().getFullYear();
    let conexion;

    try {
        conexion = await conectarBD();

        // A) Obtener total de Ingresos
        const [resIngresos] = await conexion.query(
            `SELECT SUM(monto) as total_ingresos FROM Ingresos WHERE id_usuario = ?`,
            [id_usuario]
        );

        // B) Obtener total de Diezmos apartados y "Por Entregar"
        const [resDiezmos] = await conexion.query(
            `SELECT SUM(d.monto_calculado) as diezmos_pendientes 
             FROM Diezmos d 
             JOIN Ingresos i ON d.id_ingreso = i.id_ingreso 
             WHERE i.id_usuario = ? AND d.estado = 'Por Entregar'`,
            [id_usuario]
        );

        // C) Obtener estado del Presupuesto de Mercado de este mes
        const [resMercado] = await conexion.query(
            `SELECT monto_planificado, monto_ejecutado 
             FROM Presupuestos_Mercado 
             WHERE id_usuario = ? AND mes = ? AND anio = ?`,
            [id_usuario, mesActual, anioActual]
        );

        // Armamos un paquete limpio con la información para que Flutter la dibuje
        const resumen = {
            ingresos_totales: resIngresos[0].total_ingresos || 0,
            fondo_ministerial_pendiente: resDiezmos[0].diezmos_pendientes || 0,
            mercado: resMercado.length > 0 ? resMercado[0] : { mensaje: "Sin presupuesto este mes" }
        };

        res.status(200).json(resumen);

    } catch (error) {
        console.error("Error al cargar el dashboard:", error);
        res.status(500).json({ error: "Fallo al obtener los datos." });
    } finally {
        if (conexion) await conexion.end();
    }
});

// Encender el servidor
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
});