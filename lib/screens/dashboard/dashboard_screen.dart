import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/habit_providers.dart';
import '../../providers/finance_providers.dart';
import '../../providers/workout_providers.dart';
import '../../providers/planner_providers.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/recipe_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(todayStatsProvider);
    ref.invalidate(monthIncomeProvider);
    ref.invalidate(monthExpenseProvider);
    ref.invalidate(workoutCountThisMonthProvider);
    ref.invalidate(weekAnalyticsProvider);
    ref.invalidate(todayNutritionTotalsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final todayStats = ref.watch(todayStatsProvider);
    final monthIncome = ref.watch(monthIncomeProvider);
    final monthExpense = ref.watch(monthExpenseProvider);
    final workoutCount = ref.watch(workoutCountThisMonthProvider);
    final analytics = ref.watch(weekAnalyticsProvider);

    final todayHabitsDone = todayStats['done'] as int;
    final todayHabitsTotal = todayStats['total'] as int;
    final habitProgress = todayHabitsTotal > 0
        ? todayHabitsDone / todayHabitsTotal
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.dashboard,
          style: theme.textTheme.headlineLarge,
        ),
        const Gap(20),

        // Today's habits
        ProgressCard(
          title: l10n.habits,
          progress: habitProgress,
          subtitle: '$todayHabitsDone / $todayHabitsTotal ${l10n.today.toLowerCase()}',
          icon: Icons.check_circle_outline,
          color: AppColors.habitCompleted,
          onTap: () => context.go('/habits'),
        ),
        const Gap(12),

        // Finance summary
        Card(
          child: InkWell(
            onTap: () => context.go('/finance'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 20),
                      const Gap(8),
                      Expanded(child: Text(l10n.finance, style: theme.textTheme.titleLarge)),
                    ],
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.income, style: theme.textTheme.bodySmall),
                            const Gap(4),
                            Text(
                              '${monthIncome.toStringAsFixed(0)} ₽',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.dividerColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.expense, style: theme.textTheme.bodySmall),
                              const Gap(4),
                              Text(
                                '${monthExpense.toStringAsFixed(0)} ₽',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(12),

        // Workouts
        if (workoutCount > 0)
          ProgressCard(
            title: l10n.workouts,
            progress: workoutCount / 20,
            subtitle: '$workoutCount / 20 ${l10n.month.toLowerCase()}',
            icon: Icons.fitness_center,
            color: AppColors.workoutPrimary,
            onTap: () => context.go('/workouts'),
          )
        else
          ProgressCard(
            title: l10n.workouts,
            progress: 0,
            subtitle: l10n.workouts,
            icon: Icons.fitness_center,
            color: AppColors.workoutPrimary,
            onTap: () => context.go('/workouts'),
          ),
        const Gap(12),

        // Nutrition
        _buildNutritionCard(context, ref, l10n, theme),
        const Gap(12),

        // Weekly planner
        Card(
          child: InkWell(
            onTap: () => context.go('/planner'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_view_week, color: AppColors.workoutSecondary, size: 20),
                      const Gap(8),
                      Expanded(
                        child: Text(l10n.weeklyPlaner, style: theme.textTheme.titleLarge),
                      ),
                      Text(
                        '${(analytics['progress'] * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.workoutSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (analytics['progress'] as double).clamp(0.0, 1.0),
                      backgroundColor: AppColors.workoutSecondary.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.workoutSecondary),
                      minHeight: 6,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '${analytics['completedTasks']}/${analytics['totalTasks']} ${l10n.tasks.toLowerCase()}, '
                    '${analytics['completedGoals']}/${analytics['totalGoals']} ${l10n.goals.toLowerCase()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(BuildContext context, WidgetRef ref, AppLocalizations l10n, ThemeData theme) {
    final totals = ref.watch(todayNutritionTotalsProvider);
    final targets = ref.watch(nutritionTargetsProvider);
    final calPct = targets.calories > 0 ? (totals['calories']! / targets.calories).clamp(0.0, 1.0) : 0.0;
    final protPct = targets.protein > 0 ? (totals['protein']! / targets.protein).clamp(0.0, 1.0) : 0.0;
    final fatPct = targets.fat > 0 ? (totals['fat']! / targets.fat).clamp(0.0, 1.0) : 0.0;
    final carbsPct = targets.carbs > 0 ? (totals['carbs']! / targets.carbs).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: InkWell(
        onTap: () => context.go('/nutrition'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
                  const Gap(8),
                  Expanded(child: Text(l10n.nutrition, style: theme.textTheme.titleLarge)),
                  Text(
                    '${totals['calories']!.toStringAsFixed(0)} / ${targets.calories.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              _buildDashProgressRow('Б', totals['protein']!, targets.protein, protPct, const Color(0xFFFF6B6B)),
              const Gap(6),
              _buildDashProgressRow('Ж', totals['fat']!, targets.fat, fatPct, const Color(0xFFFFE066)),
              const Gap(6),
              _buildDashProgressRow('У', totals['carbs']!, targets.carbs, carbsPct, const Color(0xFF4ECDC4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashProgressRow(String label, double current, double target, double pct, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(pct > 1.0 ? Colors.red : color),
              minHeight: 6,
            ),
          ),
        ),
        const Gap(8),
        SizedBox(
          width: 70,
          child: Text(
            '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: pct > 1.0 ? Colors.red : null),
          ),
        ),
      ],
    );
  }
}
