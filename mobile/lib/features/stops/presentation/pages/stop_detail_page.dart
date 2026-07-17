import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/status_views.dart';
import '../providers/stops_providers.dart';

/// Stop attributes, the routes serving it, and upcoming departures.
class StopDetailPage extends ConsumerWidget {
  const StopDetailPage({super.key, required this.stopId});

  final int stopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(stopDetailProvider(stopId));
    return Scaffold(
      appBar: AppBar(title: Text(detail.value?.name ?? 'Stop')),
      body: detail.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(stopDetailProvider(stopId)),
        ),
        data: (stop) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(departuresProvider(stopId)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (stop.code != null)
                Text('Stop code: ${stop.code}',
                    style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final route in stop.routes)
                    Chip(
                      label: Text(route.shortName ?? route.longName ?? '?'),
                      backgroundColor: routeColor(route.color).withValues(alpha: 0.15),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Departures (next hour)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Divider(height: 1),
              _DeparturesList(stopId: stopId),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeparturesList extends ConsumerWidget {
  const _DeparturesList({required this.stopId});

  final int stopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departures = ref.watch(departuresProvider(stopId));
    return departures.when(
      loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(departuresProvider(stopId)),
      ),
      data: (items) => items.isEmpty
          ? const EmptyView(message: 'No departures in the next hour.')
          : Column(
              children: [
                for (final departure in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: routeColor(departure.route.color),
                      child: Text(
                        departure.route.shortName ?? '?',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    title: Text(departure.headsign ?? departure.route.longName ?? ''),
                    trailing: Text(
                      DateFormat.Hm().format(departure.departureAt),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
    );
  }
}
