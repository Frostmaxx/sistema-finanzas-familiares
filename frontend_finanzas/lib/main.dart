import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// =====================================================================
// 1. PUNTO DE ENTRADA Y CONEXIÓN DEL PROVIDER
// =====================================================================
void main() {
  runApp(
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Finanzas Dashboard',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const MainDashboardLayout(),
    );
  }
}

// =====================================================================
// 2. MOTOR DE TEMAS
// =====================================================================
enum AppPalette { azul, verde, gris }

class ThemeProvider extends ChangeNotifier {
  AppPalette _currentPalette = AppPalette.azul;

  AppPalette get currentPalette => _currentPalette;

  void changePalette(AppPalette newPalette) {
    if (_currentPalette != newPalette) {
      _currentPalette = newPalette;
      notifyListeners();
    }
  }

  final Color contrastOrange = const Color(0xFFFF8C00);
  final Color contrastHoney = const Color(0xFFFFC30B);
  final Color backgroundLight = const Color(0xFFF4F7F6);

  ThemeData get themeData {
    Color primaryColor;

    switch (_currentPalette) {
      case AppPalette.verde:
        primaryColor = const Color(0xFF1A4331);
        break;
      case AppPalette.gris:
        primaryColor = const Color(0xFF4A4A4A);
        break;
      case AppPalette.azul:
      default:
        primaryColor = const Color(0xFF2C3E50);
        break;
    }

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: contrastOrange,
        tertiary: contrastHoney,
        surface: backgroundLight,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: contrastOrange,
      ),
    );
  }
}

// =====================================================================
// 3. ESTRUCTURA RESPONSIVA (Main Layout)
// =====================================================================
class MainDashboardLayout extends StatelessWidget {
  const MainDashboardLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 900 ? const LeftSidebar() : null,
      endDrawer: MediaQuery.of(context).size.width < 1200 ? const RightSidebar() : null,
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1200) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: LeftSidebar()),
                Expanded(flex: 6, child: CentralBody()),
                Expanded(flex: 2, child: RightSidebar()),
              ],
            );
          } else if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: LeftSidebar()),
                Expanded(flex: 8, child: CentralBody()),
              ],
            );
          } else {
            return const CentralBody();
          }
        },
      ),
    );
  }
}

// =====================================================================
// 4. CUERPO CENTRAL Y PESTAÑAS
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (MediaQuery.of(context).size.width < 900)
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                
                // --- INICIO DE LA MODIFICACIÓN DE PESTAÑAS ---
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    // 1. Hacemos que el indicador ocupe todo el espacio de la pestaña
                    indicatorSize: TabBarIndicatorSize.tab,
                    // 2. Quitamos la línea gris que Flutter pone por defecto debajo de las pestañas
                    dividerColor: Colors.transparent, 
                    // 3. Forzamos los colores de los textos
                    labelColor: Colors.white, // <--- CAMBIO CLAVE: Texto blanco para que resalte
                    unselectedLabelColor: Colors.grey,
                    // 4. Fondo Sólido sin transparencia
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor, // <--- SIN el .withOpacity()
                      borderRadius: BorderRadius.circular(30),
                    ),
                    tabs: const [
                      // Añadimos un poco de padding interno para que la "píldora" respire mejor
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Finanzas Personales"),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Finanzas Familiares"),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Finanzas Ministeriales"),
                        ),
                      ),
                    ],
                  ),
                ),
                // --- FIN DE LA MODIFICACIÓN DE PESTAÑAS ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.palette),
                      tooltip: "Cambiar Tema",
                      onPressed: () {
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
// 5. SIDEBAR IZQUIERDO (Navegación Principal)
// =====================================================================
class LeftSidebar extends StatelessWidget {
  const LeftSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Usamos fondo blanco puro para que contraste suavemente con el matiz medio del fondo general
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. LOGO Y NOMBRE DE LA APP
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.primaryColor,
                radius: 18,
                child: const Icon(Icons.bubble_chart, color: Colors.white, size: 20), // Icono circular
              ),
              const SizedBox(width: 12),
              Text(
                "Sphix", // Puedes cambiarlo por el nombre de tu app
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 50),

          // 2. LISTA DE NAVEGACIÓN
          // En un escenario real, 'isActive' cambiaría dinámicamente según la ruta actual
          _buildNavItem(context, "Dashboard", Icons.dashboard, isActive: true),
          _buildNavItem(context, "Ingresos", Icons.arrow_downward, isActive: false),
          _buildNavItem(context, "Gastos", Icons.arrow_upward, isActive: false),
          _buildNavItem(context, "Deudas y Créditos", Icons.credit_card, isActive: false),
          _buildNavItem(context, "Ahorros", Icons.savings, isActive: false),
          _buildNavItem(context, "Metas Financieras", Icons.flag, isActive: false),

          // Empuja el siguiente contenido hacia el fondo de la pantalla
          const Spacer(),

          // 3. OPCIONES INFERIORES (Opcional, muy común en dashboards)
          _buildNavItem(context, "Configuración", Icons.settings, isActive: false),
          _buildNavItem(context, "Cerrar Sesión", Icons.logout, isActive: false),
        ],
      ),
    );
  }

  // Método auxiliar para construir cada botón del menú
  Widget _buildNavItem(BuildContext context, String title, IconData icon, {required bool isActive}) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Separación entre botones
      decoration: BoxDecoration(
        // Si está activo, usa el color principal. Si no, es transparente.
        color: isActive ? theme.primaryColor : Colors.transparent,
        // Bordes redondeados consistentes con tu Clean UI
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Aquí iría tu lógica de navegación (ej. Navigator.pushNamed...)
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  // Contraste: Icono blanco si está activo, gris si no
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      // Texto blanco y en negrita si está activo, gris regular si no
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PANEL DERECHO (Mis Cuentas, Ingresos, Gráfico de Dona)
// =====================================================================
class RightSidebar extends StatelessWidget {
  const RightSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      // Le damos un fondo blanco puro para separarlo del cuerpo central
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SECCIÓN: MIS CUENTAS (Avatares horizontales)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mis cuentas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAccountAvatar("Banesco", "\$ 1.2k", Icons.account_balance, theme.primaryColor),
                  const SizedBox(width: 16),
                  _buildAccountAvatar("Zelle", "\$ 850", Icons.attach_money, colorScheme.secondary),
                  const SizedBox(width: 16),
                  _buildAccountAvatar("Mercantil", "\$ 4.3k", Icons.account_balance_wallet, colorScheme.tertiary),
                  const SizedBox(width: 16),
                  // Botón para agregar nueva cuenta
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        child: Icon(Icons.add, color: theme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      const Text("Agregar", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. SECCIÓN: INGRESOS (ListView de registros)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ingresos Recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            // ListView.builder para la lista de ingresos
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Mostramos 3 registros de ejemplo
              itemBuilder: (context, index) {
                // Datos simulados
                final descripciones = ["Venta de Diseño", "Asesoría Logística", "Ofrenda / Donación"];
                final montos = ["+\$ 450.00", "+\$ 320.00", "+\$ 100.00"];
                final fechas = ["Hoy, 10:30 AM", "Ayer, 04:15 PM", "12 Ago, 09:00 AM"];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(descripciones[index], style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 14)),
                            Text(fechas[index], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(montos[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // 3. SECCIÓN: GRÁFICO DE INGRESOS (Dona / PieChart)
            Text("Distribución de Ingresos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200, // Altura fija para el gráfico
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4, // Espacio en blanco entre las rebanadas
                      centerSpaceRadius: 60, // Esto convierte el PieChart en una Dona
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: theme.primaryColor,
                          value: 55,
                          title: '', // Lo dejamos en blanco para un look más "Clean"
                          radius: 25,
                        ),
                        PieChartSectionData(
                          color: colorScheme.secondary,
                          value: 30,
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          color: colorScheme.tertiary,
                          value: 15,
                          title: '',
                          radius: 25,
                        ),
                      ],
                    ),
                  ),
                  // Texto en el centro de la Dona
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Total", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("\$ 870", style: TextStyle(color: theme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Leyenda del gráfico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem("Servicios", theme.primaryColor),
                _buildLegendItem("Productos", colorScheme.secondary),
                _buildLegendItem("Otros", colorScheme.tertiary),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para los avatares de cuentas
  Widget _buildAccountAvatar(String name, String balance, IconData icon, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            // Puntito verde simulando que la cuenta está conectada/activa
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(balance, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // Widget auxiliar para la leyenda del gráfico
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// =====================================================================
// 6. EL GRID DEL DASHBOARD
// =====================================================================
class DashboardGrid extends StatelessWidget {
  final String contextoFinanciero;
  
  const DashboardGrid({Key? key, required this.contextoFinanciero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contextoFinanciero,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
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
          Row(
            children: [
              Expanded(
                child: CategoryCard(
                  title: "Ingresos",
                  amount: "\$ 21,550",
                  percentage: "↑ 52.5%",
                  icon: Icons.account_balance_wallet,
                  gradientColors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                  sparklineData: const [10, 20, 15, 30, 25, 40, 35, 50],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CategoryCard(
                  title: "Gastos",
                  amount: "\$ 4,320",
                  percentage: "↓ 12.5%",
                  icon: Icons.shopping_bag,
                  gradientColors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.7)],
                  sparklineData: const [50, 40, 45, 30, 35, 20, 25, 10],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Eliminé el "const" problemático de esta lista
          Row(
            children: const [
              Expanded(child: DeudasWidget()),
              SizedBox(width: 20),
              Expanded(child: AnalysisWidget()),
              SizedBox(width: 20),
              Expanded(child: SaldosWidget()),
            ],
          ),
          const SizedBox(height: 32),
          Text("Reciente", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
          const SizedBox(height: 16),
          const RecienteGridWidget(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

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
            Text(percentage, style: TextStyle(color: isPositive ? Colors.green : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

// =====================================================================
// 7. COMPONENTES VISUALES Y GRÁFICOS
// =====================================================================
class CategoryCard extends StatelessWidget {
  final String title, amount, percentage;
  final IconData icon;
  final List<Color> gradientColors;
  final List<double> sparklineData;

  const CategoryCard({
    Key? key, required this.title, required this.amount, required this.percentage,
    required this.icon, required this.gradientColors, required this.sparklineData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
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
              SizedBox(width: 80, height: 40, child: SparklineWidget(data: sparklineData, color: Colors.white))
            ],
          ),
        ],
      ),
    );
  }
}

class SparklineWidget extends StatelessWidget {
  final List<double> data;
  final Color color;
  const SparklineWidget({Key? key, required this.data, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklinePainter(data, color));
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final normalizedY = size.height - ((data[i] - minVal) / range) * size.height;
      final x = i * stepX;
      if (i == 0) {
        path.moveTo(x, normalizedY);
      } else {
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
// 8. MICRO-WIDGETS Y RECIENTES
// =====================================================================

// WIDGET EXTRAÍDO PARA EVITAR EL ERROR DE SCOPE
class MiniToggle extends StatelessWidget {
  final String active;
  final String inactive;

  const MiniToggle({Key? key, required this.active, required this.inactive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(16)),
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
}

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
                const MiniToggle(active: "Deudas", inactive: "Créditos"),
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
                  width: 50, height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(value: 0.25, strokeWidth: 6, backgroundColor: theme.scaffoldBackgroundColor, color: theme.primaryColor),
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
                  _buildBar(40, theme.colorScheme.secondary),
                  _buildBar(60, theme.primaryColor),
                  _buildBar(35, theme.colorScheme.tertiary),
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
    return Container(width: 16, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)));
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
                const MiniToggle(active: "Cuentas", inactive: "Efectivo"),
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

// =====================================================================
// SECCIÓN RECIENTE (Grid 2x2 - Estilo Líneas Gruesas / List Tile)
// =====================================================================

class RecienteGridWidget extends StatelessWidget {
  const RecienteGridWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
        
        // Cambiamos GridView.count por un GridView con delegado
        // Esto nos permite usar "mainAxisExtent" para fijar la altura
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12, // Espacio vertical entre líneas
            crossAxisSpacing: 16, // Espacio horizontal entre columnas
            mainAxisExtent: 70, // ¡LA MAGIA AQUÍ! Forzamos la altura a 70px exactos
          ),
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
  final String titulo, monto;
  final bool isIngreso;
  final IconData icono;
  
  const RecienteItemCard({Key? key, required this.titulo, required this.monto, required this.isIngreso, required this.icono}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Reducimos el padding vertical para que encaje perfecto en la "línea gruesa"
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Círculo del icono ligeramente más pequeño
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIngreso ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1), 
                shape: BoxShape.circle
              ),
              child: Icon(icono, color: isIngreso ? Colors.green : Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical perfecto
                children: [
                  Text(
                    titulo, 
                    // Letra un poco más estilizada para la línea
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 14), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isIngreso ? "Ahorro / Ingreso" : "Gasto / Pago", 
                    style: const TextStyle(color: Colors.grey, fontSize: 11)
                  ),
                ],
              ),
            ),
            Text(
              monto, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isIngreso ? Colors.green : theme.primaryColor)
            ),
          ],
        ),
      ),
    );
  }
}