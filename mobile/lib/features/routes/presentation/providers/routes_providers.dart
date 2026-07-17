import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../stops/data/models/stop_models.dart';
import '../../data/datasources/routes_api.dart';
import '../../data/models/route_models.dart';
import '../../data/repositories/routes_repository_impl.dart';
import '../../domain/repositories/routes_repository.dart';

final routesRepositoryProvider = Provider<RoutesRepository>(
  (ref) => RoutesRepositoryImpl(RoutesApi(ref.watch(dioProvider))),
);

class RouteSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final routeSearchQueryProvider = NotifierProvider<RouteSearchQuery, String>(
  RouteSearchQuery.new,
);

final routeSearchResultsProvider = FutureProvider<List<RouteSummary>>((ref) {
  final query = ref.watch(routeSearchQueryProvider);
  return ref.watch(routesRepositoryProvider).search(query);
});

final routeDetailProvider = FutureProvider.family<RouteDetail, int>(
  (ref, routeId) => ref.watch(routesRepositoryProvider).detail(routeId),
);

/// (routeId, directionId) pair for direction-dependent lookups.
typedef RouteDirection = ({int routeId, int directionId});

final routeStopsProvider =
    FutureProvider.family<List<StopSummary>, RouteDirection>(
      (ref, args) => ref
          .watch(routesRepositoryProvider)
          .orderedStops(args.routeId, directionId: args.directionId),
    );

final routeShapeProvider = FutureProvider.family<RouteShape, RouteDirection>(
  (ref, args) => ref
      .watch(routesRepositoryProvider)
      .shape(args.routeId, directionId: args.directionId),
);
