import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/live_tracking/presentation/pages/live_page.dart';
import '../features/planner/presentation/pages/planner_page.dart';
import '../features/routes/presentation/pages/route_detail_page.dart';
import '../features/routes/presentation/pages/routes_page.dart';
import '../features/stops/presentation/pages/stop_detail_page.dart';
import '../features/stops/presentation/pages/stops_page.dart';

/// App navigation: a bottom-tab shell with one branch per feature.
final router = GoRouter(
  initialLocation: '/stops',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ShellScaffold(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stops',
              builder: (context, state) => const StopsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => StopDetailPage(
                    stopId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/routes',
              builder: (context, state) => const RoutesPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => RouteDetailPage(
                    routeId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const PlannerPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/live',
              builder: (context, state) => const LivePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.map_pin_ellipse),
            label: 'Stops',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.map),
            label: 'Routes',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.arrow_swap),
            label: 'Planner',
          ),
          NavigationDestination(icon: Icon(CupertinoIcons.bus), label: 'Live'),
        ],
      ),
    );
  }
}
