import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_providers.dart';
import '../../data/repositories/habit_repository.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final habitsData = ref.watch(habitsWithProgressProvider);

    return Scaffold(
      body: habitsData.isEmpty
          ? EmptyState(
              icon: Icons.check_circle_outline,
              title: l10n.noData,
              subtitle: l10n.addHabit,
              action: FilledButton.icon(
                onPressed: () => _showAddHabitDialog(context, ref, l10n),
                icon: const Icon(Icons.add),
                label: Text(l10n.add),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(l10n.today, style: theme.textTheme.headlineLarge),
                const Gap(4),
                Text(
                  _formatDate(DateTime.now(), l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Gap(16),
                ...habitsData.map((data) => _HabitTile(
                      habit: data['habit'],
                      completed: data['completedToday'],
                      monthProgress: data['monthProgress'],
                      completedCount: data['completedCount'],
                      onToggle: () async {
                        await ref.read(habitRepositoryProvider)
                            .toggleCompletion(data['habit'].id, DateTime.now());
                        ref.invalidate(habitsWithProgressProvider);
                      },
                      onDelete: () async {
                        await ref.read(habitRepositoryProvider).delete(data['habit'].id);
                        ref.invalidate(habitsWithProgressProvider);
                      },
                      l10n: l10n,
                      theme: theme,
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final dayName = l10n.dayName(date.weekday);
    final monthName = l10n.monthName(date.month);
    return '${date.day} $monthName, $dayName';
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: '20');
    String selectedIcon = '✅';

    final icons = ['✅', '🏃', '💧', '📖', '🧘', '📵', '📝', '🗒', '⏰', '😴', '💪', '🍎', '🧠', '🎯', '💰'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.addHabit, style: Theme.of(ctx).textTheme.titleLarge),
              const Gap(16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: l10n.habitName),
                autofocus: true,
              ),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: icons.map((icon) => GestureDetector(
                  onTap: () => setModalState(() => selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selectedIcon == icon
                          ? AppColors.primary.withOpacity(0.2)
                          : Theme.of(ctx).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedIcon == icon
                            ? AppColors.primary
                            : Theme.of(ctx).dividerColor,
                      ),
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                  ),
                )).toList(),
              ),
              const Gap(12),
              TextField(
                controller: targetController,
                decoration: InputDecoration(hintText: l10n.targetPerMonth),
                keyboardType: TextInputType.number,
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final habit = Habit(
                      id: HabitRepository.generateId(),
                      name: nameController.text,
                      icon: selectedIcon,
                      targetPerMonth: int.tryParse(targetController.text) ?? 20,
                    );
                    await ref.read(habitRepositoryProvider).add(habit);
                    ref.invalidate(habitsWithProgressProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final bool completed;
  final double monthProgress;
  final int completedCount;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _HabitTile({
    required this.habit,
    required this.completed,
    required this.monthProgress,
    required this.completedCount,
    required this.onToggle,
    required this.onDelete,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(habit.id),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.habitCompleted.withOpacity(0.15)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed
                          ? AppColors.habitCompleted
                          : theme.dividerColor,
                      width: completed ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: completed
                        ? const Icon(Icons.check, color: AppColors.habitCompleted)
                        : Text(habit.icon, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: theme.textTheme.titleLarge),
                      const Gap(4),
                      Text(
                        '$completedCount / ${habit.targetPerMonth} ${l10n.month.toLowerCase()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      Text(
                        '${(monthProgress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: monthProgress >= 1.0
                              ? AppColors.success
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      LinearProgressIndicator(
                        value: monthProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          monthProgress >= 1.0 ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
