import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/websocket_client.dart';
import '../../data/models/live_models.dart';

/// Live vehicle state fed by the /ws/realtime WebSocket: the initial
/// 'snapshot' message seeds the map, then each 'vehicle_position' message
/// upserts one vehicle. Emits the full map after every message.
final liveVehiclesProvider =
    StreamProvider.autoDispose<Map<String, LiveVehicle>>((ref) async* {
  final socket = RealtimeSocket();
  ref.onDispose(socket.close);

  final vehicles = <String, LiveVehicle>{};
  await for (final message in socket.messages) {
    switch (message['type']) {
      case 'snapshot':
        vehicles.clear();
        for (final raw in message['vehicles'] as List<dynamic>) {
          final vehicle = LiveVehicle.fromJson(raw as Map<String, dynamic>);
          vehicles[vehicle.vehicleId] = vehicle;
        }
      case 'vehicle_position':
        final vehicle = LiveVehicle.fromJson(message);
        vehicles[vehicle.vehicleId] = vehicle;
      default:
        continue;
    }
    yield Map.unmodifiable(vehicles);
  }
});
