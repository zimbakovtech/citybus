import 'package:citybus/features/planner/data/models/planner_models.dart';
import 'package:citybus/features/planner/domain/repositories/planner_repository.dart';
import 'package:citybus/features/planner/presentation/providers/planner_providers.dart';
import 'package:citybus/features/routes/data/models/route_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class FakePlannerRepository implements PlannerRepository {
  int calls = 0;
  int? lastFromStopId;
  int? lastToStopId;

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
    calls++;
    lastFromStopId = fromStopId;
    lastToStopId = toStopId;
    return PlanResponse(
      found: true,
      fromStop: testStops[0],
      toStop: testStops[1],
      departAt: departAt,
      arriveAt: departAt.add(const Duration(minutes: 20)),
      durationSeconds: 1200,
      transfers: 0,
      legs: [
        PlanLeg.ride(
          route: const RouteSummary(id: 1, shortName: '2'),
          tripId: 42,
          boardStop: testStops[0],
          boardTime: departAt,
          alightStop: testStops[1],
          alightTime: departAt.add(const Duration(minutes: 20)),
          numStops: 5,
        ),
      ],
    );
  }
}

void main() {
  group('PlanController', () {
    late FakePlannerRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakePlannerRepository();
      container = ProviderContainer(
        overrides: [plannerRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
    });

    test('does nothing until both endpoints are chosen', () async {
      await container.read(planControllerProvider.future);
      container
          .read(plannerFormProvider.notifier)
          .setOrigin(StopEndpoint(testStops[0]));

      await container.read(planControllerProvider.notifier).submit();
      expect(repository.calls, 0);
    });

    test('submits stop ids and exposes the plan', () async {
      await container.read(planControllerProvider.future);
      final form = container.read(plannerFormProvider.notifier);
      form.setOrigin(StopEndpoint(testStops[0]));
      form.setDestination(StopEndpoint(testStops[1]));
      form.setDepartAt(DateTime(2026, 5, 4, 8));

      await container.read(planControllerProvider.notifier).submit();

      expect(repository.calls, 1);
      expect(repository.lastFromStopId, testStops[0].id);
      expect(repository.lastToStopId, testStops[1].id);

      final plan = container.read(planControllerProvider).value;
      expect(plan, isNotNull);
      expect(plan!.found, isTrue);
      expect(plan.transfers, 0);
      expect(plan.legs.single, isA<PlanRideLeg>());
    });
  });
}
