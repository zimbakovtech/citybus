import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/status_views.dart';
import '../providers/routes_providers.dart';

/// Searchable list of bus lines.
class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(routeSearchResultsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Routes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Search routes…',
              leading: const Icon(Icons.search),
              onChanged: (value) =>
                  ref.read(routeSearchQueryProvider.notifier).set(value),
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(routeSearchResultsProvider),
              ),
              data: (routes) => routes.isEmpty
                  ? const EmptyView(message: 'No routes match your search.')
                  : ListView.builder(
                      itemCount: routes.length,
                      itemBuilder: (context, index) {
                        final route = routes[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: routeColor(route.color),
                            child: Text(
                              route.shortName ?? '?',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          title: Text(route.longName ?? 'Line ${route.shortName}'),
                          onTap: () => context.go('/routes/${route.id}'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
