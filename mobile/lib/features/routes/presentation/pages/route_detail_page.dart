import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/osm_map.dart';
import '../../../../core/widgets/status_views.dart';
import '../providers/routes_providers.dart';

/// Route polyline on the map plus its ordered stops, per direction.
class RouteDetailPage extends ConsumerStatefulWidget {
  const RouteDetailPage({super.key, required this.routeId});

  final int routeId;

  @override
  ConsumerState<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends ConsumerState<RouteDetailPage> {
  int _direction = 0;

  @override
  Widget build(BuildContext context) {
    final args = (routeId: widget.routeId, directionId: _direction);
    final detail = ref.watch(routeDetailProvider(widget.routeId));
    final shape = ref.watch(routeShapeProvider(args));
    final stops = ref.watch(routeStopsProvider(args));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detail.value == null
              ? 'Route'
              : 'Line ${detail.value!.shortName} — ${detail.value!.longName}',
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Outbound')),
                ButtonSegment(value: 1, label: Text('Inbound')),
              ],
              selected: {_direction},
              onSelectionChanged: (selection) =>
                  setState(() => _direction = selection.first),
            ),
          ),
        ),
      ),
      body: detail.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(routeDetailProvider(widget.routeId)),
        ),
        data: (route) => Column(
          children: [
            Expanded(
              flex: 3,
              child: shape.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(message: error.toString()),
                data: (geo) {
                  final points = [
                    // GeoJSON coordinates are [lon, lat]
                    for (final pair in geo.coordinates) LatLng(pair[1], pair[0]),
                  ];
                  return OsmMap(
                    center: points.isEmpty ? skopjeCenter : points[points.length ~/ 2],
                    layers: [
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: points,
                            strokeWidth: 4,
                            color: routeColor(route.color),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          for (final stop in stops.value ?? [])
                            Marker(
                              point: LatLng(stop.lat, stop.lon),
                              width: 12,
                              height: 12,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: routeColor(route.color),
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: stops.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(message: error.toString()),
                data: (items) => ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    leading: Text('${index + 1}',
                        style: Theme.of(context).textTheme.labelLarge),
                    title: Text(items[index].name),
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
