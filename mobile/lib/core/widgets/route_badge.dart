import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The line-number badge used everywhere a route appears: a rounded square in
/// the route's brand color. One shared widget so lists, departures, planner
/// legs and map markers all match.
class RouteBadge extends StatelessWidget {
  const RouteBadge({
    super.key,
    required this.label,
    this.color,
    this.size = 40,
  });

  /// Route short name, e.g. '15'.
  final String label;

  /// GTFS hex color without '#'; falls back to the app seed color.
  final String? color;

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: routeColor(color),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Matching rounded-square container for leading icons in lists, so icon
/// tiles and route badges share one visual motif.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.size = 40});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Icon(icon, size: size * 0.5, color: scheme.onSecondaryContainer),
    );
  }
}
