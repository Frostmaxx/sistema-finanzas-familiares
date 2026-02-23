import 'package:flutter/material.dart';

// 1. Definimos las paletas disponibles como un listado estricto
enum AppPalette { azul, verde, gris }

// 2. Creamos nuestro Motor de Temas
class ThemeProvider extends ChangeNotifier {
  // Por defecto, iniciamos con la paleta Azul
  AppPalette _currentPalette = AppPalette.azul;

  AppPalette get currentPalette => _currentPalette;

  // Método para cambiar de tema dinámicamente
  void changePalette(AppPalette newPalette) {
    if (_currentPalette != newPalette) {
      _currentPalette = newPalette;
      notifyListeners(); // Esto le grita a toda la app: "¡Actualicen sus colores!"
    }
  }

  // 3. Colores estáticos de Contraste (comunes para todas las paletas según tus specs)
  final Color contrastOrange = const Color(0xFFFF8C00); // Naranja
  final Color contrastHoney = const Color(0xFFFFC30B);  // Miel
  
  // Fondo general (Matiz medio)
  final Color backgroundLight = const Color(0xFFF4F7F6);

  // 4. Lógica para construir el ThemeData según la paleta seleccionada
  ThemeData get themeData {
    Color primaryColor;

    // Asignamos el color principal dependiendo de la paleta elegida
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

    // Retornamos la configuración global de la UI
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: contrastOrange,
        tertiary: contrastHoney,
        background: backgroundLight,
      ),
      // ¡Aquí aplicamos tu especificación de Clean UI de forma global!
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0, // Quitamos la elevación por defecto de Material
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Tus 30px de radio
        ),
      ),
      // Configuramos el estilo global de las pestañas (TabBar)
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: contrastOrange,
      ),
    );
  }
}