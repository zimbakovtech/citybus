import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../stops/data/models/stop_models.dart';
import '../../../stops/presentation/providers/stops_providers.dart';
import '../../data/models/planner_models.dart';
import '../providers/planner_providers.dart';

/// Journey planner: pick origin + destination (stop search or device
/// location), choose a departure time, and view the legs of the plan.
class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(plannerFormProvider);
    final plan = ref.watch(planControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EndpointTile(
            label: 'From',
            icon: Icons.trip_origin,
            endpoint: form.origin,
            onChanged: (endpoint) =>
                ref.read(plannerFormProvider.notifier).setOrigin(endpoint),
          ),
          _EndpointTile(
            label: 'To',
            icon: Icons.flag_outlined,
            endpoint: form.destination,
            onChanged: (endpoint) =>
                ref.read(plannerFormProvider.notifier).setDestination(endpoint),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(
              form.departAt == null
                  ? 'Leave now'
                  : 'Leave at ${DateFormat('EEE d MMM, HH:mm').format(form.departAt!)}',
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () async {
              final now = DateTime.now();
              final date = await showDatePicker(
                context: context,
                initialDate: form.departAt ?? now,
                firstDate: now.subtract(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 365)),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(form.departAt ?? now),
              );
              if (time == null) return;
              ref.read(plannerFormProvider.notifier).setDepartAt(
                    DateTime(date.year, date.month, date.day, time.hour, time.minute),
                  );
            },
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.alt_route),
            label: const Text('Plan journey'),
            onPressed: form.ready
                ? () => ref.read(planControllerProvider.notifier).submit()
                : null,
          ),
          const SizedBox(height: 16),
          plan.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            ),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.read(planControllerProvider.notifier).submit(),
            ),
            data: (result) => result == null
                ? const SizedBox.shrink()
                : _PlanResult(plan: result),
          ),
        ],
      ),
    );
  }
}

class _EndpointTile extends ConsumerWidget {
  const _EndpointTile({
    required this.label,
    required this.icon,
    required this.endpoint,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final PlanEndpoint? endpoint;
  final ValueChanged<PlanEndpoint> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = switch (endpoint) {
      StopEndpoint(:final stop) => stop.name,
      MyLocationEndpoint() => 'My location',
      null => 'Choose a stop…',
    };
    return ListTile(
      leading: Icon(icon),
      title: Text('$label: $title'),
      trailing: IconButton(
        icon: const Icon(Icons.my_location),
        tooltip: 'Use my location',
        onPressed: () => onChanged(const MyLocationEndpoint()),
      ),
      onTap: () async {
        final stop = await showModalBottomSheet<StopSummary>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const _StopPickerSheet(),
        );
        if (stop != null) onChanged(StopEndpoint(stop));
      },
    );
  }
}

/// Bottom sheet with a server-side stop search, returning the chosen stop.
class _StopPickerSheet extends ConsumerStatefulWidget {
  const _StopPickerSheet();

  @override
  ConsumerState<_StopPickerSheet> createState() => _StopPickerSheetState();
}

class _StopPickerSheetState extends ConsumerState<_StopPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(stopsRepositoryProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                hintText: 'Search stops…',
                autoFocus: true,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                // small list; re-queries as the user types
                future: repository.search(_query),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorView(message: snapshot.error.toString());
                  }
                  if (!snapshot.hasData) return const LoadingView();
                  final stops = snapshot.data!;
                  return ListView.builder(
                    itemCount: stops.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.pin_drop_outlined),
                      title: Text(stops[index].name),
                      onTap: () => Navigator.pop(context, stops[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanResult extends StatelessWidget {
  const _PlanResult({required this.plan});

  final PlanResponse plan;

  @override
  Widget build(BuildContext context) {
    if (!plan.found) {
      return const EmptyView(
        message: 'No route found for that time. Try a different departure.',
      );
    }
    final duration = Duration(seconds: plan.durationSeconds ?? 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${DateFormat.Hm().format(plan.departAt)} → '
                  '${DateFormat.Hm().format(plan.arriveAt!)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${duration.inMinutes} min · '
                  '${plan.transfers} transfer${plan.transfers == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        for (final leg in plan.legs)
          switch (leg) {
            PlanRideLeg() => _RideLegTile(leg: leg),
            PlanTransferLeg() => _TransferLegTile(leg: leg),
          },
      ],
    );
  }
}

class _RideLegTile extends StatelessWidget {
  const _RideLegTile({required this.leg});

  final PlanRideLeg leg;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: routeColor(leg.route.color),
          child: Text(
            leg.route.shortName ?? '?',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        title: Text(
          '${leg.boardStop.name} (${DateFormat.Hm().format(leg.boardTime)}) → '
          '${leg.alightStop.name} (${DateFormat.Hm().format(leg.alightTime)})',
        ),
        subtitle: Text('${leg.numStops} stops'),
      ),
    );
  }
}

class _TransferLegTile extends StatelessWidget {
  const _TransferLegTile({required this.leg});

  final PlanTransferLeg leg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.transfer_within_a_station, size: 18),
          const SizedBox(width: 8),
          Text(
            'Transfer at ${leg.atStop.name} · '
            '${(leg.seconds / 60).ceil()} min wait',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
