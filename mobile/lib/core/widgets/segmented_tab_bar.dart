import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Segmented-control style tab bar: the themed TabBar (filled rounded
/// indicator) inside a subtle track, shared by every tabbed screen.
class SegmentedTabBar extends StatelessWidget {
  const SegmentedTabBar({super.key, required this.tabs, this.controller});

  final List<Widget> tabs;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Insets.page,
      child: Container(
        padding: const EdgeInsets.all(Insets.xs),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: TabBar(controller: controller, tabs: tabs),
      ),
    );
  }
}
