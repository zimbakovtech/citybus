// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StopSummary _$StopSummaryFromJson(Map<String, dynamic> json) => _StopSummary(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
);

Map<String, dynamic> _$StopSummaryToJson(_StopSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'lat': instance.lat,
      'lon': instance.lon,
    };

_NearbyStop _$NearbyStopFromJson(Map<String, dynamic> json) => _NearbyStop(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  distanceM: (json['distance_m'] as num).toDouble(),
);

Map<String, dynamic> _$NearbyStopToJson(_NearbyStop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'lat': instance.lat,
      'lon': instance.lon,
      'distance_m': instance.distanceM,
    };

_StopDetail _$StopDetailFromJson(Map<String, dynamic> json) => _StopDetail(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  description: json['description'] as String?,
  routes: (json['routes'] as List<dynamic>)
      .map((e) => RouteSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StopDetailToJson(_StopDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'lat': instance.lat,
      'lon': instance.lon,
      'description': instance.description,
      'routes': instance.routes.map((e) => e.toJson()).toList(),
    };

_Departure _$DepartureFromJson(Map<String, dynamic> json) => _Departure(
  tripId: (json['trip_id'] as num).toInt(),
  route: RouteSummary.fromJson(json['route'] as Map<String, dynamic>),
  headsign: json['headsign'] as String?,
  departureAt: DateTime.parse(json['departure_at'] as String),
  stopSequence: (json['stop_sequence'] as num).toInt(),
);

Map<String, dynamic> _$DepartureToJson(_Departure instance) =>
    <String, dynamic>{
      'trip_id': instance.tripId,
      'route': instance.route.toJson(),
      'headsign': instance.headsign,
      'departure_at': instance.departureAt.toIso8601String(),
      'stop_sequence': instance.stopSequence,
    };
