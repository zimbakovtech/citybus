import 'package:flutter/material.dart';

/// Design tokens — single source of truth for spacing and shape so every
/// screen shares the same rhythm.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Standard horizontal page padding.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

const _seed = Color(0xFF1976D2);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  RoundedRectangleBorder shape(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  return base.copyWith(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    // one card style everywhere: flat, hairline border, md radius
    cardTheme: base.cardTheme.copyWith(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shape(
        Radii.md,
      ).copyWith(side: BorderSide(color: scheme.outlineVariant)),
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      shape: WidgetStatePropertyAll(shape(Radii.md)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Insets.lg),
      ),
      textStyle: WidgetStatePropertyAll(base.textTheme.bodyLarge),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: shape(Radii.sm + 2),
        side: BorderSide(color: scheme.outlineVariant),
        visualDensity: VisualDensity.standard,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape(Radii.md),
        minimumSize: const Size.fromHeight(48),
        textStyle: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorShape: shape(Radii.sm + 2),
      labelTextStyle: WidgetStatePropertyAll(
        base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: shape(Radii.sm),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Insets.lg),
      minVerticalPadding: Insets.md,
    ),
  );
}

/// Parses a GTFS route color ('D32F2F', no '#') with a fallback.
Color routeColor(String? hex) {
  if (hex == null || hex.length != 6) return _seed;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? _seed : Color(0xFF000000 | value);
}
