import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/location.dart';
import '../../data/datasources/stops_api.dart';
import '../../data/models/stop_models.dart';
import '../../data/repositories/stops_repository_impl.dart';
import '../../domain/repositories/stops_repository.dart';

final stopsRepositoryProvider = Provider<StopsRepository>(
  (ref) => StopsRepositoryImpl(StopsApi(ref.watch(dioProvider))),
);

/// Current text in the stop search field.
class StopSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final stopSearchQueryProvider = NotifierProvider<StopSearchQuery, String>(StopSearchQuery.new);

/// Server-side search results for the current query.
final stopSearchResultsProvider = FutureProvider<List<StopSummary>>((ref) {
  final query = ref.watch(stopSearchQueryProvider);
  return ref.watch(stopsRepositoryProvider).search(query);
});

/// Stops around the device location (asks for permission on first use).
final nearbyStopsProvider = FutureProvider<List<NearbyStop>>((ref) async {
  final position = await currentPosition();
  return ref
      .watch(stopsRepositoryProvider)
      .nearby(lat: position.latitude, lon: position.longitude);
});

final stopDetailProvider = FutureProvider.family<StopDetail, int>(
  (ref, stopId) => ref.watch(stopsRepositoryProvider).detail(stopId),
);

final departuresProvider = FutureProvider.family<List<Departure>, int>(
  (ref, stopId) => ref.watch(stopsRepositoryProvider).departures(stopId),
);
