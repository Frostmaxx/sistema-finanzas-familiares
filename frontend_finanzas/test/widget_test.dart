
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_dashboard/main.dart';
import 'package:finanzas_dashboard/theme_provider.dart';

void main() {
  testWidgets('La app muestra los 3 tabs del dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Verificar que los 3 tabs se renderizan
    expect(find.text('Finanzas Personales'), findsOneWidget);
    expect(find.text('Finanzas Familiares'), findsOneWidget);
    expect(find.text('Finanzas Ministeriales'), findsOneWidget);
  });

  testWidgets('La app muestra el título del dashboard activo', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // El primer tab (Finanzas Personales) debe estar visible por defecto
    expect(find.text('Finanzas Personales'), findsWidgets);
  });
}
