import '../../../stops/data/models/stop_models.dart';
import '../../data/models/route_models.dart';

/// Route use-cases exposed to the presentation layer.
abstract interface class RoutesRepository {
  Future<List<RouteSummary>> search(String query);

  Future<RouteDetail> detail(int routeId);

  Future<List<StopSummary>> orderedStops(int routeId, {int directionId});

  Future<RouteShape> shape(int routeId, {int directionId});
}
