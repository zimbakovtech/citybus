import '../../data/models/stop_models.dart';

/// Stop use-cases exposed to the presentation layer. The freezed API models
/// double as domain entities (documented in mobile/README.md).
abstract interface class StopsRepository {
  Future<List<StopSummary>> search(String query);

  Future<List<NearbyStop>> nearby({
    required double lat,
    required double lon,
    double radiusM,
  });

  Future<StopDetail> detail(int stopId);

  Future<List<Departure>> departures(int stopId, {DateTime? at, int windowMin});
}
