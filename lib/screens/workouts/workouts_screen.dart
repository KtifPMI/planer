import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/workout.dart';
import '../../providers/workout_providers.dart';
import '../../data/repositories/workout_repository.dart';
import '../../core/utils/date_utils.dart' as app_date;

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final todayTemplates = ref.watch(todayWorkoutTemplatesProvider);
    final todaySession = ref.watch(todaySessionProvider);
    final count = ref.watch(workoutCountThisMonthProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.workouts, style: theme.textTheme.headlineLarge),
                    const Gap(4),
                    Text(
                      '${l10n.dayNameFull(DateTime.now().weekday)}, ${DateTime.now().day} ${l10n.monthName(DateTime.now().month)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showTemplateManager(context, ref, l10n),
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.workoutSettings,
              ),
            ],
          ),
          const Gap(16),

          // Stats
          Row(
            children: [
              Expanded(child: _StatCard(
                label: l10n.month,
                value: '$count',
                icon: Icons.fitness_center,
                color: AppColors.workoutPrimary,
              )),
              const Gap(12),
              Expanded(child: _StatCard(
                label: l10n.total,
                value: '${ref.watch(allWorkoutsProvider).length}',
                icon: Icons.history,
                color: AppColors.workoutSecondary,
              )),
            ],
          ),
          const Gap(16),

          // Today's workout or session
          if (todaySession != null)
            _ActiveWorkoutCard(
              session: todaySession,
              l10n: l10n,
              theme: theme,
              onRefresh: () {
                invalidateAllWorkouts(ref);
                setState(() {});
              },
            )
          else if (todayTemplates.isNotEmpty)
            ...todayTemplates.map((t) => _TemplateCard(
              template: t,
              l10n: l10n,
              theme: theme,
              onStart: () => _startWorkout(ref, t),
            ))
          else
            _NoWorkoutCard(
              l10n: l10n,
              theme: theme,
              onTapAdd: () => _showAddTemplateSheet(context, ref, l10n),
            ),

          const Gap(16),

          // Recent history
          Text(l10n.total, style: theme.textTheme.titleLarge),
          const Gap(8),
          ...ref.watch(allWorkoutsProvider).take(10).map((w) => Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              leading: const Icon(Icons.fitness_center, color: AppColors.workoutPrimary),
              title: Text(w.name ?? l10n.workouts),
              subtitle: Text(
                '${app_date.formatDate(w.date)} • ${w.exercises.length} ${l10n.exercise.toLowerCase()}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.confirmDelete),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await w.delete();
                    } catch (_) {
                      await ref.read(workoutRepositoryProvider).deleteSession(w.id);
                    }
                    invalidateAllWorkouts(ref);
                    setState(() {});
                  }
                },
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'settings',
            onPressed: () => _showTemplateManager(context, ref, l10n),
            child: const Icon(Icons.settings),
          ),
          const Gap(8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showAddTemplateSheet(context, ref, l10n),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _startWorkout(WidgetRef ref, WorkoutTemplate template) async {
    final repo = ref.read(workoutRepositoryProvider);
    final exercises = template.exercises.map((te) => ExerciseLog(
      exerciseName: te.name,
      sets: List.generate(
        te.targetSets,
        (i) => SetLog(setNumber: i + 1, weight: te.targetWeight, reps: te.targetReps),
      ),
    )).toList();

    final session = WorkoutSession(
      id: WorkoutRepository.generateId(),
      date: DateTime.now(),
      name: template.name,
      exercises: exercises,
      templateId: template.id,
    );
    await repo.addSession(session);
    invalidateAllWorkouts(ref);
  }

  void _showTemplateManager(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TemplateManagerSheet(l10n: l10n),
    );
  }

  void _showAddTemplateSheet(BuildContext context, WidgetRef ref, AppLocalizations l10n, {WorkoutTemplate? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TemplateEditSheet(existing: existing, l10n: l10n),
    ).then((_) => ref.invalidate(allWorkoutTemplatesProvider));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

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

// --- Today's template card ---
class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onStart;

  const _TemplateCard({
    required this.template,
    required this.l10n,
    required this.theme,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: AppColors.workoutPrimary, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(template.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Gap(12),
            ...template.exercises.map((ex) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child:               Row(
                children: [
                  Expanded(child: Text(ex.name, style: theme.textTheme.bodyMedium)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${ex.targetSets} × ${ex.targetReps}',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${l10n.sets.toLowerCase()} × ${l10n.reps.toLowerCase()}'
                        '${ex.targetWeight > 0 ? " · ${ex.targetWeight.toInt()} ${l10n.kg}" : ""}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.startWorkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Active workout card ---
class _ActiveWorkoutCard extends StatelessWidget {
  final WorkoutSession session;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onRefresh;

  const _ActiveWorkoutCard({
    required this.session,
    required this.l10n,
    required this.theme,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final allCompleted = session.exercises.isNotEmpty &&
        session.exercises.every((ex) =>
            ex.sets.isNotEmpty && ex.sets.every((s) => s.completed));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: allCompleted
          ? AppColors.success.withOpacity(0.08)
          : AppColors.workoutPrimary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allCompleted ? Icons.check_circle : Icons.play_circle,
                  color: allCompleted ? AppColors.success : AppColors.workoutPrimary,
                  size: 20,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    session.name ?? l10n.activeWorkout,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (allCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.completed,
                      style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.confirmDelete),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await session.delete();
                      onRefresh();
                    }
                  },
                ),
              ],
            ),
            const Gap(12),
            ...session.exercises.map((ex) => _ExerciseLogTile(
              exercise: ex,
              session: session,
              l10n: l10n,
              theme: theme,
              onRefresh: onRefresh,
            )),
          ],
        ),
      ),
    );
  }
}

class _ExerciseLogTile extends StatefulWidget {
  final ExerciseLog exercise;
  final WorkoutSession session;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onRefresh;

  const _ExerciseLogTile({
    required this.exercise,
    required this.session,
    required this.l10n,
    required this.theme,
    required this.onRefresh,
  });

  @override
  State<_ExerciseLogTile> createState() => _ExerciseLogTileState();
}

class _ExerciseLogTileState extends State<_ExerciseLogTile> {
  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final allSetsDone = ex.sets.isNotEmpty && ex.sets.every((s) => s.completed);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allSetsDone ? Icons.check_circle : Icons.fitness_center,
                size: 16,
                color: allSetsDone ? AppColors.success : widget.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const Gap(6),
              Text(ex.exerciseName, style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (allSetsDone) ...[
                const Gap(4),
                Text('✓', style: TextStyle(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          const Gap(4),
          ...ex.sets.map((s) => _SetRow(
            set: s,
            exercise: ex,
            session: widget.session,
            onSaved: widget.onRefresh,
          )),
          TextButton.icon(
            onPressed: _addSet,
            icon: const Icon(Icons.add, size: 16),
            label: Text('${widget.l10n.add} ${widget.l10n.sets.toLowerCase()}'),
          ),
        ],
      ),
    );
  }

  void _addSet() {
    final lastSet = widget.exercise.sets.isNotEmpty ? widget.exercise.sets.last : null;
    final newSet = SetLog(
      setNumber: widget.exercise.sets.length + 1,
      weight: lastSet?.weight ?? 0,
      reps: lastSet?.reps ?? 10,
    );
    widget.exercise.sets.add(newSet);
    widget.session.save();
    widget.onRefresh();
  }
}

class _SetRow extends StatefulWidget {
  final SetLog set;
  final ExerciseLog exercise;
  final WorkoutSession session;
  final VoidCallback onSaved;

  const _SetRow({
    required this.set,
    required this.exercise,
    required this.session,
    required this.onSaved,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(text: widget.set.weight > 0 ? widget.set.weight.toInt().toString() : '');
    _repsCtrl = TextEditingController(text: widget.set.reps.toString());
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.set.weight = double.tryParse(_weightCtrl.text) ?? 0;
    widget.set.reps = int.tryParse(_repsCtrl.text) ?? 0;
    widget.session.save();
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${widget.set.setNumber}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.kg,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  isDense: true,
                ),
                onTapOutside: (_) => _save(),
                onSubmitted: (_) => _save(),
              ),
            ),
          ),
          Text(l10n.kg, style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          )),
          const Gap(4),
          Text('×', style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          )),
          const Gap(4),
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.repsShort,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  isDense: true,
                ),
                onTapOutside: (_) => _save(),
                onSubmitted: (_) => _save(),
              ),
            ),
          ),
          Text(l10n.repsShort, style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          )),
          const Gap(4),
          Checkbox(
            value: widget.set.completed,
            onChanged: (v) {
              widget.set.completed = v ?? false;
              widget.session.save();
              widget.onSaved();
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          GestureDetector(
            onTap: () {
              widget.exercise.sets.remove(widget.set);
              for (int i = 0; i < widget.exercise.sets.length; i++) {
                widget.exercise.sets[i].setNumber = i + 1;
              }
              widget.session.save();
              widget.onSaved();
            },
            child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}

// --- No workout today ---
class _NoWorkoutCard extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback? onTapAdd;

  const _NoWorkoutCard({required this.l10n, required this.theme, this.onTapAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTapAdd,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.fitness_center, size: 40, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                const Gap(8),
                Text(
                  l10n.noWorkoutToday,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const Gap(4),
                Text(
                  l10n.addTemplate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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

// --- Template manager bottom sheet ---
class _TemplateManagerSheet extends ConsumerWidget {
  final AppLocalizations l10n;

  const _TemplateManagerSheet({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(allWorkoutTemplatesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(child: Text(l10n.workoutTemplates, style: theme.textTheme.headlineSmall)),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => _TemplateEditSheet(l10n: l10n),
                    ).then((_) => ref.invalidate(allWorkoutTemplatesProvider));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(12),
            if (templates.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              )
            else
              ...templates.map((t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.fitness_center,
                    color: t.dayOfWeek > 0 ? AppColors.workoutPrimary : AppColors.workoutSecondary,
                  ),
                  title: Text(t.name),
                  subtitle: Text(
                    t.dayOfWeek > 0
                        ? '${l10n.dayNameFull(t.dayOfWeek)} • ${t.exercises.length} ${l10n.exercise.toLowerCase()}'
                        : '${t.exercises.length} ${l10n.exercise.toLowerCase()}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      final repo = ref.read(workoutRepositoryProvider);
                      if (v == 'edit') {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => _TemplateEditSheet(existing: t, l10n: l10n),
                        ).then((_) => ref.invalidate(allWorkoutTemplatesProvider));
                      } else if (v == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.delete),
                            content: Text('${l10n.delete} "${t.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await repo.deleteWorkoutTemplate(t.id);
                          ref.invalidate(allWorkoutTemplatesProvider);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete, style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

// --- Template edit sheet ---
class _TemplateEditSheet extends ConsumerStatefulWidget {
  final WorkoutTemplate? existing;
  final AppLocalizations l10n;

  const _TemplateEditSheet({this.existing, required this.l10n});

  @override
  ConsumerState<_TemplateEditSheet> createState() => _TemplateEditSheetState();
}

class _TemplateEditSheetState extends ConsumerState<_TemplateEditSheet> {
  late TextEditingController _nameCtrl;
  int _dayOfWeek = 0;
  late List<TemplateExercise> _exercises;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _dayOfWeek = e?.dayOfWeek ?? 0;
    _exercises = e?.exercises.map((te) => TemplateExercise(
      name: te.name,
      targetSets: te.targetSets,
      targetReps: te.targetReps,
      targetWeight: te.targetWeight,
    )).toList() ?? [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? l10n.editTemplate : l10n.addTemplate, style: theme.textTheme.titleLarge),
            const Gap(16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(hintText: l10n.templateName),
              autofocus: !isEdit,
            ),
            const Gap(12),
            DropdownButtonFormField<int>(
              value: _dayOfWeek,
              decoration: InputDecoration(labelText: l10n.dayOfWeek),
              items: [
                const DropdownMenuItem(value: 0, child: Text('—')),
                ...List.generate(7, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(l10n.dayNameFull(i + 1)),
                )),
              ],
              onChanged: (v) => setState(() => _dayOfWeek = v ?? 0),
            ),
            const Gap(16),
            Row(
              children: [
                Text(l10n.exercises, style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.addExercise),
                ),
              ],
            ),
            if (_exercises.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.noData,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ),
            ..._exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final ex = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: ex.name),
                              decoration: InputDecoration(
                                hintText: l10n.exerciseName,
                                isDense: true,
                              ),
                              onChanged: (v) => ex.name = v,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _exercises.removeAt(i)),
                            icon: const Icon(Icons.close, size: 18),
                            color: AppColors.error,
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: ex.targetSets.toString()),
                              decoration: InputDecoration(
                                labelText: l10n.setsCount,
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (v) => ex.targetSets = int.tryParse(v) ?? 3,
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: ex.targetReps.toString()),
                              decoration: InputDecoration(
                                labelText: l10n.repsCount,
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (v) => ex.targetReps = int.tryParse(v) ?? 10,
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                text: ex.targetWeight > 0 ? ex.targetWeight.toInt().toString() : '',
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.targetWeight,
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (v) => ex.targetWeight = double.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  void _addExercise() {
    setState(() {
      _exercises.add(TemplateExercise(name: '', targetSets: 3, targetReps: 10, targetWeight: 0));
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final repo = ref.read(workoutRepositoryProvider);

    if (widget.existing != null) {
      widget.existing!
        ..name = _nameCtrl.text.trim()
        ..dayOfWeek = _dayOfWeek
        ..exercises = _exercises;
      await widget.existing!.save();
    } else {
      final template = WorkoutTemplate(
        id: WorkoutRepository.generateId(),
        name: _nameCtrl.text.trim(),
        dayOfWeek: _dayOfWeek,
        exercises: _exercises,
      );
      await repo.addWorkoutTemplate(template);
    }

    ref.invalidate(allWorkoutTemplatesProvider);
    ref.invalidate(todayWorkoutTemplatesProvider);

    if (mounted) Navigator.pop(context);
  }
}
