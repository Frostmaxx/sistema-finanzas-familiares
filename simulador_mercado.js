async function irAlSupermercado() {
    console.log("1. Creando Presupuesto de Mercado para Febrero (Límite: $200.00)...");
    const resPresupuesto = await fetch('http://localhost:3000/api/mercado/presupuesto', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id_usuario: 1, // Usaremos el usuario que ya creamos en la prueba anterior
            mes: 2,
            anio: 2026,
            monto_planificado: 200.00
        })
    });
    const presupuesto = await resPresupuesto.json();
    console.log(presupuesto);

    console.log("\n2. Pagando en caja y enviando la lista completa al servidor...");
    
    // Esta es la estructura de datos "Maestro-Detalle" enviada en un solo bloque
    const factura = {
        id_presupuesto: presupuesto.id_presupuesto,
        articulos: [
            { nombre_producto: "Carne de Res", cantidad: 2.5, precio_unitario: 6.00 }, // $15.00
            { nombre_producto: "Arroz (Kilo)", cantidad: 4, precio_unitario: 1.20 },  // $4.80
            { nombre_producto: "Vegetales mixtos", cantidad: 1, precio_unitario: 3.50 } // $3.50
            // Total esperado: $23.30
        ]
    };

    const resCompra = await fetch('http://localhost:3000/api/mercado/compras', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(factura)
    });
    
    const resultadoCompra = await resCompra.json();
    console.log(resultadoCompra);
}

irAlSupermercado();