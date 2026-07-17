import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        StatefulShellBranch(routes: [
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
        ]),
        StatefulShellBranch(routes: [
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
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/planner',
            builder: (context, state) => const _PlaceholderPage(title: 'Planner'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/live',
            builder: (context, state) => const _PlaceholderPage(title: 'Live'),
          ),
        ]),
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
          NavigationDestination(icon: Icon(Icons.pin_drop_outlined), label: 'Stops'),
          NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.alt_route), label: 'Planner'),
          NavigationDestination(icon: Icon(Icons.directions_bus_outlined), label: 'Live'),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — coming soon')),
    );
  }
}
