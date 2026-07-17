import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              hintText: 'Search stops…',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _nearbyMode = false);
                ref.read(stopSearchQueryProvider.notifier).set(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Search'), icon: Icon(Icons.list)),
                ButtonSegment(value: true, label: Text('Nearby'), icon: Icon(Icons.my_location)),
              ],
              selected: {_nearbyMode},
              onSelectionChanged: (selection) =>
                  setState(() => _nearbyMode = selection.first),
            ),
          ),
          Expanded(child: _nearbyMode ? const _NearbyList() : const _SearchList()),
        ],
      ),
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
          ? const EmptyView(message: 'No stops match your search.')
          : ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return ListTile(
                  leading: const Icon(Icons.pin_drop_outlined),
                  title: Text(stop.name),
                  subtitle: stop.code == null ? null : Text(stop.code!),
                  onTap: () => context.go('/stops/${stop.id}'),
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
          ? const EmptyView(message: 'No stops within 1 km.')
          : ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return ListTile(
                  leading: const Icon(Icons.near_me_outlined),
                  title: Text(stop.name),
                  subtitle: Text('${stop.distanceM.round()} m away'),
                  onTap: () => context.go('/stops/${stop.id}'),
                );
              },
            ),
    );
  }
}
