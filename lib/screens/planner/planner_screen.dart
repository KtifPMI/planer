import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/planner.dart';
import '../../providers/planner_providers.dart';
import '../../core/utils/date_utils.dart' as app_date;

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(currentWeekProvider);
    final analytics = ref.watch(weekAnalyticsProvider);
    final weekStart = ref.watch(selectedPlannerWeekProvider);

    final now = DateTime.now();
    final isCurrentWeek = app_date.isSameDay(weekStart, app_date.startOfWeek(now));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Week navigation
        Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(l10n.weeklyPlaner, style: theme.textTheme.headlineLarge),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                ref.read(selectedPlannerWeekProvider.notifier).state =
                    weekStart.subtract(const Duration(days: 7));
              },
            ),
            Text(
              l10n.monthName(weekStart.month),
              style: theme.textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                ref.read(selectedPlannerWeekProvider.notifier).state =
                    weekStart.add(const Duration(days: 7));
              },
            ),
            IconButton(
              icon: Icon(Icons.calendar_today, size: 20,
                color: isCurrentWeek ? null : AppColors.primary),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: weekStart,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  ref.read(selectedPlannerWeekProvider.notifier).state =
                      app_date.startOfWeek(picked);
                }
              },
            ),
          ],
        ),
        const Gap(4),
        Text(
          '${app_date.formatDate(weekStart)} — ${app_date.formatDate(weekStart.add(const Duration(days: 6)))}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Gap(20),

        // Analytics
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.analytics, style: theme.textTheme.titleLarge),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: _AnalyticItem(
                        label: l10n.totalTasks,
                        value: '${analytics['totalTasks']}',
                        icon: Icons.list_alt,
                      ),
                    ),
                    Expanded(
                      child: _AnalyticItem(
                        label: l10n.completed,
                        value: '${analytics['completedTasks']}',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _AnalyticItem(
                        label: l10n.progress,
                        value: '${((analytics['progress'] as double) * 100).toStringAsFixed(0)}%',
                        icon: Icons.trending_up,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Gap(16),

        // Weekly goals
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.weeklyGoals, style: theme.textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddGoalDialog(context, ref, l10n, plan),
                    ),
                  ],
                ),
                const Gap(8),
                if (plan.goals.isEmpty)
                  Text(l10n.noData, style: theme.textTheme.bodySmall)
                else
                  ...plan.goals.asMap().entries.map((e) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: e.value.completed,
                      onChanged: (_) async {
                        await ref.read(plannerRepositoryProvider).toggleGoal(plan.id, e.key);
                        ref.invalidate(currentWeekProvider);
                        ref.invalidate(weekAnalyticsProvider);
                      },
                    ),
                    title: Text(
                      e.value.title,
                      style: TextStyle(
                        decoration: e.value.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: e.value.completed
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _showEditDialog(
                            context, ref, l10n, plan,
                            initial: e.value.title,
                            onSave: (val) async {
                              await ref.read(plannerRepositoryProvider).editGoal(plan.id, e.key, val);
                              ref.invalidate(currentWeekProvider);
                              ref.invalidate(weekAnalyticsProvider);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.delete),
                                content: Text('${l10n.delete} "${e.value.title}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(plannerRepositoryProvider).deleteGoal(plan.id, e.key);
                              ref.invalidate(currentWeekProvider);
                              ref.invalidate(weekAnalyticsProvider);
                            }
                          },
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ),
        const Gap(16),

        // Daily plans
        Text(l10n.notes, style: theme.textTheme.titleLarge),
        const Gap(8),
        ...List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isToday = app_date.isSameDay(day, now);
          final dayKey = _dateKey(day);
          final dayPlan = plan.days[dayKey] ?? DayPlan();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withOpacity(0.15)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.primary : null,
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.dayName(day.weekday),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: dayPlan.totalCount > 0
                  ? Text(
                      '${dayPlan.completedCount}/${dayPlan.totalCount} ${l10n.tasks.toLowerCase()}',
                      style: theme.textTheme.bodySmall,
                    )
                  : null,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tasks
                      ...dayPlan.tasks.asMap().entries.map((e) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: e.value.completed,
                          onChanged: (_) async {
                            await ref.read(plannerRepositoryProvider).toggleTask(plan.id, day, e.key);
                            ref.invalidate(currentWeekProvider);
                            ref.invalidate(weekAnalyticsProvider);
                          },
                        ),
                        title: Text(
                          e.value.title,
                          style: TextStyle(
                            decoration: e.value.completed ? TextDecoration.lineThrough : null,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: () => _showEditDialog(
                                context, ref, l10n, plan,
                                initial: e.value.title,
                                onSave: (val) async {
                                  await ref.read(plannerRepositoryProvider).editTask(plan.id, day, e.key, val);
                                  ref.invalidate(currentWeekProvider);
                                  ref.invalidate(weekAnalyticsProvider);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.delete),
                                    content: Text('${l10n.delete} "${e.value.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await ref.read(plannerRepositoryProvider).deleteTask(plan.id, day, e.key);
                                  ref.invalidate(currentWeekProvider);
                                  ref.invalidate(weekAnalyticsProvider);
                                }
                              },
                            ),
                          ],
                        ),
                      )),
                      // Add task
                      TextButton.icon(
                        onPressed: () => _showAddTaskDialog(context, ref, l10n, plan, day),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(l10n.addTask),
                      ),
                      // Note
                      if (dayPlan.note != null && dayPlan.note!.isNotEmpty) ...[
                        const Gap(8),
                        GestureDetector(
                          onTap: () => _showEditDialog(
                            context, ref, l10n, plan,
                            initial: dayPlan.note!,
                            title: l10n.editNote,
                            onSave: (val) async {
                              await ref.read(plannerRepositoryProvider).updateNote(plan.id, day, val);
                              ref.invalidate(currentWeekProvider);
                            },
                          ),
                          child: Text(
                            dayPlan.note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                      TextButton.icon(
                        onPressed: () => _showNoteDialog(context, ref, l10n, plan, day),
                        icon: Icon(dayPlan.note != null && dayPlan.note!.isNotEmpty
                            ? Icons.edit
                            : Icons.add,
                          size: 16),
                        label: Text(dayPlan.note != null && dayPlan.note!.isNotEmpty
                            ? l10n.editNote
                            : l10n.addNote),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _showAddGoalDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, WeeklyPlan plan) {
    final controller = TextEditingController();

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
            Text(l10n.addGoal, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: controller, decoration: InputDecoration(hintText: l10n.goals), autofocus: true),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  await ref.read(plannerRepositoryProvider).addGoal(plan.id, controller.text);
                  ref.invalidate(currentWeekProvider);
                  ref.invalidate(weekAnalyticsProvider);
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

  void _showAddTaskDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, WeeklyPlan plan, DateTime day) {
    final controller = TextEditingController();

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
            Text(l10n.addTask, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: controller, decoration: InputDecoration(hintText: l10n.tasks), autofocus: true),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  await ref.read(plannerRepositoryProvider).addTask(plan.id, day, controller.text);
                  ref.invalidate(currentWeekProvider);
                  ref.invalidate(weekAnalyticsProvider);
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

  void _showEditDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, WeeklyPlan plan, {
    required String initial,
    String? title,
    required Future<void> Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initial);

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
            Text(title ?? l10n.edit, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: controller, autofocus: true),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  await onSave(controller.text);
                  ref.invalidate(currentWeekProvider);
                  ref.invalidate(weekAnalyticsProvider);
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

  void _showNoteDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, WeeklyPlan plan, DateTime day) {
    final dayKey = _dateKey(day);
    final dayPlan = plan.days[dayKey] ?? DayPlan();
    final controller = TextEditingController(text: dayPlan.note ?? '');

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
            Text(l10n.dayNotes, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.note),
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  await ref.read(plannerRepositoryProvider).updateNote(
                    plan.id, day, text.isEmpty ? null : text,
                  );
                  ref.invalidate(currentWeekProvider);
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

class _AnalyticItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _AnalyticItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 20),
        const Gap(4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
        const Gap(2),
        Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}
