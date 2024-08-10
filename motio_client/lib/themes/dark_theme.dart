import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.deepPurple,
    backgroundColor: const Color(0xFF121212),
  ).copyWith(
    secondary: Colors.deepPurple[300],
    brightness: Brightness.dark,
    surface: const Color(0xFF121212),
  ),
  dividerColor: Colors.deepPurple[300],
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF121212),
    iconTheme: IconThemeData(color: Colors.deepPurple[300]),
    titleTextStyle: TextStyle(color: Colors.deepPurple[300], fontSize: 20),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(color: Colors.deepPurple[300]),
    headlineSmall: TextStyle(color: Colors.deepPurple[300]),
    bodyLarge: const TextStyle(color: Colors.white),
    bodyMedium: const TextStyle(color: Colors.white),
    bodySmall: const TextStyle(color: Colors.white),
    titleLarge: const TextStyle(color: Colors.white),
    titleMedium: const TextStyle(color: Colors.white),
    titleSmall: const TextStyle(color: Colors.white),
    labelLarge: const TextStyle(color: Colors.white),
    labelMedium: const TextStyle(color: Colors.white),
    labelSmall: const TextStyle(color: Colors.white),
    displayLarge: const TextStyle(color: Colors.white),
    displayMedium: const TextStyle(color: Colors.white),
    displaySmall: const TextStyle(color: Colors.white),
  ),
  iconTheme: IconThemeData(color: Colors.deepPurple[300]),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 182, 28, 255),
      foregroundColor: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[800], // Ciemnoszare tło
    labelStyle: const TextStyle(color: Colors.white), // Biały tekst
    hintStyle: const TextStyle(color: Colors.white70), // Hint text in light gray
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.deepPurple[300]!),
    ),
  ),
);
