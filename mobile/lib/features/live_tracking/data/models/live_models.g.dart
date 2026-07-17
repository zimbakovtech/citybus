// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveVehicle _$LiveVehicleFromJson(Map<String, dynamic> json) => _LiveVehicle(
  vehicleId: json['vehicle_id'] as String,
  tripId: (json['trip_id'] as num?)?.toInt(),
  routeShortName: json['route_short_name'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  bearing: (json['bearing'] as num?)?.toDouble(),
  delaySeconds: (json['delay_seconds'] as num).toInt(),
  currentStopId: (json['current_stop_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$LiveVehicleToJson(_LiveVehicle instance) =>
    <String, dynamic>{
      'vehicle_id': instance.vehicleId,
      'trip_id': instance.tripId,
      'route_short_name': instance.routeShortName,
      'lat': instance.lat,
      'lon': instance.lon,
      'bearing': instance.bearing,
      'delay_seconds': instance.delaySeconds,
      'current_stop_id': instance.currentStopId,
    };
