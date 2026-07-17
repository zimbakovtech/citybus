import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/osm_map.dart';
import '../../../../core/widgets/status_views.dart';
import '../../data/models/live_models.dart';
import '../providers/live_providers.dart';

/// Live map of simulated vehicles; markers move as WebSocket updates arrive.
class LivePage extends ConsumerWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(liveVehiclesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Live buses')),
      body: vehicles.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(liveVehiclesProvider),
        ),
        data: (fleet) => Stack(
          children: [
            OsmMap(
              layers: [
                MarkerLayer(
                  markers: [
                    for (final vehicle in fleet.values)
                      Marker(
                        point: LatLng(vehicle.lat, vehicle.lon),
                        width: 52,
                        height: 52,
                        child: _VehicleMarker(vehicle: vehicle),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: Insets.md,
              left: Insets.lg,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.md,
                    vertical: Insets.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.bus,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: Insets.sm),
                      Text(
                        '${fleet.length} on the road',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({required this.vehicle});

  final LiveVehicle vehicle;

  Color get _delayColor => switch (vehicle.delaySeconds) {
        <= 60 => const Color(0xFF2E7D32),
        <= 240 => const Color(0xFFE65100),
        _ => const Color(0xFFC62828),
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: scheme.surface, width: 2),
            boxShadow: const [
              BoxShadow(blurRadius: 4, color: Color(0x33000000)),
            ],
          ),
          child: Icon(CupertinoIcons.bus, size: 14, color: scheme.onPrimary),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Insets.xs, vertical: 1),
          decoration: BoxDecoration(
            color: _delayColor,
            borderRadius: BorderRadius.circular(Radii.sm - 2),
          ),
          child: Text(
            '${vehicle.routeShortName ?? '?'} +${(vehicle.delaySeconds / 60).round()}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
