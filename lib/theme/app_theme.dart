import 'package:flutter/material.dart';

// All the colors of the app live here.
// To change the look of the whole app later, you only edit this class.
class AppColors {
  static const navy = Color(0xFF0B3A6B); // main color: app bars and buttons
  static const blue = Color(0xFF1E6FD9); // accent color
  static const background = Color(0xFFF4F7FB); // light page background
  static const textDark = Color(0xFF1B2B3A); // main text
  static const textMuted = Color(0xFF6B7A8C); // secondary text
  static const green = Color(0xFF22A55B); // fare / success
  static const orange = Color(0xFFFF8A2B); // highlights
}

// ThemeData is Flutter's "style sheet": every widget of a type
// (AppBar, ElevatedButton...) picks its look from here automatically.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',

    // Generates a matching color palette from our navy color.
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),

    // Background color of every Scaffold (page).
    scaffoldBackgroundColor: AppColors.background,

    // Every AppBar in the app becomes navy with white text and icons.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white, // back arrow and icons
      elevation: 0, // no shadow under the bar
      centerTitle: false, // title on the left, like the mockup
      surfaceTintColor: Colors.transparent, // stops Material 3 tinting the bar
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Every ElevatedButton gets this style, so we don't repeat it on each page.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52), // full width, 52 tall
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
