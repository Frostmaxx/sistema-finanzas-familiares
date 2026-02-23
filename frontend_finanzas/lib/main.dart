import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatelessWidget {
  const FinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Financiera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variables para guardar los datos que vienen del servidor
  String ingresosTotales = "0.00";
  String fondoMinisterial = "0.00";
  String mercadoEjecutado = "0.00";
  String mercadoPlanificado = "0.00";
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatosDashboard();
  }

  // Función que hace la llamada GET a tu servidor Node.js
  Future<void> cargarDatosDashboard() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/dashboard/1');
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        
        setState(() {
          ingresosTotales = datos['ingresos_totales'].toString();
          fondoMinisterial = datos['fondo_ministerial_pendiente'].toString();
          
          if (datos['mercado'] != null && datos['mercado']['monto_ejecutado'] != null) {
            mercadoEjecutado = datos['mercado']['monto_ejecutado'].toString();
            mercadoPlanificado = datos['mercado']['monto_planificado'].toString();
          }
          cargando = false;
        });
      }
    } catch (e) {
      print("Error conectando al servidor: $e");
      setState(() { cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Panel Financiero', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: cargando 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _crearTarjeta('Ingresos Totales', '\$$ingresosTotales', Colors.blueGrey),
                const SizedBox(height: 16),
                _crearTarjeta('Fondo Ministerial (Diezmos)', '\$$fondoMinisterial', Colors.indigo),
                const SizedBox(height: 16),
                _crearTarjeta('Mercado (Gastado / Límite)', '\$$mercadoEjecutado / \$$mercadoPlanificado', Colors.deepOrange),
              ],
            ),
          ),
    );
  }

  Widget _crearTarjeta(String titulo, String monto, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            Text(monto, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}