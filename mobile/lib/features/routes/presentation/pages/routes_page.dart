import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/route_badge.dart';
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
            padding: Insets.page.copyWith(bottom: Insets.md),
            child: SearchBar(
              hintText: 'Search routes…',
              leading: const Icon(CupertinoIcons.search, size: 20),
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
                  ? const EmptyView(
                      message: 'No routes match your search.',
                      icon: CupertinoIcons.search,
                    )
                  : ListView.separated(
                      itemCount: routes.length,
                      separatorBuilder: (_, _) =>
                          const Divider(indent: 72, endIndent: Insets.lg),
                      itemBuilder: (context, index) {
                        final route = routes[index];
                        return ListTile(
                          leading: RouteBadge(
                            label: route.shortName ?? '?',
                            color: route.color,
                          ),
                          title: Text(
                            route.longName ?? 'Line ${route.shortName}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Line ${route.shortName}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          trailing: const Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                          ),
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
