import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../routes/data/models/route_models.dart';

part 'stop_models.freezed.dart';
part 'stop_models.g.dart';

@freezed
abstract class StopSummary with _$StopSummary {
  const factory StopSummary({
    required int id,
    required String name,
    String? code,
    required double lat,
    required double lon,
  }) = _StopSummary;

  factory StopSummary.fromJson(Map<String, dynamic> json) =>
      _$StopSummaryFromJson(json);
}

@freezed
abstract class NearbyStop with _$NearbyStop {
  const factory NearbyStop({
    required int id,
    required String name,
    String? code,
    required double lat,
    required double lon,
    required double distanceM,
  }) = _NearbyStop;

  factory NearbyStop.fromJson(Map<String, dynamic> json) =>
      _$NearbyStopFromJson(json);
}

@freezed
abstract class StopDetail with _$StopDetail {
  const factory StopDetail({
    required int id,
    required String name,
    String? code,
    required double lat,
    required double lon,
    String? description,
    required List<RouteSummary> routes,
  }) = _StopDetail;

  factory StopDetail.fromJson(Map<String, dynamic> json) =>
      _$StopDetailFromJson(json);
}

@freezed
abstract class Departure with _$Departure {
  const factory Departure({
    required int tripId,
    required RouteSummary route,
    String? headsign,
    required DateTime departureAt,
    required int stopSequence,
  }) = _Departure;

  factory Departure.fromJson(Map<String, dynamic> json) =>
      _$DepartureFromJson(json);
}
