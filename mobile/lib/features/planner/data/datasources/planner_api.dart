import 'package:dio/dio.dart';

import '../models/planner_models.dart';

class PlannerApi {
  PlannerApi(this._dio);

  final Dio _dio;

  Future<PlanResponse> plan({
    int? fromStopId,
    int? toStopId,
    double? fromLat,
    double? fromLon,
    double? toLat,
    double? toLon,
    required DateTime departAt,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/planner',
      queryParameters: {
        'depart_at': departAt.toIso8601String(),
        'from_stop_id': ?fromStopId,
        'to_stop_id': ?toStopId,
        'from_lat': ?fromLat,
        'from_lon': ?fromLon,
        'to_lat': ?toLat,
        'to_lon': ?toLon,
      },
    );
    return PlanResponse.fromJson(response.data!);
  }
}
