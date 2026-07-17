import 'package:dio/dio.dart';

import '../models/stop_models.dart';

/// REST calls for the stops feature.
class StopsApi {
  StopsApi(this._dio);

  final Dio _dio;

  Future<List<StopSummary>> search(String query, {int limit = 30}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/stops',
      queryParameters: {if (query.isNotEmpty) 'search': query, 'limit': limit},
    );
    final items = response.data!['items'] as List<dynamic>;
    return items
        .map((item) => StopSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<NearbyStop>> nearby({
    required double lat,
    required double lon,
    double radiusM = 1000,
    int limit = 20,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/stops/nearby',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radius_m': radiusM,
        'limit': limit,
      },
    );
    return response.data!
        .map((item) => NearbyStop.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<StopDetail> detail(int stopId) async {
    final response = await _dio.get<Map<String, dynamic>>('/stops/$stopId');
    return StopDetail.fromJson(response.data!);
  }

  Future<List<Departure>> departures(
    int stopId, {
    required DateTime at,
    int windowMin = 60,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/stops/$stopId/departures',
      queryParameters: {'at': at.toIso8601String(), 'window_min': windowMin},
    );
    return response.data!
        .map((item) => Departure.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
