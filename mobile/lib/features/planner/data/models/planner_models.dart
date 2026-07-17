import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../routes/data/models/route_models.dart';
import '../../../stops/data/models/stop_models.dart';

part 'planner_models.freezed.dart';
part 'planner_models.g.dart';

/// One journey leg; the API discriminates with "type": "ride" | "transfer".
@Freezed(unionKey: 'type')
sealed class PlanLeg with _$PlanLeg {
  const factory PlanLeg.ride({
    required RouteSummary route,
    required int tripId,
    required StopSummary boardStop,
    required DateTime boardTime,
    required StopSummary alightStop,
    required DateTime alightTime,
    required int numStops,
  }) = PlanRideLeg;

  const factory PlanLeg.transfer({
    required StopSummary atStop,
    required int seconds,
  }) = PlanTransferLeg;

  factory PlanLeg.fromJson(Map<String, dynamic> json) =>
      _$PlanLegFromJson(json);
}

/// found=false is the explicit "no route found" answer.
@freezed
abstract class PlanResponse with _$PlanResponse {
  const factory PlanResponse({
    required bool found,
    required StopSummary fromStop,
    required StopSummary toStop,
    required DateTime departAt,
    DateTime? arriveAt,
    int? durationSeconds,
    int? transfers,
    required List<PlanLeg> legs,
  }) = _PlanResponse;

  factory PlanResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanResponseFromJson(json);
}
