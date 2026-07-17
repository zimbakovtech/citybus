import 'package:dio/dio.dart';

import '../../../stops/data/models/stop_models.dart';
import '../models/route_models.dart';

/// REST calls for the routes feature.
class RoutesApi {
  RoutesApi(this._dio);

  final Dio _dio;

  Future<List<RouteSummary>> search(String query, {int limit = 30}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/routes',
      queryParameters: {if (query.isNotEmpty) 'search': query, 'limit': limit},
    );
    final items = response.data!['items'] as List<dynamic>;
    return items
        .map((item) => RouteSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RouteDetail> detail(int routeId) async {
    final response = await _dio.get<Map<String, dynamic>>('/routes/$routeId');
    return RouteDetail.fromJson(response.data!);
  }

  Future<List<StopSummary>> orderedStops(
    int routeId, {
    int directionId = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/routes/$routeId/stops',
      queryParameters: {'direction_id': directionId},
    );
    return response.data!
        .map((item) => StopSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RouteShape> shape(int routeId, {int directionId = 0}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/routes/$routeId/shape',
      queryParameters: {'direction_id': directionId},
    );
    return RouteShape.fromJson(response.data!);
  }
}
