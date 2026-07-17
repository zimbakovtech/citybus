import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_api.dart';
import '../models/planner_models.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  PlannerRepositoryImpl(this._api);

  final PlannerApi _api;

  @override
  Future<PlanResponse> plan({
    int? fromStopId,
    int? toStopId,
    double? fromLat,
    double? fromLon,
    double? toLat,
    double? toLon,
    required DateTime departAt,
  }) async {
    try {
      return await _api.plan(
        fromStopId: fromStopId,
        toStopId: toStopId,
        fromLat: fromLat,
        fromLon: fromLon,
        toLat: toLat,
        toLon: toLon,
        departAt: departAt,
      );
    } catch (error) {
      throw asFailure(error);
    }
  }
}
