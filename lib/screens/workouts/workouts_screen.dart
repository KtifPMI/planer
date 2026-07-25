import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/workout.dart';
import '../../providers/workout_providers.dart';
import '../../data/repositories/workout_repository.dart';
import '../../core/utils/date_utils.dart' as app_date;

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final workouts = ref.watch(allWorkoutsProvider);
    final latest = ref.watch(latestWorkoutProvider);
    final count = ref.watch(workoutCountThisMonthProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.workouts, style: theme.textTheme.headlineLarge),
        const Gap(20),

        // Stats cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.month,
                value: '$count',
                icon: Icons.fitness_center,
                color: AppColors.workoutPrimary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _StatCard(
                label: l10n.total,
                value: '${workouts.length}',
                icon: Icons.history,
                color: AppColors.workoutSecondary,
              ),
            ),
          ],
        ),
        const Gap(16),

        // Last workout
        if (latest != null) ...[
          Text(l10n.workouts, style: theme.textTheme.titleLarge),
          const Gap(8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const Gap(8),
                      Text(
                        app_date.formatDate(latest.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (latest.name != null) ...[
                    const Gap(8),
                    Text(latest.name!, style: theme.textTheme.titleLarge),
                  ],
                  const Gap(8),
                  ...latest.exercises.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(ex.exerciseName, style: theme.textTheme.bodyMedium)),
                        Text(
                          '${ex.sets.length} × ${ex.maxWeight.toStringAsFixed(0)} кг',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const Gap(16),
        ],

        // Weight progression for first exercise
        if (latest != null && latest.exercises.isNotEmpty) ...[
          Text('${latest.exercises.first.exerciseName} — Прогрессия', style: theme.textTheme.titleLarge),
          const Gap(8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: _WeightChart(
                  exerciseName: latest.exercises.first.exerciseName,
                ),
              ),
            ),
          ),
          const Gap(16),
        ],

        // History
        Text(l10n.total, style: theme.textTheme.titleLarge),
        const Gap(8),
        ...workouts.take(10).map((w) => Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: AppColors.workoutPrimary),
            title: Text(w.name ?? l10n.workouts),
            subtitle: Text(
              '${app_date.formatDate(w.date)} • ${w.exercises.length} ${l10n.exercise.toLowerCase()}',
            ),
          ),
        )),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStartWorkoutDialog(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStartWorkoutDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.addWorkout, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: nameController, decoration: InputDecoration(hintText: l10n.name), autofocus: true),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final session = WorkoutSession(
                    id: WorkoutRepository.generateId(),
                    date: DateTime.now(),
                    name: nameController.text.isEmpty ? null : nameController.text,
                  );
                  await ref.read(workoutRepositoryProvider).addSession(session);
                  ref.invalidate(allWorkoutsProvider);
                  ref.invalidate(workoutCountThisMonthProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const Gap(8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
            const Gap(4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends ConsumerWidget {
  final String exerciseName;
  const _WeightChart({required this.exerciseName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(weightProgressionProvider(exerciseName));

    if (progression.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    final spots = progression.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calcInterval(spots),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.workoutPrimary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.workoutPrimary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.workoutPrimary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  double _calcInterval(List<FlSpot> spots) {
    if (spots.length < 2) return 10;
    final values = spots.map((s) => s.y).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    return range > 0 ? (range / 4).ceilToDouble() : 10;
  }
}
