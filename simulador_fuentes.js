async function probarNuevaArquitectura() {
    console.log("1. Creando usuario administrador...");
    const resUser = await fetch('http://localhost:3000/api/usuarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nombre: "Asdrubal", email: "admin@app.com", password: "123", id_rol: 1 })
    });
    const usuario = await resUser.json();

    console.log("\n2. Creando una Fuente de Ingreso...");
    const resFuente = await fetch('http://localhost:3000/api/fuentes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id_usuario: usuario.id_usuario,
            nombre: "Diseño Gráfico (Freelance)",
            descripcion: "Trabajos de branding y publicidad",
            periodicidad: "Ocasional",
            es_activa: true
        })
    });
    const fuente = await resFuente.json();
    console.log(fuente);

    console.log("\n3. Registrando un pago mixto (Ej: $150 USD y 1500 Bs)...");
    const resIngreso = await fetch('http://localhost:3000/api/ingresos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id_usuario: usuario.id_usuario,
            id_fuente: fuente.id_fuente,
            monto_usd: 150.00,
            monto_bs: 1500.00,
            fecha_recepcion: "2026-02-23"
        })
    });
    const ingreso = await resIngreso.json();
    console.log(ingreso);

    console.log("\n4. Consultando el Dashboard para ver los Diezmos separados...");
    const resDashboard = await fetch(`http://localhost:3000/api/dashboard/${usuario.id_usuario}`);
    const dashboard = await resDashboard.json();
    console.log(dashboard);
}

probarNuevaArquitectura();