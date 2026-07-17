import '../../../../core/network/dio_client.dart';
import '../../../stops/data/models/stop_models.dart';
import '../../domain/repositories/routes_repository.dart';
import '../datasources/routes_api.dart';
import '../models/route_models.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  RoutesRepositoryImpl(this._api);

  final RoutesApi _api;

  @override
  Future<List<RouteSummary>> search(String query) =>
      _guard(() => _api.search(query));

  @override
  Future<RouteDetail> detail(int routeId) => _guard(() => _api.detail(routeId));

  @override
  Future<List<StopSummary>> orderedStops(int routeId, {int directionId = 0}) =>
      _guard(() => _api.orderedStops(routeId, directionId: directionId));

  @override
  Future<RouteShape> shape(int routeId, {int directionId = 0}) =>
      _guard(() => _api.shape(routeId, directionId: directionId));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error) {
      throw asFailure(error);
    }
  }
}
