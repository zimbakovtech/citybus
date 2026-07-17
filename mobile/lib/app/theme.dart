import 'package:flutter/material.dart';

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

/// Parses a GTFS route color ('D32F2F', no '#') with a fallback.
Color routeColor(String? hex) {
  if (hex == null || hex.length != 6) return const Color(0xFF1976D2);
  final value = int.tryParse(hex, radix: 16);
  return value == null ? const Color(0xFF1976D2) : Color(0xFF000000 | value);
}
