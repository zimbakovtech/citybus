import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/route_badge.dart';
import '../../../../core/widgets/section_header.dart';
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
        padding: Insets.page,
        children: [
          const SizedBox(height: Insets.sm),
          Card(
            child: Column(
              children: [
                _EndpointTile(
                  label: 'From',
                  icon: CupertinoIcons.smallcircle_fill_circle,
                  endpoint: form.origin,
                  onChanged: (endpoint) =>
                      ref.read(plannerFormProvider.notifier).setOrigin(endpoint),
                ),
                const Divider(indent: 56),
                _EndpointTile(
                  label: 'To',
                  icon: CupertinoIcons.flag,
                  endpoint: form.destination,
                  onChanged: (endpoint) => ref
                      .read(plannerFormProvider.notifier)
                      .setDestination(endpoint),
                ),
                const Divider(indent: 56),
                _DepartureTimeTile(form: form),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),
          FilledButton.icon(
            icon: const Icon(CupertinoIcons.arrow_swap, size: 18),
            label: const Text('Plan journey'),
            onPressed: form.ready
                ? () => ref.read(planControllerProvider.notifier).submit()
                : null,
          ),
          plan.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(Insets.xl),
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
          const SizedBox(height: Insets.xl),
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
    final theme = Theme.of(context);
    final value = switch (endpoint) {
      StopEndpoint(:final stop) => stop.name,
      MyLocationEndpoint() => 'My location',
      null => 'Choose a stop…',
    };
    return ListTile(
      leading: Icon(icon, size: 22, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: endpoint == null ? theme.colorScheme.onSurfaceVariant : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(CupertinoIcons.location, size: 20),
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

class _DepartureTimeTile extends ConsumerWidget {
  const _DepartureTimeTile({required this.form});

  final PlannerFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        CupertinoIcons.clock,
        size: 22,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'Departure',
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      subtitle: Text(
        form.departAt == null
            ? 'Leave now'
            : DateFormat('EEE d MMM, HH:mm').format(form.departAt!),
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
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
              padding: const EdgeInsets.all(Insets.lg),
              child: SearchBar(
                hintText: 'Search stops…',
                autoFocus: true,
                leading: const Icon(CupertinoIcons.search, size: 20),
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
                  return ListView.separated(
                    itemCount: stops.length,
                    separatorBuilder: (_, _) =>
                        const Divider(indent: 72, endIndent: Insets.lg),
                    itemBuilder: (context, index) => ListTile(
                      leading:
                          const IconBadge(icon: CupertinoIcons.map_pin_ellipse),
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
        icon: CupertinoIcons.slash_circle,
      );
    }
    final theme = Theme.of(context);
    final duration = Duration(seconds: plan.durationSeconds ?? 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Journey'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Insets.lg),
            child: Column(
              children: [
                Text(
                  '${DateFormat.Hm().format(plan.departAt)} → '
                  '${DateFormat.Hm().format(plan.arriveAt!)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  '${duration.inMinutes} min · '
                  '${plan.transfers} transfer${plan.transfers == 1 ? '' : 's'}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Insets.md),
        for (final leg in plan.legs)
          switch (leg) {
            PlanRideLeg() => _RideLegCard(leg: leg),
            PlanTransferLeg() => _TransferRow(leg: leg),
          },
      ],
    );
  }
}

class _RideLegCard extends StatelessWidget {
  const _RideLegCard({required this.leg});

  final PlanRideLeg leg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Insets.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RouteBadge(label: leg.route.shortName ?? '?', color: leg.route.color),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegStopRow(
                    name: leg.boardStop.name,
                    time: DateFormat.Hm().format(leg.boardTime),
                    timeStyle: timeStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Insets.xs),
                    child: Text(
                      '${leg.numStops} stops',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  _LegStopRow(
                    name: leg.alightStop.name,
                    time: DateFormat.Hm().format(leg.alightTime),
                    timeStyle: timeStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegStopRow extends StatelessWidget {
  const _LegStopRow({
    required this.name,
    required this.time,
    required this.timeStyle,
  });

  final String name;
  final String time;
  final TextStyle? timeStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(time, style: timeStyle),
      ],
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({required this.leg});

  final PlanTransferLeg leg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.arrow_right_arrow_left,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Insets.sm),
          Text(
            'Transfer at ${leg.atStop.name} · '
            '${(leg.seconds / 60).ceil()} min wait',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
