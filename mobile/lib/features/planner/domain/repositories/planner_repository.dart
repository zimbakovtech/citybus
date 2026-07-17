import '../../data/models/planner_models.dart';

/// Journey-planning use-case. Each endpoint is either a stop id or a
/// coordinate pair (the API snaps coordinates to the nearest stop).
abstract interface class PlannerRepository {
  Future<PlanResponse> plan({
    int? fromStopId,
    int? toStopId,
    double? fromLat,
    double? fromLon,
    double? toLat,
    double? toLon,
    required DateTime departAt,
  });
}
