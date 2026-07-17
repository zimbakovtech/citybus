import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/route_badge.dart';
import '../../../../core/widgets/status_views.dart';
import '../providers/stops_providers.dart';

/// Stop search (server-side) with a "nearby" mode using the device location.
class StopsPage extends ConsumerStatefulWidget {
  const StopsPage({super.key});

  @override
  ConsumerState<StopsPage> createState() => _StopsPageState();
}

class _StopsPageState extends ConsumerState<StopsPage> {
  bool _nearbyMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stops')),
      body: Column(
        children: [
          Padding(
            padding: Insets.page,
            child: SearchBar(
              hintText: 'Search stops…',
              leading: const Icon(CupertinoIcons.search, size: 20),
              onChanged: (value) {
                setState(() => _nearbyMode = false);
                ref.read(stopSearchQueryProvider.notifier).set(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.md),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Search'),
                  icon: Icon(CupertinoIcons.search, size: 18),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Nearby'),
                  icon: Icon(CupertinoIcons.location, size: 18),
                ),
              ],
              selected: {_nearbyMode},
              onSelectionChanged: (selection) =>
                  setState(() => _nearbyMode = selection.first),
            ),
          ),
          Expanded(
            child: _nearbyMode ? const _NearbyList() : const _SearchList(),
          ),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.stopId,
    required this.name,
    required this.icon,
    this.subtitle,
  });

  final int stopId;
  final String name;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(icon: icon),
      title: Text(
        name,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
      onTap: () => context.go('/stops/$stopId'),
    );
  }
}

class _SearchList extends ConsumerWidget {
  const _SearchList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(stopSearchResultsProvider);
    return results.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(stopSearchResultsProvider),
      ),
      data: (stops) => stops.isEmpty
          ? const EmptyView(
              message: 'No stops match your search.',
              icon: CupertinoIcons.search,
            )
          : ListView.separated(
              itemCount: stops.length,
              separatorBuilder: (_, _) =>
                  const Divider(indent: 72, endIndent: Insets.lg),
              itemBuilder: (context, index) {
                final stop = stops[index];
                return _StopTile(
                  stopId: stop.id,
                  name: stop.name,
                  icon: CupertinoIcons.map_pin_ellipse,
                  subtitle: stop.code,
                );
              },
            ),
    );
  }
}

class _NearbyList extends ConsumerWidget {
  const _NearbyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearby = ref.watch(nearbyStopsProvider);
    return nearby.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(nearbyStopsProvider),
      ),
      data: (stops) => stops.isEmpty
          ? const EmptyView(
              message: 'No stops within 1 km.',
              icon: CupertinoIcons.location,
            )
          : ListView.separated(
              itemCount: stops.length,
              separatorBuilder: (_, _) =>
                  const Divider(indent: 72, endIndent: Insets.lg),
              itemBuilder: (context, index) {
                final stop = stops[index];
                return _StopTile(
                  stopId: stop.id,
                  name: stop.name,
                  icon: CupertinoIcons.location,
                  subtitle: '${stop.distanceM.round()} m away',
                );
              },
            ),
    );
  }
}
