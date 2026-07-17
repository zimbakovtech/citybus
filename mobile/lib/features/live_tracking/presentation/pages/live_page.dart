import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
          message: 'Realtime connection failed: $error',
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
                        width: 46,
                        height: 46,
                        child: _VehicleMarker(vehicle: vehicle),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Chip(label: Text('${fleet.length} buses on the road')),
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
        <= 60 => Colors.green,
        <= 240 => Colors.orange,
        _ => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.directions_bus, size: 16, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: _delayColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${vehicle.routeShortName ?? '?'} +${(vehicle.delaySeconds / 60).round()}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
