import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../stops/data/models/stop_models.dart';

part 'route_models.freezed.dart';
part 'route_models.g.dart';

@freezed
abstract class RouteSummary with _$RouteSummary {
  const factory RouteSummary({
    required int id,
    String? shortName,
    String? longName,
    String? color,
  }) = _RouteSummary;

  factory RouteSummary.fromJson(Map<String, dynamic> json) =>
      _$RouteSummaryFromJson(json);
}

@freezed
abstract class RouteDetail with _$RouteDetail {
  const factory RouteDetail({
    required int id,
    String? shortName,
    String? longName,
    String? color,
    required String gtfsRouteId,
    required int routeType,
    String? textColor,
    required String agencyName,
  }) = _RouteDetail;

  factory RouteDetail.fromJson(Map<String, dynamic> json) =>
      _$RouteDetailFromJson(json);
}

/// GeoJSON LineString geometry: coordinates are [lon, lat] pairs.
@freezed
abstract class RouteShape with _$RouteShape {
  const factory RouteShape({
    required String type,
    required List<List<double>> coordinates,
  }) = _RouteShape;

  factory RouteShape.fromJson(Map<String, dynamic> json) =>
      _$RouteShapeFromJson(json);
}

/// Times are GTFS-style HH:MM:SS strings and may exceed 24:00:00.
@freezed
abstract class TripSummary with _$TripSummary {
  const factory TripSummary({
    required int id,
    String? headsign,
    int? directionId,
    required String startsAt,
    required String endsAt,
  }) = _TripSummary;

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);
}

@freezed
abstract class TripStopTime with _$TripStopTime {
  const factory TripStopTime({
    required int stopSequence,
    required StopSummary stop,
    required String arrivalTime,
    required String departureTime,
  }) = _TripStopTime;

  factory TripStopTime.fromJson(Map<String, dynamic> json) =>
      _$TripStopTimeFromJson(json);
}

@freezed
abstract class TripDetail with _$TripDetail {
  const factory TripDetail({
    required int id,
    required String gtfsTripId,
    required RouteSummary route,
    String? headsign,
    int? directionId,
    required List<TripStopTime> stopTimes,
  }) = _TripDetail;

  factory TripDetail.fromJson(Map<String, dynamic> json) =>
      _$TripDetailFromJson(json);
}
