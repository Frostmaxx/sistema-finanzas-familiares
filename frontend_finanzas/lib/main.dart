import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme_provider.dart'; // Tu motor de temas externo

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
// MAIN LAYOUT
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
// CENTRAL BODY
// =====================================================================
class CentralBody extends StatelessWidget {
  const CentralBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return DefaultTabController(
      length: 3,
      // EL CAMBIO ESTÁ AQUÍ: Envolvemos en un Builder para que las Sidebars 
      // puedan "escuchar" el cambio de pestaña en tiempo real.
      child: Builder(
        builder: (context) {
          return Padding(
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
                    Expanded(
                      child: TabBar(
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent, 
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        // Agregamos un onTap para forzar la reconstrucción de las Sidebars
                        onTap: (index) {
                          (context as Element).markNeedsBuild();
                        },
                        tabs: const [
                          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("Finanzas Personales"))),
                          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("Finanzas Familiares"))),
                          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("Finanzas Ministeriales"))),
                        ],
                      ),
                    ),
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
          );
        }
      ),
    );
  }

// =====================================================================
// SIDEBAR IZQUIERDO (Left Sidebar)
// =====================================================================
class LeftSidebar extends StatelessWidget {
  const LeftSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Detectamos la pestaña activa a través del DefaultTabController
    final tabController = DefaultTabController.of(context);
    // Si la pestaña es la 2 (Finanzas Ministeriales), cambiamos el menú
    final bool esMinisterial = tabController.index == 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 16.0, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.primaryColor,
                radius: 18,
                child: const Icon(Icons.bubble_chart, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text("Sphix", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            ],
          ),
          const SizedBox(height: 50),
          
          // ITEMS DINÁMICOS
          if (esMinisterial) ...[
            _buildNavItem(context, "Resumen Ministerial", Icons.dashboard, isActive: true),
            _buildNavItem(context, "Diezmos y Ofrendas", Icons.auto_awesome, isActive: false),
            _buildNavItem(context, "Pactos", Icons.handshake, isActive: false),
            _buildNavItem(context, "Metas Financieras", Icons.flag, isActive: false),
          ] else ...[
            _buildNavItem(context, "Dashboard", Icons.dashboard, isActive: true),
            _buildNavItem(context, "Ingresos", Icons.arrow_downward, isActive: false),
            _buildNavItem(context, "Gastos", Icons.arrow_upward, isActive: false),
            _buildNavItem(context, "Deudas y Créditos", Icons.credit_card, isActive: false),
            _buildNavItem(context, "Ahorros", Icons.savings, isActive: false),
            _buildNavItem(context, "Metas Financieras", Icons.flag, isActive: false),
          ],

          const Spacer(),
          _buildNavItem(context, "Configuración", Icons.settings, isActive: false),
          _buildNavItem(context, "Cerrar Sesión", Icons.logout, isActive: false),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, {required bool isActive}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isActive ? Colors.white : Colors.grey.shade600),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
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
// PANEL DERECHO (Right Sidebar)
// =====================================================================
class RightSidebar extends StatelessWidget {
  const RightSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    final bool esMinisterial = tabController.index == 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 24.0, 24.0, 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (esMinisterial) ...[
              // EN ORDEN MINISTERIAL:
              const DiezmosEntregadosWidget(), // El antiguo "Ingresos Recientes" ahora arriba
              const SizedBox(height: 24),
              const DistribucionIngresosWidget(), // Gráfico de Ofrendas, Diezmos y Pactos
            ] else ...[
              // ORDEN ESTÁNDAR:
              const MisCuentasWidget(),
              const SizedBox(height: 24),
              const IngresosRecientesSidebarWidget(),
              const SizedBox(height: 24),
              const DistribucionIngresosWidget(),
            ],
          ],
        ),
      ),
    );
  }
}

class MisCuentasWidget extends StatelessWidget {
  const MisCuentasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildAccountAvatar(String name, String balance, IconData icon, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(balance, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class IngresosRecientesSidebarWidget extends StatelessWidget {
  const IngresosRecientesSidebarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ingresos Recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
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
                        child: const Icon(Icons.arrow_downward, color: Colors.green, size: 16),
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
          ],
        ),
      ),
    );
  }
}

class DistribucionIngresosWidget extends StatelessWidget {
  const DistribucionIngresosWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Distribución de Ingresos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(color: theme.primaryColor, value: 55, title: '', radius: 25),
                        PieChartSectionData(color: colorScheme.secondary, value: 30, title: '', radius: 25),
                        PieChartSectionData(color: colorScheme.tertiary, value: 15, title: '', radius: 25),
                      ],
                    ),
                  ),
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
// DASHBOARD GRID Y TARJETAS
// =====================================================================
class DashboardGrid extends StatelessWidget {
  final String contextoFinanciero;
  
  const DashboardGrid({Key? key, required this.contextoFinanciero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool esMinisterial = contextoFinanciero == "Finanzas Ministeriales";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contextoFinanciero, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
          const SizedBox(height: 16),
          
          // 1. RESUMEN DE CABECERA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickStat(esMinisterial ? "Ingresos Totales" : "Total Balance", esMinisterial ? "\$ 12,450" : "\$ 21,550", "+ 12.5%", true, theme),
              _buildQuickStat(esMinisterial ? "Diezmos" : "Gastos", esMinisterial ? "\$ 1,245" : "\$ 1,200", esMinisterial ? "10%" : "- 5.5%", !esMinisterial, theme),
              _buildQuickStat(esMinisterial ? "Ofrendas" : "Ahorros", esMinisterial ? "\$ 3,100" : "\$ 5,500", "+ 8.3%", true, theme),
            ],
          ),
          const SizedBox(height: 32),

          // 2. WIDGETS GRANDES (Diezmos y Ofrendas / Ingresos y Gastos)
          Row(
            children: [
              Expanded(
                child: CategoryCard(
                  title: esMinisterial ? "Diezmos Entregados" : "Ingresos", 
                  amount: esMinisterial ? "\$ 1,245" : "\$ 21,550", 
                  percentage: esMinisterial ? "Fiel" : "↑ 52.5%", 
                  icon: esMinisterial ? Icons.auto_awesome : Icons.account_balance_wallet,
                  gradientColors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                  sparklineData: esMinisterial ? [5, 10, 8, 15, 12, 20, 18, 25] : [10, 20, 15, 30, 25, 40, 35, 50],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CategoryCard(
                  title: esMinisterial ? "Ofrendas Entregadas" : "Gastos", 
                  amount: esMinisterial ? "\$ 3,100" : "\$ 4,320", 
                  percentage: esMinisterial ? "Generoso" : "↓ 12.5%", 
                  icon: esMinisterial ? Icons.volunteer_activism : Icons.shopping_bag,
                  gradientColors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.7)],
                  sparklineData: esMinisterial ? [10, 5, 20, 15, 30, 25, 35, 40] : [50, 40, 45, 30, 35, 20, 25, 10],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 3. FILA DE MICRO-WIDGETS DINÁMICOS
          Row(
            children: [
              Expanded(child: esMinisterial ? const FondosAhorroMinisterial() : const DeudasWidget()),
              const SizedBox(width: 20),
              Expanded(child: esMinisterial ? const MetasMinisterialesScroll() : const AnalysisWidget()),
              const SizedBox(width: 20),
              Expanded(child: esMinisterial ? const PactosEntregadosWidget() : const SaldosWidget()),
            ],
          ),
          const SizedBox(height: 32),

          // 4. SECCIÓN RECIENTE
          Text(esMinisterial ? "Ofrendas y Pactos Recientes" : "Reciente", 
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
          const SizedBox(height: 16),
          RecienteGridWidget(esMinisterial: esMinisterial),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  // ... resto de métodos auxiliares (_buildQuickStat)

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
              RepaintBoundary(
                child: SizedBox(width: 80, height: 40, child: SparklineWidget(data: sparklineData, color: Colors.white)),
              )
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
      child: Container(
        height: 150, // Ajustado a 150px
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
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("\$ 15,000", style: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("Faltan \$45,000", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(value: 0.25, strokeWidth: 4, backgroundColor: theme.scaffoldBackgroundColor, color: theme.primaryColor),
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
      child: Container(
        height: 150, // Ajustado a 150px
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Analysis", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const Spacer(),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(30, theme.colorScheme.secondary),
                  _buildBar(50, theme.primaryColor),
                  _buildBar(25, theme.colorScheme.tertiary),
                  _buildBar(40, theme.primaryColor.withOpacity(0.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBar(double height, Color color) {
    return Container(width: 12, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)));
  }
}

class SaldosWidget extends StatelessWidget {
  const SaldosWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        height: 150, // Ajustado a 150px
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
            const Spacer(),
            Text("\$ 15,000", style: TextStyle(color: theme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("+ \$4,041 hace 50 mins", style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class RecienteGridWidget extends StatelessWidget {
  final bool esMinisterial;
  const RecienteGridWidget({Key? key, this.esMinisterial = false}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
            mainAxisExtent: 70,
          ),
          children: esMinisterial 
          ? const [
            RecienteItemCard(titulo: "Ofrenda General", monto: "+\$ 50.00", isIngreso: true, icono: Icons.church),
            RecienteItemCard(titulo: "Pacto por Familia", monto: "+\$ 100.00", isIngreso: true, icono: Icons.handshake),
            RecienteItemCard(titulo: "Ofrenda Misionera", monto: "+\$ 30.00", isIngreso: true, icono: Icons.public),
            RecienteItemCard(titulo: "Siembra Especial", monto: "+\$ 200.00", isIngreso: true, icono: Icons.spa),
          ]
          : const [
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(isIngreso ? "Ahorro / Ingreso" : "Gasto / Pago", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Text(monto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isIngreso ? Colors.green : theme.primaryColor)),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGETS EXCLUSIVOS: FINANZAS MINISTERIALES (ALTURA UNIFORME 150px)
// =====================================================================

class FondosAhorroMinisterial extends StatelessWidget {
  const FondosAhorroMinisterial({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        height: 150, // Altura Clave para Uniformidad
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Fondos Ahorro", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const Spacer(),
            Text("\$ 5,200", style: TextStyle(color: theme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Reservado para misiones", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class MetasMinisterialesScroll extends StatelessWidget {
  const MetasMinisterialesScroll({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 150, // Altura Clave para Uniformidad
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListView(
          children: [
            _buildMetaItem(context, "Construcción Templo", 0.85),
            const SizedBox(height: 12),
            _buildMetaItem(context, "Sonido Nuevo", 1.0),
            const SizedBox(height: 12),
            _buildMetaItem(context, "Viaje Misionero", 0.40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, String titulo, double progreso) {
    final alcanzada = progreso >= 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            if (alcanzada) const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: alcanzada ? Colors.amber : Theme.of(context).primaryColor,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class PactosEntregadosWidget extends StatelessWidget {
  const PactosEntregadosWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        height: 150, // Altura Clave para Uniformidad
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pactos", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const Spacer(),
            _buildPactoItem("\$ 500", "15 Feb"),
            const Divider(height: 16),
            _buildPactoItem("\$ 200", "01 Feb"),
          ],
        ),
      ),
    );
  }

  Widget _buildPactoItem(String monto, String fecha) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(monto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(fecha, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}