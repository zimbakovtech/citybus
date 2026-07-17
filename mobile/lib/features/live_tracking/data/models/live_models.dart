import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_models.freezed.dart';
part 'live_models.g.dart';

/// Latest known state of one simulated vehicle (REST snapshot shape; the
/// WebSocket 'snapshot' message carries the same fields).
@freezed
abstract class LiveVehicle with _$LiveVehicle {
  const factory LiveVehicle({
    required String vehicleId,
    int? tripId,
    String? routeShortName,
    required double lat,
    required double lon,
    double? bearing,
    required int delaySeconds,
    int? currentStopId,
  }) = _LiveVehicle;

  factory LiveVehicle.fromJson(Map<String, dynamic> json) =>
      _$LiveVehicleFromJson(json);
}
