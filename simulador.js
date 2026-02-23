// Simularemos ser la aplicación haciendo el registro
async function probarApp() {
    console.log("1. Creando usuario de prueba...");
    const resUser = await fetch('http://localhost:3000/api/usuarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            nombre: "Juan Perez",
            email: "juan@ejemplo.com",
            password: "clave_encriptada_falsa",
            id_rol: 1
        })
    });
    const usuario = await resUser.json();
    console.log(usuario);

    console.log("\n2. Registrando un pago por un trabajo de Diseño Gráfico (Ej: $550)...");
    const resIngreso = await fetch('http://localhost:3000/api/ingresos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id_usuario: usuario.id_usuario,
            monto: 550.00,
            fuente: "Pago de Branding Mundo Logístico",
            fecha: "2026-02-23"
        })
    });
    const resultadoIngreso = await resIngreso.json();
    console.log(resultadoIngreso);
}

probarApp();