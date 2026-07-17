// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteSummary _$RouteSummaryFromJson(Map<String, dynamic> json) =>
    _RouteSummary(
      id: (json['id'] as num).toInt(),
      shortName: json['short_name'] as String?,
      longName: json['long_name'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$RouteSummaryToJson(_RouteSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'short_name': instance.shortName,
      'long_name': instance.longName,
      'color': instance.color,
    };

_RouteDetail _$RouteDetailFromJson(Map<String, dynamic> json) => _RouteDetail(
  id: (json['id'] as num).toInt(),
  shortName: json['short_name'] as String?,
  longName: json['long_name'] as String?,
  color: json['color'] as String?,
  gtfsRouteId: json['gtfs_route_id'] as String,
  routeType: (json['route_type'] as num).toInt(),
  textColor: json['text_color'] as String?,
  agencyName: json['agency_name'] as String,
);

Map<String, dynamic> _$RouteDetailToJson(_RouteDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'short_name': instance.shortName,
      'long_name': instance.longName,
      'color': instance.color,
      'gtfs_route_id': instance.gtfsRouteId,
      'route_type': instance.routeType,
      'text_color': instance.textColor,
      'agency_name': instance.agencyName,
    };

_RouteShape _$RouteShapeFromJson(Map<String, dynamic> json) => _RouteShape(
  type: json['type'] as String,
  coordinates: (json['coordinates'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
);

Map<String, dynamic> _$RouteShapeToJson(_RouteShape instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

_TripSummary _$TripSummaryFromJson(Map<String, dynamic> json) => _TripSummary(
  id: (json['id'] as num).toInt(),
  headsign: json['headsign'] as String?,
  directionId: (json['direction_id'] as num?)?.toInt(),
  startsAt: json['starts_at'] as String,
  endsAt: json['ends_at'] as String,
);

Map<String, dynamic> _$TripSummaryToJson(_TripSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'headsign': instance.headsign,
      'direction_id': instance.directionId,
      'starts_at': instance.startsAt,
      'ends_at': instance.endsAt,
    };

_TripStopTime _$TripStopTimeFromJson(Map<String, dynamic> json) =>
    _TripStopTime(
      stopSequence: (json['stop_sequence'] as num).toInt(),
      stop: StopSummary.fromJson(json['stop'] as Map<String, dynamic>),
      arrivalTime: json['arrival_time'] as String,
      departureTime: json['departure_time'] as String,
    );

Map<String, dynamic> _$TripStopTimeToJson(_TripStopTime instance) =>
    <String, dynamic>{
      'stop_sequence': instance.stopSequence,
      'stop': instance.stop.toJson(),
      'arrival_time': instance.arrivalTime,
      'departure_time': instance.departureTime,
    };

_TripDetail _$TripDetailFromJson(Map<String, dynamic> json) => _TripDetail(
  id: (json['id'] as num).toInt(),
  gtfsTripId: json['gtfs_trip_id'] as String,
  route: RouteSummary.fromJson(json['route'] as Map<String, dynamic>),
  headsign: json['headsign'] as String?,
  directionId: (json['direction_id'] as num?)?.toInt(),
  stopTimes: (json['stop_times'] as List<dynamic>)
      .map((e) => TripStopTime.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripDetailToJson(_TripDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gtfs_trip_id': instance.gtfsTripId,
      'route': instance.route.toJson(),
      'headsign': instance.headsign,
      'direction_id': instance.directionId,
      'stop_times': instance.stopTimes.map((e) => e.toJson()).toList(),
    };
