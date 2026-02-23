import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// =====================================================================
// 1. PUNTO DE ENTRADA Y CONEXIÓN DEL PROVIDER
// =====================================================================
void main() {
  runApp(
    // Envolvemos la app en el Provider para inyectar el motor de temas
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Finanzas Dashboard',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData, // Aplicamos el tema dinámico
      home: const MainDashboardLayout(),
    );
  }
}

// =====================================================================
// 2. MOTOR DE TEMAS (Idealmente en /providers/theme_provider.dart)
// =====================================================================
enum AppPalette { azul, verde, gris }

class ThemeProvider extends ChangeNotifier {
  AppPalette _currentPalette = AppPalette.azul; // Azul por defecto

  AppPalette get currentPalette => _currentPalette;

  void changePalette(AppPalette newPalette) {
    if (_currentPalette != newPalette) {
      _currentPalette = newPalette;
      notifyListeners();
    }
  }

  // Colores de contraste constantes
  final Color contrastOrange = const Color(0xFFFF8C00);
  final Color contrastHoney = const Color(0xFFFFC30B);
  final Color backgroundLight = const Color(0xFFF4F7F6);

  ThemeData get themeData {
    Color primaryColor;

    switch (_currentPalette) {
      case AppPalette.verde:
        primaryColor = const Color(0xFF1A4331); // Verde jade oscuro
        break;
      case AppPalette.gris:
        primaryColor = const Color(0xFF4A4A4A); // Gris plomo
        break;
      case AppPalette.azul:
      default:
        primaryColor = const Color(0xFF2C3E50); // Azul frío
        break;
    }

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: contrastOrange,
        tertiary: contrastHoney,
        background: backgroundLight,
      ),
      // Clean UI: Estilos globales para las tarjetas
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      // Estilos globales para las pestañas
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: contrastOrange,
      ),
    );
  }
}

// =====================================================================
// 3. ESTRUCTURA RESPONSIVA (Idealmente en /screens/main_layout.dart)
// =====================================================================
class MainDashboardLayout extends StatelessWidget {
  const MainDashboardLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menús laterales colapsables para móviles
      drawer: MediaQuery.of(context).size.width < 900 ? const LeftSidebar() : null,
      endDrawer: MediaQuery.of(context).size.width < 1200 ? const RightSidebar() : null,
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1200) {
            // Layout Windows/Pantallas grandes: 3 Columnas
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: LeftSidebar()),
                Expanded(flex: 6, child: CentralBody()),
                Expanded(flex: 2, child: RightSidebar()),
              ],
            );
          } else if (constraints.maxWidth >= 900) {
            // Layout Tablets: 2 Columnas (Panel derecho oculto en EndDrawer)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: LeftSidebar()),
                Expanded(flex: 8, child: CentralBody()),
              ],
            );
          } else {
            // Layout Android/Móviles: 1 Columna (Sidebars ocultos en Drawers)
            return const CentralBody();
          }
        },
      ),
    );
  }
}

// =====================================================================
// 4. CUERPO CENTRAL Y PESTAÑAS (Idealmente en /widgets/central_body.dart)
// =====================================================================
class CentralBody extends StatelessWidget {
  const CentralBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header con Pestañas y Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Para móviles, mostramos el botón del Drawer si es necesario
                if (MediaQuery.of(context).size.width < 900)
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                const Expanded(
                  child: TabBar(
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(text: "Finanzas Personales"),
                      Tab(text: "Finanzas Familiares"),
                      Tab(text: "Finanzas Ministeriales"),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Botón temporal para probar el cambio de temas
                    IconButton(
                      icon: const Icon(Icons.palette),
                      tooltip: "Cambiar Tema",
                      onPressed: () {
                        // Cambia al siguiente tema cíclicamente
                        final current = themeProvider.currentPalette;
                        final next = current == AppPalette.azul 
                            ? AppPalette.verde 
                            : (current == AppPalette.verde ? AppPalette.gris : AppPalette.azul);
                        themeProvider.changePalette(next);
                      },
                    ),
                    IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
                    if (MediaQuery.of(context).size.width < 1200)
                      IconButton(
                        icon: const Icon(Icons.account_balance_wallet),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            // Contenido dinámico según la pestaña
            const Expanded(
              child: TabBarView(
                children: [
                  DashboardGrid(contextoFinanciero: "Finanzas Personales"),
                  DashboardGrid(contextoFinanciero: "Finanzas Familiares"),
                  DashboardGrid(contextoFinanciero: "Finanzas Ministeriales"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 5. WIDGETS PLACEHOLDERS (Para que el código compile y veas la estructura)
// =====================================================================

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text("Left Sidebar\n(Menú)", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
    );
  }
}

class RightSidebar extends StatelessWidget {
  const RightSidebar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text("Right Sidebar\n(Cuentas/Gráficos)", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
    );
  }
}

class DashboardGrid extends StatelessWidget {
  final String contextoFinanciero;
  const DashboardGrid({Key? key, required this.contextoFinanciero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Contenido de:\n$contextoFinanciero", textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
    );
  }
}

// =====================================================================
// 4.1. EL GRID DEL DASHBOARD (Reemplaza el DashboardGrid anterior)
// =====================================================================
class DashboardGrid extends StatelessWidget {
  final String contextoFinanciero;
  
  const DashboardGrid({Key? key, required this.contextoFinanciero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos los colores dinámicos de nuestro motor de temas
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Título y Estadísticas Rápidas
          Text(
            contextoFinanciero,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickStat("Total Balance", "\$ 21,550", "+ 52.5%", true, theme),
              _buildQuickStat("Gastos", "\$ 1,200", "- 5.5%", false, theme),
              _buildQuickStat("Ahorros", "\$ 5,500", "+ 12.3%", true, theme),
            ],
          ),
          
          const SizedBox(height: 32),

          // 2. Tarjetas Grandes de Categoría (Ingresos y Gastos)
          Row(
            children: [
              // Tarjeta de Ingresos (Color Principal)
              Expanded(
                child: CategoryCard(
                  title: "Ingresos",
                  amount: "\$ 21,550",
                  percentage: "↑ 52.5%",
                  icon: Icons.account_balance_wallet,
                  // Gradiente usando el color principal y un tono un poco más claro
                  gradientColors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.7),
                  ],
                  // Datos de prueba para la gráfica
                  sparklineData: const [10, 20, 15, 30, 25, 40, 35, 50],
                ),
              ),
              const SizedBox(width: 20), // Espaciado entre tarjetas
              
              // Tarjeta de Gastos (Color de Contraste - Naranja)
              Expanded(
                child: CategoryCard(
                  title: "Gastos",
                  amount: "\$ 4,320",
                  percentage: "↓ 12.5%",
                  icon: Icons.shopping_bag,
                  // Gradiente usando el color secundario (Naranja)
                  gradientColors: [
                    colorScheme.secondary,
                    colorScheme.secondary.withOpacity(0.7),
                  ],
                  sparklineData: const [50, 40, 45, 30, 35, 20, 25, 10],
                ),
              ),

              // --- INICIO DE LA INSERCIÓN DEL PINPOINT 1 ---
          const SizedBox(height: 32),

          // 3. Fila de Micro-Widgets
          Row(
            children: const [
              Expanded(child: DeudasWidget()),
              const SizedBox(width: 20),
              Expanded(child: AnalysisWidget()),
              const SizedBox(width: 20),
              Expanded(child: SaldosWidget()),
            ],
          ),

          // --- INICIO DE LA INSERCIÓN DEL PINPOINT 1 ---
          const SizedBox(height: 32),
          
          Text(
            "Reciente",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // 4. Grid 2x2 de Transacciones Recientes
          const RecienteGridWidget(),
          // --- FIN DE LA INSERCIÓN DEL PINPOINT 1 ---
        ], // <--- ESTE ES EL CORCHETE QUE CIERRA EL COLUMN PRINCIPAL DEL DASHBOARDGRID
      ),
    );
  }
         
  // Widget auxiliar para las estadísticas rápidas (texto limpio)
  Widget _buildQuickStat(String label, String value, String percentage, bool isPositive, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(
              percentage,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }
}

// =====================================================================
// 4.2. TARJETA DE CATEGORÍA CON GRADIENTE
// =====================================================================
class CategoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;
  final IconData icon;
  final List<Color> gradientColors;
  final List<double> sparklineData;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.gradientColors,
    required this.sparklineData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Aplicamos el BorderRadius general de 30px que definiste
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              const Icon(Icons.more_vert, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 30),
          
          // Valor Principal y Gráfica
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Valor", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(amount, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(percentage, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              // Aquí inyectamos nuestra mini gráfica (Sparkline)
              SizedBox(
                width: 80,
                height: 40,
                child: SparklineWidget(data: sparklineData, color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// 4.3. SPARKLINE PERSONALIZADO (Gráfica de línea sin librerías)
// =====================================================================
class SparklineWidget extends StatelessWidget {
  final List<double> data;
  final Color color;

  const SparklineWidget({Key? key, required this.data, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(data, color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      // Normalizamos el valor Y para que encaje en el alto del Canvas
      final normalizedY = size.height - ((data[i] - minVal) / range) * size.height;
      final x = i * stepX;

      if (i == 0) {
        path.moveTo(x, normalizedY);
      } else {
        // Usamos una curva cúbica suave (Bezier) para que no se vea poligonal
        final previousX = (i - 1) * stepX;
        final previousY = size.height - ((data[i - 1] - minVal) / range) * size.height;
        
        final controlPointX = previousX + (x - previousX) / 2;
        path.cubicTo(controlPointX, previousY, controlPointX, normalizedY, x, normalizedY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =====================================================================
// 5. MICRO-WIDGETS
// =====================================================================

class DeudasWidget extends StatelessWidget {
  const DeudasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Deudas", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                _buildMiniToggle(context, "Deudas", "Créditos"),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Por pagar", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("\$ 15,000", style: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Faltan \$45,000", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.25,
                        strokeWidth: 6,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        color: theme.primaryColor,
                      ),
                      Center(child: Text("25%", style: TextStyle(fontSize: 10, color: theme.primaryColor))),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisWidget extends StatelessWidget {
  const AnalysisWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Analysis", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const SizedBox(height: 24),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(40, colorScheme.secondary),
                  _buildBar(60, theme.primaryColor),
                  _buildBar(35, colorScheme.tertiary),
                  _buildBar(50, theme.primaryColor.withOpacity(0.5)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.home, size: 14, color: Colors.grey),
                Icon(Icons.directions_car, size: 14, color: Colors.grey),
                Icon(Icons.shopping_cart, size: 14, color: Colors.grey),
                Icon(Icons.fastfood, size: 14, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 16,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class SaldosWidget extends StatelessWidget {
  const SaldosWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Saldos", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                _buildMiniToggle(context, "Cuentas", "Efectivo"),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Balance Disponible", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text("\$ 15,000", style: TextStyle(color: theme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("+ \$4,041 hace 50 mins", style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

Widget _buildMiniToggle(BuildContext context, String active, String inactive) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(active, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(inactive, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ),
      ],
    ),
  );
}

// --- INICIO DE LA INSERCIÓN DEL PINPOINT 2 ---

// =====================================================================
// 6. SECCIÓN RECIENTE (Grid 2x2)
// =====================================================================

class RecienteGridWidget extends StatelessWidget {
  const RecienteGridWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nos permite saber el ancho disponible en tiempo real
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si la pantalla es menor a 600px (móvil), usamos 1 columna. Si es mayor, 2 columnas.
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true, // Vital para que funcione dentro de un SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll interno del grid
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth < 600 ? 4 : 3, // Ajusta la proporción ancho/alto
          children: const [
            RecienteItemCard(titulo: "Pago de Luz", monto: "-\$ 45.00", isIngreso: false, icono: Icons.electric_bolt),
            RecienteItemCard(titulo: "Ahorro Vehículo", monto: "+\$ 150.00", isIngreso: true, icono: Icons.directions_car),
            RecienteItemCard(titulo: "Compra Supermercado", monto: "-\$ 120.00", isIngreso: false, icono: Icons.shopping_cart),
            RecienteItemCard(titulo: "Fondo Emergencia", monto: "+\$ 200.00", isIngreso: true, icono: Icons.savings),
          ],
        );
      }
    );
  }
}

class RecienteItemCard extends StatelessWidget {
  final String titulo;
  final String monto;
  final bool isIngreso;
  final IconData icono;

  const RecienteItemCard({
    Key? key, 
    required this.titulo, 
    required this.monto, 
    required this.isIngreso, 
    required this.icono
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            // Círculo con el icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Usamos colores suaves de fondo para mantener el estilo "Clean"
                color: isIngreso ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: isIngreso ? Colors.green : Colors.redAccent, size: 24),
            ),
            const SizedBox(width: 16),
            // Textos descriptivos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titulo, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Corta el texto largo con "..."
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isIngreso ? "Ahorro / Ingreso" : "Gasto / Pago", 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                ],
              ),
            ),
            // Monto
            Text(
              monto, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                color: isIngreso ? Colors.green : theme.primaryColor
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --- FIN DE LA INSERCIÓN DEL PINPOINT 2 ---