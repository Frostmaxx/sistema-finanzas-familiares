import 'package:flutter/material.dart';

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

  ThemeData get themeData {
    Color primaryColor;
    Color backgroundColor;
    Color surfaceColor; // Color de los widgets/cards

    switch (_currentPalette) {
      case AppPalette.verde:
        primaryColor = const Color(0xFF1A4331);
        backgroundColor = const Color(0xFFD5E0D9); // Verde grisáceo base
        surfaceColor = const Color(0xFFE8F0EB);    // Verde muy ligero para widgets
        break;
      case AppPalette.gris:
        primaryColor = const Color(0xFF4A4A4A);
        backgroundColor = const Color(0xFFD1D1D1); // Gris base
        surfaceColor = const Color(0xFFE5E5E5);    // Gris muy ligero para widgets
        break;
      case AppPalette.azul:
      default:
        primaryColor = const Color(0xFF0B1D39);
        backgroundColor = const Color(0xFFCED8E0); // Tu azul/gris actual
        surfaceColor = const Color(0xFFDAE4ED);    // Azul ligero armónico para widgets
        break;
    }

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: contrastOrange,
        tertiary: contrastHoney,
        surface: surfaceColor, // Inyectamos el color de los widgets aquí
      ),
      cardTheme: CardThemeData(
        color: surfaceColor, // Las tarjetas ahora toman este color automáticamente
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: primaryColor.withOpacity(0.6),
        indicatorColor: contrastOrange,
      ),
    );
  }
}