import 'package:flutter/material.dart';

TextTheme circularStdTextTheme() {
  return TextTheme(
    displayLarge: const TextStyle(fontFamily: 'CircularStd', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: const TextStyle(fontFamily: 'CircularStd', fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: const TextStyle(fontFamily: 'CircularStd', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    headlineLarge: TextStyle(fontFamily: 'CircularStd', fontSize: 24, fontWeight: FontWeight.normal, color: Colors.grey[300]),
    headlineMedium: TextStyle(fontFamily: 'CircularStd', fontSize: 20, fontWeight: FontWeight.normal, color: Colors.grey[300]),
    headlineSmall: TextStyle(fontFamily: 'CircularStd', fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey[300]),
    titleLarge: const TextStyle(fontFamily: 'CircularStd', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    titleMedium: const TextStyle(fontFamily: 'CircularStd', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    titleSmall: const TextStyle(fontFamily: 'CircularStd', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontFamily: 'CircularStd', fontSize: 20, fontWeight: FontWeight.normal, color: Colors.grey[300]),
    bodyMedium: TextStyle(fontFamily: 'CircularStd', fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey[300]),
    bodySmall: TextStyle(fontFamily: 'CircularStd', fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[300]),
    labelLarge: const TextStyle(fontFamily: 'CircularStd', fontSize: 18, fontWeight: FontWeight.normal, color: Color(0xFF8c8c8c)),
    labelMedium: const TextStyle(fontFamily: 'CircularStd', fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF8c8c8c)),
    labelSmall: const TextStyle(fontFamily: 'CircularStd', fontSize: 10, fontWeight: FontWeight.normal, color: Color(0xFF8c8c8c)),
  );
}

Color backgroundColor({double? opacity}) {
  return const Color.fromARGB(255, 7, 27, 36);
}

Color navBarColor({double? opacity}) {
  return const Color.fromARGB(255, 20, 40, 54);
}