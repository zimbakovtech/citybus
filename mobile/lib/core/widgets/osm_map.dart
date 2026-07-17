import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Skopje city center — sensible initial camera for the seed network.
const skopjeCenter = LatLng(41.9965, 21.4314);

/// Shared OpenStreetMap scaffold: tile layer with the required attribution;
/// callers add polylines/markers via [layers].
class OsmMap extends StatelessWidget {
  const OsmMap({
    super.key,
    required this.layers,
    this.center = skopjeCenter,
    this.zoom = 13,
    this.controller,
  });

  final List<Widget> layers;
  final LatLng center;
  final double zoom;
  final MapController? controller;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(initialCenter: center, initialZoom: zoom),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'mk.citybus.citybus',
        ),
        ...layers,
        const SimpleAttributionWidget(
          source: Text('© OpenStreetMap contributors'),
        ),
      ],
    );
  }
}
