import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/stops_repository.dart';
import '../datasources/stops_api.dart';
import '../models/stop_models.dart';

class StopsRepositoryImpl implements StopsRepository {
  StopsRepositoryImpl(this._api);

  final StopsApi _api;

  @override
  Future<List<StopSummary>> search(String query) =>
      _guard(() => _api.search(query));

  @override
  Future<List<NearbyStop>> nearby({
    required double lat,
    required double lon,
    double radiusM = 1000,
  }) => _guard(() => _api.nearby(lat: lat, lon: lon, radiusM: radiusM));

  @override
  Future<StopDetail> detail(int stopId) => _guard(() => _api.detail(stopId));

  @override
  Future<List<Departure>> departures(
    int stopId, {
    DateTime? at,
    int windowMin = 60,
  }) => _guard(
    () =>
        _api.departures(stopId, at: at ?? DateTime.now(), windowMin: windowMin),
  );

  /// Rethrows any transport/parse error as a typed [Failure].
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error) {
      throw asFailure(error);
    }
  }
}
