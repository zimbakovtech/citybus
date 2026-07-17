// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanRideLeg _$PlanRideLegFromJson(Map<String, dynamic> json) => PlanRideLeg(
  route: RouteSummary.fromJson(json['route'] as Map<String, dynamic>),
  tripId: (json['trip_id'] as num).toInt(),
  boardStop: StopSummary.fromJson(json['board_stop'] as Map<String, dynamic>),
  boardTime: DateTime.parse(json['board_time'] as String),
  alightStop: StopSummary.fromJson(json['alight_stop'] as Map<String, dynamic>),
  alightTime: DateTime.parse(json['alight_time'] as String),
  numStops: (json['num_stops'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$PlanRideLegToJson(PlanRideLeg instance) =>
    <String, dynamic>{
      'route': instance.route.toJson(),
      'trip_id': instance.tripId,
      'board_stop': instance.boardStop.toJson(),
      'board_time': instance.boardTime.toIso8601String(),
      'alight_stop': instance.alightStop.toJson(),
      'alight_time': instance.alightTime.toIso8601String(),
      'num_stops': instance.numStops,
      'type': instance.$type,
    };

PlanTransferLeg _$PlanTransferLegFromJson(Map<String, dynamic> json) =>
    PlanTransferLeg(
      atStop: StopSummary.fromJson(json['at_stop'] as Map<String, dynamic>),
      seconds: (json['seconds'] as num).toInt(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PlanTransferLegToJson(PlanTransferLeg instance) =>
    <String, dynamic>{
      'at_stop': instance.atStop.toJson(),
      'seconds': instance.seconds,
      'type': instance.$type,
    };

_PlanResponse _$PlanResponseFromJson(Map<String, dynamic> json) =>
    _PlanResponse(
      found: json['found'] as bool,
      fromStop: StopSummary.fromJson(json['from_stop'] as Map<String, dynamic>),
      toStop: StopSummary.fromJson(json['to_stop'] as Map<String, dynamic>),
      departAt: DateTime.parse(json['depart_at'] as String),
      arriveAt: json['arrive_at'] == null
          ? null
          : DateTime.parse(json['arrive_at'] as String),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      transfers: (json['transfers'] as num?)?.toInt(),
      legs: (json['legs'] as List<dynamic>)
          .map((e) => PlanLeg.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlanResponseToJson(_PlanResponse instance) =>
    <String, dynamic>{
      'found': instance.found,
      'from_stop': instance.fromStop.toJson(),
      'to_stop': instance.toStop.toJson(),
      'depart_at': instance.departAt.toIso8601String(),
      'arrive_at': instance.arriveAt?.toIso8601String(),
      'duration_seconds': instance.durationSeconds,
      'transfers': instance.transfers,
      'legs': instance.legs.map((e) => e.toJson()).toList(),
    };
